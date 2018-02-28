clear all;

global metal_path_g height_g input_width_g;
metal_path_g = 'preprocessed_data/metal/';
height_g = 2 * 50 + 1;
input_width_g = 6;
%%

% TRAINING DATA

% liear     %2, %3, %4, %5, %6, 7, 8, 9, 10, 11, 12, %13
% stepwise  %1, %2, %3, %7, 11, 12, 13, 14, 15
l = [7, 9, 10, 12];
s = [11, 13, 15];

for k = 1:size(l,2)
    training_files(k) = string(strcat('metal_linear_', num2str(l(k)), '.bin'));
end
for k = 1:size(s,2)
    training_files(size(l,2)+k) = string(strcat('metal_stepwise_', num2str(s(k)), '.bin'));
end

training_files = cat(2, training_files, 'train.bin');

% TESTING DATA

l_v = [8, 11];
s_v = [12, 14];

for k = 1:size(l_v,2)
    validation_files(k) = string(strcat('metal_linear_', num2str(l_v(k)), '.bin'));
end
for k = 1:size(s_v,2)
    validation_files(size(l_v,2)+k) = string(strcat('metal_stepwise_', num2str(s_v(k)), '.bin'));
end

mean_squared_error = [];

    %% DATA
    
    [oct_training, force_training] = getData(training_files);
    [oct_validation, force_validation] = getData(validation_files(1));
    validation_data = {oct_validation, force_validation};

    %% LAYERS
    
    % define layers
    layers = [
        imageInputLayer([height_g, input_width_g, 1])
    
        convolution2dLayer([3, 6], 16, 'Padding', 'same')
        reluLayer
        maxPooling2dLayer(2, 'Stride', 2)
 
        fullyConnectedLayer(1)
        
        regressionLayer];

    % define options
    options = trainingOptions('sgdm', ...
        'MaxEpochs', 5,  ...
        'ValidationData', validation_data, ...
        'ValidationFrequency', 30, ...
        'MiniBatchSize', 32, ...
        'Verbose', true, ...
        'Plots', 'training-progress');

    %% TRAIN NETWORK
    
    net = trainNetwork(oct_training, force_training, layers, options);
    
    %% TEST NETWORK
    
    for test_index = 2:numel(validation_files)
        
        [oct_validation, force_validation] = getData(validation_files(test_index));

        force_prediction = predict(net, oct_validation);

        mse = immse(force_validation, double(force_prediction));

        store_force_validation{test_index} = force_validation;
        store_force_prediction{test_index} = force_prediction;
        store_mse{test_index} = mse;
        
        % PLOT
        
        figure;
        hold on;
        plot(force_validation);
        plot(smooth(force_prediction, 30));
        xlim([0, size(force_validation, 1)]);
        name_validation_file = erase(validation_files(test_index), '.bin');
        title(name_validation_file, 'Interpreter', 'none');
        
    end    

%% FUNCTION -- getData()

function  [oct, force] = getData(files)
    
    global metal_path_g height_g input_width_g;  
    
    oct = [];
    force = [];
    
    % TRAINING DATA
    
    for index = 1:numel(files)
        
        % read raw data from files 
        [oct_buffer, force_buffer] = readData(files, index);
 
        % split the raw data into smaller images with depth
        [oct_new_data, force_new_data] = splitData(oct_buffer, force_buffer, input_width_g);
        
        % concatenate data
        % [oct_training] = (height_g x input_width_g x 1 x depth)
        % depth = number of images in direction of time
        % [force_training] = (1 x depth)
        oct    = cat(4, oct, oct_new_data);
        force  = cat(1, force, force_new_data);
        
    end
    
end

%% FUNCTION -- readData()
% function to read data from files

function [oct_buffer, force_buffer] = readData(files, files_index)

    global height_g metal_path_g;

    force_path      = strcat(metal_path_g, 'forces/', files(files_index));
    force_file_id   = fopen(force_path);
    force_buffer    = fread(force_file_id, Inf, 'float');

    oct_path        = strcat(metal_path_g, 'oct/', files(files_index));
    oct_file_id     = fopen(oct_path);
    oct_buffer      = fread(oct_file_id, [height_g, Inf], 'float');

end

%%  FUNCTION -- splitData()
%   function to split raw data into large number of smaller images(height_g x input_width_g) 

function [oct_4D, force] = splitData(oct, force, input_width_g)

    image_width = size(oct, 2);
    new_size = image_width - input_width_g + 1;
    
    for split_index = 1:new_size
        input_image = oct(:, split_index:(split_index + input_width_g - 1));
        oct_4D(:, :, 1, split_index) = input_image;
    end
    
    force = force(input_width_g:end);
    force = force - max(force);
    
end