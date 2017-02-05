%% SCRIPT TO CREATE fMRI REGRESSORS
% this script creates required basic data for an SPM GLM and regressors for
% parametric modulations
% it needs logfiles created by the fmri task "start_exp.m" script
% reads data from parameter_creation script

% input has the following structure
    % LINE 01 - trial number
    % LINE 02 - trial presentation time
    % LINE 03 - reaction time
    % LINE 04 - choice: 1 = fixed option; 2 = risky/ambiguous option
    % LINE 05 - choice: 1 = fixed, risky; 2 = risky; 3 = fixed, ambiguous; 4 = ambiguous
    % LINE 06 - choice: 1 = left, 2 = right
    % LINE 07 - trial type: 1 = risky, 2 = ambiguous
    % LINE 08 - [not used for this experiment]
    % LINE 09 - position of counteroffer: 1 = left, 2 = right
    % LINE 10 - probability of high amount
    % LINE 11 - probability of low amount
    % LINE 12 - risky amount high
    % LINE 13 - risky amount low
    % LINE 14 - ambiguous amount high
    % LINE 15 - ambiguous amount low
    % LINE 16 - counteroffer amount

    % LINE 17 - stimulus number (sorted)
    % LINE 18 - session number (to combine matrices for behavioral analysis)
    % LINE 19 - risk variance level (1-5; low to high variance)
    % LINE 20 - ambiguity variance level (1-5; low to high variance
    % LINE 21 - counteroffer level (1-number of levels; low to high counteroffer)

%% SETUP
clear; close all; clc;

SUBJECTS = 1:40;
SESSIONS = 1:3;

%% PREPARE SCRIPT

% set paths, load data
DIR.home = pwd;
DIR.input = fullfile(DIR.home, 'behavioral_results');
DIR.data = fullfile(DIR.home, 'analysis_results');
load(fullfile(DIR.data, 'parameters.mat'), 'PARAM');

%% CREATE REGRESSORS

% insert proper REGS preallocation

for sub = SUBJECTS
    fprintf(['analysing subject subject ' num2str(sub) ' ... ']);
    for run = SESSIONS
        
        % load subjects stimuli and response created from the experiment
        load_file = fullfile(DIR.input, [ 'part_' sprintf('%03d', sub) '_sess_' num2str(run) '.mat'] );
        load(load_file, 'logrec');
        
        % run seperately for both types
        for trialtype = {'risky', 'ambiguous'}
            
            % select only one type of trials
            switch cell2mat(trialtype)
                case 'risky'
                    select = logrec(:,logrec(7,:) == 1); % only risk trials
                    variance_location = 19; % where is the variance in the logrec stored
                case 'ambiguous'
                    select = logrec(:,logrec(7,:) == 2); % only ambiguous trials
                    variance_location = 20; % where is the variance in the logrec stored
            end
            
            data.onsets = select(2,:); % onset times in seconds
            data.RT = select(3,:); % RT
            data.varlevel = select(variance_location, :); % level of variance 1-5 increasing
            
            % create regs of one type of trials
            switch cell2mat(trialtype)
                case 'risky'
                    REGS.risk{sub,run} = data; % all data of risky trials
                case 'ambiguous'
                    REGS.ambi{sub,run} = data; % all data of ambi trials
            end
         
        % end trialtype loop  
        end
        
    end
    disp('done.');
end

%% SAVE REGS DATA

save(fullfile(DIR.data, 'regressors.mat'), 'REGS');
