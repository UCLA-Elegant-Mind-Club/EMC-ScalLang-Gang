%% Data Analysis Script for Eye Tracking Protocol Data
% #sponsored by Mark and Daniel (special thanks to Caominh and Brian)
close all; clear all; clc;

%% Declaring Variables
% monitor dimensions
width_px = 4096;
height_px = 2160;

%participant distance
dist_cm = 121;

% face height in degrees
face = 8;

% frame rate in hz
frameRate = 90;

% axis label step size for x-y plot
step = 2;

% overlay image
% see plotIndex function at bottom for indexing info of plotData
imgs = [imread('121cm F1.png'), imread('121cm F2.png'), imread('121cm F3.png'), imread('121cm demo.png')];
clear plotData;
plotData(length(imgs)).eyeTrackingLines = [];

%% test

imgs = [imread('121cm F1 1.41deg.png'), imread('121cm F2 1.41deg.png')];

%% Loading and Processing Data from Files

% Import and reformat raw eye-tracking data from txt file
[file, folder] = uigetfile('*.txt');
eyeData = readtable(fullfile(folder, file));
eyeData = eyeData(any(ismissing(eyeData)), :); % Remove NaN rows
eyeTime = eyeData{:,2} / frameRate * 1000; % (arbitrary) CPU 'time'
eyeX = atand((eyeData{:,3} - width_px/2) / dist_cm); %x and y coords are now in angles of eccen
eyeY = atand((eyeData{:,4} - height_px/2) / dist_cm);

% Import and reformat RT data from csv file
[file, folder] = uigetfile('*.csv');
RTData = table2array(readtable(fullfile(folder, file)));
breakPoints = RTData(:,5) / frameRate * 1000 + timeDelay; %finds (arbitrary) CPU 'time' when face appears
endPoints = breakPoints + RTData(:,3); %finds (arbitrary) 'time' when response
targets = RTData(:,4);
heights = RTData(:,2);

%% Processing
eyeTrackingIndex = 1;
for trial = 1:height(breakPoints)
    if RTData(trial,1) == 0; continue; end %skips incorrect trials
    while eyeTrackingIndex < breakPoints(trial)
        eyeTrackingIndex = eyeTrackingIndex + 1;
    end
    start = eyeTrackingIndex;
    while eyeTrackingIndex < endPoints(trial)
        eyeTrackingIndex = eyeTrackingIndex + 1;
    end
    index = plotIndex(targets(trial), heights(trial));
    plotData(index).eyeTrackingLines = [plotData(index).eyeTrackingLines; [start, eyeTrackingIndex - 1]];
end

%% Plotting
for i = 1:length(plotData)
    plotXY(eyeX, eyeY, plotData(i));
end

function index = plotIndex(target, size)
    targetIndex = find([1, 2, 3, -1] == target);
    sizeIndex = find([1,1.3,2] == size);
    index = targetIndex * 11 + sizeIndex - 11;
end

function plotXY(eyeX, eyeY, lines, target, size, showLines)
    if nargin < 6; showLines = false; end
    index = plotIndex(target, size);
    figure(index * 10);
    title("X-Y Plot for Target " + target + " (size = " + size + ")");
    xlabel("Horizontal Eccentricity (degrees)");
    ylabel("Vertical Eccentricity (degrees)");
    imshow(imgs(index));
    set(gca, 'color', 'none', 'box','off');
    set(gca, 'YDir','reverse')
    axis on;
    
    hold on
    for i = 1:height(lines)
        range = lines(i,1):lines(i,2);
        if showLines; plot(eyeX(range), eyeY(range), "LineWidth", 2, "Marker", '.', "MarkerSize", 20);
        else; scatter(eyeX(range), eyeY(range), 30, "Marker", '.'); end
    end
    axis([-face/2 face/2 -face/2 face/2]);
end

function plotXTime(eyeX, eyeTime, lines, target, size)
    index = plotIndex(target, size);
    figure(index * 10 + 1);
    title("X-Time Plot for Target " + target + " (size = " + size + ")");
    xlabel("Time (ms)");
    ylabel("Horizontal Eccentricity (degrees)");
    
    hold on;
    for i = 1:height(lines)
        range = lines(i,1):lines(i,2);
        plot(eyeTime(range), eyeX(range));
    end
    xlim([0, inf]) % Automatically rescales x-axis: Time, in ms
    ylim([-30, 30])
end

function plotYTime(eyeY, eyeTime, lines, target, size)
    index = plotIndex(target, size);
    figure(plotIndex * 10 + 2)
    title("Y-Time Plot for Target " + target + " (size = " + size + ")");
    xlabel("Time (ms)")
    ylabel("Vertical Eccentricity (degrees)")
    set(gca, 'YDir','reverse')
    
    hold on
    for i = 1:height(lines)
        range = lines(i,1):lines(i,2);
        plot(eyeTime(range), eyeY(range));
    end
    
    xlim([0, inf]) % Automatically rescales x-axis: Time, in ms
    ylim([-20, 20])
end
