%% code to preprocess fMRI data
% uses spm12 toolbox
% needs a SPM preprocessing batch to work with

%% SETUP
clear; close all;

% where is the data to be processed stored:
DATA_FOLDER = '/home/fridolin/DATA/EXPERIMENTS/04_Madeleine/DATA/fMRI/fMRI_images/prepro_test';
% which batch should be used for processing (must be in a "batch" subfolder):
BATCH = 'prepro_batch.mat';
% which subjects should be processed:
SUBJECTS = 1:40;

% SPM SETUP
DIR.SPM.spmpath = '/home/fridolin/DATA/MATLAB/SPM/spm12b/'; % path of SPM 12
% path for tissue probability maps to use for segmentation
DIR.SPM.tissuemaps = '/home/fridolin/DATA/MATLAB/SPM/spm12b/tpm/';

% PARAMETERS
P.TR = 2.372; % time to repeat
P.SLICES = 40; % number of slices

% access current matlabbatch via SPM:
% spm_jobman('interactive',matlabbatch);

%% PREPARE PREPROCESSING

% DO SOME PATHWORK
DIR.home = pwd;
DIR.data = DATA_FOLDER; clear DATA_FOLDER;
DIR.batch = fullfile(DIR.home, 'batch');
DIR.savedir = fullfile(DIR.batch, 'used_batches');
if exist(DIR.savedir, 'dir') ~= 7; mkdir(DIR.savedir); end

% START SPM AND PREPARE BATCH
addpath(DIR.SPM.spmpath);
spm('Defaults','fMRI');
spm_jobman('initcfg');

% load batch
load(fullfile(DIR.batch, BATCH));

% add tissue probability maps
filekeeper = cellstr(spm_select('ExtFPList', fullfile(DIR.SPM.tissuemaps), 'TPM.nii', inf));
for tpm = 1:6;
    matlabbatch{1, 3}.spm.spatial.preproc.tissue(tpm).tpm = filekeeper(tpm);
end
clear tpm;

% set slice time correction parameters
matlabbatch{1, 2}.spm.temporal.st.nslices = P.SLICES;
matlabbatch{1, 2}.spm.temporal.st.tr = P.TR;
matlabbatch{1, 2}.spm.temporal.st.ta = P.TR-(P.TR/P.SLICES);
matlabbatch{1, 2}.spm.temporal.st.so = 1:P.SLICES; % assuming ascending aquisition
matlabbatch{1, 2}.spm.temporal.st.refslice = round(P.SLICES/2);

% save batch for subject loop
save(fullfile(DIR.savedir, 'base_batch.mat'), 'matlabbatch');

clear matlabbatch;

%% LOAD AND MODIFY THE BATCH, START PROCESSING

% prepare batches
parallel_store = cell(1, size(SUBJECTS,2));
for sub = SUBJECTS
    
    subcode = sprintf('%03d',sub);

    % load batch
    load(fullfile(DIR.savedir, 'base_batch.mat'));
    
    % add files to process
    filekeeper = cellstr(spm_select('ExtFPList', fullfile(DIR.data, subcode, 'mr_data'), '^sn.*run1.*nii', inf));
    matlabbatch{1, 1}.spm.spatial.realignunwarp.data(1).scans = filekeeper;
    
    filekeeper = cellstr(spm_select('ExtFPList', fullfile(DIR.data, subcode, 'mr_data'), '^sn.*run2.*nii', inf));
    matlabbatch{1, 1}.spm.spatial.realignunwarp.data(2).scans = filekeeper;
    
    filekeeper = cellstr(spm_select('ExtFPList', fullfile(DIR.data, subcode, 'mr_data'), '^sn.*run3.*nii', inf));
    matlabbatch{1, 1}.spm.spatial.realignunwarp.data(3).scans = filekeeper;
    
    filekeeper = cellstr(spm_select('ExtFPList', fullfile(DIR.data, subcode, 'mr_data'), '^sn.*t1.*nii', inf));
    matlabbatch{1, 3}.spm.spatial.preproc.channel.vols = filekeeper;
    
    % save batch
    save(fullfile(DIR.savedir, ['sub_' subcode '_batch.mat']), 'matlabbatch');
    parallel_store{sub} = matlabbatch;
   
end

% run batches
parfor sub = SUBJECTS
    spm_jobman('initcfg');
    spm_jobman('run',parallel_store{sub});
end

clear subcode filekeeper matlabbatch sub;

%% FINISH SCRIPT AND SAVE DIAGNOSTICS

save(fullfile(DIR.savedir, 'prepro_parameters.mat'));
