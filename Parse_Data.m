%% Path to data

folder_path = '';

for p = 1:1
    for m = 1:1
        file = strcat('p', num2str(p), 'm', num2str(m));

        %% Read data
        if exist('f_path','var')
            new_file = contains(f_path, file) == 0;
        else 
            new_file = 1;
        end

        if new_file
            disp(strcat('New file: ', file));
            % Force
            f_path = strcat(folder_path, 'forces/', file, '.txt');
            f_data = dlmread(f_path);
            f_time = f_data(:,1);
            f_z = f_data(:, 4);

            % OCT
            o_path = strcat(folder_path, 'oct/', file, '.bin');
            o_time_path = strcat(folder_path, 'oct/', file, '_timestamp.txt');
            file_id = fopen(o_path);
            o_data = fread(file_id, [512, 108900], 'float');
            o_time = dlmread(o_time_path);

            time = readtable('timestamps.txt', 'Format', '%s%u%u%u');
            for i=1:9
                if strcmp(time.Var1(i), file)
        		    f_start = time.Var2(i);
					f_end = time.Var3(i);
					f_number_of_samples = f_end - f_start;
					f_sampling_frequency = 10^6 * size(f_time, 1) / (f_time(end) - f_time(1));
        		    o_start = time.Var4(i);
					o_sampling_frequency = 100 * size(o_time, 1) / (o_time(end) - o_time(1));
					o_number_of_samples = round(f_number_of_samples * o_sampling_frequency / f_sampling_frequency);
					o_end = o_start + o_number_of_samples;
                end
            end
            % Remove offset
            f_z = f_z(f_start:f_end);
            o_data = o_data(:, o_start:o_end);
        end

        %% Tidy up data

        % Maximal values
        [o_pks, o_locs] = max(o_data);
        o_locs_smooth = smooth(o_locs);
        axis_max = o_locs(1) + 70;
        axis_min = o_locs(1) - 70;

        %% Plot 2

        % Flip 
        o_data_flip = flipud(o_data);
        [~, o_locs_flip] = max(o_data_flip);
        axis_max_flip = o_locs_flip(1) + 70;
        axis_min_flip = o_locs_flip(1) - 70;

        figure;

        subplot(2,1,1);
        plot(f_z);
        xlabel('Time');
        ylabel('Force Z');
        title('Force Sensor');

        subplot(2,1,2);
        image(o_data_flip);
        hold on;
        plot(smooth(o_locs_flip), '.r');
        axis([0 12*10^4 axis_min_flip axis_max_flip]);
        xlabel('Time');
        ylabel('Intensity');
        title('OCT');

        %% Write into file
        f_data_final = strcat(file, '_force_z.bin');
        o_data_final = strcat(file, '_oct.bin');
        t_final = strcat(file, '_timestamp.bin');

        cd forces/;
        f_fileID = fopen(f_data_final, 'w');
        fwrite(f_fileID, f_z, 'float');
        fclose(f_fileID);

        cd ../oct/;
        o_fileID = fopen(o_data_final, 'w');
        fwrite(o_fileID, o_data, 'float');
        fclose(o_fileID);

        timestamp = [1, 2, 3];
        t_fileID = fopen(t_final, 'w');
        fwrite(t_fileID, timestamp, 'float');
        fclose(t_fileID);
        cd ..;
        %% Clear

        clear o_pks_flip o_locs_flip axis_max_flip axis_min_flip;
        clear axis_max axis_min f_z_plot file_id folder_path o_data_flip o_max_plot o_locs_smooth;
        clear o_path o_time_path;
    end;
end;
