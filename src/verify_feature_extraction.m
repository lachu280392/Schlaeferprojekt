clear all;
depth = 2 * 50 + 1;

metal_path  = '../preprocessed_data/metal/';
metal_files = ls(strcat(metal_path, 'forces/'));
metal_files = metal_files(1:end - 1);
metal_files = convertCharsToStrings(metal_files);
metal_files = strsplit(metal_files);

for file_index = 1:numel(metal_files)
    file = metal_files(file_index);

    oct_path = strcat(metal_path, 'oct/', file);
    oct_file_id = fopen(oct_path);
    oct_data = fread(oct_file_id, [depth, inf], 'float');
    features_buffer = extract_features(oct_data);
    depth_at_maximum_intensity = features_buffer.depth_at_maximum_intensity;

    figure;
    hold on;
    image(oct_data);
    plot(depth_at_maximum_intensity, '.r');
    title(file, 'Interpreter', 'none');
end

