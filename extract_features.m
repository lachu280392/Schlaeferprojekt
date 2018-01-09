function features = extract_features(oct_data)
    mean_value = mean(oct_data, 1);
    oct_sorted = sort(oct_data, 1, 'descend');
    number_of_maxima_per_scan = 3;
    maximum_intensity = [];
    depth_at_maximum_intensity = [];
    standard_deviation = [];
    for i = 1:size(oct_data, 2)
        maximum_intensity = cat(2, maximum_intensity, oct_sorted(1:number_of_maxima_per_scan, i));
        for j = 1:number_of_maxima_per_scan
            depth_at_maximum_intensity = cat(1, depth_at_maximum_intensity, find(oct_data(:, i) == maximum_intensity(j, i)));
        end
        standard_deviation = cat(2, standard_deviation, std(oct_data(:, i)));
    end
    % this is weird. For number_of_maxima_per_scan > ~20, the size of the vector is slightly larger than it should be...
    depth_at_maximum_intensity = depth_at_maximum_intensity(1:number_of_maxima_per_scan * size(oct_data, 2));
    depth_at_maximum_intensity = reshape(depth_at_maximum_intensity, [number_of_maxima_per_scan, size(oct_data, 2)]);
    % ATTENTION PLEASE! the feature table must have time as the first dimension. Hence, some features need to be transposed because the OCT has the time as the second dimension.
    features = table(mean_value', maximum_intensity', depth_at_maximum_intensity', standard_deviation');
    features.Properties.VariableNames = {'mean_value', 'maximum_intensity', 'depth_at_maximum_intensity', 'standard_deviation'};
end
