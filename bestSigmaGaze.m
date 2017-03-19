%function bestSigmaGaze

clear all;
close all
clc

addpath(strcat(pwd,'\scr-matlab'))
addpath(strcat(pwd,'\scr-matlab\shuffled-AUC'))
 %C = nchoosek(v,4);
names={
    'bus'
    'city'
    'crew'
    'flower'
    'foreman'
    'hall'
    'harbour'
    'mobile'
    'mother'
    'soccer'
    'stefan'
    'tempete'
    };
videoNumber = 1;
iFrame = 50;
gaussSigma = 0 : 10 : 100;
gaussSigma(1) = 0.5;
aucVal = length(gaussSigma);
videoInfo.file.directory = '.\database';
videoInfo.file.fullname = strcat(names{videoNumber},'.mat');
load(fullfile(videoInfo.file.directory, videoInfo.file.fullname));
videoInfo.data=vid;
videoInfo.Frames.Number=length(videoInfo.data);
s = regexp(videoInfo.file.fullname,'(?<name>(\w+-*\w*))\.(?<extension>\w+)','names');
videoInfo.file.name = s.name;
videoInfo.file.extension = s.extension;
imSize=size(vid{1});
%aucVal = zeros(videoInfo.Frames.Number-videoInfo.Frames.Start,1);
fileNameMask = strcat('CSV/',videoInfo.file.name,'-mask.csv');
fileNameScreen = strcat('CSV/',videoInfo.file.name,'-Screen.csv');
% Read the gaze locations from the input CSV file
if exist(fileNameScreen,'file')
    [GazeLocations, ~] = xlsread(fileNameScreen);
    GazeLocations = round(GazeLocations);
else
    disp 'Error! Input gaze location CSV file not found!'
end
% Load the relevant flag matrix from the file (Mask)
if exist(fileNameMask,'file')
    [FlagMatrix, ~] = xlsread(fileNameMask);
else
    disp 'Error! Input mask CSV file not found!'
end

shufMap = points2SaliencyMapConv(...
        [GazeLocations(:,1:2:end)',GazeLocations(:,2:2:end)'], ...
        imSize(1), imSize(2), 0, ...
        [FlagMatrix(:,1:2:end)',FlagMatrix(:,2:2:end)']);

M = 1:2:60;
Num = 5;
for i = 1 : Num
    C = randperm(30)*2-1;
    setPoints1 = C(1:15);
    setPoints2 = C(16:30);
    gaussFilterTemp = 0;
    
    pointMap = points2SaliencyMapConv(...
        [GazeLocations(iFrame,C)',GazeLocations(iFrame,C+1)'], ...
        imSize(1), imSize(2), gaussFilterTemp, ...
            [FlagMatrix(iFrame,C)',FlagMatrix(iFrame,C+1)']);
    
    pointMap1 = points2SaliencyMapConv(...
        [GazeLocations(iFrame,setPoints1)',GazeLocations(iFrame,setPoints1+1)'], ...
        imSize(1), imSize(2), gaussFilterTemp, ...
            [FlagMatrix(iFrame,setPoints1)',FlagMatrix(iFrame,setPoints1+1)']);
        
    pointMap2 = points2SaliencyMapConv(...
        [GazeLocations(iFrame,setPoints2)',GazeLocations(iFrame,setPoints2+1)'], ...
        imSize(1), imSize(2), gaussFilterTemp, ...
            [FlagMatrix(iFrame,setPoints2)',FlagMatrix(iFrame,setPoints2+1)']);
    j = 1;
    fprintf('step = %d\n', i);
    
    gazeMap2 = pointMap2;
    
    for sigmaValue = gaussSigma  
        gaussFilterTemp = myGaussDistribution(sigmaValue);
        gazeMap1 = conv2( pointMap1 , gaussFilterTemp , 'same' );
        gazeMap1 = gazeMap1 ./ max(gazeMap1(:));
        %gazeMap2 = conv2( pointMap2 , gaussFilterTemp , 'same' );
        %gazeMap2 = gazeMap2 ./ max(gazeMap2(:));
        %salMap(salMap < 0.5)=0;
        %humanGazeMap(humanGazeMap < 0.5)=0;
        %aucVal(i) = rocSal(humanGazeMap ./ max(humanGazeMap(:)),salMap ./ max(salMap(:)));
        %aucVal(i,j) = rocSal(gazeMap1, gazeMap2);
        %aucVal(i,j) = accuracyMetric(gazeMap1, gazeMap2, 0.01);
        %aucVal(i,j) = calcAUCscore(gazeMap1, gazeMap2);
        %aucVal(i,j) = myMapCompa   rator(gazeMap1, gazeMap2);
        %aucVal(i,j) = myMapComparatorAVER(gazeMap1, gazeMap2);
        %aucVal(i,j) = myMapComparatorSUM(gazeMap1, gazeMap2);  
        
        aucVal(i,j) = calcAUCscore(gazeMap1, gazeMap2,shufMap);
        %subplot(2,length(gaussSigma),i),imshow(humanGazeMap);
        %subplot(2,length(gaussSigma),length(gaussSigma)+i),imshow(salMap);
        %xlabel(strcat('\sigma = ', num2str(sigmaValue)));
        %subplot(1,2,1),imshow(gazeMap1);
        %subplot(1,2,2),imshow(gazeMap2);
        %xlabel(strcat('\sigma = ', num2str(sigmaValue)));
        j=j+1;
    end
end
%figure, plot (gaussSigma,aucVal,'LineWidth', 1);
av = sum(aucVal)/Num;