function spm_preprocess_batch(job_info)

% A large script to conduct all spm preprocess. For this script to work
% data must use a bids format where:
%
%   data folder ==> subjects (sub-xx) ==> anatomical data (anat)
%                                     ==> functional data (func)  ==> sessions (sess-xx) 
%
%If there is only one session, please add it in a folder denoted sess-01

% How to use : specify the following struct (mind that jobs are specified
% as strings)

% job_info = struct;
% job_info.path_to_data = '/path/to/data/';
% job_info.spm_folder = '/path/to/spm/folder/';
% job_info.subjects = [1,2,...,n];
% job_info.sessions = [1,2,...,n];
% job_info.jobs = ["re","co","se","nm","sm","ar"];
% job_info.temporal.nslices = x;
% job_info.temporal.TR = x;
% job_info.temporal.slice_order = x;
% job_info.temporal.refslice = x;
% job_info.prefix = 2 first letter of your mr images

% Available jobs
% dicom import                - im
% 3d to 4d                    - 4d
% unzip                       - gz
% realign                     - re
% slice time                  - sl
% coregister                  - co
% segment                     - se
% normalize func and anat     - nm
% smooth                      - sm
% art                         - ar

% cleanining

spm('defaults', 'FMRI');
spm fmri

% logger
filename = [job_info.path_to_data sprintf('%s-Preprocessing.txt',date)];
fid = fopen(filename, 'wt');
fprintf(fid,[datestr(now,'HH:MM:SS'),' Working on folder: ',job_info.path_to_data, '\n\n']);

% data type
if contains("im",job_info.jobs)
    job_info.dtype = 'MR.dic';
elseif contains("4d",job_info.jobs)
    job_info.dtype = '.img';
elseif contains("gz",job_info.jobs)
    job_info.dtype = '.nii.gz';
else
    job_info.dtype = input('Enter mr image data type (nii / img):','s');   
end


if (contains("im",job_info.jobs) && contains("4d",job_info.jobs)) || ...
   (contains("im",job_info.jobs) && contains("gz",job_info.jobs)) || ... 
   (contains("4d",job_info.jobs) && contains("gz",job_info.jobs))
    msg = 'You entered contradictory data types for mri images.';
    error(msg)
end

% subject/session loop

