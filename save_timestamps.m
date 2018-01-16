% plots the data asks for the start and end time of the data
% saves it in Timestamps.txt

%% Read data

data_path = 'data/metal/';
disp(strcat('your path is: ', data_path));
prompt = 'linear or stepwise? [l/s] ';
type = input(prompt, 's'); 
if strcmp(type, 'l') == 1
    type = 'linear';
elseif  strcmp(type, 's') == 1
    type = 'stepwise';
else
    disp('Please enter l or s'); 
    return; 
end
prompt = 'number: ';
number = num2str(input(prompt));
name = strcat('metal_', type, '_', number);

force_path = strcat(data_path, 'forces/', name, '.txt');
force_data = dlmread(force_path);
force_time = force_data(:,1);
force_data = force_data(:,4);

oct_path = strcat(data_path, 'oct/metal_', type, '_', number, '.bin');

oct_file_id = fopen(oct_path);
oct_data = fread(oct_file_id, [512, inf], 'float');

%% Plot data

figure;
subplot(2,1,1);
plot(force_data);
title(strcat('metal ', type, ' ', number));

subplot(2,1,2);
image(oct_data);
hold on;
[~, oct_locs] = max(oct_data);

%% force_start
prompt = 'force start: ';
force_start = input(prompt);
%% force_end
prompt = 'force_end: ';
force_end = input(prompt);
%% oct_start
prompt = 'oct_start: ';
oct_start = input(prompt);

%% Write into timestamps.txt
write_id = fopen('timestamps.txt', 'a');
fprintf(write_id, '%s,%u,%u,%u\n', name, force_start, force_end, oct_start);
fclose(write_id);
