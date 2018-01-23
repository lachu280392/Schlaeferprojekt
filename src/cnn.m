clear all;

global metal_path_g height_g input_width_g;
metal_path_g = '../preprocessed_data/metal/';
height_g = 2 * 50 + 1;
input_width_g = 5;

% metal files to use
l = [7, 8, 9, 10, 11, 12];
s = [11, 12, 13, 14, 15];

for k = 1:size(l,2)
    metal_files(k) = string(strcat('metal_linear_', num2str(l(k)), '.bin'));
end
for k = 1:size(s,2)
    metal_files(size(l,2)+k) = string(strcat('metal_stepwise_', num2str(s(k)), '.bin'));
end

mean_squared_error = [];

% perform leave-one-out cross validation with all metal files
for file_index = 1:1 %numel(metal_files)
    %% DATA
    
    % decide which files are used for training and validation 
    validation_file = metal_files(file_index)
    training_files = metal_files(metal_files~=validation_file);
    
    [oct_training, force_training, validation_data] = getData(validation_file, training_files);

    %% LAYERS
    
    % define layers
    layers = [
        imageInputLayer([height_g, input_width_g, 1])
    
        convolution2dLayer([7, 3], 16)
        reluLayer
        batchNormalizationLayer
        
        convolution2dLayer([3, 1],16)
        reluLayer
        
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
    
    oct_validation = cell2mat(validation_data(1, 1));
    force_validation = cell2mat(validation_data(1, 2));
    
    force_prediction = predict(net, oct_validation);

    %% PLOT
    
    figure;
    hold on;
    plot(force_validation);
    plot(smooth(force_prediction, 10));
    xlim([0, size(force_validation, 1)]);
    title(validation_file, 'Interpreter', 'none');
    
    %% SAVE MODEL

%     % save model
%     model_path = '../models/cnn';
%     save(model_path, 'net');
end

%% FUNCTION -- getData()

function  [oct_training, force_training, validation_data] = getData(validation_file, training_files)
    
    global metal_path_g height_g input_width_g;  
    
    force_training = [];
    oct_training = [];

    % VALIDATION DATA
    
    % force_data for validation
    force_path = strcat(metal_path_g, 'forces/', validation_file);
    force_file_id = fopen(force_path);
    force_validation = fread(force_file_id, Inf, 'float');

    % oct_data for validation
    oct_path = strcat(metal_path_g, 'oct/', validation_file);
    oct_file_id = fopen(oct_path);
    oct_validation = fread(oct_file_id, [height_g, Inf], 'float');
    
    % define validation data
    [oct_validation, force_validation] = splitData(oct_validation, force_validation, input_width_g);
    validation_data = {oct_validation, force_validation};
    
    % TRAINING DATA
    
    for training_files_index = 1:numel(training_files)
        
        % read raw data from files 
        [oct_buffer, force_buffer] = readData(training_files, training_files_index);
 
        % split the raw data into smaller images with depth
        [oct_new_data, force_new_data] = splitData(oct_buffer, force_buffer, input_width_g);
        
        % concatenate data
        % [oct_training] = (height_g x input_width_g x 1 x depth)
        % depth = number of images in direction of time
        % [force_training] = (1 x depth)
        oct_training    = cat(4, oct_training, oct_new_data);
        force_training  = cat(1, force_training, force_new_data);
        
    end
    
end

%% FUNCTION -- readData()
% function to read data from files

function [oct_buffer, force_buffer] = readData(training_files, training_files_index)

    global height_g metal_path_g;

    force_path      = strcat(metal_path_g, 'forces/', training_files(training_files_index));
    force_file_id   = fopen(force_path);
    force_buffer    = fread(force_file_id, Inf, 'float');

    oct_path        = strcat(metal_path_g, 'oct/', training_files(training_files_index));
    oct_file_id     = fopen(oct_path);
    oct_buffer      = fread(oct_file_id, [height_g, Inf], 'float');

end

%%  FUNCTION -- splitData()
%   function to split raw data into large number of smaller images(height_g x input_width_g) 

function [data4D, force] = splitData(oct, force, input_width_g)

    image_width = size(oct, 2);
    new_size = image_width - input_width_g + 1;
    
    for split_index = 1:new_size
        input_image = oct(:, split_index:(split_index + input_width_g - 1));
        data4D(:, :, 1, split_index) = input_image;
    end
    
    force = force(input_width_g:end);
    
end