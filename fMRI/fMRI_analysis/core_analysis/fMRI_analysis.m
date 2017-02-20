%% FUNCTIONAL IMAGING ANALYSIS SCRIPT
% combined script to run 1st and 2nd level fMRI data analysis
% needs functions to generate SPM batchfiles create_first_level.m & create_second_level.m in a subfolder called "batches"
% needs the "regressors.mat" file created by the "regressor_creation.m" script in a subfolder called "regressors"

%% SETUP
clear; close('all'); clc;

% set model
SET.estimate = 0; % acutually estimate data or only save the batches
SET.workers = 6; % number of parallel workers to use for estimation

SET.model = 'TEST'; % name the model to create a folder and save data
SET.regs = {'varlevel'}; % parametric modulators (pmods) to include
SET.ortho = 0; % set if pmods should be orthogonalized by SPM

SET.duration_type = 'events'; % how should duration be modeled - options: 'events', 'fixed', 'RT'
SET.duration_fixed = 0; % which duration if fixed (in seconds)

SET.subs = 1:40; % which subjects should be included (1:40)
SET.runs = 1:3; % which runs should be included (1:3)

% set directories
DIR.data = '/home/fridolin/DATA/EXPERIMENTS/04_Madeleine/DATA/fMRI/fMRI_images/preprocessed';
DIR.modeldata = '/home/fridolin/DATA/EXPERIMENTS/04_Madeleine/DATA/fMRI/fMRI_models';
DIR.spmpath = '/home/fridolin/DATA/MATLAB/SPM/spm12b/'; % path of SPM 12

% access current matlabbatch via SPM:
%   spm_jobman('interactive',matlabbatch);

%% GENERAL STARTUP

% SECURITY CHECK
if  SET.estimate == 1;
    warning('if the model is set to estimate the whole model folder will be deleted and recreated!');
    disp('do you want to continue? 1 = no, 2 = yes');
    answer = input(' ');
    if answer ~= 2
        error('please correct your "SET.estimate" flag');
    end
end

% PATHWORK
DIR.home = pwd;
addpath(fullfile(DIR.home, 'batches'));
addpath(fullfile(DIR.home, 'regressors'));
load('regressors.mat');
% make directories
DIR.model = fullfile(DIR.modeldata, SET.model);
DIR.batchsave = fullfile(DIR.model, 'used_bacthes');
DIR.first_level = fullfile(DIR.model, 'first_level');
DIR.second_level = fullfile(DIR.model, 'second_level');
% clear old data
if SET.estimate == 1;
    if exist(DIR.model, 'dir') == 7; rmdir(fullfile(DIR.model),'s'); end
else
    delete(fullfile(DIR.batchsave, '*'));
end

% START SPM AND PREPARE BATCH
fprintf('starting spm and preparing analysis...');
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
if exist(DIR.batchsave, 'dir') ~= 7; mkdir(DIR.batchsave); end
basebatch = fullfile(DIR.batchsave, 'base_batch_first_level.mat');
save(basebatch, 'matlabbatch');
disp(' done');

%%% LOOP OVER SUBS
fprintf('building batchfiles for spm for each subject...');
batchcollector = cell(size(SET.subs)); % preallocate
nRegs = length(SET.regs); % create additional variables
for iSub = SET.subs
    subcode = sprintf('%03d',iSub);
    
    % load batch
    load(basebatch);
    
    % set directory
    savedir = fullfile(DIR.first_level, ['sub_' num2str(subcode)]);
    matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(savedir);
    
    % session based operations |conditions: 1 = risky; 2 = ambiguous
    for iRun = SET.runs
        
        %%% --- SET SCANS
        
        filekeeper = cellstr(spm_select('ExtFPList', fullfile(DIR.data, num2str(subcode), 'mr_data'), '^swau.*run1.*.nii', inf));
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).scans = filekeeper;
        
        %%% --- SET ONSETS AND DURATIONS
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(1).onset = REGS.risk{iSub, iRun}.base.onsets(:);
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(2).onset = REGS.ambi{iSub, iRun}.base.onsets(:);
        switch SET.duration_type
            case 'events'
                matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(1).duration = 0;
                matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(2).duration = 0;
            case 'fixed'
                matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(1).duration = SET.duration_fixed;
                matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(2).duration = SET.duration_fixed;
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
disp(' done!');

%%% ANALYZE FIRST LEVEL

% set destination for first level results (contrasts)
destination = fullfile(DIR.first_level, 'all_contrasts');
if exist(destination, 'dir') ~= 7; mkdir(destination); end

if SET.estimate == 1;
    
    %%% START ACTUAL SPM GENERAL LINEAR MODEL ESTIMATION
    
    % start parallel processing
    parpool(SET.workers);
    parsub = SET.subs;
    % run batches
    parfor iSub = parsub
        disp(['+++++++++++++++++++++++++++++++++++++++ RUN SUB ' num2str(iSub) ' +++++++++++++++++++++++++++++++++++++++']);
        mkdir(char(batchcollector{iSub}{1}.spm.stats.fmri_spec.dir));
        spm_jobman('initcfg');
        spm_jobman('run',batchcollector{iSub});
    end
    delete(gcp);
    
    %%% COPY FIRST LEVEL CONTRASTS
    fprintf('now copying and renaming first-level contrasts for second level processing...');
    
    % ... and copy files
    for iCon = 1:nCons
        concode = sprintf('%04d',iCon);
        for iSub = SET.subs
            subcode = sprintf('%03d',iSub);
            
            input = fullfile(DIR.first_level, ['sub_' num2str(subcode)], ['con_' num2str(concode) '.nii']);
            output = fullfile(destination, [contrast_names{iCon} '_' num2str(subcode) '.nii']);
            
            if exist(input, 'file') == 2;
                copyfile(input, output);
            else
                disp(' the following file does not exist:');
                disp(input);
                error(['there seems to be a problem with contrast ' num2str(iCon) ' of subject ' num2str(iSub) ' - please correct that issue!']);
            end
        end
    end
    disp(' done!');
    
