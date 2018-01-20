clear all;
metal_path= '../preprocessed_data/metal/';

depth = 2 * 50 + 1;

% all metal files, i. e. the training and validation set
metal_files = ls(strcat(metal_path, 'forces/'));
metal_files = metal_files(1:end - 1);
metal_files = convertCharsToStrings(metal_files);
metal_files = strsplit(metal_files);

mse_model = [];
mse_validation = [];
mse_smoothed_validation = [];

% specify relative size of validation and training set
validation_set_size = 0.3;

% compute absolute size of validation and training set
validation_set_size = ceil(validation_set_size * numel(metal_files));
training_set_size = numel(metal_files) - validation_set_size;

% the number of repeated random sub-sampling validations
number_of_cross_validations = 4;
for cross_validation_iteration = 1:number_of_cross_validations
    disp(cross_validation_iteration);

    % randomly select indices
    randomized_indices = randperm(numel(metal_files));
    training_set_indices = randomized_indices(1:training_set_size);
    validation_set_indices = randomized_indices((training_set_size + 1):end);

    % the corresponding files
    training_set_files = metal_files(training_set_indices);
    validation_set_files = metal_files(validation_set_indices);

    % load training set data
    force_training = [];
    depth_at_maximum_intensity_training = [];
    for training_set_index = 1:numel(training_set_files)
        force_path = strcat(metal_path, 'forces/', training_set_files(training_set_index));
        force_file_id = fopen(force_path);
        force_buffer = fread(force_file_id, Inf, 'float');
        force_buffer = force_buffer - mean(force_buffer(1:9));
        force_training = cat(1, force_training, force_buffer);

        oct_path = strcat(metal_path, 'oct/', training_set_files(training_set_index));
        oct_file_id = fopen(oct_path);
        oct_buffer = fread(oct_file_id, [depth, Inf], 'float');
        features_buffer = extract_features(oct_buffer);
        depth_at_maximum_intensity_training = cat(1, depth_at_maximum_intensity_training, (features_buffer.depth_at_maximum_intensity)');
    end

    % load validation set data
    force_validation = [];
    depth_at_maximum_intensity_validation = [];
    for validation_set_index = 1:numel(validation_set_files)
        force_path = strcat(metal_path, 'forces/', validation_set_files(validation_set_index));
        force_file_id = fopen(force_path);
        force_buffer = fread(force_file_id, Inf, 'float');
        force_buffer = force_buffer - mean(force_buffer(1:9));
        force_validation = cat(1, force_validation, force_buffer);

        oct_path = strcat(metal_path, 'oct/', validation_set_files(validation_set_index));
        oct_file_id = fopen(oct_path);
        oct_buffer = fread(oct_file_id, [depth, Inf], 'float');
        features_buffer = extract_features(oct_buffer);
        depth_at_maximum_intensity_validation = cat(1, depth_at_maximum_intensity_validation, (features_buffer.depth_at_maximum_intensity)');
    end


    % linear regression
    linear_model = fitlm(depth_at_maximum_intensity_training, force_training);

    % the mse for the training set
    mse_model = [mse_model, linear_model.MSE];

    % predict force
    force_prediction = predict(linear_model, depth_at_maximum_intensity_validation);

    % smooth force prediction
    smoothed_force_prediction = smooth(force_prediction, 42);

    % the mse for the validation set
    mse_validation = [mse_validation, immse(force_prediction, force_validation)];

    % the mse for the smoothed prediction
    mse_smoothed_validation = [mse_smoothed_validation, immse(smoothed_force_prediction, force_validation)];

    % plots
    figure;
    hold on;
    plot(force_validation);
    plot(force_prediction);
    xlim([0, size(force_validation, 1)]);
    title(strcat('iteration ', num2str(cross_validation_iteration)));

    % close all files
    fclose('all');
end

% train final model with all data
force_data = [];
depth_at_maximum_intensity = [];
for file_index = 1:numel(metal_files)
    force_path = strcat(metal_path, 'forces/', metal_files(file_index));
    force_file_id = fopen(force_path);
    force_buffer = fread(force_file_id, Inf, 'float');
    force_buffer = force_buffer - mean(force_buffer(1:9));
    force_data = cat(1, force_data, force_buffer);

    oct_path = strcat(metal_path, 'oct/', metal_files(file_index));
    oct_file_id = fopen(oct_path);
    oct_buffer = fread(oct_file_id, [depth, Inf], 'float');
    features_buffer = extract_features(oct_buffer);
    depth_at_maximum_intensity = cat(1, depth_at_maximum_intensity, (features_buffer.depth_at_maximum_intensity)');
end

% linear regression
linear_model = fitlm(depth_at_maximum_intensity, force_data);

% the mse of the final model
mse_final_model = linear_model.MSE;

% save model
model_path = '../models/linear_model';
save(model_path, 'linear_model');
