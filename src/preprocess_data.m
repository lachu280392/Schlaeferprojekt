clear all;
% preprocessed data is written to files
write_to_file = true;
% preprocessed data is plotted
plot_data = true;

% the sampling frequencies were averaged over all measurements
force_sampling_frequency_metal = 1.000449978653207e+02;
force_sampling_frequency_phantoms = 4.998892869544537e+02;
oct_sampling_frequency = 1.226095404779195e+03;

% the decimation is used to reduce the resolution of force and oct data. decimation = 100 means that every 100ths value is used
decimation = 1;

% the 50 horizontal_slicing means that the oct data is reduced to all data of the mean depth +- 50
horizontal_slicing = 50;

% Path to data
data_path = 'data/metal/oct/';

files  = "val";
force_path = strcat(data_path, files, '.txt');
% oct_path = strcat(data_path, files, '.bin');
% oct_time_path = strcat(data_path, files, '__timestamp.txt');

%%
for file_index = 1:numel(files)
    % current file
    file = files(file_index);

    % choose proper directory for current file
    metal_or_phantom = 'metal/';
    force_sampling_frequency = force_sampling_frequency_metal;
    smoothing_parameter = 5;
    
    % timestamps for start and end of force measurement as well as start of oct measurement (end of oct measurement is calculated)
    opts = detectImportOptions('timestamps.txt');
    opts.DataLine = 2;
    timestamps = readtable('timestamps.txt', opts);
    
    % read force data
    force_data = dlmread(force_path);
    force_time = force_data(:, 1);
    force_data = force_data(:, 4);

    % read oct data
    oct_file_id = fopen(oct_path);
    oct_data = fread(oct_file_id, [512, Inf], 'float');
    oct_time = dlmread(oct_time_path);
    
    for i = 1:size(timestamps, 1)
        if strcmp(timestamps.Measurement(i), file)
            if timestamps.use_file(i) == 1
                use_this_file = true;
            else
                use_this_file = false;
            end
            force_start = timestamps.force_start(i);
            force_end = timestamps.force_end(i);
            force_number_of_samples = force_end - force_start + 1;
            force_sampling_frequency = 10^6 * size(force_time, 1) / (force_time(end) - force_time(1));
            
            oct_start = timestamps.oct_start(i);
            oct_sampling_frequency = 100 * size(oct_time, 1) / (oct_time(end) - oct_time(1));
            oct_number_of_samples = round(force_number_of_samples * oct_sampling_frequency / force_sampling_frequency);
            oct_end = oct_start + oct_number_of_samples;
        end
    end
    
    % bool if file should be used is set in timestamps.txt
    % if it is set to false, this file will not be loaded and user for
    % preprocessing
    if use_this_file == false
        continue;
    else
        disp(file);
    end

    % remove offset
    force_data = force_data(force_start:force_end);
    oct_data = oct_data(:, oct_start:oct_end);

    % smooth force data
    force_data = smooth(force_data, smoothing_parameter);
    % interpolate
    force_data = interp1(1:numel(force_data), force_data', linspace(1, numel(force_data), size(oct_data, 2)));

    % downsampling
    force_data = force_data(1:decimation:end);
    oct_data = oct_data(:, 1:decimation:end);

    % maximum values
    [oct_pks, oct_locs] = max(oct_data);

    % horizontal slicing
    oct_mean = round(mean(oct_locs));
    lower_boundary = oct_mean - horizontal_slicing;
    upper_boundary = oct_mean + horizontal_slicing;
    oct_data = oct_data(lower_boundary:upper_boundary, :);

    %% plot
    if (plot_data)
        % flip 
        oct_locs_smooth = smooth(oct_locs);
        oct_data_flip = flipud(oct_data);
        [~, oct_locs_flip] = max(oct_data_flip);

        figure('name', file);
        title(file, 'Interpreter', 'none');

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
        xlim([0, size(oct_data, 2)]);
        xlabel('Time');
        ylabel('Depth');
        title('OCT');
    end

    %% write into file
    if (write_to_file)
        preprocessed_data_path = 'preprocessed_data/train/';

        % write force data
        force_path = strcat(preprocessed_data_path, 'forces/', files ,'.bin');
        force_file_id = fopen((force_path), 'w');
        fwrite(force_file_id, force_data, 'float');
        fclose(force_file_id);

        % write oct data
        oct_path = strcat(preprocessed_data_path, 'oct/', files, '.bin');
        oct_file_id = fopen((oct_path), 'w');
        fwrite(oct_file_id, oct_data, 'float');
        fclose(oct_file_id);
    end
end
