# so gr8ful i can do this w/o pmacs: see https://pennlinc.github.io/docs/cubic#using-rr-studio-and-installation-of-r-packages to customize r packages as needed
.libPaths('~/R_mgcv')
# mgcv needed for gams
library(mgcv)
# ppcor for directionality detection
library(ppcor)

# difference in R2
DeltaR2EstVec<-function(x){
  # relevant df
  testdf<-data.frame(cbind(as.numeric(df$interview_age),as.numeric(df$sex),df$FD,x))
  colnames(testdf)<-c('Age','Sex','Motion','varofint')
  # no-age model (segreg ~ sex + motion)
  noAgeGam<-gam(varofint~Sex+Motion,data=testdf)
  noAgeSum<-summary(noAgeGam)
  # age-included model for measuring difference
  AgeGam<-gam(varofint~Sex+Motion+s(Age,k=4),data=testdf)
  AgeSum<-summary(AgeGam)
  dif<-AgeSum$r.sq-noAgeSum$r.sq
  # partial spearmans to extract age relation (for direction)
  pspear=pcor(testdf,method='spearman')$estimate
  corest<-pspear[4]
  if(corest<0){
    dif=dif*-1
  }
  return(dif) 
}

# Next, to derive the statistical significance of observed age effects, we need to test if the two models (one with an age term, one without) are significantly different. We use an ANOVA for this procedure. These p-values will eventually be FDR-corrected.

# chisq test sig. output
DeltaPEstVec<-function(x){
  # relevant df
  testdf<-data.frame(cbind(as.numeric(df$interview_age),as.numeric(df$sex),df$FD,x))  
  colnames(testdf)<-c('Age','Sex','Motion','varofint')
  # no-age model (segreg ~ sex + motion)
  noAgeGam<-gam(varofint~Sex+Motion,data=testdf)
  # age-included model for measuring difference
  AgeGam<-gam(varofint~Sex+Motion+s(Age,k=4),data=testdf)  
  # test of dif with anova.gam
  anovaRes<-anova.gam(noAgeGam,AgeGam,test='Chisq')
  anovaP<-anovaRes$`Pr(>Chi)`
  anovaP2<-unlist(anovaP)
  return(anovaP2[2])  
}
# end functions - start actual script

# extract range of vertices to be covered in this run from VertBin
Lfaces=4851
Rfaces=4842

# load in subj list
subjList=read.delim('/cbica/projects/pinesParcels/PWs/hcpd_subj_list.txt')

# load in ages
demo=read.csv('/cbica/projects/pinesParcels/PWs/hcpd_demographics.csv')
# convert to used naming convention
demo$SubjID<-gsub('HCD','sub-',demo$src_subject_id)

# load in FD
FD_TRs=read.csv('/cbica/projects/pinesParcels/PWs/Subj_FD_RemTRs_c.csv')
colnames(FD_TRs)[1]<-'SubjID'
colnames(FD_TRs)[2]<-'FD'
colnames(FD_TRs)[3]<-'RemainingTRs'

# merge by subjID
mergeddf<-merge(demo,FD_TRs,by='SubjID')

# exclude subjects with less than 300 TRs remaining
inclusionVec<-mergeddf$RemainingTRs>300
# include NAs in the exclusion
inclusionVec[is.na(inclusionVec)==TRUE]=FALSE
# subset the master df accordingly
df<-mergeddf[inclusionVec,]
# get count of remaining subjects
remainingSubjs=dim(df)[1]
print(remainingSubjs)

# initialize face-level vectors: keeping 0s in the slots untouched by this run to verify allocation later
# for plotting means
TD_L=rep(0,Lfaces)
BU_L=rep(0,Lfaces)
BuProp=rep(0,Lfaces)
ThetasFromPG=rep(0,Lfaces)

# for plotting age effect sizes
TD_L_adr2=rep(0,Lfaces)
BU_L_adr2=rep(0,Lfaces)
BuProp_adr2=rep(0,Lfaces)
ThetasFromPG_adr2=rep(0,Lfaces)

# for fdr-correcting age associations
TD_L_ap=rep(0,Lfaces)
BU_L_ap=rep(0,Lfaces)
BuProp_ap=rep(0,Lfaces)
ThetasFromPG_ap=rep(0,Lfaces)

# subjvec to run in parallel for even more confidence in merging
Subjvec=rep(0,remainingSubjs)

