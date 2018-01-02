%% 
folder_path = '/media/yuria/STIIIIICK';
%% FORCES

file_forces = '/forces/p1m1_1.txt';
force_path = strcat(folder_path, file_forces);
force_data = dlmread(force_path);
force_time = force_data(:,1);
force_z = force_data(:, 4);
force_x = force_data(:, 2);

% PLOTS

% forceX_plot = subplot(2,1,1);
% plot(forceX_plot, force_time, force_x);
% forceZ_plot = subplot(2, 1, 2);
% plot(forceZ_plot, force_time, force_z);

clear file_forces, force_path, forceX_plot, forceZ_plot;

%% OCT
file_oct = '/oct/p1m1.bin';
file_timestamp = '/oct/p1m1.bin__timestamp.txt';
oct_path = strcat(folder_path, file_oct);
timestamp_path = strcat(folder_path, file_timestamp);
oct_time = dlmread(timestamp_path);
oct = fopen(oct_path);
oct_data = fread(oct_path);
