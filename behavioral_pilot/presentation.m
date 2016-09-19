%% code to present the experiment
% dependencies: stimuli.m, mean_variance.m

% USER MANUAL

% ...

%% SET PARAMETERS (these will be fed to the function directly later on...)

clear; close all; clc;

SESSION = 1;                % which session (1 or 2)
AMBIGUITY = 0;              % 1 = yes, 0 = no
SAVE_FILE = '/home/fridolin/DATA/EXPERIMENTS/04_Madeleine/CODE/madeleine/behavioral_pilot/logfiles/part_001_sess_1_ambiguity_1.mat';    % where to save

% --- --- --- %

SCREEN_NR = 0;              % set screen to use 
                            % run Screen('Screens') to check what is available on your machine

LINUX_MODE = 1;             % set button mapping for linux system
BUTTON_BOX = 0;             % set button mapping for fMRI button box

DEBUG_MODE = 1;             % set full screen or window for testing

%% CREATE STIMULI MATRIX

% current design: 14 steps of variation with 2 repeats; 224 trials, ca. 7.5min (x 2 sessions)
% alternative: 18 steps of variation with 3 repeats; 432 trials, ca. 15min (x 1 sessions)

STIMS.reveal_amb = AMBIGUITY;                           % 1 = yes, 0 = no
STIMS.steps = 14;
STIMS.repeats = 2;
STIMS.diagnostic_graphs = 0;

% create matrix
[stim_mat, stim_nr] = stimuli(STIMS.reveal_amb, STIMS.steps, STIMS.repeats, STIMS.diagnostic_graphs);

% derandomize
sorted_matrix = sortrows(stim_mat', [2 3])';

%% PREPARE PRESENTATION

% --> code


%% PREPARE PSYCHTOOLBOX

addpath('/home/fridolin/DATA/MATLAB/PSYCHTOOLBOX/Psychtoolbox');

% set used keys
if LINUX_MODE == 1;
    rightkey = 115; leftkey = 114;
else
    rightkey = 39; leftkey = 37;
end

if BUTTON_BOX == 1;
    rightkey = 49; leftkey = 51;
end



% open a screen to start presentation (can be closed with "sca" command)
if DEBUG_MODE == 1;
    disp(' '); disp('press enter to open the screen...');
    pause;
    window = Screen('OpenWindow', SCREEN_NR, [], [0 0 1280 768]);
else
    window = Screen('OpenWindow', SCREEN_NR);
end


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

%% SAVE RESULTS

save(SAVE_FILE);