function job_info = create_cfg_file(job_info)

job_info.fprefix = 'r';
job_info =  data_grabber(job_info);

filename = [job_info.path_to_data sprintf('%s-Sub-%s-Sess-%s-art-cfg.cfg',date,job_info.subject,job_info.session)];

cfg_file = fopen(filename,'wt');
fprintf(cfg_file,'sessions: 1\n');                         %number of sessions
fprintf(cfg_file,'global_mean: 1\n');                      %global mean type (1: Standard 2: User-defined mask)
fprintf(cfg_file,'global_threshold: 9.0\n');               %threhsolds for outlier detection
fprintf(cfg_file,'motion_threshold: 2.0\n');
fprintf(cfg_file,'motion_file_type: 0\n');                 %motion file type (0: SPM .txt file 1: FSL .par file 2:Siemens .txt file)
fprintf(cfg_file,'motion_fname_from_image_fname: 0\n');    %1/0: derive motion filename from data filename
fprintf(cfg_file,'end\n');

if job_info.curr_dtype == 'nii'
    fprintf(cfg_file,['session 1 image ',job_info.func_files{1},'\n']);
end

if job_info.curr_dtype == 'img'
    for i=1:length(job_info.func_files)
        fprintf(cfg_file,['session 1 image ',job_info.func_files{i},'\n']);
    end
end

fprintf(cfg_file,['session 1 motion ',job_info.reallign_params{1},'\n']);
fprintf(cfg_file,'end\n');
fclose(cfg_file);

job_info.cfg_file = filename;


end
