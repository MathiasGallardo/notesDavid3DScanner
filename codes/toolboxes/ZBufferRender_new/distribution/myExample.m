%function my_example
%renderSpinningBox - an example of how to render a 3d surface with time
%varying vertex positions, and changing the texture map.

% Author: Toby Collins
% Work address
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

main_vertex_id=repmat([224 50 100 150 200 250],1,3);
force=[0.5*ones(1,6) 0.25*ones(1,6) 0.75*ones(1,6)];

for deformation=0%1:length(main_vertex_id)


Msh = read3dMesh('../template_uterus/templateMash_500.obj');
Msh.texMap.img = imread('../template_uterus/templateModel.tif');


if deformation ~= 0
    options.CG_shift = 0.5;
    %orientation of the deforming force
    options.orientation = [];
    %id of the vertex to push or pull
    options.main_vertex_id = main_vertex_id(deformation);%224;
    % -1 for push and +1 for pull
    options.push_pull = -1;

    % Force for push/pull
    options.force = force(deformation);
    [vertex_def, t, ang] = basic_extensible_deform_mesh(Msh.faces, Msh.vertexPos, options);
    Msh.vertexPos=vertex_def;
end

camOp = struct;
camOp.res = [700,700];
camera = initPerspectiveCam(Msh,camOp); %initialises a perspective
camera.params.T(3)=7;
%camera that looks at the mesh.
light = []; %not specifying a light model
options.srcFrame = 'world';
options.shadingMethod='smooth';

options.propertyMaps={'depth'};


mm = mean(Msh.vertexPos,1);

%loop a sequence of rotations
rvec = [1,0,0];
angles = linspace(0,2*pi,30);
vertsPosBox = Msh.vertexPos;
folder=sprintf('./deformationp%d/',deformation);
mkdir(folder);
h=figure(1);
set(h,'Visible','on');

for i=1:length(angles)
   r =  rvec*angles(i);
   R = RodriguezRotate2ndOrd(r);
   R(4,4) = 1;
   MT = eye(4);
   MT(1:3,end) = -mm;
   Mbox = inv(MT)*R*MT;
   vertsFrame = homoMult(Mbox,vertsPosBox);
   Msh.vertexPos = vertsFrame;
   [imOut,msk,baryMask,ptsPix,VisibFaces,pMaps] = z_bufferMesh(camera,Msh,light,options);
   %h=figure(1);
   clf;
   imshow(uint8(imOut));
   pause(1);
   
   imwrite(imOut,[folder sprintf('angle%02d.png',i)],'png');
   
   save([folder sprintf('Mesh%02d.mat',i)],'Msh','msk','baryMask','ptsPix','VisibFaces','pMaps');
end

end