for subject = job_info.subjects
    job_info.subject = num2str(subject, '%02d');
    
    for session = job_info.sessions
        job_info.session = num2str(session, '%02d');
        
        fprintf(fid,[datestr(now,'HH:MM:SS'),' Working on Subject: ',job_info.subject,'----- Session: ',job_info.session,'\n']);

        % prefix cleaning
        job_info.fprefix = job_info.prefix;
        job_info.aprefix = job_info.prefix;
        job_info.curr_dtype = job_info.dtype;
        % getdata
        job_info =  data_grabber(job_info);

        % unzip
        if  contains("gz",job_info.jobs)
            fprintf(fid,[datestr(now,'HH:MM:SS'),' Gunzipping anatomical files\n']);
            gunzip(job_info.anat_files)
            fprintf(fid,[datestr(now,'HH:MM:SS'),' Gunzipping functional files\n']);
            gunzip(job_info.func_files)
            job_info.curr_dtype = 'nii';
        end

        % dicom import - im
        if  contains("im",job_info.jobs)
            fprintf(fid,[datestr(now,'HH:MM:SS'),' Converting dicoms to 4d images\n']);
            
            matlabbatch = {};
            matlabbatch{1}.spm.util.import.dicom.data = job_info.anat_files;
            matlabbatch{1}.spm.util.import.dicom.root = 'flat';
            matlabbatch{1}.spm.util.import.dicom.outdir = {''};
            matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
            matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
            matlabbatch{1}.spm.util.import.dicom.convopts.meta = 0;
            matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;

            matlabbatch{2}.spm.util.import.dicom.data = job_info.func_files;
            matlabbatch{2}.spm.util.import.dicom.root = 'flat';
            matlabbatch{2}.spm.util.import.dicom.outdir = {''};
            matlabbatch{2}.spm.util.import.dicom.protfilter = '.*';
            matlabbatch{2}.spm.util.import.dicom.convopts.format = 'nii';
            matlabbatch{2}.spm.util.import.dicom.convopts.meta = 0;
            matlabbatch{2}.spm.util.import.dicom.convopts.icedims = 0;

            spm_jobman('run', matlabbatch)

            job_info.curr_dtype = 'nii';
        end
        % 3d to 4d 
        if  contains("4d",job_info.jobs)
            fprintf(fid,[datestr(now,'HH:MM:SS'),' Converting 3d images to 4d\n']);
            
            matlabbatch = {};
            matlabbatch{1}.spm.util.cat.vols = job_info.anat_files;
            matlabbatch{1}.spm.util.cat.name = [job_info.aprefix,'_anatomical_4D.nii'];
            matlabbatch{1}.spm.util.cat.dtype = 4;
            matlabbatch{1}.spm.util.cat.RT = NaN;

            matlabbatch{2}.spm.util.cat.vols = job_info.func_files;
            matlabbatch{2}.spm.util.cat.name = [job_info.fprefix,'_functional_4D.nii'];
            matlabbatch{2}.spm.util.cat.dtype = 4;

            spm_jobman('run', matlabbatch)

            job_info.curr_dtype = 'nii';
            job_info =  data_grabber(job_info);
        end
        % realign
        if  contains("re",job_info.jobs)

            fprintf(fid,[datestr(now,'HH:MM:SS'),' Starting Reallignment and Rescling\n']);

            matlabbatch = {};
            matlabbatch{1}.spm.spatial.realign.estwrite.data = {job_info.func_files};
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r' ;

            spm_jobman('run', matlabbatch)

            fprintf(fid,[datestr(now,'HH:MM:SS'),' Reallignment and Rescling Ended\n']);
            job_info.fprefix = ['r' job_info.fprefix];
            job_info =  data_grabber(job_info);
        end
        
        % slice time correction
        if  contains("sl",job_info.jobs)
            fprintf(fid,[datestr(now,'HH:MM:SS'),' Starting Slice Time Correction\n']);
            matlabbatch = {};
            matlabbatch{1}.spm.temporal.st.scans = {job_info.func_files};
            matlabbatch{1}.spm.temporal.st.nslices = job_info.temporal.nslices;
            matlabbatch{1}.spm.temporal.st.tr = job_info.temporal.TR;
            matlabbatch{1}.spm.temporal.st.ta = job_info.temporal.TR-(job_info.temporal.TR/job_info.temporal.TR);

            matlabbatch{1}.spm.temporal.st.so = job_info.temporal.slice_order;
            matlabbatch{1}.spm.temporal.st.refslice = job_info.temporal.refslice;
            matlabbatch{1}.spm.temporal.st.prefix = 'a' ;

            spm_jobman('run', matlabbatch)
            fprintf(fid,[datestr(now,'HH:MM:SS'),' Slice Time Correction Ended\n']);

            job_info.fprefix = ['a' job_info.fprefix];
            job_info =  data_grabber(job_info);
        end
        % coregister
        if  contains("co",job_info.jobs)

            fprintf(fid,[datestr(now,'HH:MM:SS'),' Starting Coregistration\n']);

            matlabbatch = {};
            matlabbatch{1}.spm.spatial.coreg.estimate.ref = job_info.mean_image;
            matlabbatch{1}.spm.spatial.coreg.estimate.source = job_info.anat_files;
            matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

            spm_jobman('run', matlabbatch)

            fprintf(fid,[datestr(now,'HH:MM:SS'),' Coregistration Ended\n']);
            job_info =  data_grabber(job_info);
        end
        % segment

        if  contains("se",job_info.jobs)

            fprintf(fid,[datestr(now,'HH:MM:SS'),' Starting Segmentation\n']);
            matlabbatch = {};
            matlabbatch{1}.spm.spatial.preproc.channel.vols = job_info.anat_files;
            matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
            matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
            matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {sprintf('%stpm/TPM.nii,1',job_info.spm_folder)};
            matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
            matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {sprintf('%stpm/TPM.nii,2',job_info.spm_folder)};
            matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
            matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {sprintf('%stpm/TPM.nii,3',job_info.spm_folder)};
            matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
            matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {sprintf('%stpm/TPM.nii,4',job_info.spm_folder)};
            matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
            matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {sprintf('%stpm/TPM.nii,5',job_info.spm_folder)};
            matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
            matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {sprintf('%stpm/TPM.nii,6',job_info.spm_folder)};
            matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
            matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
            matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
            matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
            matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
            matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
            matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
            matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];
            matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
            matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                                          NaN NaN NaN];
            spm_jobman('run', matlabbatch)
            fprintf(fid,[datestr(now,'HH:MM:SS'),' Segmentation Ended\n']);
            job_info =  data_grabber(job_info);
        end
        % normalize
        if contains("nm",job_info.jobs)

            fprintf(fid,[datestr(now,'HH:MM:SS'),' Starting Normalization\n']);
            matlabbatch = {};
            matlabbatch{1}.spm.spatial.normalise.write.subj.def = job_info.deformation_fields;
            matlabbatch{1}.spm.spatial.normalise.write.subj.resample = job_info.func_files;
            matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                                      78 76 85];
            matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
            matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
            matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';

            matlabbatch{2}.spm.spatial.normalise.write.subj.def = job_info.deformation_fields;
            matlabbatch{2}.spm.spatial.normalise.write.subj.resample = job_info.anat_files;
            matlabbatch{2}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                                      78 76 85];
            matlabbatch{2}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
            matlabbatch{2}.spm.spatial.normalise.write.woptions.interp = 4;
            matlabbatch{2}.spm.spatial.normalise.write.woptions.prefix = 'w';

            spm_jobman('run', matlabbatch)

            fprintf(fid,[datestr(now,'HH:MM:SS'),' Normalization Ended\n']);
            job_info.fprefix = ['w' job_info.fprefix];
            job_info =  data_grabber(job_info);
        end

        % smooth

        if contains("sm",job_info.jobs)

            fprintf(fid,[datestr(now,'HH:MM:SS'),' Starting Smoothing\n']);
            matlabbatch = {};
            matlabbatch{1}.spm.spatial.smooth.data = job_info.func_files;
            matlabbatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';

            spm_jobman('run', matlabbatch)

            fprintf(fid,[datestr(now,'HH:MM:SS'),' Smoothing Ended\n']);
            job_info.fprefix = ['s' job_info.fprefix];
            job_info =  data_grabber(job_info);
        end
     fprintf(fid,'\n\n');
    end
end
end


