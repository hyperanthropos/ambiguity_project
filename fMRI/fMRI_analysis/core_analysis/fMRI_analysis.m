%% FUNCTIONAL IMAGING ANALYSIS SCRIPT
% combined script to run 1st and 2nd level fMRI data analysis
% needs the "regressors.mat" file created by the "regressor_creation.m"
% script in a subfolder called "regressors"

%% SETUP
clear; close('all');

% set model
SET.estimate = 0; % acutually estimate data or only save the batches
SET.workers = 6; % number of parallel workers to use for estimation

SET.model = 'TEST'; % name the model to create a folder and save data
SET.regs = {'varlevel'}; % parametric modulators (pmods) to include
SET.ortho = 0; % set if pmods should be orthogonalized by SPM

SET.duration.type = 'events'; % how should duration be modeled - options: 'events', 'fixed', 'RT'
SET.duration.fixed = 1; % which duration if fixed (in seconds)

SET.subs = 1:40; % which subjects should be included (1:40)
SET.runs = 1:3; % which runs should be included (1:3)

% set directories
DIR.data = '/home/fridolin/DATA/EXPERIMENTS/04_Madeleine/DATA/fMRI/fMRI_images/preprocessed';
DIR.modeldata = '/home/fridolin/DATA/EXPERIMENTS/04_Madeleine/DATA/fMRI/fMRI_models';
DIR.spmpath = '/home/fridolin/DATA/MATLAB/SPM/spm12b/'; % path of SPM 12

% access current matlabbatch via SPM:
%   spm_jobman('interactive',matlabbatch);

%% GENERAL STARTUP

% PATHWORK
DIR.home = pwd;
addpath(fullfile(DIR.home, 'batches'));
addpath(fullfile(DIR.home, 'regressors'));
load('regressors.mat');
DIR.model = fullfile(DIR.modeldata, SET.model);
DIR.batchsave = fullfile(DIR.model, 'used_bacthes');
if exist(DIR.batchsave, 'dir') ~= 7; mkdir(DIR.batchsave); end
delete(fullfile(DIR.batchsave, '*'));

% START SPM AND PREPARE BATCH
addpath(DIR.spmpath);
spm('Defaults','fMRI');
spm_jobman('initcfg');

%% FIRST LEVEL ANALYSIS

%%% GENERATE BACTH TO LOOP
matlabbatch = create_first_level();
% set orthogonalization
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).orth = SET.ortho;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).orth = SET.ortho;
% generate correct amount of sessions
base_run = matlabbatch{1}.spm.stats.fmri_spec.sess;
for iRun = SET.runs
    matlabbatch{1}.spm.stats.fmri_spec.sess(iRun) = base_run;
end
% save batch
basebatch = fullfile(DIR.batchsave, 'base_batch.mat');
save(basebatch, 'matlabbatch');

