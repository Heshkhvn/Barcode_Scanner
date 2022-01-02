clc
close all
clear

% Import data csv file
filename = 'SampleDataK.csv';
M = csvread(filename, 360); % Read the csv file starting from row 360

% Save the colour data
Colour = M(:, 3);

% Import the Lookup table
LookupTable = readtable('LookupTable.xlsx');
Characters = table2array(LookupTable(:,1));
LookupWidth = table2array(LookupTable(1:end,2:end));


% LPF using moving average (sliding window)
ws = 15;
for i=1:length(Colour)-(ws-1)
    ColourAvg(i) = sum(Colour(i:i+(ws-1)))/ws;
end


% Calculate the difference (slope) to find edges
for i=1:length(ColourAvg)-1
    ColourDer(i) = abs(ColourAvg(i+1)-ColourAvg(i));
end


% Find peaks
[pks,locs] = findpeaks(ColourDer,'MinPeakDistance',50,'MinPeakHeight',0.5);

% Find the width between peaks
for i=1:length(locs)-1
    widths(i) = locs(i+1)-locs(i);
    RegionXMidPoint(i) = round((locs(i+1)+locs(i))/2);
end

% Scale the width found
widths_scaled = round(widths / min(widths))


Colour_Threshold = mean(ColourAvg(RegionXMidPoint));

% Serch for the matched data from lookup table and print the correspond
% letter
for i=1:length(Characters)
    if LookupWidth(i,:) == widths_scaled
        fprintf('The letter correspond to the barcode is %c\n', char(Characters(i,1)))
    end
end


% Plot the colour data
subplot(3,1,1)
plot(Colour)
title('Barcode Digital Signal Processing', 'FontSize', 13)

% Plot the modified colour data
subplot(3,1,2)
plot(ColourAvg, 'r')
hold on
plot(RegionXMidPoint,ColourAvg(RegionXMidPoint),'ob','LineWidth',3)
hold on
ThresholdLine = 0 .* ColourAvg + Colour_Threshold;
plot(ThresholdLine,'--k', 'LineWidth',1)

% Plot the peak data
subplot(3,1,3)
plot(ColourDer, 'm')
hold on
plot(locs,pks,'ko')
hold on
plot(RegionXMidPoint,zeros(1,length(RegionXMidPoint)),'^k','LineWidth',4)
