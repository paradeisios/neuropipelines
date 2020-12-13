# Nibabel code to convert 3D nifti files (in BIDS folder format) 
# Written by Boulakis Paradeisios 
# Physiology of cognition Lab. 
# Date: 14 June 2020


import os
import nibabel as nb

parent_dir = '/home/rantanplan/Documents/Paris/heart_bids_data'

for folder in os.listdir(parent_dir):
    folder_dir =  os.path.join(parent_dir,folder)
    os.chdir(folder_dir)
    curr_dir = os.getcwd()

    for folder in os.listdir(curr_dir):
        working_dir = os.path.join(curr_dir,folder)
        os.chdir(working_dir)
    
        for file in os.listdir(os.getcwd()):
            #if file.endswith('.img'):
            fname = file  
            img = nb.load(fname)
            nb.save(img, fname.replace('.img', '.nii'))
                
                
                


