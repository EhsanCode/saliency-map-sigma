function salMap = points2SaliencyMapConv(pointLocations, H, W, gaussFilterTemp, flagMatrix)

if nargin <= 2
    disp 'Not enough input arguments! Please read the help.';
end

mapSize = size(pointLocations);
noPoints = fix(mapSize(1)*mapSize(2)/2);
pointLocations = reshape(pointLocations,noPoints,2);

if nargin ==5
    flagMatrix = reshape(flagMatrix,noPoints,2);
    pointLocations = pointLocations(flagMatrix(:,1).*flagMatrix(:,2)==1,:);
end

if nargin <=3
    gaussFilterTemp = 0;
end

pointLocations=pointLocations(pointLocations(:,1)>=1,:);
pointLocations=pointLocations(pointLocations(:,1)<=W,:);
pointLocations=pointLocations(pointLocations(:,2)>=1,:);
pointLocations=pointLocations(pointLocations(:,2)<=H,:);
    
% Generate the heatmap of the current frame using subjects' gaze locations
salMap = zeros(H,W);
salMap((pointLocations(:,1)-1)*H+pointLocations(:,2))=1;

%salMap = myconv2(myconv2( salMap , k ),k');
if gaussFilterTemp ~= 0
    salMap = conv2( salMap , gaussFilterTemp , 'same' );
    salMap = salMap ./ max(salMap(:));
end
%salMap = mat2gray(salMap);