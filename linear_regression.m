clear all;
preprocessed_data_path = 'data/preprocessed_data/';

% create array of all file names
all_files = [];
for p = 1:3
	for m = 1:3
		file = string(strcat('p', num2str(p), 'm', num2str(m)));
		all_files = [all_files, file];
	end
end

decimation = 100;
mse = [];
r_squared_adjusted = [];

% 3-fold cross validation with data from 1 phantom as validation set and data from the other 2 phantoms as training sets
for p = 1:m:numel(all_files)
	% validation set
	validation_files = all_files(p:p+m-1);
	disp(validation_files);
	force_validation = [];
	oct_validation = [];
	training_files_indices = logical(ones(1, numel(all_files)));
	for i = 1:numel(validation_files)
		force_path = strcat(preprocessed_data_path, 'forces/', validation_files(i), '_forces.bin');
		force_file_id = fopen(force_path);
		force_data = fread(force_file_id, Inf, 'float');
		force_validation = cat(1, force_validation, force_data(1:decimation:end));

		oct_path = strcat(preprocessed_data_path, 'oct/', validation_files(i), '_oct.bin');
		oct_file_id = fopen(oct_path);
		oct_data = fread(oct_file_id, [512, Inf], 'float');
		oct_validation = cat(1, oct_validation, oct_data(:, 1:decimation:end)');

		% some logical operations to get the training files indices
		training_files_indices = training_files_indices & all_files~=validation_files(i);
	end

	% training set
	training_files = all_files(training_files_indices);
	force_training = [];
	oct_training = [];
	for i = 1:numel(training_files)
		force_path = strcat(preprocessed_data_path, 'forces/', training_files(i), '_forces.bin');
		force_file_id = fopen(force_path);
		force_data = fread(force_file_id, Inf, 'float');
		force_training = cat(1, force_training, force_data(1:decimation:end));

		oct_path = strcat(preprocessed_data_path, 'oct/', training_files(i), '_oct.bin');
		oct_file_id = fopen(oct_path);
		oct_data = fread(oct_file_id, [512, Inf], 'float');
		oct_training = cat(1, oct_training, oct_data(:, 1:decimation:end)');
	end

	% linear regression
	linear_model = fitlm(oct_training, force_training);
	force_prediction = predict(linear_model, oct_validation);

	% model evaluation (see https://en.wikipedia.org/wiki/Regression_validation)
	mse = [mse, linear_model.MSE];
	r_squared_adjusted = [r_squared_adjusted, linear_model.Rsquared.Adjusted];

	% plots
	figure;
	hold on;
	plot(force_validation);
	plot(smooth(force_prediction, 31));
	xlim([0, size(force_validation, 1)]);
	title(strcat('Phantom', num2str(p - m)));
end

% output
mse
r_squared_adjusted
