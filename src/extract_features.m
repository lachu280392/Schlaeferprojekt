function features = extract_features(oct_data)
    assert(size(oct_data, 1) < size(oct_data, 2), 'The time axis of the OCT data should be the second dimension. Please consider transposing your data!');

    % sort oct data to easily find maxima
    oct_sorted = sort(oct_data, 1, 'descend');

    % the reference depth is used to try to remove the zero line
    reference_intensity = oct_sorted(1, 1);
    reference_depth = find(oct_data(:, 1) == reference_intensity);
    reference_depth = reference_depth - round(0.05 * size(oct_data, 1))

    % multiple maxima are collected; only the smallest depth is used
    number_of_maxima_per_scan = 9;
    depth_at_maximum_intensity = [];
    for i = 1:size(oct_data, 2)
        % find a number of depths with the largest intensities
        maximum_intensity = oct_sorted(1:number_of_maxima_per_scan, i);

        % initialization with the reference depth makes sure that no depth larger than it is considered
        depth_buffer = [reference_depth];
        for j = 1:number_of_maxima_per_scan
            depth_buffer = cat(1, depth_buffer, find(oct_data(:, i) == maximum_intensity(j)));
        end

        % use only the lowest depth
        depth_at_maximum_intensity = cat(1, depth_at_maximum_intensity, min(depth_buffer));
    end

    % fill local outliers by linear interpolation
    depth_at_maximum_intensity = filloutliers(depth_at_maximum_intensity, 'linear', 'movmean', 64);

    % moving average for smoothing
    depth_at_maximum_intensity = smooth(depth_at_maximum_intensity, 32);

    % standardize features
    depth_at_maximum_intensity = zscore(depth_at_maximum_intensity);

    % create table of features
    features = table(depth_at_maximum_intensity');
    features.Properties.VariableNames = {'depth_at_maximum_intensity'};
end
