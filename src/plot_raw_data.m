% plots the data asks for the start and end time of the data
% saves it in Timestamps.txt

%% Read data

data_path = '../data';
material_path = '/metal'; % {/metal /phantoms /train}
name = '/metal_stepwise_8'; % metal:     {/metal_linear_ (2 to 14) /metal_stepwise_ (1 to 15) /test}
                       % phantoms:  {p (1 to 3) m (1 to 3)

force_path = strcat(data_path, material_path, '/forces', name, '.txt');
force_data = dlmread(force_path);
force_time = force_data(:,1);
force_data = force_data(:,4);

oct_path = strcat(data_path, material_path, '/oct', name, '.bin');

oct_file_id = fopen(oct_path);
oct_data = fread(oct_file_id, [512, inf], 'float');

%% Plot data

figure;
subplot(2,1,1);
plot(force_data);
title(strcat(name), 'Interpreter', 'none');

subplot(2,1,2);
image(oct_data);
hold on;
[~, oct_locs] = max(oct_data);
