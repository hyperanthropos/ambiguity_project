%% code to present the experiment
% dependencies: stimuli.m, mean_variance.m, draw_stims.m
% written for Psychtoolbox (Version 3.0.13 - Build date: Aug 19 2016)

% input: SESSION, AMBIGUTIY, SAVE_FILE, SETTINGS

% USER MANUAL

% ...

%% SET PARAMETERS

% ...these will be fed to the function directly later on...)
clear; close all; clc;

SESSION = 1;                % which session (1 or 2)
AMBIGUITY = 0;              % 1 = yes, 0 = no
SAVE_FILE = '/home/fridolin/DATA/EXPERIMENTS/04_Madeleine/CODE/madeleine/behavioral_pilot/logfiles/part_001_sess_1_ambiguity_1.mat';    % where to save

% FURTHER SETTINGS

SETTINGS.DEBUG_MODE = 1;             % set full screen or window for testing

SETTINGS.LINUX_MODE = 1;             % set button mapping for linux or windows system
SETTINGS.BUTTON_BOX = 0;             % set button mapping for fMRI button box ( has to be set on "12345" )

SETTINGS.SCREEN_NR = 0;              % set screen to use
% run Screen('Screens') to check what is available on your machine
SETTINGS.SCREEN_RES = [1440 900];    % set screen resolution (centered according to this input)

% TIMING SETTINGS

TIMING.time = [];




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

%% PREPARE PRESENTATION AND PSYCHTOOLBOX

addpath(genpath('/home/fridolin/DATA/MATLAB/PSYCHTOOLBOX/Psychtoolbox'));

% set used keys
if SETTINGS.LINUX_MODE == 1;
    rightkey = 115; leftkey = 114;
else
    rightkey = 39; leftkey = 37;
end

if SETTINGS.BUTTON_BOX == 1;
    rightkey = 49; leftkey = 51;    % button box has to be set on "12345"
end

% open a screen to start presentation (can be closed with "sca" command)
if SETTINGS.DEBUG_MODE == 1;
    disp(' '); disp('press enter to open the screen...');
    pause;
    window = Screen('OpenWindow', SETTINGS.SCREEN_NR, [], [0 0 SETTINGS.SCREEN_RES]);
else
    window = Screen('OpenWindow', SETTINGS.SCREEN_NR);   % open screen
    HideCursor;                                 % and hide cursor
end

% set origion to middle of the screen
Screen('glTranslate', window, SETTINGS.SCREEN_RES(1)/2, SETTINGS.SCREEN_RES(2)/2, 0);

% synchronise with fMRI machine
% ---> insert code when changing to scanner design

% start timer
start_time = GetSecs;

%% PRESENT STIMULI

% prepare an preallocate log
logrec = NaN(1,stim_nr);
warning('optimized preallocation with actual log size');

% loop over all trials
for i = 1:stim_nr;
    
    % sort elements that will be used for each trial
    probablity = stim_mat(10,i);
    risk_low = stim_mat(11,i);
    risk_high = stim_mat(12,i);
    ambiguity_low = stim_mat(13,i);
    ambiguity_high = stim_mat(14,i);
    counteroffer = stim_mat(15,i);
    ambiguity_resolve = stim_mat(5,i);  % 1 = yes, 0 = no
    response = 0; % first draw stimuli without response
    
    % recolor the fixaton cross shorty befor presenting a new stimulus
    Screen('DrawLine', window, [0 128 0], -10, 0, 10, 0, 5);
    Screen('DrawLine', window, [0 128 0], 0, -10, 0, 10, 5);
    Screen(window, 'Flip');
    WaitSecs(0.4);
    
    % select what to draw
    if stim_mat(4,i) == 1;
        if stim_mat(21,i) == 1;
            typus = 1; position = 1; % risky trial, counteroffer left
            disp(' ');
            disp([ num2str(counteroffer) ' CHF | OR | ' num2str(probablity*100) '% chance of ' num2str(risk_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(risk_low) 'CHF' ]);
        elseif stim_mat(21,i) == 2;
            typus = 1; position = 2; % risky trial, counteroffer right
            disp(' ');
            disp([ num2str(probablity*100) '% chance of ' num2str(risk_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(risk_low) ' | OR | ' num2str(counteroffer) ' CHF'  ]);
        end
        
    elseif stim_mat(4,i) == 2;
        if stim_mat(21,i) == 1;
            typus = 2; position = 1; % ambigious trial, counteroffer left
            disp(' ');
            disp([ num2str(counteroffer) ' CHF | OR | ' num2str(ambiguity_high) ' CHF ? ' num2str(ambiguity_low) 'CHF' ]);
            disp([ 'turns out to be: ' num2str(probablity*100) '% chance of ' num2str(ambiguity_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(ambiguity_low) 'CHF' ])
        elseif stim_mat(21,i) == 2;
            typus = 2; position = 2; % ambigious trial, counteroffer right
            disp(' ');
            disp([ num2str(ambiguity_high) ' CHF ? ' num2str(ambiguity_low) 'CHF | OR | ' num2str(counteroffer) ' CHF' ]);
            disp([ 'turns out to be: ' num2str(probablity*100) '% chance of ' num2str(ambiguity_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(ambiguity_low) 'CHF' ])
        end
        
    end
    
    %%% USE FUNCTION TO DRAW THE STIMULI
    
    % (1) DRAW THE STIMULUS (before response)
    draw_stims(window, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response, ambiguity_resolve, 0);
    
    % (X) GET THE RESPONSE
    % --> CODE
    disp('waiting for response...');
    pause;
    response = randi(2); % 1 left, 2 = right
    
    % (2) DRAW THE RESPONSE
    draw_stims(window, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response, ambiguity_resolve, 0);
    
    % (3) REVEAL AMBIGUITY (or visual control) (last input of function)
    WaitSecs(0.5); % shortly wait before revealing ambiguity
    draw_stims(window, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response, ambiguity_resolve, 1);
    
    % (X) WAIT AND FLIP BACK TO PRESENTATION CROSS
    WaitSecs(2); % present final choice
    Screen('DrawLine', window, 0, -10, 0, 10, 0, 5);
    Screen('DrawLine', window, 0, 0, -10, 0, 10, 5);   
    Screen(window, 'Flip');
    
    %%% END OF STIMULI PRESENTATION
    
    % log everything relevant that happened this trial
    logrec(1,i) = probablity;
    % --> CODE
    
    
    clear probablity risk_low risk_high ambiguity_low ambiguity_high counteroffer risk position response;
    
    WaitSecs(3); % wait before next trial (later ISI)    
    
    % pause;
    
end

%% SAVE RESULTS

save(SAVE_FILE);