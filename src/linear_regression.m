clear all;
metal_path= '../preprocessed_data/metal/';

depth = 2 * 50 + 1;

% all metal files, i. e. the training and validation set
metal_files = ls(strcat(metal_path, 'forces/'));
metal_files = metal_files(1:end - 1);
metal_files = convertCharsToStrings(metal_files);
metal_files = strsplit(metal_files);


test_files = ["metal_linear_8.bin", "metal_linear_11.bin", "metal_stepwise_12.bin", "metal_stepwise_14.bin"];
for file_index = 1:numel(test_files)
    metal_files = metal_files(metal_files~=test_files(file_index));
end

excluded_files = ["metal_linear_5.bin", "metal_linear_7.bin", "metal_linear_9.bin", "metal_linear_10.bin"];
for file_index = 1:numel(excluded_files)
    metal_files = metal_files(metal_files~=excluded_files(file_index));
end

training_files = metal_files;

force_data = [];
depth_at_maximum_intensity = [];

for file_index = 1:numel(training_files)
    file = training_files(file_index);

    force_path = strcat(metal_path, 'forces/', file);
    force_file_id = fopen(force_path);
    force_buffer = fread(force_file_id, Inf, 'float');
    force_buffer = force_buffer - mean(force_buffer(1:9));
    force_data = cat(1, force_data, force_buffer);

    oct_path = strcat(metal_path, 'oct/', file);
    oct_file_id = fopen(oct_path);
    oct_buffer = fread(oct_file_id, [depth, Inf], 'float');
    features_buffer = extract_features(oct_buffer);
    depth_buffer = (features_buffer.depth_at_maximum_intensity)';
    depth_buffer = depth_buffer - mean(depth_buffer(1:9));
    depth_at_maximum_intensity = cat(1, depth_at_maximum_intensity, depth_buffer);
end
fclose all;

% linear regression
linear_model = fitlm(depth_at_maximum_intensity, force_data);

% scatter plot
figure;
hold on;
scatter(depth_at_maximum_intensity, force_data, 2, 'filled');
x_limits = xlim;
predictor = x_limits(1):x_limits(2);
coefficients = linear_model.Coefficients.Estimate;
straight_line = coefficients(1) + coefficients(2) * predictor;
plot(predictor, straight_line);

for file_index = 1:numel(test_files)
    file = test_files(file_index);

    force_path = strcat(metal_path, 'forces/', file);
    force_file_id = fopen(force_path);
    force_data = fread(force_file_id, Inf, 'float');
    force_data = force_data - mean(force_data(1:9));

    oct_path = strcat(metal_path, 'oct/', file);
    oct_file_id = fopen(oct_path);
    oct_buffer = fread(oct_file_id, [depth, Inf], 'float');
    features_buffer = extract_features(oct_buffer);
    depth_at_maximum_intensity = (features_buffer.depth_at_maximum_intensity)';
    depth_at_maximum_intensity = depth_at_maximum_intensity - mean(depth_at_maximum_intensity(1:9));

    force_prediction = predict(linear_model, depth_at_maximum_intensity);

    prediction_error = force_prediction - force_data;

    % root mean squared error
    root_mean_squared_error = sqrt(mse(prediction_error));

    % plot measured and predicted force
    figure;
    hold on;
    plot(force_data);
    plot(force_prediction);
    plot(prediction_error);
    title(file, 'Interpreter', 'none');
end
fclose all;

% save model
model_path = '../models/linear_model';
save(model_path, 'linear_model');
