function Gradient_ofPG(subj)
% addpath needed for reading cifti
addpath(genpath('/cbica/projects/hcpd/scripts/tools'));
% and path needed for opflow
addpath(genpath('/cbica/projects/abcdfnets/scripts/NeuroPattToolbox'));

%%% load in normative x y coordinates for left
FM_l=gifti('/cbica/projects/pinesParcels/data/Surfs/S900.L.flat.32k_fs_LR.surf.gii');
FM_r=gifti('/cbica/projects/pinesParcels/data/Surfs/S900.R.flat.32k_fs_LR.surf.gii');
% extract coordinates
xL=double(FM_l.vertices(:,1));
xR=double(FM_r.vertices(:,1));
yL=double(FM_l.vertices(:,2));
yR=double(FM_r.vertices(:,2));
% going to need to expand these to make seperable bins IN ACCORDANCE WITH PROC. POWER AVAILABLE
xL=xL*.2; % example: xL*10 for 10x resolution
xR=xR*.2;
yL=yL*.2;
yR=yR*.2;

%%% read in subject's PG
sname=char(subj);
childfp=['/cbica/projects/pinesParcels/results/PWs/Proced/' sname '/'];
PG=read_cifti([childfp sname '_PG_LR_32k_rest.dscalar.nii']);

% following - https://github.com/coalsont/cifti-matlab/blob/master/cifti_dense_get_surf_map.m
% prepare indices of left hemi
[vertlist1L, ciftilistL, numvertsL] = cifti_dense_get_surf_map(PG.diminfo{1}, 'CORTEX_LEFT');
% prepare indices of right hemi
[vertlist1R, ciftilistR, numvertsR] = cifti_dense_get_surf_map(PG.diminfo{1}, 'CORTEX_RIGHT');

%%% get flatmap and masks in order
% need to use combined index where xL yL xR yR are not 0 and cifti index is not 0, first step is filtering by vertlist from ciftiinfo
% this extracts the shape of the flatmap in the form of x and y coordinates - vertices of all coordinates comprising the flatmaps
xLPartialFilt=xL(vertlist1L);
yLPartialFilt=yL(vertlist1L);
xRPartialFilt=xR(vertlist1R);
yRPartialFilt=yR(vertlist1R);
% no negative coordinates
xLPartialFilt=xLPartialFilt+abs(min(xLPartialFilt));
yLPartialFilt=yLPartialFilt+abs(min(yLPartialFilt));
xRPartialFilt=xRPartialFilt+abs(min(xRPartialFilt));
yRPartialFilt=yRPartialFilt+abs(min(yRPartialFilt));
% size of "grid"
s_gridX_L=max(xL)-min(xL);
s_gridX_R=max(xR)-min(xR);
s_gridY_L=max(yL)-min(yL);
s_gridY_R=max(yR)-min(yR);
% get border of flatmap in a sized rectangle
vqBound_L = boundary(double(xLPartialFilt),double(yLPartialFilt)); 
vqBound_R = boundary(double(xRPartialFilt),double(yRPartialFilt));	
% Xq and Yq will be equally spaced integer grid values
XqL=1:s_gridX_L;
YqL=1:s_gridY_L;
XqR=1:s_gridX_R;
YqR=1:s_gridY_R;
% convert to grid
[xL,yL]=meshgrid(XqL,YqL);
[xR,yR]=meshgrid(XqR,YqR);
% create mask for vertices within boundaries of shape (within rectangle)
bwL = poly2mask(double(xLPartialFilt(vqBound_L)),double(yLPartialFilt(vqBound_L)),double(max(max(yL))),double(max(max(xL))));
bwR = poly2mask(double(xLPartialFilt(vqBound_R)),double(yLPartialFilt(vqBound_R)),double(max(max(yR))),double(max(max(xR))));	
% convert to NaN's instead of 0
bwNL=double(bwL);
bwNL(bwNL==0)=NaN;
bwNR=double(bwR);
bwNR(bwNR==0)=NaN;
% extract PG values
PG_LH=PG.cdata(ciftilistL,1);
% extract right
PG_RH=PG.cdata(ciftilistR,1);
% Interp. onto grid CHECK MESHGRID TO LOOK FOR SOURCE OF TRANSPOSE HERE
% source of transpose is matlab and python naturally don't represent matrices the same way: one is transposed from the other 
PG_gr_L = griddata(double(xLPartialFilt),double(yLPartialFilt),double(PG_LH),double(xL),double(yL));
PG_gr_R = griddata(double(xRPartialFilt),double(yRPartialFilt),double(PG_RH),double(xR),double(yR));
% mask gaps that were interpolated in
masked_PG_gr_L=(PG_gr_L).*(bwNL);
masked_PG_gr_R=(PG_gr_R).*(bwNR);
% get the gradient of the PG (I know, language sucks)
[GxL,GyL]=imgradientxy(masked_PG_gr_L);
[GxR,GyR]=imgradientxy(masked_PG_gr_R);

% save out gradient gradients
dlmwrite([childfp sname '_PG_GxR_BU.csv'],GxR);
dlmwrite([childfp sname '_PG_GyR_BU.csv'],GyR);
dlmwrite([childfp sname '_PG_GxL_BU.csv'],GxL);
dlmwrite([childfp sname '_PG_GyL_BU.csv'],GyL);

% save out low-res gradients for percentile binning
dlmwrite([childfp sname '_PG_lowResFlat_L.csv'],masked_PG_gr_L);
dlmwrite([childfp sname '_PG_lowResFlat_R.csv'],masked_PG_gr_R);
