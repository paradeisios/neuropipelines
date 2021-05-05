MNI=/usr/local/fsl/data/standard/MNI152_T1_2mm.nii.gz
MNI_BRAIN=/usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz

DATA=/home/paradeisios/Desktop/fsl_test_dir/data/
OUTPUT=/home/paradeisios/Desktop/fsl_test_dir/output/



for ((i=1;i<=1;i++));do 
	
	echo "Working on Subject ${i}";

	FUNC_DIR=${DATA}sub-${i}/func/;
	ANAT_DIR=${DATA}sub-${i}/anat/;
	
	
	mkdir ${OUTPUT}/sub-${i}/
	ANAT_OUTPUT=${OUTPUT}sub-${i}/anat/
	mkdir ${ANAT_OUTPUT}
	FUNC_OUTPUT=${OUTPUT}sub-${i}/func/
	mkdir ${FUNC_OUTPUT}

	ANAT_IMG=${ANAT_DIR}$(ls ${ANAT_DIR})
	FUNC_IMG=${FUNC_DIR}$(ls ${FUNC_DIR})
	
	############ structural stuff

	# brain extraction
	
	cd ${ANAT_OUTPUT}
	
	echo "Running brain extraction ..."
	bet ${ANAT_IMG} struct_brain -f 0.30 -m -g 0.20
	
	# segmentation
	echo "Running segmentation ..."
	fast -t 1 -n 3 -B -b -g -S 1 struct_brain
	
	# structural linear registration
	echo "Running linear registration of structural volume to standard space ..."

	flirt -in struct_brain_restore -ref ${MNI_BRAIN} -out brain_restore_flirt -omat h2s_affine.mat -cost mutualinfo -dof 12 -interp spline
	
	# structural nonlinear registration
	echo "Running non-linear registration of structural volume to standard space ..."

	fnirt --aff=h2s_affine.mat --config=T1_2_MNI152_2mm --cout=T1_w_fieldwarp.nii.gz --in=${ANAT_IMG} --ref=${MNI} --iout=T1_w_warped
	
	############ functional stuff
	
	cd ${FUNC_OUTPUT}
	# image to float
	echo "Converting functional volumes to float data type ..."
	fslmaths ${FUNC_IMG}  funcf -odt float

	# volume removal
	echo "Removing initial functional volumes ..."
	fslroi funcf funcf 5 -1

	# realignment
	echo "Running realignment ..."
	mcflirt -in funcf -dof 6 -out funcf_mcf -mats -plots

	# get mean image
	echo "Extracting mean functional image ..."
	fslmaths funcf_mcf -Tmean funcf_mcf_mean

	# functional linear registration of mean realigned image to structural data
	echo "Running linear registration of mean functional image to subject structural space ..."
	flirt -in funcf_mcf_mean -ref ${ANAT_OUTPUT}struct_brain_restore -out funcf_mcf_mean_flirt -omat f2h_affine.mat -cost mutualinfo -dof 6 -interp spline

	# apply func2structural transformation matrix and structural2standa warp to register functional to standard
	echo "Running nonlinear registration of functional data to standard space ..."
	applywarp --in=funcf_mcf --ref=${MNI} --out=funcf_mcf_warp --warp=${ANAT_OUTPUT}T1_w_fieldwarp --premat=f2h_affine.mat

	# smoothing
	echo "Smoothing functional data ..."
	fslmaths funcf_mcf_warp -s 2.54797 funcf_mcf_warp_smooth



done
