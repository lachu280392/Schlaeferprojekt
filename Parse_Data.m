%% Path to data

folder_path = '';
file = 'p1m1';

%% Read data

if exist('f_path','var')
    new_file = contains(f_path, file) == 0;
else 
    new_file = 1;
end

if new_file
    disp(strcat('new file: ', file));
    % Force
    f_path = strcat(folder_path, 'forces/', file, '.txt');
    f_data = dlmread(f_path);
    f_time = f_data(:,1) - f_data(1,1);     % offset removed
    f_z = f_data(:, 4);
    f_x = f_data(:, 2);

    % OCT
    o_path = strcat(folder_path, 'oct/', file, '.bin');
    o_time_path = strcat(folder_path, 'oct/', file, '_timestamp.txt');
    file_id = fopen(o_path);
    o_data = fread(file_id, [512, 108900], 'float');
    o_time = dlmread(o_time_path);
end

%% Tidy up data

% Forces

% Remove offset
f_x = f_x - mean(f_x);
% Find value, location, and width of peaks
%[f_pks, f_locs, f_wds] = findpeaks(f_x,...
%                             'MinPeakHeight', 0.5,...
%                             'MinPeakDistance', 100);

% Time real measurement starts
%f_start = f_locs(end) + f_wds(end)/2;

% OCT

% Remove offset
o_time = o_time - o_time(1);
% Maximal values
[o_pks, o_locs] = max(o_data);
o_locs_smooth = smooth(o_locs);
axis_max = o_locs(1) + 70;
axis_min = o_locs(1) - 70;

%% PLOT 1

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

o_max_plot = subplot(3, 1, 3);
plot(o_locs_smooth);
axis([0 12*10^4 axis_min axis_max]);
xlabel('Time');
ylabel('OCT Depth');

%% PLOT 2

% Flip 
[~, o_locs_flip] = max(flipud(o_data));
axis_max_flip = o_locs_flip(1) + 70;
axis_min_flip = o_locs_flip(1) - 70;

figure;

subplot(2,1,1);
plot(f_time, f_z);
xlabel('Time');
ylabel('Force Z');
title('Force Sensor');

subplot(2,1,2);
image(o_data_flip);
hold on;
plot(smooth(o_locs_flip), '.r');
axis([0 12*10^4 axis_min_flip axis_max_flip]);
xlabel('Time');
ylabel('Intensity');
title('OCT');

clear o_pks_flip o_locs_flip axis_max_flip axis_min_flip;
