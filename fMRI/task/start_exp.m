%% code to present fMRI experiment
% dependencies: stimuli.m, mean_variance.m, draw_stims.m
% written for Psychtoolbox (Version 3.0.13 - Build date: Aug 19 2016)
% input: PARTICIPANT NUMBER, SESSION

% USER MANUAL
% this function creates stimuli via stimuli.mat ("stim_mat") presents it to
% the subject via draw_stims.m and records the repsonse. results are
% collected in the "logrec" variable, which gets saved in wd/logfiles and
% is ordered like this:

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
% LINE 19 - risk variance level (1-4; low to high variance)
% LINE 20 - ambiguity variance level (1-4; low to high variance
% LINE 21 - counteroffer level (1-number of levels; low to high counteroffer)

% stimuli.m has more information about the stimuli created
% (matching, diagnostics, ...)
% draw_stims.m features additional settings for visual presentation
% (colors, visual control variants, ...)

%% PREPARE SCRIPT
clear; close all; clc;
home = pwd;
addpath(fullfile(home, 'dependencies'));

%% SETTINGS

% SETTINGS GENERAL
SETTINGS.fMRI = 1;                                  % wait for scanner trigger (else start with button press)
SETTINGS.BUTTON_BOX = 1;                            % set button mapping for fMRI button box ( USB / HID KEY 12345 | HHSC-1x4-D )

% SETTINGS TESTING
SETTINGS.TEST_MODE = 0;                             % show reduced number of trials
SETTINGS.WINDOW_MODE = 0;                           % set full screen or window for testing
SETTINGS.DEBUG_MODE = 0;                            % display trials in command window and some diagnotcis
SETTINGS.LINUX_MODE = 0;                            % set button mapping for linux or windows system

% TIMING SETTINGS
TIMING.pre_time = .5;       % time to show recolored fixation cross to prepare action
TIMING.duration = 5;        % time to decide, max RT (based on reaction time of subjects)
TIMING.indication = .5;     % time for choice indication
TIMING.iti = 1;             % variable inter trial interval, optimized to detect convolved bold signal       

% SCREEN SETTINGS
SETTINGS.SCREEN_NR = max(Screen('Screens'));        % set screen to use
                                                    % run Screen('Screens') to check what is available on your machine
SETTINGS.SCREEN_RES = [1280 1024];                  % set screen resolution (centered according to this input)
                                                    % test with Screen('Resolution', SETTINGS.SCREEN_NR)  
                                                    
%% PREPARE FOR PRESENTATION

% capture subject data
disp('welcome to the experiment!'); disp(' ');
PARTICIPANT_NR = input('enter participant number:');
SESSION = input('enter session number:');

% prepare file structure and save file
savedir = fullfile(home, 'logfiles');
if exist(savedir, 'dir') ~= 7; mkdir(savedir); end % create savedir if it doesn't exist
SAVE_FILE = fullfile(savedir, [ 'part_' sprintf('%03d', PARTICIPANT_NR) '_sess_' num2str(SESSION) '.mat'] );
if exist(SAVE_FILE, 'file')==2; % check if savefiles exist
    disp(' '); disp('a logfile for this subjects already exists! do you want to overwrite?');
    overwrite = input('enter = no / ''yes'' = yes : '); disp(' ');
    if strcmp(overwrite, 'yes');
        display('will continue and overwrite...'); 
    else
        error('security shutdown initiated! - check logfiles or choose annother participant number or session!');
    end
end
clear overwrite;

% security check for settings
disp('SETTINGS ARE:'); disp(' ');
disp(SETTINGS);
if (SETTINGS.TEST_MODE + SETTINGS.WINDOW_MODE + SETTINGS.DEBUG_MODE + SETTINGS.LINUX_MODE) > 0;
    warning('some test / debug settings are active');
end
if (SETTINGS.fMRI + SETTINGS.BUTTON_BOX) < 2;
    warning('not all fMRI options are set');
end
disp(' '); disp(['participant number: ' num2str(PARTICIPANT_NR)]);
disp(['session number: ' num2str(SESSION)]);
disp(' '); disp('VALIDATE AND PRESS ENTER TO CONTINUE...'); pause;

% create replicable randomization
randomisation = RandStream('mt19937ar', 'Seed', PARTICIPANT_NR + 10000*SESSION);
RandStream.setGlobalStream(randomisation);
clear randomisation;

%% CREATE STIMULI MATRIX

% current design: 12 steps of variation = 120 trials;
% 6s per trial + 1s ISI = 120s*7 + 20 null events (3s) = 900s
% (scanner should run 910s)

STIMS.steps = 12;
STIMS.diagnostic_graphs = 0;
STIMS.session = SESSION;

% replace steps with reduced number if testing
if SETTINGS.TEST_MODE == 1;
    STIMS.steps = 1;
end

% create matrix
[stim_mat, stim_nr, duration] = stimuli(STIMS.steps, STIMS.diagnostic_graphs, STIMS.session, TIMING);
% derandomize matrix
% sorted_matrix = sortrows(stim_mat', [2 3])';

% display time calulations
if STIMS.diagnostic_graphs == 1 || SETTINGS.DEBUG_MODE == 1;
    disp([ num2str(stim_nr) ' trials will be presented, taking approximately ' num2str( (duration+20)/60 ) ' minutes.' ]);
    % +20 seconds to capture last HRF (scanner should stop before presentation)
end

% prepare and preallocate log
logrec = NaN(21,stim_nr);

%% PREPARE PRESENTATION AND PSYCHTOOLBOX
% help for PTB Screen commands can be displayed with "Screen [command]?" 
% help with keycodes with KbName('KeyNames') and affiliates

% select function to draw stimuli
draw_function = @draw_stims;

% set used keys
if SETTINGS.LINUX_MODE == 1;
    rightkey = 115; leftkey = 114;
else
    rightkey = 39; leftkey = 37;
end

if SETTINGS.BUTTON_BOX == 1;
    rightkey = 49; leftkey = 51;    % button box has to be set on "12345"
end

% supress warnings to see diagnostic output of stimuli
% you can run "ScreenTest" to check the current machine
warning('PTB warings are currently suppressed');
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'VisualDebugLevel', 0);

% open a screen to start presentation (can be closed with "sca" command)
if SETTINGS.WINDOW_MODE == 1;
    window = Screen('OpenWindow', SETTINGS.SCREEN_NR, [], [0 0 SETTINGS.SCREEN_RES]);
else
    window = Screen('OpenWindow', SETTINGS.SCREEN_NR); % open screen
    HideCursor;  % and hide cursor
end

% set font and size
Screen('TextFont', window, 'Calibri');
Screen('TextSize', window, 36);

% set origion to middle of the screen
Screen('glTranslate', window, SETTINGS.SCREEN_RES(1)/2, SETTINGS.SCREEN_RES(2)/2, 0);

% set background color
background_color = ones(1,3)*230;
Screen(window, 'FillRect', background_color);
Screen(window, 'Flip');
clear background_color;

% launch a start screen (setting screen back to default to draw text and later back to origin again *)
% * this  double transformation is necessary for compatibility with different PTB versions
Screen('glTranslate', window, -SETTINGS.SCREEN_RES(1)/2, -SETTINGS.SCREEN_RES(2)/2, 0);
offset = Screen(window, 'TextBounds', 'PLEASE WAIT...')/2;
Screen(window, 'DrawText', 'PLEASE WAIT...', SETTINGS.SCREEN_RES(1)/2-offset(3), SETTINGS.SCREEN_RES(2)/2-offset(4));
Screen(window, 'Flip');
Screen('glTranslate', window, SETTINGS.SCREEN_RES(1)/2, SETTINGS.SCREEN_RES(2)/2, 0);
clear offset;

% wait to start experiment (synchronise with fMRI machine)
disp('waiting for scanner trigger...');
if SETTINGS.fMRI == 1;
    continue_key = 53; % this is "y" on linux 
    press = 0;
    while press == 0;
        [~, ~, kb_keycode] = KbCheck;
        if find(kb_keycode)==continue_key;
            press = 1;
        end
    end
else
    disp('set manual start - press a button "G" to continue...');
    if SETTINGS.LINUX_MODE == 1; % set key to 'G'
        continue_key = 43;
    else
        continue_key= 71;
    end
    press = 0;
    while press == 0;
        [~, ~, kb_keycode] = KbCheck;
        if find(kb_keycode)==continue_key;
            press = 1;
        end
    end
end
clear continue_key kb_keycode;

%% PRESENT STIMULI

% start timer
start_time = GetSecs;

% loop over all trials
for i = 1:stim_nr;
    
    %%% WRITE LOG %%%
    logrec(1,i) = i; % trial number
    %%% WRITE LOG %%%
      
    % sort elements that will be used for each trial
    probablity = stim_mat(10,i);
    risk_low = stim_mat(11,i);
    risk_high = stim_mat(12,i);
    ambiguity_low = stim_mat(13,i);
    ambiguity_high = stim_mat(14,i);
    counteroffer = stim_mat(15,i);
    
    response = 0; % first draw stimuli without response
    
    % wait for specified trial start
    WaitSecs('UntilTime', start_time + stim_mat(20,i));

    % recolor the fixaton cross shorty befor presenting a new stimulus
    Screen('DrawLine', window, [0 128 0], -10, 0, 10, 0, 5);
    Screen('DrawLine', window, [0 128 0], 0, -10, 0, 10, 5);
    Screen(window, 'Flip');
    WaitSecs(TIMING.pre_time);
    
    % select what to draw
    if stim_mat(4,i) == 1;
        if stim_mat(21,i) == 1;
            typus = 1; position = 1; % risky trial, counteroffer left
            if SETTINGS.DEBUG_MODE == 1;
            disp([ num2str(counteroffer) ' CHF | OR | ' num2str(probablity*100) '% chance of ' num2str(risk_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(risk_low) 'CHF' ]);
            end
        elseif stim_mat(21,i) == 2;
            typus = 1; position = 2; % risky trial, counteroffer right
            if SETTINGS.DEBUG_MODE == 1;
            disp([ num2str(probablity*100) '% chance of ' num2str(risk_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(risk_low) ' | OR | ' num2str(counteroffer) ' CHF'  ]);
            end
        end
        
    elseif stim_mat(4,i) == 2;
        if stim_mat(21,i) == 1;
            typus = 2; position = 1; % ambigious trial, counteroffer left
            if SETTINGS.DEBUG_MODE == 1;
            disp([ num2str(counteroffer) ' CHF | OR | ' num2str(ambiguity_high) ' CHF ? ' num2str(ambiguity_low) 'CHF' ]);
            end
        elseif stim_mat(21,i) == 2;
            typus = 2; position = 2; % ambigious trial, counteroffer right
            if SETTINGS.DEBUG_MODE == 1;
            disp([ num2str(ambiguity_high) ' CHF ? ' num2str(ambiguity_low) 'CHF | OR | ' num2str(counteroffer) ' CHF' ]);
            end
        end
        
    end
    
    %%% WRITE LOG %%%
    logrec(7,i) = typus; % trial type: 1 = risky, 2 = ambiguous
    logrec(8,i) = NaN; % this line is not used
    logrec(9,i) = position; % position of counteroffer: 1 = left, 2 = right

    logrec(2,i) = GetSecs-start_time; % time of presention of trial
    %%% WRITE LOG %%%
    
    %%% USE FUNCTION TO DRAW THE STIMULI
    
    % (1) DRAW THE STIMULUS (before response)
    draw_function(window, SETTINGS.SCREEN_RES, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response);
    
    % get time to meassure response (RT)
    ref_time = GetSecs;
    
    % view logfile debug info
    if SETTINGS.DEBUG_MODE == 1;
        disp(' ');
        disp([ 'trial type: 1 = risky, 2 = ambiguous: ' num2str(logrec(7,i)) ]);
        disp([ 'position of counteroffer: 1 = left, 2 = right: ' num2str(logrec(9,i)) ]);
        disp(' ');
        disp([ 'time: ' num2str(logrec(2,i)) ]);
        if i > 1;
            disp([ 'total stimulus lenght (last): ' num2str(logrec(2,i)-logrec(2,i-1)) ]);
            disp([ 'total stimulus lenght (last) without RT: ' num2str(logrec(2,i)-logrec(2,i-1)-logrec(3,i-1)) ]);
        end
    end
    
    % (X) GET THE RESPONSE
    while response == 0 && GetSecs - ref_time < TIMING.duration; % wait for respsonse or timeout
        [~, ~, kb_keycode] = KbCheck;
        
        if find(kb_keycode)==leftkey        % --- left / LINUX: 114 / WIN: 37
            response = 1;
            
            %%% WRITE LOG %%%
            logrec(3,i) = GetSecs-ref_time; % reaction time
            logrec(6,i) = response; % response (1 = left, 2 = right);
            
            if position == 1; % counteroffer left
                logrec(4,i) = 1; % choice was fixed option
                if typus == 1; % risky trial
                    logrec(5,i) = 1; % choice was fixed (risky)
                elseif typus == 2; % ambigious trial
                    logrec(5,i) = 3; % choice was fixed (ambiguous)
                end
            elseif position == 2; % counteroffer right
                logrec(4,i) = 2; % choice was risky/ambiguous option
                if typus == 1; % risky trial
                    logrec(5,i) = 2; % choice risky
                elseif typus == 2; % ambigious trial
                    logrec(5,i) = 4; % choice ambiguous
                end
            end
            %%% WRITE LOG %%%
     
        elseif find(kb_keycode)==rightkey   % --- right / LINUX: 115 / WIN: 39
            response = 2;
            
            %%% WRITE LOG %%%
            logrec(3,i) = GetSecs-ref_time; % reaction time
            logrec(6,i) = response; % response (1 = left, 2 = right);
            
            if position == 1; % counteroffer left
                logrec(4,i) = 2; % choice was risky/ambiguous option
                if typus == 1; % risky trial
                    logrec(5,i) = 2; % choice risky
                elseif typus == 2; % ambigious trial
                    logrec(5,i) = 4; % choice ambiguous
                end
            elseif position == 2; % counteroffer right
                logrec(4,i) = 1; % choice was fixed option
                if typus == 1; % risky trial
                    logrec(5,i) = 1; % choice was fixed (risky)
                elseif typus == 2; % ambigious trial
                    logrec(5,i) = 3; % choice was fixed (ambiguous)
                end
            end
            %%% WRITE LOG %%%
            
        end
    end
   
    % (2) DRAW THE RESPONSE OR MISS INDICATOR
    if response ~= 0;
        draw_function(window, SETTINGS.SCREEN_RES, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response);
    elseif response == 0; % indicate missing response
        Screen('DrawLine', window, [250 0 0], -18, 0, 18, 0, 5);
        Screen('DrawLine', window, [250 0 0], -18, -2, 18, -2, 5);
        Screen('DrawLine', window, [250 0 0], -18, 2, 18, 2, 5);
        Screen('DrawLine', window, [250 0 0], 0, -18, 0, 18, 5); 
        Screen('DrawLine', window, [250 0 0], -2, -18, -2, 18, 5); 
        Screen('DrawLine', window, [250 0 0], 2, -18, 2, 18, 5); 
        Screen(window, 'Flip');
    end
        
    % (X) WAIT AND FLIP BACK TO PRESENTATION CROSS
    WaitSecs(TIMING.indication);
    
    Screen('DrawLine', window, 0, -10, 0, 10, 0, 5);
    Screen('DrawLine', window, 0, 0, -10, 0, 10, 5);   
    Screen(window, 'Flip');

    %%% END OF STIMULI PRESENTATION
    
    % log everything relevant that happened this trial
    % (this is done independend of stim_mat for security reason (can be validated later on))
    logrec(10,i) = probablity;          % probability of high amount
    logrec(11,i) = 1 - probablity;      % probability of low amount
    logrec(12,i) = risk_high;           % risky amount high
    logrec(13,i) = risk_low;            % risky amount low
    logrec(14,i) = ambiguity_high;      % ambiguous amount high
    logrec(15,i) = ambiguity_low;       % ambiguous amount low
    logrec(16,i) = counteroffer;        % counteroffer amount

    % view logfile debug info
    if SETTINGS.DEBUG_MODE == 1;
        disp(' ');
        disp([ 'RT: ' num2str(logrec(3,i)) ]);
        disp([ 'choice: 1 = fixed; 2 = ambiguous: ' num2str(logrec(4,i)) ]);
        disp([ 'choice: 1 = fixed, risky; 2 = risky; 3 = fixed, ambiguous; 4 = ambiguous: ' num2str(logrec(5,i)) ]); 
        
        disp(' '); disp(' --- --- --- --- --- --- ---- '); disp(' ');
    end
    
    % clear all used variables for security
    clear probablity risk_low risk_high ambiguity_low ambiguity_high counteroffer risk position response typus kb_keycode;
    
end
clear i leftkey rightkey;

% wait for 20 seconds to capture last HRF
WaitSecs(20);

% close the screen
Screen('CloseAll');

%% SAVE RESULTS

% add relevant info from stim_mat to logfile...
logrec(17,:) = stim_mat(3,:);        % stimulus number
logrec(18,:) = stim_mat(2,:);        % repeat number
logrec(19,:) = stim_mat(6,:);        % risk variance level
logrec(20,:) = stim_mat(7,:);        % ambiguity variance level
logrec(21,:) = stim_mat(8,:);        % counteroffer level

% ...derandomize...
sorted_stim_mat = sortrows(stim_mat', [2 3])';
sorted_logrec = sortrows(logrec', [18 17])';

% ...and save
disp(' '); disp('saving data...');
save(SAVE_FILE);

% also create a reward file at the end
if SESSION == 3
    create_reward_file(PARTICIPANT_NR, savedir);
end

%% END OF SCRIPT
    