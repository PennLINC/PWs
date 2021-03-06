function Vis_FaceVec(FaceVecL,FaceVecR,Fn) 

%angDistFP=['/cbica/projects/pinesParcels/results/PWs/Proced/' subj '/' subj '_AngDistMat.mat'];
%Angs=load(angDistFP);
%AngsL=Angs.AngDist.gLeft';
%AngsR=Angs.AngDist.gRight';

% calc AFC
%bothHemisHierAngTS=vertcat(AngsL,AngsR);
%AngFC=corrcoef(bothHemisHierAngTS');

% arbitrarily pick a face to highlight the AFC profile of
%ArbFaceNum=720;

%Modes=readtable('test_leftmode.csv')
%FaceVec=table2array(Modes(:,2));

% get ang dist in
%FaceVecL=AngFC(ArbFaceNum,1:20480);
%FaceVecR=AngFC(ArbFaceNum,20481:40960);

addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'))

%%% Load in surface data
SubjectsFolder = '/cbica/software/external/freesurfer/centos7/7.2.0/subjects/fsaverage4';
surfL = [SubjectsFolder '/surf/lh.sphere'];
surfR = [SubjectsFolder '/surf/rh.sphere'];
% surface topography
[vx_l, faces_l] = read_surf(surfL);
[vx_r, faces_r] = read_surf(surfR);
% +1 the faces: begins indexing at 0
faces_l = faces_l + 1;
faces_r = faces_r + 1;
% faces_L
F_L=faces_l;
% vertices V
V_L=vx_l;
% faces_R
F_R=faces_r;
% vertices V
V_R=vx_r;

% use native freesurfer command for mw mask indices
surfML = '/cbica/software/external/freesurfer/centos7/6.0.0/subjects/fsaverage4/label/lh.Medial_wall.label';
mwIndVec_l = read_medial_wall_label(surfML);
surfMR = '/cbica/software/external/freesurfer/centos7/6.0.0/subjects/fsaverage4/label/rh.Medial_wall.label';
mwIndVec_r = read_medial_wall_label(surfMR);
% make binary "is medial wall" vector for vertices
mw_L=zeros(1,2562);
mw_L(mwIndVec_l)=1;
mw_R=zeros(1,2562);
mw_R(mwIndVec_r)=1;
% convert to faces
% convert to faces
F_MW_L=sum(mw_L(faces_l),2)./3;
F_MW_R=sum(mw_R(faces_r),2)./3;
% convert "partial" medial wall to medial wall
F_MW_L=ceil(F_MW_L);
F_MW_R=ceil(F_MW_R);
% face mask indices
fmwIndVec_l=find(F_MW_L);
fmwIndVec_r=find(F_MW_R);
% make medial wall vector
g_noMW_combined_L=setdiff([1:5120],fmwIndVec_l);
g_noMW_combined_R=setdiff([1:5120],fmwIndVec_r);

%%%%%%%%%%%%%%%%%%%%%%%%
data=zeros(1,5120);
data(g_noMW_combined_L)=FaceVecL;

%%%%%%% fixed colorscale varities

%%% circular
mincol=-.15;
maxcol=.15;


%%% for red/blue 0-centered
%mincol=0;
%maxcol=10;
custommap=colormap(b2r(mincol,maxcol));
% abscense of color to gray to accom. lighting "none"
custommap(126,:)=[.5 .5 .5];

% blue-orange color scheme
%BO_cm=inferno(9);
%BO_cm(1,:)=[49 197 244];
%BO_cm(2,:)=[71 141 203];
%BO_cm(3,:)=[61 90 168];
%BO_cm(4,:)=[64 104 178];
%BO_cm(5,:)=[126 126 126];
%BO_cm(6,:)=[240 74 35];
%BO_cm(7,:)=[243 108 33];
%BO_cm(8,:)=[252 177 11];
%BO_cm(9,:)=[247 236 31];
% scale to 1
%BO_cm=BO_cm.*(1/255);
% interpolate color gradient
%interpsteps=[0 .125 .25 .375 .5 .625 .75 .875 1];
%BO_cm=interp1(interpsteps,BO_cm,linspace(0,1,255));
%custommap=BO_cm;
%custommap=colormap(inferno);

%%% matches circular hist
% for 180 degree max
%roybigbl_cm=inferno(6);
%roybigbl_cm(1,:)=[0, 0, 255];
%roybigbl_cm(2,:)=[0, 255, 255];
%roybigbl_cm(3,:)=[116, 192, 68];
%roybigbl_cm(4,:)=[246, 235, 20];
%roybigbl_cm(5,:)=[255, 165, 0];
%roybigbl_cm(6,:)=[255, 0, 0];
% scale to 1
%roybigbl_cm=roybigbl_cm.*(1/255);
% interpolate color gradient
%interpsteps=[0 .2 .4 .6 .8 1];
%roybigbl_cm=interp1(interpsteps,roybigbl_cm,linspace(0,1,255));
% make circular with flipud
%custommap=vertcat(flipud(roybigbl_cm),roybigbl_cm);

% for 90 degree max
%roybigbl_cm=inferno(3);
% blue
%roybigbl_cm(1,:)=[0, 0, 255];
% cyan
%roybigbl_cm(2,:)=[0, 255, 255];
% green
%roybigbl_cm(3,:)=[116, 192, 68];
% yellow
%roybigbl_cm(4,:)=[246, 235, 20];
% scale to 1
%roybigbl_cm=roybigbl_cm.*(1/255);
% interpolate color gradient
%interpsteps=[0 .33333 .66666 1];
%interpsteps=[0 .5 1];
%roybigbl_cm=interp1(interpsteps,roybigbl_cm,linspace(0,1,255));
% make circular with flipud
%custommap=vertcat(flipud(roybigbl_cm),roybigbl_cm);
%custommap=roybigbl_cm;
%custommap=colormap(parula);
% mw to black
%custommap(1,:)=[0 0 0];

figure
[vertices, faces] = freesurfer_read_surf('/cbica/software/external/freesurfer/scientificlinux6/6.0.0/subjects/fsaverage4/surf/lh.inflated');

asub = subaxis(2,2,1, 'sh', 0, 'sv', 0, 'padding', 0, 'margin', 0);

aplot = trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3))
view([90 0]);
colormap(custommap)
daspect([1 1 1]);
axis tight;
axis vis3d off;
lighting none;
shading flat;
camlight;
	alpha(1)

