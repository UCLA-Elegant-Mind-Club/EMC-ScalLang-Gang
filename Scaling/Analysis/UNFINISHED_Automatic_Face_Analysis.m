%% Data Analysis Script for Eye Tracking Protocol Data
% #sponsored by Mark and Daniel (special thanks to Caominh and Brian)
close all; clear all; clc;

%% Declaring Variables
% monitor dimensions
width_px = 4096;
height_px = 2160;

width_cm = 121;
height_cm = 68;

%participant distance
dist_cm = 121;

% face height in degrees
face = 8;

% time delay in ms
timeDelay = 109;

% frame rate in hz
frameRate = 90;

% axis label step size for x-y plot
step = 2;

% overlay image
% see imgIndex function at bottom for indexing info of plotData
imgs = [imread('121cm F1.png'), imread('121cm F2.png'), imread('121cm F3.png'), imread('121cm demo.png')];
clear plotData;
plotData(length(imgs)).eyeTrackingLines = [];


%% Conversion Factors
x_deg2px = dist_cm*tand(1) * width_px / width_cm;
y_deg2px = dist_cm*tand(1) * height_px / height_cm;

%% Loading and Processing Data from Files

% Import and reformat raw eye-tracking data from txt file
[file, folder] = uigetfile('*.txt');
eyeData = readtable(fullfile(folder, file));
eyeData = eyeData(any(ismissing(eyeData)), :); % Remove NaN rows
eyeTime = eyeData{:,2};
eyeX = atand((eyeData{:,3} - width_px/2) / dist_cm); %x and y coords are now in angles of eccen
eyeY = atand((eyeData{:,4} - height_px/2) / dist_cm);

% Import and reformat RT data from csv file
[file, folder] = uigetfile('*.csv');
RTData = table2array(readtable(fullfile(folder, file)));
breakPoints = RTData(:,5) + timeDelay / 1000 * frameRate; %finds specific CPU Uptimes when face appears
endPoints = breakPoints + RTData(:,4) / 1000 * frameRate; %finds specific CPU Uptimes when response
targets = RTData(:,2);
heights = RTData(:,3);

%% Processing
eyeTrackingIndex = 1;
for trial = 1:height(breakPoints)
    if RTData(:,1) == 0; continue; end %skips incorrect trials
    while eyeTrackingIndex < breakPoints(trial)
        eyeTrackingIndex = eyeTrackingIndex + 1;
    end
    start = eyeTrackingIndex;
    while eyeTrackingIndex < endPoints(trial)
        eyeTrackingIndex = eyeTrackingIndex + 1;
    end
    index = imgIndex(targets(trial), heights(trial));
    plotData(index).eyeTrackingLines = [plotData(index).eyeTrackingLines; [start, eyeTrackingIndex - 1]];
end

%% Plotting

%figure 1: X-time


%figure 2: X-Y
    figure(2)
    imshow(imgs);
    hold on
%comment out EITHER plot(...) or scatter(...) to include lines or not between points
    %plot(EyeTracking_X(1:max(closestIndex2),i), EyeTracking_Y(1:max(closestIndex2),i), "LineWidth", 2, "Marker", '.', "MarkerSize", 20)
    scatter(EyeTracking_X(1:max(closestIndex2),i), EyeTracking_Y(1:max(closestIndex2),i), 30, "Marker", '.')
    title("X-Y Plot")
    set(gca, 'YDir','reverse')
    xlabel("Horizontal Eccentricity (degrees)")
    ylabel("Vertical Eccentricity (degrees)")
    axis([((width_px/2) - ((face/2)*x_deg2px)) ((width_px/2) + ((face/2)*x_deg2px)) ...
        ((height_px/2) - ((face/2)*y_deg2px)) ((height_px/2) + ((face/2)*y_deg2px))]) % For X_Y Plot
    xticks([((width_px/2) - ((face/2)*x_deg2px)): (step*x_deg2px): ((width_px/2) + ((face/2)*x_deg2px))])
    xticklabels([-(face/2): step: (face/2)])
    yticks([((height_px/2) - ((face/2)*y_deg2px)): (step*y_deg2px): ((height_px/2) + ((face/2)*y_deg2px))])
    yticklabels([-(face/2): step: (face/2)])
    axis on
    set(gca, 'color', 'none', 'box','off');
    hold off
%figure 3: Y-time
    figure(3)
    hold on
    plot(EyeTracking_Time(:,i), EyeTracking_Y(:,i))
    set(gca, 'YDir','reverse')
    title("Y-Time Plot")
    xlabel("Time (s)")
    ylabel("Vertical Distance (degrees)")
    xlim([0,maxReadingLines]) % Time, in s
    ylim([((height_px/2) - (20*y_deg2px)), ((height_px/2) + (20*y_deg2px))])
    xticks([0, 1000, 2000, 3000, 4000, 5000,6000,7000,8000,9000,10000])
    xticklabels([0, 1, 2, 3, 4, 5,6,7,8,9,10])
    yticks([((height_px/2) - (20*y_deg2px)), ((height_px/2) - (10*y_deg2px)), ...
        (height_px/2), ...
        ((height_px/2) + (10*y_deg2px)), ((height_px/2) + (20*y_deg2px))])
    yticklabels([-20,-10,0,10,20])

function index = imgIndex(target, size)
    
end

function plotXTime(eyeX, time, lines, target, height)
    index = imgIndex(target, height);
    figure(index);
    hold on
    for i = 1:height(lines)
        start
        plot(time, x)
    end
    title("X-Time Plot for Target " + target);
    xlabel("Time (ms)")
    ylabel("Horizontal Distance (degrees)")
    xlim([0,maxReadingLines]) % Time, in s
    ylim([((width_px/2) - (30*x_deg2px)), ((width_px/2) + (30*x_deg2px))])
    xticks([0,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000])
    xticklabels([0,1,2,3,4,5,6,7,8,9,10])
    yticks([((width_px/2) - (30*x_deg2px)),((width_px/2) - (20*x_deg2px)),((width_px/2) - (10*x_deg2px)), ...
        (width_px/2), ...
        ((width_px/2) + (10*x_deg2px)),((width_px/2) + (20*x_deg2px)),((width_px/2) + (30*x_deg2px))])
    yticklabels([-30,-20,-10,0,10,20,30])
    hold off
