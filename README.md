# fmri_convertors

Some useful programms to convert fmri files from one format to another (files must already be in BIDS format)

1. `3d_to_4d.m` Converts 3d img to 4d concatenated volumes - Utilizes SPM
2. `dicom_to_4d.py` Converts dicom to 4d concatenated volumes - Utilizes the dicom2nifti library (change input and output folder parameters)
3. `img_to_nii.py`Replaces .img with .nii images - Utilizes the nibabel library (change input parameters)
