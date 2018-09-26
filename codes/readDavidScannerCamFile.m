function camera = readDavidScannerCamFile(fin)
% This function read the camera parameters (intrinsics and extrinsics) from the calibration file created by David 3D software after the camera calibration
% INPUT
% fin: the path to the camera calibration file (usually 'camera.xml')
% OUTPUT:
% camera: a structure that contains all useful camera parameters


% Mathias Gallardo 2017
% mathiasgallardo@gmail.com

fid = fopen(fin);
K = eye(3);
R = zeros(3,3);
t = zeros(3,1);
tline = fgetl(fid);
while ischar(tline)
    %disp(tline)
    tline = fgetl(fid);
	
	% Intrinsic matrix
    if strfind(tline, '<cx>')           % x-coordinate of the center point
        K(1,3) = getNum(tline);
    end
    if strfind(tline, '<cy>')           % y-coordinate of the center point
        K(2,3) = getNum(tline);
    end
    if strfind(tline, '<f>')            % focal length
        K(2,2) = getNum(tline);
    end
    if strfind(tline, '<sx>')           % skew
        K(1,1) = getNum(tline)* K(2,2);
    end
    
    if strfind(tline, '<kappa1>')
        kappa1 = getNum(tline);
    end
    
	% Rotation matrix
    if strfind(tline, '<nx>')
        R(1,1) = getNum(tline);
    end
    if strfind(tline, '<ny>')
        R(2,1) = getNum(tline);
    end
    if strfind(tline, '<nz>')
        R(3,1) = getNum(tline);
    end
    
    if strfind(tline, '<ox>')
        R(1,2) = getNum(tline);
    end
    if strfind(tline, '<oy>')
        R(2,2) = getNum(tline);
    end
    if strfind(tline, '<oz>')
        R(3,2) = getNum(tline);
    end
    
    if strfind(tline, '<ax>')
        R(1,3) = getNum(tline);
    end
    if strfind(tline, '<ay>')
        R(2,3) = getNum(tline);
    end
    if strfind(tline, '<az>')
        R(3,3) = getNum(tline);
    end
    
	% Translation vector 
    if strfind(tline, '<px>')
        t(1) = getNum(tline);
    end
    if strfind(tline, '<py>')
        t(2) = getNum(tline);
    end
    if strfind(tline, '<pz>')          
        t(3) = getNum(tline);
    end
    
    
    if strfind(tline, '<resX>')         % resolution along x-axis
        resx = getNum(tline);
    end
    if strfind(tline, '<resY>')         % resolution along y-axis
        resy = getNum(tline);
    end
   
    
end

fclose(fid);
M = [R,t];
M(4,4) = 1;
Minv = inv(M);

% the David 3D Scanner gives the position and the orientation of the camera
% in the world coordinates frame

R_world2Cam = Minv(1:3,1:3);
t_world2Cam = Minv(1:3,end);


% Intrinsics
camera.params.K = K; 

% Extrinsics
camera.params.R = R_world2Cam;
camera.params.T = t_world2Cam;
camera.params.kappa1 = kappa1;

camera.type = 'perspective';
camera.model = 'Tsai';
camera.pixelResH = resy;
camera.pixelResW = resx;

function n = getNum(tline)
f1 = strfind(tline,'>');
f2 = strfind(tline,'<');
s = tline(f1(1)+1:f2(2)-1);
n = str2num(s);
