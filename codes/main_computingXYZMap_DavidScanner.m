clear all
close all
clc

% Mathias Gallardo 2017
% mathiasgallardo@gmail.com

%% Addpath
% error('Add the utilsmatlab-new of Toby Collins, where there is z_bufferMesh');
% error('Before running this code, remove, in all .mtl, all the newmaterial (newmtl) where map_Kd is not defined. Usually, this comes from holes filling.');
addpath(genpath('toolboxes/ZBufferRender_new/'));
addpath(genpath('toolboxes/ba_interpolation/')); % make sure to compile the ba_interp2.cpp file using the command 'mex -O ba_interp2.cpp'

%% Description
% The idea is to load the mesh and to render the XYZ map of the
% ground-truth shapeacquired by the David 3D Scanner system.

%% Data paths
paths.rawData = './data/rawData/scans/'; % where are the scans (.obj, .mtl, and .png)
paths.camData = './data/rawData/camera/';% where is 'camera.xml'
paths.gtShapeData = './data/gtShapeData/';

%% Params
% name of the scans
image.prefix = 'Scan_';
image.suffix = '';
image.formatRaw = 'png';

% parameters to render the scene
light = []; % not specifying a light model
options_depth.srcFrame = 'world';
options_depth.shadingMethod='flat';
options_depth.propertyMaps = {'depth'};

%%
% Extracting the intrinsic parameters
camera = readDavidScannerCamFile([paths.camData 'camera.xml']);
K = camera.params.K;
save([paths.camData 'K.mat'],'K');
disp(['K matrix saved in the folder ' paths.camData ]);

% Listing the scans 
nfiles = dir([paths.rawData image.prefix '*' image.suffix '.' image.formatRaw]);

for i = 1:length(nfiles)
    filename = [paths.rawData nfiles(i).name(1:end-4)];

    filename_depth = filename;
    disp(['Depth : Reading ' filename_depth]);
    Msh = read3dMesh([filename_depth '.obj']);

    [imOut,msk,~,ptsPix,~,pMaps] = z_bufferMesh(camera,Msh,light,options_depth);

    [XX,YY] = meshgrid([1:size(pMaps{1}.map,2)],[1:size(pMaps{1}.map,1)]);

    px = [XX(:),YY(:)]';
    px(3,:) = 1;
    px_n = inv(K)*px;
    XMmp = zeros(size(pMaps{1}.map));
    YMmp = zeros(size(pMaps{1}.map));
    ZMmp = zeros(size(pMaps{1}.map));
    XMmp(:) = px_n(1,:);
    YMmp(:) = px_n(2,:);
    ZMmp(:) = 1;
    XYZMap = cat(3,XMmp.*pMaps{1}.map,YMmp.*pMaps{1}.map,ZMmp.*pMaps{1}.map); 

    ptsPix = ptsPix';

    % Display
    XMap = XYZMap(:,:,1); 
    YMap = XYZMap(:,:,2); 
    ZMap = XYZMap(:,:,3); 
    
    Q(1,:) = XMap(:);
    Q(2,:) = YMap(:);
    Q(3,:) = ZMap(:);
    

    figure(i+200);
    clf;
    plot3(Q(1,:),Q(2,:),Q(3,:),'r.');
    axis equal;
    title(['3D shape of view ' nfiles(i).name(1:end-4)]);

    figure(i+250);
    clf;
    subplot(221);
    imshow(imOut);
    hold on;
    plot(ptsPix(1,:),ptsPix(2,:),'r+');
    hold off;
    title('Reprojection of the vertices');
    axis equal;
    subplot(222);
    imagesc(XYZMap(:,:,1));
    title('X map');
    axis equal;
    subplot(223);
    imagesc(XYZMap(:,:,2));
    title('Y map');
    axis equal;
    subplot(224);
    imagesc(XYZMap(:,:,3));
    title('Z map');
    axis equal;

    % Saving 
    nameScan = nfiles(i).name(1:end-4);
    save([paths.gtShapeData nfiles(i).name(1:end-4) '.mat'], 'XYZMap', 'nameScan');

    disp(['3D shape of view ' nfiles(i).name(1:end-4) ' saved!']);
end
