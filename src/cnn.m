clear all;
metal_path= '../preprocessed_data/metal/';

depth = 2 * 50 + 1;

% all metal files, i. e. the training and validation set
metal_files = ls(strcat(metal_path, 'forces/'));
metal_files = metal_files(1:end - 1);
metal_files = convertCharsToStrings(metal_files);
metal_files = strsplit(metal_files);
metal_files = erase(metal_files, '.txt');

mean_squared_error = [];

% perform leave-one-out cross validation with all metal files
for file_index = 1:1 %numel(metal_files)
    % decide which files are used for training and validation 
    validation_file = metal_files(file_index)
    training_files = metal_files(metal_files~=validation_file);

    % force_data for validation
    force_path = strcat(metal_path, 'forces/', validation_file);
    force_file_id = fopen(force_path);
    force_validation = fread(force_file_id, Inf, 'float');

    % oct_data for validation
    oct_path = strcat(metal_path, 'oct/', validation_file);
    oct_file_id = fopen(oct_path);
    oct_validation = fread(oct_file_id, [depth, Inf], 'float')';

    force_training = [];
    oct_training = [];
    for training_files_index = 1:numel(training_files)
        force_path = strcat(metal_path, 'forces/', training_files(training_files_index));
        force_file_id = fopen(force_path);
        force_buffer = fread(force_file_id, Inf, 'float');
        force_training = cat(1, force_training, force_buffer);

        oct_path = strcat(metal_path, 'oct/', training_files(training_files_index));
        oct_file_id = fopen(oct_path);
        oct_buffer = fread(oct_file_id, [depth, Inf], 'float');
        size_oct_buffer = size(oct_buffer);
        oct_buffer_smoothed = zeros(size_oct_buffer(1),size_oct_buffer(2));
        for j = 1:size_oct_buffer(2)
            oct_buffer_smoothed(:,j) = smooth(oct_buffer(:,j),5);
        end
        for j = 1:size_oct_buffer(1)
            oct_buffer_smoothed(j,:) = smooth(oct_buffer_smoothed(j,:),5);
        end
        oct_training = cat(1, oct_training, oct_buffer_smoothed');
    end
    
    % input (As an H-by-W-by-C-by-N array)
    %   H - height of image
    %   W - width of image
    %   C - number of channels
    %   N - number of images
    
    % inputs need to be 4 dimensional
    oct_buffer = zeros(depth, 1, 1, size(oct_training, 1));
    oct_buffer(:, 1, 1, :) = oct_training';
    oct_training = oct_buffer;

    % define layers
    layers = [
        imageInputLayer([depth, 1, 1])
    
        convolution2dLayer([3, 1], 2)
        reluLayer
        batchNormalizationLayer
        
        convolution2dLayer([3,1],4)
        reluLayer
        
        convolution2dLayer([3,1],16)
        reluLayer
 
        fullyConnectedLayer(1)
        regressionLayer];

    % define validation data
    oct_buffer = zeros(depth, 1, 1, size(oct_validation, 1));
    oct_buffer(:, 1, 1, :) = oct_validation';
    validation_data = {oct_buffer, force_validation};

    % define options
    options = trainingOptions('sgdm', ...
        'MaxEpochs', 5,  ...
        'ValidationData', validation_data, ...
        'ValidationFrequency', 30, ...
        'MiniBatchSize', 32, ...
        'Verbose', true, ...
        'Plots', 'training-progress');

    % train network
    net = trainNetwork(oct_training, force_training, layers, options);

    % convert oct_validation to 4 dimensional array and predict force
    oct_buffer = zeros(depth, 1, 1, size(oct_validation, 1));
    oct_buffer(:, 1, 1, :) = oct_validation';
    oct_validation = oct_buffer;
    force_prediction = predict(net, oct_validation);

    % plots
    figure;
    hold on;
    plot(force_validation);
    plot(smooth(force_prediction, 10));
    xlim([0, size(force_validation, 1)]);
    title(validation_file);

%     % save model
%     model_path = '../models/cnn';
%     save(model_path, 'net');
end
