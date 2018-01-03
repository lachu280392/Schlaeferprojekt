%% Path to data

folder_path = '';
%% FORCES

% Get data
f_path = strcat(folder_path, 'forces/p1m1.txt');
f_data = dlmread(f_path);
f_time = f_data(:,1);
f_z = f_data(:, 4);
f_x = f_data(:, 2);

% Remove offset
f_x = f_x - mean(f_x);

% Find value, location, and width of peaks
[f_pks, f_locs, f_wds] = findpeaks(f_x,...
                            'MinPeakHeight', 0.5,...
                            'MinPeakDistance', 100);

% Time real measurement starts
f_start = f_locs(end) + f_wds(end)/2;
figure;
plot(f_data(f_start:end,2));
                       
% PLOTS
figure;
forceX_plot = subplot(3,1,1);
plot(forceX_plot, f_time, f_x);
title('Force Sensor Data');
xlabel('Time');
ylabel('Force X');

forceZ_plot = subplot(3, 1, 2);
plot(forceZ_plot, f_time, f_z);
xlabel('Time');
ylabel('Force Z');
clear forceX_plot, forceZ_plot;

clear file_forces, f_path;

%% OCT

o_path = strcat(folder_path, 'oct/p1m1.bin');
o_time_path = strcat(folder_path, 'oct/p1m1_timestamp.txt');
file_id = fopen(o_path);
o_data = fread(file_id, [512, 108900], 'float');
o_time = dlmread(o_time_path);

o_plot = subplot(3, 1, 3);
plot(o_plot, o_data);
