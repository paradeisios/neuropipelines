## SPM SCRIPTING HELPER

```spm_preprocess_batch.m``` is a self contained spm  script that covers a wide variety of preprocessing steps. The goal is to minimize user inputs, and facilitate multi subject preprocessing.

The script accepts a job_info struct that contains all the necessary information to run the preprocessing pipeline.

% job_info = struct;<br/>
% job_info.path_to_data = '/path/to/data/';<br/>
% job_info.spm_folder = '/path/to/spm/folder/';<br/>
% job_info.subjects = [1,2,...,n];<br/>
% job_info.sessions = [1,2,...,n];<br/>
% job_info.jobs = ["re","co","se"];<br/>
% job_info.temporal.nslices = x;<br/>
% job_info.temporal.TR = x;<br/>
% job_info.temporal.slice_order = x;<br/>
% job_info.temporal.refslice = x;<br/>
% job_info.prefix = 2 first letter of your mr images<br/>

The current available jobs are:

% dicom import                - im<br/>
% 3d to 4d                    - 4d<br/>
% unzip                       - gz<br/>
% realign                     - re<br/>
% slice time                  - sl<br/>
% coregister                  - co<br/>
% segment                     - se<br/>
% normalize func and anat     - nm<br/>
% smooth                      - sm<br/>
% art                         - ar<br/>

Please make sure that your data are in BIDS format, you input the jobs as STRINGS and the prefix as CHAR. 
