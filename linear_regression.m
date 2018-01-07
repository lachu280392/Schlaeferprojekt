preprocessed_data_path = 'data/preprocessed_data/';

% create array of all file names
file_names = [];
for p = 1:3
	for m = 1:3
		file = string(strcat('p', num2str(p), 'm', num2str(m)));
		file_names = [file_names, file];
	end
end

decimation = 100;

for k = 1:numel(file_names)
	% validation set
	validation_file = file_names(k);
	disp(validation_file);

	force_path = strcat(preprocessed_data_path, 'forces/', validation_file, '_forces.bin');
	force_file_id = fopen(force_path);
	force_data = fread(force_file_id, Inf, 'float');
	force_validation = force_data(1:decimation:end);

	oct_path = strcat(preprocessed_data_path, 'oct/', validation_file, '_oct.bin');
	oct_file_id = fopen(oct_path);
	oct_data = fread(oct_file_id, [512, Inf], 'float');
	oct_validation = oct_data(:, 1:decimation:end)';

	% training set
	training_files = file_names(file_names~=validation_file);
	force_training = [];
	oct_training = [];
	for i = 1:numel(training_files)
		file = training_files(i);
		force_path = strcat(preprocessed_data_path, 'forces/', file, '_forces.bin');
		force_file_id = fopen(force_path);
		force_data = fread(force_file_id, Inf, 'float');
		force_training = cat(1, force_training, force_data(1:decimation:end));

		oct_path = strcat(preprocessed_data_path, 'oct/', file, '_oct.bin');
		oct_file_id = fopen(oct_path);
		oct_data = fread(oct_file_id, [512, Inf], 'float');
		oct_training = cat(1, oct_training, oct_data(:, 1:decimation:end)');
	end

	% linear regression
	linear_model = fitlm(oct_training, force_training);
	force_prediction = predict(linear_model, oct_validation);
	force_error = force_prediction - force_validation;

	%plots
	figure;
	hold on;
	plot(force_validation);
	plot(smooth(force_prediction, 31));
	xlim([0, size(force_validation, 1)]);
	title(validation_file);
end