length(faces)

set(gca,'CLim',[mincol,maxcol]);
set(aplot,'FaceColor','flat','FaceVertexCData',data','CDataMapping','scaled');

asub = subaxis(2,2,4, 'sh', 0.00, 'sv', 0.00, 'padding', 0, 'margin', 0);
aplot = trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3))
view([90 0]);
rotate(aplot, [0 0 1], 180)
colormap(custommap)
caxis([mincol; maxcol]);
daspect([1 1 1]);
axis tight;
axis vis3d off;
lighting none;
material metal %shiny %metal;
shading flat;
camlight;
alpha(1)
 pos = get(asub, 'Position');
 posnew = pos; posnew(2) = posnew(2) + 0.13; posnew(1) = posnew(1) -.11; set(asub, 'Position', posnew);
set(gcf,'Color','w')

set(gca,'CLim',[mincol,maxcol]);
set(aplot,'FaceColor','flat','FaceVertexCData',data','CDataMapping','scaled');


%%% right hemisphere
data=zeros(1,5120);
data(g_noMW_combined_R)=FaceVecR;

[vertices, faces] = freesurfer_read_surf('/cbica/software/external/freesurfer/scientificlinux6/6.0.0/subjects/fsaverage4/surf/rh.inflated');

asub = subaxis(2,2,2, 'sh', 0.0, 'sv', 0.0, 'padding', 0, 'margin', 0,'Holdaxis');
aplot = trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3),data)
view([90 0]);
rotate(aplot, [0 0 1], 180)
colormap(custommap)
caxis([mincol; maxcol]);
daspect([1 1 1]);
axis tight;
axis vis3d off;
lighting none
material metal %shiny %metal;%shading flat;
shading flat;
camlight;
 pos = get(asub, 'Position');
 posnew = pos; posnew(1) = posnew(1) - 0.11; set(asub, 'Position', posnew);
alpha(1)


set(gca,'CLim',[mincol,maxcol]);
set(aplot,'FaceColor','flat','FaceVertexCData',data','CDataMapping','scaled');

asub = subaxis(2,2,3, 'sh', 0.0, 'sv', 0.0, 'padding', 0, 'margin', 0);
aplot = trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3),data)
view([90 0]);
colormap(custommap)
caxis([mincol; maxcol]);
daspect([1 1 1]);
axis tight;
axis vis3d off;
lighting none;
material metal %shiny %metal;
shading flat;
camlight;
alpha(1)
 pos = get(asub, 'Position');
 posnew = pos; posnew(2) = posnew(2) + 0.13; set(asub, 'Position', posnew);
set(gcf,'Color','w')


set(gca,'CLim',[mincol,maxcol]);
set(aplot,'FaceColor','flat','FaceVertexCData',data','CDataMapping','scaled');
%c=colorbar;
%c=colorbar('XTickLabel',{'.45', '.50', '.55'},'XTick', .45:.05:.55)
%c.Location='southoutside'
%colormap(custommap)

print(Fn,'-dpng')
