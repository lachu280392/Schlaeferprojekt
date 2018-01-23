clear all;
metal_path= '../preprocessed_data/metal/';

depth = 2 * 50 + 1;

% all metal files, i. e. the training and validation set
metal_files = ls(strcat(metal_path, 'forces/'));
metal_files = metal_files(1:end - 1);
metal_files = convertCharsToStrings(metal_files);
metal_files = strsplit(metal_files);
metal_files = erase(metal_files, '.txt');

excluded_files = ["metal_linear_5.bin", "metal_linear_7.bin", "metal_linear_9", "metal_linear_10"];
for file_index = 1:numel(excluded_files)
    metal_files = metal_files(metal_files~=excluded_files(file_index));
end

force_training = [];
depth_at_maximum_intensity_training = [];
for file_index = 1:numel(metal_files)
    disp(metal_files(file_index));

    % concatenate force data of all metal files
    force_path = strcat(metal_path, 'forces/', metal_files(file_index));
    force_file_id = fopen(force_path);
    force_buffer = fread(force_file_id, Inf, 'float');
    force_buffer = force_buffer - mean(force_buffer(1:9));
    force_training = cat(1, force_training, force_buffer);

    % concatenate the features extracted from all metal files
    oct_path = strcat(metal_path, 'oct/', metal_files(file_index));
    oct_file_id = fopen(oct_path);
    oct_buffer  = fread(oct_file_id, [depth, Inf], 'float');
    features_buffer = extract_features(oct_buffer);
    depth_buffer = (features_buffer.depth_at_maximum_intensity);
    depth_buffer = depth_buffer - mean(depth_buffer(1:9));
    depth_at_maximum_intensity_training = cat(2, depth_at_maximum_intensity_training, depth_buffer);
end

% convert to cell arrays
depth_at_maximum_intensity_training = num2cell(depth_at_maximum_intensity_training);
force_training = num2cell(force_training');

% create and train recurrent neural network
net = layrecnet(1, 5);
net.trainParam.showCommandLine = true;
net.trainFcn = 'trainlm';
[net, training_record] = train(net, depth_at_maximum_intensity_training, force_training);

% save model
model_path = '../models/rnn';
save(model_path, 'net');
