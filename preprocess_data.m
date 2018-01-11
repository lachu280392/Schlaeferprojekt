clear all;
% set 'no_write' to true to prevent writing data to files
no_write = true;
% set 'no_plots' to true to prevent plots
no_plots = false;

decimation = 1;

% Path to data
data_path = 'data/';

metal_files = ls(strcat(data_path, 'metal/forces/'));
metal_files = metal_files(1:end - 1);
metal_files = convertCharsToStrings(metal_files);
metal_files = strsplit(metal_files);

phantoms_files = ls(strcat(data_path, 'phantoms/forces/'));
phantoms_files = phantoms_files(1:end - 1);
phantoms_files = convertCharsToStrings(phantoms_files);
phantoms_files = strsplit(phantoms_files);

files = [metal_files, phantoms_files];
files = erase(files, '.txt');

for i = 1:numel(files)
    % current file
    file = files(i)

    % choose proper directory for current file
    if (i <= numel(metal_files))
        metal_or_phantom = 'metal/';
    else
        metal_or_phantom = 'phantoms/';
    end

    % read force data
    force_path = strcat(data_path, metal_or_phantom, 'forces/', file, '.txt');
    force_data = dlmread(force_path);
    force_time = force_data(:, 1);
    force_data = force_data(:, 4);

    % read oct data
    oct_path = strcat(data_path, metal_or_phantom, 'oct/', file, '.bin');
    oct_file_id = fopen(oct_path);
    oct_data = fread(oct_file_id, [512, Inf], 'float');
    oct_time_path = strcat(data_path, metal_or_phantom, 'oct/', file, '_timestamp.txt');
    oct_time = dlmread(oct_time_path);

    % timestamps for start and end of force measurement as well as start of oct measurement (end of oct measurement is calculated)
    opts = detectImportOptions('timestamps.txt');
    opts.DataLine = 2;
    time = readtable('timestamps.txt', opts);
    for j = 1:numel(files)
        if strcmp(time.Measurement(j), file)
            force_start = time.force_start(j);
            force_end = time.force_end(j);
            force_number_of_samples = force_end - force_start + 1;
            force_sampling_frequency = 10^6 * size(force_time, 1) / (force_time(end) - force_time(1));
            oct_start = time.oct_start(j);
            oct_sampling_frequency = 100 * size(oct_time, 1) / (oct_time(end) - oct_time(1));
            oct_number_of_samples = round(force_number_of_samples * oct_sampling_frequency / force_sampling_frequency);
            oct_end = oct_start + oct_number_of_samples - 1;
        end
    end

    % remove offset
    force_data = force_data(force_start:force_end);
    oct_data = oct_data(:, oct_start:oct_end);

    % interpolate
    force_data = interp1(1:double(force_number_of_samples), force_data', linspace(1, double(force_number_of_samples), double(oct_number_of_samples)));

    % downsampling
    force_data = force_data(1:decimation:end);
    oct_data = oct_data(:, 1:decimation:end);

    % maximum values
    [oct_pks, oct_locs] = max(oct_data);

    % horizontal slicing
    oct_mean = mean(oct_locs);
    oct_std = std(oct_locs);
    lower_boundary = max(floor(oct_mean - 3 * oct_std), 1);
    upper_boundary = ceil(oct_mean + 3 * oct_std);
    oct_data = oct_data(lower_boundary:upper_boundary, :);

    %% plot
    if (not(no_plots))
        % flip 
        oct_locs_smooth = smooth(oct_locs);
        oct_data_flip = flipud(oct_data);
        [~, oct_locs_flip] = max(oct_data_flip);

        figure('name', file);
        title(file);

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
    if (not(no_write))
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
    end
end