%%% LOOP OVER SUBS
batchcollector = cell(size(SET.subs)); % preallocate
nRegs = length(SET.regs); % create additional variables
for iSub = SET.subs
    subcode = sprintf('%03d',iSub);
    
    % load batch
    load(basebatch);
    
    % set directory
    savedir = fullfile(DIR.model, 'first_level', ['sub_' num2str(subcode)]);  mkdir(savedir);
    matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(savedir);
    
    % session based operations |conditions: 1 = risky; 2 = ambiguous
    for iRun = SET.runs
        
        %%% --- SET SCANS
        
        filekeeper = cellstr(spm_select('ExtFPList', fullfile(DIR.data, num2str(subcode), 'mr_data'), '^swau.*run1.*.nii', inf));
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).scans = filekeeper;
        
        %%% --- SET ONSETS AND DURATIONS
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(1).onset = REGS.risk{iSub, iRun}.base.onsets(:);
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(2).onset = REGS.ambi{iSub, iRun}.base.onsets(:);
        switch SET.duration.type
            case 'events'
                matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(1).duration = 0;
                matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(2).duration = 0;
            case 'fixed'
                matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(1).duration = SET.duration.fixed;
                matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(2).duration = SET.duration.fixed;
            case 'RT'
                matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(1).duration = REGS.risk{iSub, iRun}.base.RT(:);
                matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(2).duration = REGS.ambi{iSub, iRun}.base.RT(:);
        end
        
        %%% --- SET PARAMETRIC MODULATORS PER RUN
        
        for regressor = 1:nRegs
            % regressors for risk
            matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(1).pmod(regressor).param = eval([ 'REGS.risk{iSub,iRun}.base.' SET.regs{regressor} '(:)' ]);
            matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(1).pmod(regressor).name = SET.regs{regressor};
            matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(1).pmod(regressor).poly = 1;
            % regressors for ambiguity
            matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(2).pmod(regressor).param = eval([ 'REGS.ambi{iSub,iRun}.base.' SET.regs{regressor} '(:)' ]);
            matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(2).pmod(regressor).name = SET.regs{regressor};
            matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(2).pmod(regressor).poly = 1;
        end
        
    end % end iRun loop (session based operations)
    
    %%% --- SET CONTRASTS
    
    % in general there are 4 types of contrasts to be used for later analysis:
    % (1) only risk; (2) only ambiguity; (3) ambiguity+risk versus baseline; (4) risk>ambiguity;
    % each of those is created for all pmods + one time only on the onsets using pmods just as covariates
    % so contrast 1:4 = onsets only; cons 5:8 = pmod 1; cons 9:12 = pmod 2, ...
    
    % determine how many contrasts will be created
    nCons = (nRegs+1)*4; % number of contrasts to create
    
    % create contrast names
    contrast_names = cell(1,nCons);
    suffixes{1} = 'risk'; suffixes{2} = 'ambi'; suffixes{3} = 'risk+ambi'; suffixes{4} = 'risk>ambi'; % prefixes for names
    counter = 0;
    for iConGroup = 0:length(SET.regs)
        for iSuffix = 1:4
            counter = counter + 1;
            if iConGroup == 0;
                contrast_names{counter} = ['base_' suffixes{iSuffix}];
            else
                contrast_names{counter} = [SET.regs{iConGroup} '_' suffixes{iSuffix}];
            end
        end
    end
    
    % create empty contrast vectors for one run
    session_con = zeros(nCons, (1+nRegs)*2 ); % ( 1 for onsets + number of regs ) * 2 conditions
    
    % fill empty contrast vector with contrasts for each pmod + onsets
    for iRegs = 0:nRegs
        if iRegs == 0
            session_con(1:4,1) = [1 0 1 1];
            session_con(1:4,1+nRegs+1) = [0 1 1 -1];
        else
            session_con( iRegs*4+1:iRegs*4+4, iRegs+1) = [1 0 1 1];
            session_con( iRegs*4+1:iRegs*4+4, nRegs+1+iRegs+1) = [0 1 1 -1];
        end
    end
    
    % replicate contrast for one session over all
    nNuisance = 0; % number of nuisance parameters in the design matrix created from phyiological data
    zero_padding = zeros(nCons,nNuisance+length(SET.runs));  % zeros for nuisance and run means
    contrasts = [repmat(session_con, 1, length(SET.runs)), zero_padding];
    
    % write contrasts into the batch
    for iCon = 1:nCons
        matlabbatch{3}.spm.stats.con.consess{iCon}.tcon.weights = contrasts(iCon,:);
        matlabbatch{3}.spm.stats.con.consess{iCon}.tcon.name = char(contrast_names{iCon});
        matlabbatch{3}.spm.stats.con.consess{iCon}.tcon.sessrep = 'none';
    end
    
    % save batch
    save(fullfile(DIR.batchsave, [num2str(subcode) '_first_level.mat']));
    batchcollector{iSub} = matlabbatch;
    
end % end iSubs loop

%%% ANALYZE FIRST LEVEL
if SET.estimate == 1;
    % start parallel processing
    parpool(SET.workers);
    parsub = SET.subs;
    % run batches
    parfor iSub = parsub
        disp(['++++++++++++++++++++++++++++++++++++++++++++++ RUN SUB ' num2str(iSub) ' ++++++++++++++++++++++++++++++++++++++++++++++']);
        spm_jobman('initcfg');
        spm_jobman('run',batchcollector{iSub});
    end
    delete(gcp);
end

%% SECOND LEVEL ANALYSIS

%%% TODO - CHANGE base. covar. regressor structure to simplier mechanism

% % % --> copy data
% % 
% % % load batch
% % matlabbatch = create_second_level();
% % 
% % % set directory
% % savedir = fullfile(DIR.model, 'second_level', 'one_sample');  mkdir(savedir);
% % 
% % 
% % % --> analyse batch
% % spm_jobman('initcfg');
% % spm_jobman('run',matlabbatch);
% % 
% % % optional: some automated ouptput

