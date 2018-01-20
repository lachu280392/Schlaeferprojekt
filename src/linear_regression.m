clear all;
metal_path= '../preprocessed_data/metal/';

depth = 2 * 50 + 1;

% all metal files, i. e. the training and validation set
metal_files = ls(strcat(metal_path, 'forces/'));
metal_files = metal_files(1:end - 1);
metal_files = convertCharsToStrings(metal_files);
metal_files = strsplit(metal_files);

model_mean_squared_error = [];
validation_mean_squared_error = [];
smoothed_validation_mean_squared_error = [];

% specify relative size of validation and training set
validation_set_size = 0.3;

% compute absolute size of validation and training set
validation_set_size = ceil(validation_set_size * numel(metal_files));
training_set_size = numel(metal_files) - validation_set_size;

% the number of repeated random sub-sampling validation
number_of_cross_validations = 10;
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
    oct_training = [];
    for training_set_index = 1:numel(training_set_files)
        force_path = strcat(metal_path, 'forces/', training_set_files(training_set_index));
        force_file_id = fopen(force_path);
        force_buffer = fread(force_file_id, Inf, 'float');
        force_training = cat(1, force_training, force_buffer);

        oct_path = strcat(metal_path, 'oct/', training_set_files(training_set_index));
        oct_file_id = fopen(oct_path);
        oct_buffer = fread(oct_file_id, [depth, Inf], 'float');
        oct_training = cat(1, oct_training, oct_buffer');
    end

    % load validation set data
    force_validation = [];
    oct_validation = [];
    for validation_set_index = 1:numel(validation_set_files)
        force_path = strcat(metal_path, 'forces/', validation_set_files(validation_set_index));
        force_file_id = fopen(force_path);
        force_buffer = fread(force_file_id, Inf, 'float');
        force_validation = cat(1, force_validation, force_buffer);

        oct_path = strcat(metal_path, 'oct/', validation_set_files(validation_set_index));
        oct_file_id = fopen(oct_path);
        oct_buffer = fread(oct_file_id, [depth, Inf], 'float');
        oct_validation = cat(1, oct_validation, oct_buffer');
    end

    % linear regression
    linear_model = fitlm(oct_training, force_training);

    % the mse for the training set
    model_mean_squared_error = [model_mean_squared_error, linear_model.MSE];

    % predict force
    force_prediction = predict(linear_model, oct_validation);

    % smooth force prediction
    smoothed_force_prediction = smooth(force_prediction, 42);

    % the mse for the validation set
    validation_mean_squared_error = [validation_mean_squared_error, immse(force_prediction, force_validation)];

    % 
    smoothed_validation_mean_squared_error = [smoothed_validation_mean_squared_error, immse(smoothed_force_prediction, force_validation)];

    % plots
    figure;
    hold on;
    plot(force_validation);
    plot(force_prediction);
    xlim([0, size(force_validation, 1)]);
    title(strcat('iteration ', num2str(cross_validation_iteration)));
end

% train final model with all data
force_data = [];
oct_data = [];
for file_index = 1:numel(metal_files)
    force_path = strcat(metal_path, 'forces/', metal_files(file_index));
    force_file_id = fopen(force_path);
    force_buffer = fread(force_file_id, Inf, 'float');
    force_data = cat(1, force_data, force_buffer);

    oct_path = strcat(metal_path, 'oct/', metal_files(file_index));
    oct_file_id = fopen(oct_path);
    oct_buffer = fread(oct_file_id, [depth, Inf], 'float');
    oct_data = cat(1, oct_data, oct_buffer');
end

% linear regression
linear_model = fitlm(oct_data, force_data);

% the mse of the final model
final_mean_squared_error = linear_model.MSE;

% save model
model_path = '../models/linear_model';
save(model_path, 'linear_model');
