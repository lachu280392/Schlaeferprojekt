function features = extract_features(oct_data)
    assert(size(oct_data, 1) < size(oct_data, 2), 'The time axis of the OCT data should be the second dimension. Please consider transposing your data!');

    % sort oct data to easily find maxima
    oct_sorted = sort(oct_data, 1, 'descend');

    % the reference depth is used to try to remove the zero line
    reference_intensity = oct_sorted(1, 1);
    reference_depth = find(oct_data(:, 1) == reference_intensity);
    reference_depth = reference_depth - round(0.05 * size(oct_data, 1));

    maxima_to_consider = 42;
    depth_at_maximum_intensity = [];
    for i = 1:size(oct_data, 2)
        % threshold for candidates of maximal intensity
        intensity_threshold = 0.85 * oct_sorted(1, i);

        % find intensities that are larger than the threshold
        j = 2;
        maximum_intensities = [];
        while ((oct_sorted(j, i) > intensity_threshold) & j < maxima_to_consider)
            maximum_intensities = cat(1, maximum_intensities, oct_sorted(j, i));
            j = j + 1;
        end

        % initialization with the reference depth makes sure that no depth larger than it is considered
        depth_buffer = [reference_depth];

        % find the depths of all maximum intensities
        for k = 1:numel(maximum_intensities)
            depth_buffer = cat(1, depth_buffer, find(oct_data(:, i) == maximum_intensities(k)));
        end

        % use only the lowest depth
        depth_at_maximum_intensity = cat(1, depth_at_maximum_intensity, min(depth_buffer));
    end

    % subtract reference depth
    depth_at_maximum_intensity = depth_at_maximum_intensity - reference_depth;

    % fill local outliers by linear interpolation
    depth_at_maximum_intensity = filloutliers(depth_at_maximum_intensity, 'linear', 'movmean', 64);

    % moving average for smoothing
    depth_at_maximum_intensity = smooth(depth_at_maximum_intensity, 32);

    % create table of features
    features = table(depth_at_maximum_intensity');
    features.Properties.VariableNames = {'depth_at_maximum_intensity'};
end
