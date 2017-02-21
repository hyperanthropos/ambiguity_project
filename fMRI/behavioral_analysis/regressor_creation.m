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
    
% the following data for a GLM data is created
    % onsets                % onset times in seconds
    % RT                    % RT
    % varlevel              % level of variance: 1-5 increasing
    % chosen_var            % only variance levels of chosen trials
    % chosen_var_neg        % variance inversely coded if not chosen
    %             
    % counteroffer          % value of counteroffer
    % diff_value            % difference in EV between options (positive = counteroffer higher than gamble)
    % abs_value             % absolute presented value
    % position              % position of counteroffer: 0 = left, 1 = right
    % choice                % chosen option: 1 = fixed option; 2 = risky/ambiguous option


%% SETUP
clear; close all; clc;

% set range
SUBJECTS = 1:40; % subs to analyze
SESSIONS = 1:3; % sessions/runs to analyze
SAVEREGS = 1; % save created regressors or only show graphical output

% set graphical output
% (to check independence / orhthogonalization of regressors to use)
FIGURE.PAUSE = 0; % create a pause to examine online figure before next subjects' data is drawn 
FIGURE.SUBS = 40; % for which subjects should a correlation matrix be created
FIGURE.SESS = 3; % for which runs shoould a correlation matrix be created

% define fixed EV for all offers
EV = 22.5;

%% PREPARE SCRIPT

% set paths, load data
DIR.home = pwd;
DIR.input = fullfile(DIR.home, 'behavioral_results');
DIR.data = fullfile(DIR.home, 'analysis_results');
load(fullfile(DIR.data, 'parameters.mat'), 'PARAM');

%% CREATE REGRESSORS

% preallocate
REGS.risk = cell(size(SUBJECTS, 2), size(SESSIONS, 2)); REGS.ambi = REGS.risk;

% open online covariance output
online_fig = figure('Name', 'online correlation of regs', 'Color', 'w', 'units', 'normalized', 'outerposition', [.3 .3 .5 .6]);

for sub = SUBJECTS
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
                    high_amount_location = 12;
                    low_amount_location = 13;
                case 'ambiguous'
                    select = logrec(:,logrec(7,:) == 2); % only ambiguous trials
                    variance_location = 20; % where is the variance in the logrec stored
                    high_amount_location = 14;
                    low_amount_location = 15;
            end
            
            % create base regressors
            data.onsets = select(2,:); % onset times in seconds
            data.RT = select(3,:); % RT
            data.varlevel = select(variance_location, :); % level of variance: 1-5 increasing
            data.chosen_var = select(variance_location, :).*(select(4,:)-1); % only variance levels of chosen trials
            data.chosen_var_neg = select(variance_location, :).*((select(4,:)-1.5)*2); % variance inversely coded if not chosen
            
            % create control covariates
            data.counteroffer = select(16,:); % value of counteroffer
            data.diff_value = select(16,:)-EV; % difference in EV between options (positive = counteroffer higher than gamble)
            data.abs_value = select(high_amount_location,:)+select(low_amount_location,:)+select(16,:); % absolute presented value
            data.position = select(9,:)-1; % position of counteroffer: 0 = left, 1 = right
            data.choice = select(4,:); % chosen option: 1 = fixed option; 2 = risky/ambiguous option
            
            % create regs of one type of trials
            switch cell2mat(trialtype)
                case 'risky'
                    REGS.risk{sub,run} = data; % all data of risky trials
                case 'ambiguous'
                    REGS.ambi{sub,run} = data; % all data of ambi trials
            end
            
            % create online correlation figure
            figure(online_fig);
            variables = [   data.RT; data.varlevel; data.chosen_var; data.chosen_var_neg; ...
                    data.counteroffer; data.diff_value; data.abs_value; data.position; data.choice  ]';
            varnames = {'RT', 'var', 'vXc', 'vX-c', 'counter', 'diff', 'abs', 'pos', 'ch'};
            switch cell2mat(trialtype)
                case 'risky'
                    subplot(2,size(SESSIONS, 2),run);
                    imagesc(corr(variables, 'type', 'Spearman'));
                    title(['SUB: ' num2str(sub) ' | SESS: ' num2str(run) ' | R']);
                    drawnow;
                case 'ambiguous'
                    subplot(2,size(SESSIONS, 2),run+size(SESSIONS, 2));
                    imagesc(corr(variables, 'type', 'Spearman'));
                    title(['SUB: ' num2str(sub) ' | SESS: ' num2str(run) ' | A']);
                    drawnow;
            end

            % create a figure showing full covariance matrix data of regressors
            if sum(find(FIGURE.SUBS==sub)) && sum(find(FIGURE.SESS==run))
                corrplot(variables, 'varNames', varnames);
                corrfig = gcf;
                corrfig.Name = ['SUB: ' num2str(sub) ' | SESS: ' num2str(run) ' | ' cell2mat(trialtype)];
                corrfig.Color = [1 1 1]; corrfig.Units = 'normalized'; corrfig.Position = [0 0 1 1];
            end
         
        end % end trialtype loop
        
    end % end run loop
    
    if FIGURE.PAUSE == 1;
        fprintf('press key to contiue ... ');
        pause; disp('okay.');
    end
    
end % end sub loop

%% SAVE REGS DATA

if SAVEREGS == 1;
    save(fullfile(DIR.data, 'regressors.mat'), 'REGS');
end
