%% Path to data

measured_data_path = 'data/measured_data/';

for p = 1:1
    for m = 1:1
        file = strcat('p', num2str(p), 'm', num2str(m));
        disp(file);

        %% Read data
        % Force
        force_path = strcat(measured_data_path, 'forces/', file, '.txt');
        force_data = dlmread(force_path);
        force_time = force_data(:, 1);
        force_data = force_data(:, 4);

        % OCT
        oct_path = strcat(measured_data_path, 'oct/', file, '.bin');
        oct_time_path = strcat(measured_data_path, 'oct/', file, '_timestamp.txt');
        oct_file_id = fopen(oct_path);
        oct_data = fread(oct_file_id, [512, Inf], 'float');
        oct_time = dlmread(oct_time_path);

		% timestamps for start and end of force measurement as well as start of oct measurement (end of oct measurement is calculated)
        time = readtable('data/timestamps.txt', 'Format', '%s%u%u%u');
        for i=1:9
            if strcmp(time.Var1(i), file)
        	    force_start = time.Var2(i);
				force_end = time.Var3(i);
				force_number_of_samples = force_end - force_start + 1;
				force_sampling_frequency = 10^6 * size(force_time, 1) / (force_time(end) - force_time(1));
        	    oct_start = time.Var4(i);
				oct_sampling_frequency = 100 * size(oct_time, 1) / (oct_time(end) - oct_time(1));
				oct_number_of_samples = round(force_number_of_samples * oct_sampling_frequency / force_sampling_frequency);
				oct_end = oct_start + oct_number_of_samples - 1;
            end
        end

        % Remove offset
        force_data = force_data(force_start:force_end);
        oct_data = oct_data(:, oct_start:oct_end);

		% smooth and interpolate
		force_data = smooth(force_data, 317);
		force_data = interp1(1:double(force_number_of_samples), force_data', linspace(1, double(force_number_of_samples), double(oct_number_of_samples)));

        %% Tidy up data

        % Maximum values
        [oct_pks, oct_locs] = max(oct_data);
        oct_locs_smooth = smooth(oct_locs);
        axis_max = oct_locs(1) + 70;
        axis_min = oct_locs(1) - 70;

        %% Plot

        % Flip 
        oct_data_flip = flipud(oct_data);
        [~, oct_locs_flip] = max(oct_data_flip);
        axis_max_flip = oct_locs_flip(1) + 70;
        axis_min_flip = oct_locs_flip(1) - 70;

        figure;

        subplot(2,1,1);
        plot(force_data);
		xlim([0, size(force_data, 2)]);
        xlabel('Time');
        ylabel('Force Z');
        title('Force Sensor');

        subplot(2,1,2);
        image(oct_data_flip);
        hold on;
        plot(smooth(oct_locs_flip), '.r');
        axis([0, size(oct_data, 2), axis_min_flip, axis_max_flip]);
        xlabel('Time');
        ylabel('Depth');
        title('OCT');

        %% Write into file
        cd data/preprocessed_data/forces/;
        force_file_id = fopen(strcat(file, '_forces.bin'), 'w');
        fwrite(force_file_id, force_data, 'float');
        fclose(force_file_id);

        cd ../oct/;
        oct_file_id = fopen(strcat(file, '_oct.bin'), 'w');
        fwrite(oct_file_id, oct_data, 'float');
        fclose(oct_file_id);

		cd ../time/;
        time = linspace(0, (size(force_data, 2) - 1) / 1000, size(force_data, 2));
        t_file_id = fopen(strcat(file, '_time.bin'), 'w');
        fwrite(t_file_id, time, 'float');
        fclose(t_file_id);
        cd ..;
		cd ..;
		cd ..;
    end;
end;

%% Clear
clear force_file_id force_end force_path force_start force_time;
clear oct_end oct_file_id oct_start oct_time t_file_id;
clear p i m;
clear file
clear oct_pks_flip oct_locs_flip axis_max_flip axis_min_flip oct_locs oct_pks;
clear axis_max axis_min force_data_plot file_id measured_data_path oct_data_flip oct_max_plot oct_locs_smooth;
clear oct_path oct_time_path;
clear all;