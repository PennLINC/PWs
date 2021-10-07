# subject name
subj=$1

# output filepath
OFP=/cbica/projects/abcdfnets/results/wave_output/${subj}/

# subject's principal gradients
LPGfp=/scratch/abcdfnets/nda-abcd-s3-downloader/August_2021_DL/derivatives/abcd-hcp-pipeline/${subj}/ses-baselineYear1Arm1/func/${subj}_spunPGL.func.gii
RPGfp=/scratch/abcdfnets/nda-abcd-s3-downloader/August_2021_DL/derivatives/abcd-hcp-pipeline/${subj}/ses-baselineYear1Arm1/func/${subj}_spunPGR.func.gii

# left hemisphere
/cbica/projects/abcdfnets/scripts/workbench-1.2.3/exe_rh_linux64/wb_command -metric-resample ${LPGfp} ~/standard_mesh_atlases/resample_fsaverage/fsaverage5_std_sphere.L.10k_fsavg_L.surf.gii ~/standard_mesh_atlases/resample_fsaverage/fs_LR-deformed_to-fsaverage.L.sphere.32k_fs_LR.surf.gii ADAP_BARY_AREA ${OFP}${subj}_PG_L_spun_32k.func.gii -area-metrics ~/standard_mesh_atlases/resample_fsaverage/fsaverage5.L.midthickness_va_avg.10k_fsavg_L.shape.gii ~/standard_mesh_atlases/resample_fsaverage/fs_LR.L.midthickness_va_avg.32k_fs_LR.shape.gii
# right hemisphere
/cbica/projects/abcdfnets/scripts/workbench-1.2.3/exe_rh_linux64/wb_command -metric-resample ${RPGfp} ~/standard_mesh_atlases/resample_fsaverage/fsaverage5_std_sphere.R.10k_fsavg_R.surf.gii ~/standard_mesh_atlases/resample_fsaverage/fs_LR-deformed_to-fsaverage.R.sphere.32k_fs_LR.surf.gii ADAP_BARY_AREA ${OFP}${subj}_PG_R_spun_32k.func.gii -area-metrics ~/standard_mesh_atlases/resample_fsaverage/fsaverage5.R.midthickness_va_avg.10k_fsavg_R.shape.gii ~/standard_mesh_atlases/resample_fsaverage/fs_LR.R.midthickness_va_avg.32k_fs_LR.shape.gii

# combine
/cbica/projects/abcdfnets/scripts/workbench-1.2.3/exe_rh_linux64/wb_command -cifti-create-dense-from-template /cbica/projects/abcdfnets/data/hcp.gradients.dscalar.nii ${OFP}${subj}_PG_LR_spun_32k.dscalar.nii -metric CORTEX_LEFT ${OFP}${subj}_PG_L_spun_32k.func.gii -metric CORTEX_RIGHT ${OFP}${subj}_PG_R_spun_32k.func.gii
