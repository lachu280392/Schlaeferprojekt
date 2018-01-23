clear all;

% load model
model_path = strcat('../models/linear_model');
model = load(model_path);
model = struct2cell(model);
model = model{1};

% all phantom files, i. e. the testing set
phantoms_path = '../preprocessed_data/phantoms/';
phantoms_files = ls(strcat(phantoms_path, 'forces/'));
phantoms_files = phantoms_files(1:end - 1);
phantoms_files = convertCharsToStrings(phantoms_files);
phantoms_files = strsplit(phantoms_files);
phantoms_files = erase(phantoms_files, '.txt');

depth = 2 * 50 + 1;

mean_squared_error = [];
for file_index = 1:numel(phantoms_files)
    testing_file = phantoms_files(file_index);

    % force_data for testing
    force_path = strcat(phantoms_path, 'forces/', testing_file);
    force_file_id = fopen(force_path);
    force_testing = fread(force_file_id, Inf, 'float');
    force_testing = force_testing - mean(force_testing(1:9));

    % oct_data for testing
    oct_path = strcat(phantoms_path, 'oct/', testing_file);
    oct_file_id = fopen(oct_path);
    oct_buffer = fread(oct_file_id, [depth, Inf], 'float');
    features_buffer = extract_features(oct_buffer);
    depth_at_maximum_intensity_testing = (features_buffer.depth_at_maximum_intensity);
    depth_at_maximum_intensity_testing = depth_at_maximum_intensity_testing - mean(depth_at_maximum_intensity_testing(1:9));
    depth_at_maximum_intensity_testing = depth_at_maximum_intensity_testing';
    % model evaluation (see https://en.wikipedia.org/wiki/Regression_validation)
    force_prediction = predict(model, depth_at_maximum_intensity_testing);
    mean_squared_error = [mean_squared_error, immse(force_prediction, force_testing)];

    % plots
    figure;
    hold on;
    plot(force_testing);
    plot(force_prediction);
    xlim([0, size(force_testing, 1)]);
    title(testing_file);
end
