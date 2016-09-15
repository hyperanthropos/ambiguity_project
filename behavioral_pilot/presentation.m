%% code to present the experiment
% written by Sebastian Weissengruber
% dependencies: stimuli.m, mean_variance.m
clear; close all; clc;

% USER MANUAL

% ...

%% SET PARAMETERS

PARTICIPANT_NR = 1;     % which participant
SESSION = 1;            % which session (1 or 2)
AMBIGUITY = 0;          % 1 = yes, 0 = no

%% PREPARE PRESENTATION

% prepare file structure and save file
home = pwd;
savedir = fullfile(home, 'logfiles');
if exist(savedir, 'dir') ~= 7; mkdir(savedir); end % create savedir if it doesn't exist
save_file = fullfile(save_directory, ['x.mat']);

% make savefile containing VP, SESSION

%%% USE RISK_PRESENTATION REDUCE

%% CREATE STIMULI MATRIX

% current design: 14 steps of variation with 2 repeats; 224 trials, ca. 7.5min (x 2 sessions)
% alternative: 18 steps of variation with 3 repeats; 432 trials, ca. 15min (x 1 sessions)

STIMS.reveal_amb = AMBIGUITY;                           % 1 = yes, 0 = no
STIMS.steps = 14;
STIMS.repeats = 2;
STIMS.diagnostic_graphs = 0;

% create replicable randomization 
randomisation = RandStream('mt19937ar', 'Seed', PARTICIPANT_NR + 1000*SESSION + 10000*AMBIGUITY);
RandStream.setGlobalStream(randomisation);

% create matrix
[stim_mat, stim_nr] = stimuli(STIMS.reveal_amb, STIMS.steps, STIMS.repeats, STIMS.diagnostic_graphs);

% derandomize
sorted_matrix = sortrows(stim_mat', [2 3])';

%% PRESENT STIMULI

for i = 1:stim_nr;
    
    probablity = stim_mat(10,i)*100;
    risk_low = stim_mat(11,i);
    risk_high = stim_mat(12,i);
    ambiguity_low = stim_mat(13,i);
    ambiguity_high = stim_mat(14,i);
    counteroffer = stim_mat(15,i);
    
    if stim_mat(4,i) == 1; % risky trial
        
        if stim_mat(21,i) == 1 % counteroffer left
            
            disp(' ');
            disp([ num2str(counteroffer) ' CHF | OR | ' num2str(probablity) '% chance of ' num2str(risk_high) ' CHF and ' num2str(100-probablity) '% chance of ' num2str(risk_low) 'CHF' ]);
            
        elseif stim_mat(21,i) == 2 % counteroffer right
            
            disp(' ');
            disp([ num2str(probablity) '% chance of ' num2str(risk_high) ' CHF and ' num2str(100-probablity) '% chance of ' num2str(risk_low) ' | OR | ' num2str(counteroffer) ' CHF'  ]);
            
        end
        
    elseif stim_mat(4,i) == 2; % ambigious trial
        
        if stim_mat(21,i) == 1 % counteroffer left
            
            disp(' ');
            disp([ num2str(counteroffer) ' CHF | OR | ' num2str(ambiguity_high) ' CHF ? ' num2str(ambiguity_low) 'CHF' ]);
            disp([ 'turns out to be: ' num2str(probablity) '% chance of ' num2str(ambiguity_high) ' CHF and ' num2str(100-probablity) '% chance of ' num2str(ambiguity_low) 'CHF' ])
            
        elseif stim_mat(21,i) == 2 % counteroffer right
            
            disp(' ');
            disp([ num2str(ambiguity_high) ' CHF ? ' num2str(ambiguity_low) 'CHF | OR | ' num2str(counteroffer) ' CHF' ]);
            disp([ 'turns out to be: ' num2str(probablity) '% chance of ' num2str(ambiguity_high) ' CHF and ' num2str(100-probablity) '% chance of ' num2str(ambiguity_low) 'CHF' ])
            
        end
        
    end
    
    clear probablity risk_low risk_high ambiguity_low ambiguity_high counteroffer;
    
    % pause;
    
end