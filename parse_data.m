%% Path to data

measured_data_path = 'data/measured_data/';

for p = 1:1
    for m = 1:1
        file = strcat('p', num2str(p), 'm', num2str(m));
        disp(file);

        %% Read data
        % Force
        f_path = strcat(measured_data_path, 'forces/', file, '.txt');
        f_data = dlmread(f_path);
        f_time = f_data(:, 1);
        f_data = f_data(:, 4);

        % OCT
        o_path = strcat(measured_data_path, 'oct/', file, '.bin');
        o_time_path = strcat(measured_data_path, 'oct/', file, '_timestamp.txt');
        o_file_id = fopen(o_path);
        o_data = fread(o_file_id, [512, Inf], 'float');
        o_time = dlmread(o_time_path);

		% timestamps for start and end of force measurement as well as start of oct measurement (end of oct measurement is calculated)
        time = readtable('data/timestamps.txt', 'Format', '%s%u%u%u');
        for i=1:9
            if strcmp(time.Var1(i), file)
        	    f_start = time.Var2(i);
				f_end = time.Var3(i);
				f_number_of_samples = f_end - f_start + 1;
				f_sampling_frequency = 10^6 * size(f_time, 1) / (f_time(end) - f_time(1));
        	    o_start = time.Var4(i);
				o_sampling_frequency = 100 * size(o_time, 1) / (o_time(end) - o_time(1));
				o_number_of_samples = round(f_number_of_samples * o_sampling_frequency / f_sampling_frequency);
				o_end = o_start + o_number_of_samples - 1;
            end
        end

        % Remove offset
        f_data = f_data(f_start:f_end);
        o_data = o_data(:, o_start:o_end);

		% smooth and interpolate
		f_data = smooth(f_data, 317);
		f_data = interp1(1:double(f_number_of_samples), f_data', linspace(1, double(f_number_of_samples), double(o_number_of_samples)));

        %% Tidy up data

        % Maximum values
        [o_pks, o_locs] = max(o_data);
        o_locs_smooth = smooth(o_locs);
        axis_max = o_locs(1) + 70;
        axis_min = o_locs(1) - 70;

        %% Plot

        % Flip 
        o_data_flip = flipud(o_data);
        [~, o_locs_flip] = max(o_data_flip);
        axis_max_flip = o_locs_flip(1) + 70;
        axis_min_flip = o_locs_flip(1) - 70;

        figure;

        subplot(2,1,1);
        plot(f_data);
		xlim([0, size(f_data, 2)]);
        xlabel('Time');
        ylabel('Force Z');
        title('Force Sensor');

        subplot(2,1,2);
        image(o_data_flip);
        hold on;
        plot(smooth(o_locs_flip), '.r');
        axis([0, size(o_data, 2), axis_min_flip, axis_max_flip]);
        xlabel('Time');
        ylabel('Depth');
        title('OCT');

        %% Write into file
        cd data/preprocessed_data/forces/;
        f_file_id = fopen(strcat(file, '_forces.bin'), 'w');
        fwrite(f_file_id, f_data, 'float');
        fclose(f_file_id);

        cd ../oct/;
        o_file_id = fopen(strcat(file, '_oct.bin'), 'w');
        fwrite(o_file_id, o_data, 'float');
        fclose(o_file_id);

		cd ../time/;
        time = linspace(0, (size(f_data, 2) - 1) / 1000, size(f_data, 2));
        t_file_id = fopen(strcat(file, '_time.bin'), 'w');
        fwrite(t_file_id, time, 'float');
        fclose(t_file_id);
        cd ..;
		cd ..;
		cd ..;
    end;
end;

%% Clear
clear f_file_id f_end f_path f_start f_time;
clear o_end o_file_id o_start o_time t_file_id;
clear p i m;
clear file
clear o_pks_flip o_locs_flip axis_max_flip axis_min_flip o_locs o_pks;
clear axis_max axis_min f_data_plot file_id measured_data_path o_data_flip o_max_plot o_locs_smooth;
clear o_path o_time_path;
