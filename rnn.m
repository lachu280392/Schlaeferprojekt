clear all;
metal_path= 'preprocessed_data/metal/';

depth = 2 * 50 + 1;

% all metal files, i. e. the training and validation set
metal_files = ls(strcat(metal_path, 'forces/'));
metal_files = metal_files(1:end - 1);
metal_files = convertCharsToStrings(metal_files);
metal_files = strsplit(metal_files);
metal_files = erase(metal_files, '.txt');

mean_squared_error = [];

% perform leave-one-out cross validation with all metal files
for file_index = 1:1%numel(metal_files)
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
        oct_training = cat(1, oct_training, oct_buffer');
    end

    % extract index (depth) at maximum intensity
    [~, maximum_intensity_index_training] = max(oct_training, [], 2);
    [~, maximum_intensity_index_validation] = max(oct_validation, [], 2);

    % create and train recurrent neural network
    maximum_intensity_index_training = num2cell(maximum_intensity_index_training');
    force_training = num2cell(force_training');
    net = layrecnet(1, 5);
    net.trainParam.showCommandLine = true;
    net.trainFcn = 'trainbr';
    [net, training_record] = train(net, maximum_intensity_index_training, force_training);

    % predict force
    maximum_intensity_index_validation = num2cell(maximum_intensity_index_validation');
    force_prediction = net(maximum_intensity_index_validation);
    force_prediction = cell2mat(force_prediction);

    % model evaluation (see https://en.wikipedia.org/wiki/Regression_validation)
    mean_squared_error = [mean_squared_error, 0];

    % plots
    figure;
    hold on;
    plot(force_validation);
    plot(force_prediction);
    xlim([0, size(force_validation, 1)]);
    title(validation_file);

    % save model
    model_path = 'models/rnn'; save(model_path, 'net'); end
