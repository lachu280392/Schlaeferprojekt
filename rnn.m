clear all;
metal_path= 'preprocessed_data/metal/';

depth = 2 * 50 + 1;

% all metal files, i. e. the training and validation set
metal_files = ls(strcat(metal_path, 'forces/'));
metal_files = metal_files(1:end - 1);
metal_files = convertCharsToStrings(metal_files);
metal_files = strsplit(metal_files);
metal_files = erase(metal_files, '.txt');

force_data = [];
features = [];
for file_index = 1:1%numel(metal_files)
    disp(metal_files(file_index));
    % concatenate force data of all metal files
    force_path = strcat(metal_path, 'forces/', metal_files(file_index));
    force_file_id = fopen(force_path);
    force_buffer = fread(force_file_id, Inf, 'float');
    force_data = cat(1, force_data, force_buffer);

    % concatenate the features extracted from all metal files
    oct_path = strcat(metal_path, 'oct/', metal_files(file_index));
    oct_file_id = fopen(oct_path);
    oct_data  = fread(oct_file_id, [depth, Inf], 'float');
    features = cat(1, features, extract_features(oct_data));
end

% convert to cell arrays
depth_at_maximum_intensity = num2cell(features.depth_at_maximum_intensity);
force_data = num2cell(force_data');

% create and train recurrent neural network
net = layrecnet(1, 5);
net.trainParam.showCommandLine = true;
net.trainFcn = 'trainlm';
[net, training_record] = train(net, depth_at_maximum_intensity, force_data);

% save model
model_path = 'models/rnn'; save(model_path, 'net');
