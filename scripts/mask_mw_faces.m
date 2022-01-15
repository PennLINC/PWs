function mask_mw_faces(subj)
% Add OFD toolbox to path
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'))

%%%% Load in angular distances
AngDistFP=['/cbica/projects/pinesParcels/results/PWs/Proced/' subj '/' subj '_AngDistMat.mat'];
data=load(AngDistFP)

%%% Load in surface data
SubjectsFolder = '/cbica/software/external/freesurfer/centos7/7.2.0/subjects/fsaverage5';
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
mw_v_l=read_medial_wall_label([SubjectsFolder '/label/lh.Medial_wall.label']);
mw_v_r=read_medial_wall_label([SubjectsFolder '/label/rh.Medial_wall.label']);

% all faces that touch a medial wall vertex to be masked
MW_f1_L=find(ismember(F_L(:,1),mw_v_l));
MW_f2_L=find(ismember(F_L(:,2),mw_v_l));
MW_f3_L=find(ismember(F_L(:,3),mw_v_l));
% rh
MW_f1_R=find(ismember(F_R(:,1),mw_v_r));
MW_f2_R=find(ismember(F_R(:,2),mw_v_r));
MW_f3_R=find(ismember(F_R(:,3),mw_v_r));
% inclusive - mask if face involves ANY mw vertices
MW_combined_L=union(MW_f1_L,MW_f2_L);
MW_combined_L=union(MW_combined_L,MW_f3_L);
% now for right hemisphere
MW_combined_R=union(MW_f1_R,MW_f2_R);
MW_combined_R=union(MW_combined_R,MW_f3_R);
% to be combined with mask vector derived below from PGGs

% MASK WHERE PGG = 0: individ AND group
% load in GROUP PG
gLPGfp=['/cbica/projects/pinesParcels/data/princ_gradients/Gradients.lh.fsaverage5.func.gii'];
gLPGf=gifti(gLPGfp);
gPG_LH=gLPGf.cdata(:,1);
% right hemi
gRPGfp=['/cbica/projects/pinesParcels/data/princ_gradients/Gradients.rh.fsaverage5.func.gii'];
gRPGf=gifti(gRPGfp);
gPG_RH=gRPGf.cdata(:,1);
% load in subject's PG
LPGfp=['/cbica/projects/pinesParcels/results/PWs/Proced/' subj '/' subj '_PG_L_10k_rest.func.gii'];
LPGf=gifti(LPGfp);
PG_LH=LPGf.cdata(:,1);
% right hemi
RPGfp=['/cbica/projects/pinesParcels/results/PWs/Proced/' subj '/' subj '_PG_R_10k_rest.func.gii'];
RPGf=gifti(RPGfp);
PG_RH=RPGf.cdata(:,1);
% calculate PG gradient on sphere
PGg_L = grad(F_L, V_L, PG_LH);
PGg_R = grad(F_R, V_R, PG_RH);
% calculate group PG gradient on sphere
gPGg_L = grad(F_L, V_L, gPG_LH);
gPGg_R = grad(F_R, V_R, gPG_RH);
% get index of where they are 0 in all directions
PGg_L0=find(all(PGg_L')==0);
gPGg_L0=find(all(gPGg_L')==0);
PGg_R0=find(all(PGg_R')==0);
gPGg_R0=find(all(gPGg_R')==0);

% continue to get unions
ind_MW_combined_L=union(MW_combined_L,PGg_L0);
gro_MW_combined_L=union(MW_combined_L,gPGg_L0);
% and right hemi
ind_MW_combined_R=union(MW_combined_R,PGg_R0);
gro_MW_combined_R=union(MW_combined_R,gPGg_R0);
% get inverse for indexing : faces that ARE NOT touching mW verts
i_noMW_combined_L=setdiff([1:20480],ind_MW_combined_L);
i_noMW_combined_R=setdiff([1:20480],ind_MW_combined_R);
g_noMW_combined_L=setdiff([1:20480],gro_MW_combined_L);
g_noMW_combined_R=setdiff([1:20480],gro_MW_combined_R);

% mask angular distances
AngD_L=data.AngDist.Left;
AngD_R=data.AngDist.Right;
AngD_L_masked=AngD_L(:,i_noMW_combined_L);
AngD_R_masked=AngD_R(:,i_noMW_combined_R);
gAngD_L=data.AngDist.gLeft;
gAngD_R=data.AngDist.gRight;
gAngD_L_masked=gAngD_L(:,g_noMW_combined_L);
gAngD_R_masked=gAngD_R(:,g_noMW_combined_R);

%%% mask PG
% convert PG to faces, average value across three vertices defining face
% for f in faces
% vert 1 = faces(f,1)
% vert 2 = faces(f,2)
% vert 3 = faces(f,3)
% pg val = mean(PG(vert1),PG(vert2),PG(vert3)
%end


% write in R-friendly format
writetable(table(AngD_L_masked),['/cbica/projects/pinesParcels/results/PWs/Proced/' subj '/' subj '_AngDist_Masked_L.csv']);
writetable(table(AngD_R_masked),['/cbica/projects/pinesParcels/results/PWs/Proced/' subj '/' subj '_AngDist_Masked_R.csv']);
% and group
writetable(table(gAngD_L_masked),['/cbica/projects/pinesParcels/results/PWs/Proced/' subj '/' subj '_gAngDist_Masked_L.csv']);
writetable(table(gAngD_R_masked),['/cbica/projects/pinesParcels/results/PWs/Proced/' subj '/' subj '_gAngDist_Masked_R.csv']);

