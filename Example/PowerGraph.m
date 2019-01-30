%% Demo with xml2struct to read TCX files and compare power measurements.
clear all;
close all;
clc;
addpath(genpath('../Toolboxes/'));

%% Define Inputs
inputP1 = 'Roblemondo_PowertapP1_2019-01-29.tcx';
inputSL = 'Roblemondo_PowertapSL_2019-01-29.tcx';
inputRouvy = 'Roblemondo_Rouvy_2019-01-29.tcx';
inputTacx = 'Roblemondo_Tacx_2019-01-29.tcx';

%% Load and parse PowertapSL
tic
fprintf('Parsing: %s\n', inputP1);
powertapP1_struct = xml2struct(inputP1);
[powertapP1_watts,powertapP1_dt] = parseTCX(powertapP1_struct);
toc
%% Load and parse Tacx
tic
fprintf('Parsing: %s\n', inputTacx);
tacx = xml2struct(inputTacx);
[tacx_watts,tacx_dt] = parseTCX(tacx);
toc
%% Load and parse PowertapP1
tic
fprintf('Parsing: %s\n', inputSL);
powertapSL_struct = xml2struct(inputSL);
[powertapSL_watts,powertapSL_dt] = parseTCX(powertapSL_struct);
toc
%% Load and parse PowertapP1
tic
fprintf('Parsing: %s\n', inputRouvy);
rouvy_struct = xml2struct(inputRouvy);
[rouvy_watts,rouvy_dt] = parseTCX(rouvy_struct);
toc
%% Create TimeTable
TTtacx = timetable(tacx_dt',tacx_watts');
TTpowertapSL = timetable(powertapSL_dt',powertapSL_watts');
TTpowertapP1 = timetable(powertapP1_dt',powertapP1_watts');
TTrouvy = timetable(rouvy_dt',rouvy_watts');

% Synchronize two timestables and fill in missing data using linear interpolation
%TT = synchronize(TTpowertapSL,TTpowertapP1,TTtacx,TTrouvy,'union','linear');
TT = synchronize(TTpowertapSL,TTpowertapP1,TTtacx,TTrouvy,'commonrange','linear');
% Eliminate absolute date and time.
timeOffset = TT.Time(1); TT.Time = TT.Time - timeOffset;
%% Plot time stamped comparison
% Define moving average
movingmean=3;

% Statistics
mean_powertap = mean(powertapP1_watts);
mean_tacx = mean(tacx_watts);
delta = mean_tacx - mean_powertap;

%close (fig1);
scrsz = get(groot,'ScreenSize');
fig1=figure('Position',[100 100 scrsz(3)/1.2 scrsz(4)/1.3], ...
    'Name','Power Plot Window','NumberTitle','off');
subp1=subplot(3,1,[1 2]);
plot (TT.Time,movmean(TT.Var1_TTtacx,movingmean));
hold on;
plot (TT.Time,movmean(TT.Var1_TTpowertapSL,movingmean));
plot (TT.Time,movmean(TT.Var1_TTpowertapP1,movingmean));
plot (TT.Time,movmean(TT.Var1_TTrouvy,movingmean));
legend('Tacx','PowertapSL+','PowertapP1','Rouvy');
grid on;
hold off;
xlabel('Time [hh:mm:ss]'); % x-axis label
ylabel('Power [Watt]'); % y-axis label
%ylim(gca,[0 550]);
xlim(gca,[TT.Time(1), TT.Time(length(TT.Time))]);
title(strcat('Power Measurements Comparison - Tacx Smart Trainer vs Powertap (Moving Mean:', num2str(movingmean), ')'));

% Annotation
dim = [.2 .3 .1 .6];
anno = ({strcat('Mean Tacx: ', 32,  num2str(mean_tacx,4), 'W'),...
    strcat('Mean Powertap: ', 32,  num2str(mean_powertap,4), 'W'),...
    strcat('\Delta Mean: ', 32,  num2str(abs(delta),4), 'W')});
annotation('textbox',dim,'String',anno,'FitBoxToText','on');

% Plot delta
subplot(3,1,3);
plot (TT.Time,movmean((TT.Var1_TTtacx-TT.Var1_TTpowertapP1),movingmean));
hold on;
plot (TT.Time,movmean((TT.Var1_TTrouvy-TT.Var1_TTpowertapP1),movingmean));
grid on;
hold off;
legend('Tacx-P1','Rouvy-P1');
xlabel('Time [hh:mm:ss]'); % x-axis label
ylabel('\Delta Power [Watt]'); % y-axis label
ylim(gca,[-50, 100]);
xlim(gca,[TT.Time(1), TT.Time(length(TT.Time))]);
%title('Delta');

%% Write plot to file
print(strcat('Powergraph_AVR',num2str(movingmean)),'-dpng')