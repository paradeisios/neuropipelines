function job_info =  data_grabber(job_info)

    anat_directory = [job_info.path_to_data,'sub-', job_info.subject,'/anat/'];
    func_directory = [job_info.path_to_data,'sub-', job_info.subject,'/func/','sess-',job_info.session,'/'];

    anat_file_names = dir([anat_directory, job_info.aprefix, '*',job_info.curr_dtype]);
    anat_files = cell(numel(anat_file_names),1);
    func_file_names = dir([func_directory, job_info.fprefix, '*',job_info.curr_dtype]);
    func_files = cell(numel(func_file_names),1);

    for i=1:numel(anat_file_names)
        anat_files{i} = [anat_directory anat_file_names(i).name];
    end
    for i=1:numel(func_file_names)
        func_files{i} = [func_directory func_file_names(i).name];
    end
    
    mean_image_name = dir([func_directory 'mean*']);
    mean_image = cellstr([func_directory mean_image_name.name]);
    
    reallign_params_names = dir([func_directory 'rp*']);
    reallign_params = cellstr([func_directory reallign_params_names.name]);
    
    deformation_field_names =  dir([anat_directory 'y*']);
    deformation_fields = cellstr([anat_directory deformation_field_names.name]);
    
    job_info.anat_files = anat_files;
    job_info.func_files = func_files;
    job_info.mean_image = mean_image;
    job_info.reallign_params = reallign_params;
    job_info.deformation_fields = deformation_fields;
end

