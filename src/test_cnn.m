%% PREPROCESS DATA

clear all;
% preprocessed data is written to files
write_to_file = true;
% preprocessed data is plotted
plot_data = true;

% the decimation is used to reduce the resolution of force and oct data. decimation = 100 means that every 100ths value is used
decimation = 1;

% the 50 horizontal_slicing means that the oct data is reduced to all data of the mean depth +- 50
horizontal_slicing = 50;

% Path to data
data_path = 'data/metal/';

files  = "val";
force_path = strcat(data_path, 'forces/', files, '.txt');
oct_path = strcat(data_path, 'oct/', files, '.bin');
oct_time_path = strcat(data_path, 'oct/', files, '_timestamp.txt');

% read force data
force_data = dlmread(force_path);
force_time = force_data(:, 1);
force_data = force_data(:, 4);

% read oct data
oct_file_id = fopen(oct_path);
oct_data = fread(oct_file_id, [512, Inf], 'float');
oct_time = dlmread(oct_time_path);

figure;
subplot(2,1,1);
plot(force_data);
title(files);

subplot(2,1,2);
image(flipud(oct_data));
    
%% ENTER force_start, force_end, oct_start!!!

force_start = 500;
force_end = 1500;
oct_start = 7339;
%%

force_number_of_samples = force_end - force_start + 1;
force_sampling_frequency = 10^6 * size(force_time, 1) / (force_time(end) - force_time(1));
oct_sampling_frequency = 100 * size(oct_time, 1) / (oct_time(end) - oct_time(1));
oct_number_of_samples = round(force_number_of_samples * oct_sampling_frequency / force_sampling_frequency);
oct_end = oct_start + oct_number_of_samples;

% remove offset
force_data = force_data(force_start:force_end);
oct_data = oct_data(:, oct_start:oct_end);

% smooth force data
force_data = smooth(force_data, 5);
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

preprocessed_data_path = 'preprocessed_data/metal/';

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
    
%% TEST NETWORK

clear all;

global height_g input_width_g;
height_g = 2 * 50 + 1;

force_given = true;

% LOAD DATA

load('models/cnn.mat')
input_width_g = net.Layers(1,1).InputSize(1,2);

data_path = 'preprocessed_data/';
material_file = 'metal/';           % {metal, phantoms}
name = 'val';

oct_test_data_path = strcat(data_path, material_file, 'oct/', name, '.bin')
oct_fille_id = fopen(oct_test_data_path);
oct_data = fread(oct_fille_id, [height_g, Inf], 'float');

figure;
hold on;
image(oct_data);
[~, locs] = max(oct_data);
h1 = plot(locs);
delete(h1);
axis([0 size(oct_data,2) 0 size(oct_data,1)])
xlabel('Time');
ylabel('Depth');
title(name, 'Interpreter', 'none');

if force_given
    force_test_data_path = strcat(data_path, material_file, 'forces/', name, '.bin')
    force_file_id = fopen(force_test_data_path);
    force_data = fread(force_file_id,  Inf, 'float');
    force_data = force_data - force_data(1);
    force_data = smooth(force_data, 5);
else
    force_data = [];
end

[oct_test_data, force_test_data] = splitData(oct_data, force_data);

% TEST

test_force_prediction = predict(net, oct_test_data);

%% PLOT

measured_data = force_test_data - force_test_data(1);
predicted_data = smooth(test_force_prediction, 100);
error = predicted_data - measured_data;
figure;
hold on;
if force_given
    plot(measured_data);
    xlim([0, size(test_force_prediction, 1)]);
end
plot(predicted_data);
plot(error);
xlabel('Time');
ylabel('Force');
legend('Measured Force', 'Predicted Force', 'Error');
title(name, 'Interpreter', 'none');

%% MSE

mse = sqrt(mean(error.^2))

%%  FUNCTION -- splitData()
%   function to split raw data into large number of smaller images(height_g x input_width_g) 

function [oct_4D, force] = splitData(oct, force)
global input_width_g;

    image_width = size(oct, 2);
    new_size = image_width - input_width_g + 1;
    
    for split_index = 1:new_size
        input_image = oct(:, split_index:(split_index + input_width_g - 1));
        oct_4D(:, :, 1, split_index) = input_image;
    end
    
    force = force(input_width_g:end);
    force = force - max(force);
    
end