end
clear('batchcollector');

%% SECOND LEVEL ANALYSIS
    
%%% BUILD AND MODIFY BATCH 1 (two sample t-test; risk vs. ambi)
fprintf('building batchfiles for second level analysis...');

% load batch
matlabbatch = create_second_level();
basebatch = fullfile(DIR.batchsave, 'base_batch_second_level.mat');
save(basebatch, 'matlabbatch');

% create a unique batch for each pmod + onset
all_params = ['base' SET.regs];
for iBatch = 1:length(all_params)
    
    % load batch
    load(basebatch);
    
    %%% TEST 1 - paired t-test (risk & ambiguity)
    
    % set directory
    savedir = fullfile(DIR.second_level, [num2str(sprintf('%02d',iBatch)) '_' all_params{iBatch}]);
    matlabbatch{1, 1}.spm.stats.factorial_design.dir = cellstr(savedir);
    
    % select files
    % remember: suffixes{1} = 'risk'; suffixes{2} = 'ambi'; suffixes{3} = 'risk+ambi'; suffixes{4} = 'risk>ambi';
    filekeeper_risk = cellstr(spm_select('ExtFPList', destination, ['^' all_params{iBatch} '_' suffixes{1} '_.*.nii'], inf));
    filekeeper_ambi = cellstr(spm_select('ExtFPList', destination, ['^' all_params{iBatch} '_' suffixes{2} '_.*.nii'], inf));
    for iSub = SET.subs
        filekeeper = [filekeeper_risk(iSub); filekeeper_ambi(iSub)];
        matlabbatch{1, 1}.spm.stats.factorial_design.des.pt.pair(iSub).scans = filekeeper;
    end
    
    %%% TEST 2 - two sample t-test (risk & ambiguity)
    
    %%% TEST 3 - one sample t-test risk
    
    %%% TEST 4 - one sample t-test ambiguity
    
    %%% TEST 5 - one sample t-test risk>ambiguity
    
    
    
    
    
    % save batch
    save( fullfile(DIR.batchsave, ['X_' num2str(sprintf('%02d',iBatch)) '_' all_params{iBatch} '_second_level.mat']) );
    
    % save batch for processing
    batchcollector{iBatch} = matlabbatch;
    
end
disp(' done');


keyboard;

 
%%% BUILD AND MODIFY BATCH 2 (ANOVA; all parameters)

%%%%%%%%%% UNDER CONSTRUCTION %%%%%%%%%%%%%%%%%%%%%%%

% % %     % load batch
% % %     matlabbatch = create_second_level('ANOVA');
% % %     savebatch = fullfile(DIR.batchsave, ['X_' 'all_pmods_batch_second_level.mat']);
% % %     save(savebatch, 'matlabbatch');
% % %     %%% --> build another factorial design to compare all pmods with an F-test
% % % 
% % %     % save batch for processing
% % %     batchcollector{iRegs+1+1} = matlabbatch;
% % % 
% % %     % spm_jobman('interactive',matlabbatch);

%%%%%%%%%% UNDER CONSTRUCTION %%%%%%%%%%%%%%%%%%%%%%%

% run second level analysis
if SET.estimate == 1;
    for iReg = 0:nRegs
        disp(['+++++++++++++++++++++++++++++++++++++++ RUN 2nd LEVEL REG ' num2str(iReg) ' +++++++++++++++++++++++++++++++++++++++']);
        mkdir(char(batchcollector{iRegs+1}{1}.spm.stats.factorial_design.dir));
        spm_jobman('initcfg');
        spm_jobman('run',batchcollector{iRegs+1});
    end
end

%% OUTPUT LOGS

%%% TODO - CHANGE base. covar. regressor structure to simplier mechanism

if SET.estimate == 1;
    % make a diary file
    disp(SET);
    disp(DIR);
end

disp('ALL OPERATIONS COMPLETE - THANK YOU, COME AGAIN');

%%%%%%%%%%%%%% SCRATCHPAD:

% % % % Example 3:  Making a conjunction map between two suprathreshold t-maps
% % % 
% % % % Read in both t-maps
% % % TMap1 = spm_read_vols(spm_vol('/Users/mvlombardo/Documents/fMRI/Contrast1/spmT_0001.img'));
% % % TMap2 = spm_read_vols(spm_vol('/Users/mvlombardo/Documents/fMRI/Contrast1/spmT_0002.img'));
% % % 
% % % % Define t-threshold
% % % tthresh = 3.1768423;
% % % 
% % % % Mask out suprathreshold voxels from both t-maps
% % % TMap1_suprathresh = TMap1>=tthresh;
% % % TMap2_suprathresh = TMap2>=tthresh;
% % % 
% % % % Make conjunction map as the logical AND of both suprathreshold t-maps
% % % ConjunctionMap = TMap1_suprathresh & TMap2_suprathresh;
% % % 
% % % % Write out the new conjunction map
% % % V = spm_vol('/Users/mvlombardo/Documents/fMRI/Contrast1/spmT_0001.img');
% % % V.fname = 'ConjunctionMap_TMap1_AND_TMap2.nii';
% % % V.private.dat.fname = V.fname;
% % % spm_write_vol(V,ConjunctionMap);


