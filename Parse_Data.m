%% Path to data

folder_path = '';
%% FORCES

% Get data
f_path = strcat(folder_path, 'forces/p1m1.txt');
f_data = dlmread(f_path);
f_time = f_data(:,1) - f_data(1,1);     % offset removed
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
                       
% Plots
figure;
f_x_plot = subplot(3,1,1);
plot(f_x_plot, f_time, f_x);
title('Force Sensor Data');
xlabel('Time');
ylabel('Force X');

f_z_plot = subplot(3, 1, 2);
plot(f_z_plot, f_time, f_z);
xlabel('Time');
ylabel('Force Z');

clear file_forces, f_path;

%% OCT

o_path = strcat(folder_path, 'oct/p1m1.bin');
o_time_path = strcat(folder_path, 'oct/p1m1_timestamp.txt');
file_id = fopen(o_path);
o_data = fread(file_id, [512, 108900], 'float');
o_time = dlmread(o_time_path);
o_time = o_time - o_time(1);            % remove offset

% Plot of maximal values
[o_pks, o_locs] = max(o_data);
o_locs_smooth = smooth(o_locs);
o_max_plot = subplot(3, 1, 3);
plot(o_locs_smooth);
axis([0 12*10^4 50 150]);
xlabel('Time');
ylabel('OCT Depth');

%% COMPARE BOTH DATA

% Image 
figure;
subplot(2,1,1);
plot(f_time, f_z);
subplot(2,1,2);
image(o_data);
hold on;
plot(o_locs_smooth, '.r');
axis([0 12*10^4 50 150]);

% OCT variance to define when noise gets larger 
% Hoping that this is the point, where the needle touches the gelatine
o_size = size(o_data);
for j=1:o_size(2)
    o_var(j) = var(o_data(:,j));
end

% Force time of touch must be calculated by the change of value 
% This would be the cut off after manual movement in x-direction