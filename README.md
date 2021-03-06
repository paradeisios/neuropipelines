# SPM SCRIPTING HELPER

```spm_preprocess_batch.m``` is a self contained spm  script that covers a wide variety of preprocessing steps. The goal is to minimize user inputs, and facilitate multi subject preprocessing.

The script accepts a job_info struct that contains all the necessary information to run the preprocessing pipeline.

% job_info = struct;
% job_info.path_to_data = '/path/to/data/';
% job_info.spm_folder = '/path/to/spm/folder/';
% job_info.subjects = [1,2,...,n];
% job_info.sessions = [1,2,...,n];
% job_info.jobs = ["re","co","se"];
% job_info.temporal.nslices = x;
% job_info.temporal.TR = x;
% job_info.temporal.slice_order = x;
% job_info.temporal.refslice = x;
% job_info.prefix = 2 first letter of your mr images

The current available jobs are:

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

Please make sure that your data are in BIDS format, you input the jobs as STRINGS and the prefix as CHAR. 
