# Python code to convert DICOM files into compressed 4d nifit (in BIDS folder format) 
# Written by Boulakis Paradeisios 
# Physiology of cognition Lab. 
# Date: 14 June 2020



import os
import dicom2nifti
from datetime import datetime
import time,math
#specify input and outpul folders

bids_path = '/home/rantanplan/Documents/Paris/heart_bids_data'
original_path = '/home/rantanplan/Documents/Paris/heart_data'

# create logfile

filename = "Dicom_To_Nifti_logfile_{}.txt".format(datetime.now().strftime("%d_%m_%Y_%H_%M_%S"))
filename = os.path.join('/home/rantanplan/Documents/Paris/',filename)
logfile = open(filename, "a+")

#make output subdirectories in bids format


for ii in range(len(os.listdir(original_path))):
    subject = 'sub-{0:0=2d}'.format(ii+1)
    folder = os.path.join(bids_path,subject)
    anat_folder = os.path.join(folder,'anat')
    func_folder = os.path.join(folder,'func')
    
    os.mkdir(folder)
    os.mkdir(anat_folder)
    os.mkdir(func_folder)

# start of conversions
starting_time = time.time()

for num,subject in enumerate(os.listdir(bids_path)):
    
    sub = 'sub-{0:0=2d}'.format(num+1)
    msg =  'Start of Subject {}: [{}]\n\n'.format(num+1, datetime.now().strftime("%d_%m_%Y_%H:%M:%S:%f"))
    print('Working on subject: {}'.format(num+1))
    
# start of anatomical conversion - specify whether you want compression
 
    start = time.time()
    anatomical_in = os.path.join(original_path,sub,'anat')
    anatomical_out = os.path.join(bids_path,sub,'anat')
    msg += 'Starting anatomical dicoms on location: {} ----- Onset Time :[{}]\n'.format(anatomical_out,datetime.now().strftime("%d_%m_%Y_%H:%M:%S:%f"))
    print('Starting anatomical dicoms for {} on location: {}'.format(sub,anatomical_out))
    dicom2nifti.convert_directory(dicom_directory = anatomical_in, 
                                  output_folder = anatomical_out, 
                                  compression= False, 
                                  reorient=False)
    
    original_name = os.path.join(anatomical_out,os.listdir(anatomical_out)[0])
    anatomical_name = os.path.join(bids_path,sub,'anat','sub-{0:0=2d}_T1w.nii.gz'.format(num+1))
    os.rename(original_name,anatomical_name)
    msg += 'End of anatomical dicoms on location: {} ----- Ending Time :[{}]\n'.format(anatomical_out,datetime.now().strftime("%d_%m_%Y_%H:%M:%S:%f"))
    time
    end = time.time()
    time_elapsed = (end - start)/60
    msg += 'Time elapsed: {} mins\n\n'.format(math.ceil(time_elapsed))
    
    
 # start of functional conversion - specify whether you want compression, change bold name 
    
    start = time.time()
    functional_in = os.path.join(original_path,sub,'func')
    functional_out = os.path.join(bids_path,sub,'func')
    msg += 'Starting functional dicoms on location: {} ----- Onset Time :[{}]\n'.format(functional_out,datetime.now().strftime("%d_%m_%Y_%H:%M:%S:%f"))
    print('Starting functional dicoms for {} on location: {}'.format(sub,functional_out))
    dicom2nifti.convert_directory(dicom_directory = functional_in, 
                                  output_folder = functional_out, 
                                  compression=False, 
                                  reorient=False)
    original_name = os.path.join(functional_out,os.listdir(functional_out)[0])
    functional_name = os.path.join(bids_path,sub,'func','sub-{0:0=2d}_heart_bold.nii.gz'.format(num+1))
    os.rename(original_name,functional_name)
    msg += 'End of functional dicoms on location: {} ----- Ending Time :[{}]\n'.format(anatomical_out,datetime.now().strftime("%d_%m_%Y_%H:%M:%S:%f"))
    end = time.time()
    time_elapsed = (end - start)/60
    msg += 'Time elapsed: {} mins\n\n'.format(math.ceil(time_elapsed))
    msg += '-'*100 + '\n\n'
    
    logfile.write(msg)   

ending_time = time.time()
time_to_convert = (ending_time - starting_time)/60

logfile.write('Conversion complete - Time Elapsed: {}'.format(math.ceil(time_to_convert)))
print('Conversion complete - Time Elapsed: {} mins'.format(math.ceil(time_to_convert)))

logfile.close()
    
