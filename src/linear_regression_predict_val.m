clear all;

depth = 2 * 50 + 1;
 
% load model
model_path = strcat('../models/linear_model');
model = load(model_path);
model = struct2cell(model);
model = model{1};

file = 'val.bin';
file_path = '../preprocessed_data/metal/';

oct_path = strcat(file_path, 'oct/', file);
oct_file_id = fopen(oct_path);
oct_buffer = fread(oct_file_id, [depth, Inf], 'float');
features_buffer = extract_features(oct_buffer);
depth_at_maximum_intensity = (features_buffer.depth_at_maximum_intensity);
depth_at_maximum_intensity = depth_at_maximum_intensity - mean(depth_at_maximum_intensity(1:9));
depth_at_maximum_intensity = depth_at_maximum_intensity';

force_prediction = predict(model, depth_at_maximum_intensity);
figure;
plot(force_prediction);
