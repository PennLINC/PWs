function Vis_FaceVec_Bup(FaceVecL,FaceVecR,Fn) 

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
SubjectsFolder = '/cbica/software/external/freesurfer/centos7/6.0.0/subjects/fsaverage5';
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

% now load in medial wall VERTICES
%mw_v_l=read_medial_wall_label([SubjectsFolder '/label/lh.Medial_wall.label']);
%mw_v_r=read_medial_wall_label([SubjectsFolder '/label/rh.Medial_wall.label']);

% all faces that touch a medial wall vertex to be masked
%MW_f1_L=find(ismember(F_L(:,1),mw_v_l));
%MW_f2_L=find(ismember(F_L(:,2),mw_v_l));
%MW_f3_L=find(ismember(F_L(:,3),mw_v_l));
% rh
%MW_f1_R=find(ismember(F_R(:,1),mw_v_r));
%MW_f2_R=find(ismember(F_R(:,2),mw_v_r));
%MW_f3_R=find(ismember(F_R(:,3),mw_v_r));
% inclusive - mask if face involves ANY mw vertices
%MW_combined_L=union(MW_f1_L,MW_f2_L);
%MW_combined_L=union(MW_combined_L,MW_f3_L);
% now for right hemisphere
%MW_combined_R=union(MW_f1_R,MW_f2_R);
%MW_combined_R=union(MW_combined_R,MW_f3_R);
% get inverse for indexing : faces that ARE NOT touching mW verts
%noMW_combined_L=setdiff([1:5120],MW_combined_L);
%noMW_combined_R=setdiff([1:5120],MW_combined_R);
% further mask derivation
% MASK WHERE PGG = 0: individ AND group
% load in GROUP PG
gLPGfp=['/cbica/projects/pinesParcels/data/hcp.gradients_L_10k.func.gii'];
gLPGf=gifti(gLPGfp);
gPG_LH=gLPGf.cdata(:,1);
% right hemi
gRPGfp=['/cbica/projects/pinesParcels/data/hcp.gradients_R_10k.func.gii'];
gRPGf=gifti(gRPGfp);
gPG_RH=gRPGf.cdata(:,1);
% calculate group PG gradient on sphere
gPGg_L = grad(F_L, V_L, gPG_LH);
gPGg_R = grad(F_R, V_R, gPG_RH);
% get index of where they are 0 in all directions
gPGg_L0=find(all(gPGg_L')==0);
gPGg_R0=find(all(gPGg_R')==0);

% continue to get unions
%gro_MW_combined_L=union(MW_combined_L,gPGg_L0);
% and right hemi
%gro_MW_combined_R=union(MW_combined_R,gPGg_R0);
% get inverse for indexing : faces that ARE NOT touching mW verts
%g_noMW_combined_L=setdiff([1:5120],gro_MW_combined_L);
%g_noMW_combined_R=setdiff([1:5120],gro_MW_combined_R);
%%%%% version without MW mask explicitly
g_noMW_combined_L=setdiff([1:(5120*4)],gPGg_L0);
g_noMW_combined_R=setdiff([1:(5120*4)],gPGg_R0);


%%% PCA section
%bothHemisHierAngTS=vertcat(AngsL(g_noMW_combined_L,:),AngsR(g_noMW_combined_R,:));
%AngFC=corrcoef(bothHemisHierAngTS');
%disp('Running PCA')
% make matrix a lil sparser
%smol=find(abs(AngFC)<0.1);
%AngFC(smol)=0;
% recover PCs of AngFC
%[coeffs,scores,latent,explained]=fastpca(AngFC);

% print out variances explained
%scores(1:2)
%latent(1:2)

% assign to facevels
%FaceVecL=coeffs(1:length(g_noMW_combined_L),2);
%FaceVecR=coeffs((length(g_noMW_combined_L)+1:37066),2);

%%%%%%%%


data=zeros(1,(5120*4));
data(g_noMW_combined_L)=FaceVecL;

% fixed colorscale
% CIRCULAR
mincol=.4;
maxcol=.6;

%custommap=colormap(roybigbl_cm);
custommap=colormap(inferno);

figure
[vertices, faces] = freesurfer_read_surf('/cbica/software/external/freesurfer/scientificlinux6/6.0.0/subjects/fsaverage5/surf/lh.inflated');

asub = subaxis(2,2,1, 'sh', 0, 'sv', 0, 'padding', 0, 'margin', 0);

aplot = trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3))
view([90 0]);
colormap(custommap)
daspect([1 1 1]);
axis tight;
axis vis3d off;
lighting gouraud; %phong;
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
lighting gouraud; %phong;
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
data=zeros(1,(5120*4));
data(g_noMW_combined_R)=FaceVecR;

[vertices, faces] = freesurfer_read_surf('/cbica/software/external/freesurfer/scientificlinux6/6.0.0/subjects/fsaverage5/surf/rh.inflated');

asub = subaxis(2,2,2, 'sh', 0.0, 'sv', 0.0, 'padding', 0, 'margin', 0,'Holdaxis');
aplot = trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3),data)
view([90 0]);
rotate(aplot, [0 0 1], 180)
colormap(custommap)
caxis([mincol; maxcol]);
daspect([1 1 1]);
axis tight;
axis vis3d off;
lighting phong; %gouraud
lighting none;
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
lighting gouraud; %phong;
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
%c=colorbar
%c.Location='southoutside'
%colormap(custommap);

print(Fn,'-dpng')
