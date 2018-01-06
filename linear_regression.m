preprocessed_data_path = 'data/preprocessed_data/';

for p = 1:1
	for m = 1:1
        file = strcat('p', num2str(p), 'm', num2str(m));

        force_path = strcat(preprocessed_data_path, 'forces/', file, '_forces.bin');
        force_file_id = fopen(force_path);
        force_data = fread(force_file_id, Inf, 'float');
		force_data = force_data';

        oct_path = strcat(preprocessed_data_path, 'oct/', file, '_oct.bin');
        oct_file_id = fopen(oct_path);
        oct_data = fread(oct_file_id, [512, Inf], 'float');
		oct_data = oct_data';

		linear_model = fitlm(oct_data, force_data);

		force_prediction = predict(linear_model, oct_data);
		force_error = force_data - force_prediction;
	end
end


