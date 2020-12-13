%-----------------------------------------------------------------------
% Convert 3d nii in BIDS format to 4d nii - have data in bids folder format
% spm SPM - SPM12 (7771)
% Created by Boulakis Paradeisios
% 15 June 2020
%-----------------------------------------------------------------------

subjects = [];
path_to_data  = '/home/rantanplan/Documents/Paris/heart_img_data/';

for subject = subjects
    subject = num2str(subject, '%02d');
        fprintf(['Proccessing Subject :',  subject, '\n'])
        anat_directory = [path_to_data,'sub-', subject,'/anat/'];
        func_directory = [path_to_data,'sub-', subject,'/func/'];
        disp(anat_directory)
        disp(func_directory)
    
        anat_file_names = dir([anat_directory]);
        anat_files = cell(numel(anat_file_names),1);
        func_file_names = dir([func_directory]);
        func_files = cell(numel(func_file_names),1);
        
        
        for i=1:numel(anat_file_names)
            anat_files{i} = [anat_directory anat_file_names(i).name];
        end
        for i=1:numel(func_file_names)
            func_files{i} = [func_directory func_file_names(i).name];
        end


        spm('defaults', 'fmri')
        spm_jobman('initcfg')
        
        %-----------------------------------------------------------------------
        matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'Anatomical';
        matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {
            
            cellstr(anat_files)
            
            }';
        matlabbatch{2}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'Functional';
        
        matlabbatch{2}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {
            
             cellstr(func_files)
           
            }';
        
        matlabbatch{3}.spm.util.cat.vols(1) = cfg_dep('Named File Selector: Anatomical(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
        matlabbatch{3}.spm.util.cat.name = sprintf('sub-%s_T1w.nii',subject);
        matlabbatch{3}.spm.util.cat.dtype = 4;
        matlabbatch{4}.spm.util.cat.vols(1) = cfg_dep('Named File Selector: Functional(1) - Files', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
        matlabbatch{4}.spm.util.cat.name = sprintf('sub-%s_heart_bold.nii',subject);
        matlabbatch{4}.spm.util.cat.dtype = 4;
        spm_jobman('run', matlabbatch)
end
  