# initialize iterable face value column - to avoid storing this data for multiple faces over this upcoming loop
df$FaceBuProp=rep(0,remainingSubjs)
df$FaceBu_rv=rep(0,remainingSubjs)
df$FaceTd_rv=rep(0,remainingSubjs)
df$FaceThetaDist=rep(0,remainingSubjs)

# that leaves a column for face value, one for age, one for FD, one for sex. Remaining TRs controlled for via exclusion

# for each face in this run's range
for (f in 1:4851){
	print(f)
	# load in D and shapes iteratively
	for (s in 1:remainingSubjs){
	    subj=df$SubjID[s]
	    ResFP_L=paste0('/cbica/projects/pinesParcels/results/PWs/Proced/',subj,'/',subj,'_BUTD_L_c.csv')
	    # if output exists
	    if (file.exists(paste0(ResFP_L))) {
	      # load in dat data
	      Res=read.csv(ResFP_L)
		# extract TD resvec length
		df$FaceBuProp[s]=Res[f,1]	
		# extract BU resvec length
		df$FaceBu_rv[s]=Res[f,2]
		# extract prop of BU TRs
		df$FaceTd_rv[s]=Res[f,3]
		# extract global resvec theta from gPGG
		df$FaceThetaDist[s]=Res[f,4]
	    }
	}
	# extract mean
	TD_L[f]=mean(df$FaceTd_rv)
	# extract mean
	BU_L[f]=mean(df$FaceBu_rv)
	# extract mean
	BuProp[f]=mean(df$FaceBuProp)
	# you already know doe
	ThetasFromPG[f]=mean(df$FaceThetaDist)
	
        # extract age dr2
        TD_L_adr2[f]=DeltaR2EstVec(df$FaceTd_rv)
        # extract age dr2
        BU_L_adr2[f]=DeltaR2EstVec(df$FaceBu_rv)
        # extract age dr2
        BuProp_adr2[f]=DeltaR2EstVec(df$FaceBuProp)
        # you already know doe
        ThetasFromPG_adr2[f]=DeltaR2EstVec(df$FaceThetaDist)
	
	# extract age p
        TD_L_ap[f]=DeltaPEstVec(df$FaceTd_rv)
        # extract age p
        BU_L_ap[f]=DeltaPEstVec(df$FaceBu_rv)
        # extract age p
        BuProp_ap[f]=DeltaPEstVec(df$FaceBuProp)
        # you already know doe
        ThetasFromPG_ap[f]=DeltaPEstVec(df$FaceThetaDist)
}

# saveout means
write.csv(TD_L,'~/results/PWs/MeanTDresLen_L_c.csv',col.names=F,row.names=F,quote=F)
write.csv(BU_L,'~/results/PWs/MeanBUresLen_L_c.csv',col.names=F,row.names=F,quote=F)
write.csv(BuProp,'~/results/PWs/MeanPropBU_L_c.csv',col.names=F,row.names=F,quote=F)
write.csv(ThetasFromPG,'~/results/PWs/MeanThetafromPGG_L_c.csv',col.names=F,row.names=F,quote=F)

# saveout dr2s and ps - still needs to be merged with results from other hemi for MC correction
saveRDS(TD_L_adr2,paste0('/cbica/projects/pinesParcels/results/PWs/LTDL_adr2_c.rds'))
saveRDS(BU_L_adr2,paste0('/cbica/projects/pinesParcels/results/PWs/LBUL_adr2_c.rds'))
saveRDS(BuProp_adr2,paste0('/cbica/projects/pinesParcels/results/PWs/LBUProp_adr2_c.rds'))
saveRDS(ThetasFromPG_adr2,paste0('/cbica/projects/pinesParcels/results/PWs/LThetasFromPG_adr2_c.rds'))

saveRDS(TD_L_ap,paste0('/cbica/projects/pinesParcels/results/PWs/LTDL_p_c.rds'))
saveRDS(BU_L_ap,paste0('/cbica/projects/pinesParcels/results/PWs/LBUL_p_c.rds'))
saveRDS(BuProp_ap,paste0('/cbica/projects/pinesParcels/results/PWs/LBUProp_p_c.rds'))
saveRDS(ThetasFromPG_ap,paste0('/cbica/projects/pinesParcels/results/PWs/LThetasFromPG_p_c.rds'))

