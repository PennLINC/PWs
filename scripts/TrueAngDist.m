function TrueAngDist(subj)

%%% pull out PG grad, OpFl distribution, calculate angular distance per pixel

% char conversion and input file locations
sname=char(subj);
childfp=['/cbica/projects/pinesParcels/results/PWs/Proced/' sname '/'];

% extract PG gradients 
PGBU_L_x=load([childfp sname '_PG_GxL_BU.csv']);
PGBU_L_y=load([childfp sname '_PG_GyL_BU.csv']);
PGBU_R_x=load([childfp sname '_PG_GxR_BU.csv']);
PGBU_R_y=load([childfp sname '_PG_GyR_BU.csv']);
PGTD_L_x=load([childfp sname '_PG_GxL_TD.csv']);
PGTD_L_y=load([childfp sname '_PG_GyL_TD.csv']);
PGTD_R_x=load([childfp sname '_PG_GxR_TD.csv']);
PGTD_R_y=load([childfp sname '_PG_GyR_TD.csv']);

% extract OpFl results
OpFlResfn=['/cbica/projects/pinesParcels/results/OpFl_output/' sname '/OpFlowResults3.mat'];
OpFlRes=load(OpFlResfn);

% pull in mask
%FlatMask_L=load([childfp sname '_FlatMask_L.csv']);
%FlatMask_R=load([childfp sname '_FlatMask_R.csv']);

% merge vector fields across runs (concatenate across time dimension)
LeftVFs=cat(3,OpFlRes.MegaStruct.Vf_Left{:});
RightVFs=cat(3,OpFlRes.MegaStruct.Vf_Right{:});

% extract available number of frames
sizeOfVfs=size(LeftVFs);
NumFrames=sizeOfVfs(3);

% get coordinates of each viable pixel
[Lrow,Lcol]=find(~isnan(PGBU_L_x));
[Rrow,Rcol]=find(~isnan(PGBU_R_x));

% initialize TD,BU,and angle-doubled outArray
BU_angDist=zeros(NumFrames,(length(Lrow)+length(Rrow)));

% for each Left pixel
for P = 1:length(Lrow)
	% get coordinates
	Row=Lrow(P);
	Col=Lcol(P);
	% PG Vectors
	PGVecBU=[PGBU_L_x(Row,Col) PGBU_L_y(Row,Col)];
	% for each vector field (each TR)
	for V = 1:NumFrames
		% Vf Vectors
		XVec=real(LeftVFs(Row,Col,V));
		YVec=imag(LeftVFs(Row,Col,V));
		VFVec=[XVec YVec];
		% calculate distance between angles: 
		% mathworks.com/matlabcentral/answers/101590-how-can-i-determine-the-angle-between-two-vectors-in-matlab
		BUCosTheta = max(min(dot(PGVecBU,VFVec)/(norm(PGVecBU)*norm(VFVec)),1),-1);
		BUThetaInDegrees = real(acosd(BUCosTheta));
		% throw em in the ang Dist vectors. To be averaged over TRs
		BU_angDist(V,P)=BUThetaInDegrees;
	end
% end for each pixel
end

% for each Right pixel
for P = 1:length(Rrow)
        % get coordinates
        Row=Rrow(P);
        Col=Rcol(P);
        % PG Vectors
        PGVecBU=[PGBU_R_x(Row,Col) PGBU_R_y(Row,Col)];
        % for each vector field (each TR)
        for V = 1:NumFrames
                % Vf Vectors
                XVec=real(RightVFs(Row,Col,V));
                YVec=imag(RightVFs(Row,Col,V));
                VFVec=[XVec YVec];
                % calculate distance between angles: 
                % mathworks.com/matlabcentral/answers/101590-how-can-i-determine-the-angle-between-two-vectors-in-matlab
                BUCosTheta = max(min(dot(PGVecBU,VFVec)/(norm(PGVecBU)*norm(VFVec)),1),-1);
                BUThetaInDegrees = real(acosd(BUCosTheta));
                % throw em in the ang Dist vectors. To be averaged over TRs
                BU_angDist(V,P+length(Lrow))=BUThetaInDegrees;
        end
end

% save out files
writetable(table(BU_angDist),[childfp sname '_BU_angDist.csv']);
