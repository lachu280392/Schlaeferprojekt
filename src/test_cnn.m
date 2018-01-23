%% TEST DATA

clear all;

global height_g input_width_g;
height_g = 2 * 50 + 1;

% LOAD

load('models/cnn/width_7/force_prediction_metal_linear_8.mat')
input_width_g = net.Layers(1,1).InputSize(1,2);

oct_test_data_path = 'preprocessed_data/phantoms/oct/p1m1.bin';
oct_fille_id = fopen(oct_test_data_path);
oct_data = fread(oct_fille_id, [height_g, Inf], 'float');

force_test_data_path = 'preprocessed_data/phantoms/forces/p1m2.bin';
force_file_id = fopen(force_test_data_path);
force_data = fread(force_file_id,  Inf, 'float');

[oct_test_data, force_test_data] = splitData(oct_data, force_data);

% TEST

test_force_prediction = predict(net, oct_test_data);

% PLOT
figure;
hold on;
plot(test_force_prediction);
plot(force_test_data);
xlim([0, size(force_test_data, 1)]);
title('test');

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