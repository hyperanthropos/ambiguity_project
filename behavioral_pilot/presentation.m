function [ ] = presentation( SESSION_IN, AMBIGUITY_IN, SAVE_FILE_IN, SETTINGS_IN )
%% code to present the experiment
% dependencies: stimuli.m, mean_variance.m, draw_stims.m
% written for Psychtoolbox (Version 3.0.13 - Build date: Aug 19 2016)
% input: SESSION, AMBIGUTIY, SAVE_FILE, SETTINGS

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
% LINE 07 - 
% LINE 08 - 
% LINE 09 - 
% LINE 10 - 

% stimuli.m has more information about the stimuli created
% (matching, diagnostics, ...)
% draw_stims.m features additional settings for visual presentation
% (colors, visual control variants, ...)

%% SET PARAMETERS

SESSION = SESSION_IN;               % which session (1 or 2) or 0 for training
AMBIGUITY = AMBIGUITY_IN;           % resolve ambiguity, 1 = yes, 0 = no
SAVE_FILE = SAVE_FILE_IN;           % where to save

% FURTHER SETTINGS

SETTINGS.DEBUG_MODE = 1;                            % set full screen or window for testing and display trials in command window and some diagnotcis
SETTINGS.TEST_MODE = SETTINGS_IN.TEST_FLAG;         % show reduced number of trials (training number) for each session

SETTINGS.LINUX_MODE = SETTINGS_IN.LINUX_MODE;       % set button mapping for linux or windows system
SETTINGS.BUTTON_BOX = 0;                            % set button mapping for fMRI button box ( has to be set on "12345" )

SETTINGS.SCREEN_NR = max(Screen('Screens'));        % set screen to use
                                                    % run Screen('Screens') to check what is available on your machine
SETTINGS.SCREEN_RES = [1280 1024];                  % set screen resolution (centered according to this input)
                                                    % test with Screen('Resolution', SETTINGS.SCREEN_NR)

% TIMING SETTINGS

TIMING.pre_time = .2;       % time to show recolored fixation cross to prepare action
TIMING.selection = .3;      % time to show selected choice before revealing (not revealing) probabilities
TIMING.outcome = 2;         % time to shwo the actual outcome (resolved probabilities or control)
TIMING.isi = .2;            % time to wait before starting next trial with preparatory fixation cross
                            % put within the stim_nr loop, for variable ITI

%% CREATE STIMULI MATRIX

% current design: 12 steps of variation with 2 repeats; 192 trials, ca. 15min (x 2 sessions)
% alternative: 16 steps of variation with 3 repeats; 384 trials, ca. 32min (x 1 sessions)

STIMS.reveal_amb = AMBIGUITY;                           % 1 = yes, 0 = no
STIMS.steps = 12;
STIMS.repeats = 2;
STIMS.diagnostic_graphs = 0;
STIMS.session = SESSION;

% show reduced number of trials in training test_mode
if SETTINGS.TEST_MODE == 1;
    STIMS.steps = 1;
    STIMS.repeats = 2;
end

% never reveal ambiguity in training (session = 0) + shorten trial number
if SESSION == 0;
    STIMS.steps = 1;
    STIMS.repeats = 1;
    STIMS.reveal_amb = 0;
end

% create matrix
[stim_mat, stim_nr] = stimuli(STIMS.reveal_amb, STIMS.steps, STIMS.repeats, STIMS.diagnostic_graphs, STIMS.session);

% display time calulations
if STIMS.diagnostic_graphs == 1;
    reaction_time = 2;
    disp([ num2str(stim_nr) ' trials will be presented, taking approximately ' ...
        num2str( (TIMING.pre_time + reaction_time + TIMING.selection + TIMING.outcome + TIMING.isi)*stim_nr/60 ) ' minutes.' ]);
end

% derandomize
sorted_matrix = sortrows(stim_mat', [2 3])';

% prepare and preallocate log
logrec = NaN(1,stim_nr);
warning('optimize preallocation with actual log size!');

%% PREPARE PRESENTATION AND PSYCHTOOLBOX
% help for PTB Screen commands can be displayed with "Screen [command]?" 
% help with keycodes with KbName('KeyNames') and affiliates

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
if SETTINGS.DEBUG_MODE == 1;
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
background_color = [224, 224, 224];
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

% wait to start experiment (later synchronise with fMRI machine)
% ---> insert code when changing to scanner design
if SESSION == 0;
    disp('press a button to continue...');
    pause;
else
    switch SESSION
        case 1
            % WAIT TOGETHER FOT SESSION 1 (press F)
            fprintf('\nthank you, the training is now finished. please have a short break.');
            if SETTINGS.LINUX_MODE == 1; % set key to 'F'
                continue_key = 42;
            else
                continue_key = 70;
            end
        case 2
            % WAIT TOGETHER FOT SESSION 2 (press G)
            fprintf('\nthank you, half of the experiment is now finished. please have a short break.');
            if SETTINGS.LINUX_MODE == 1; % set key to 'G'
                continue_key = 43;
            else
                continue_key= 71;
            end
    end
    press = 0;
    while press == 0;
        [~, ~, kb_keycode] = KbCheck;
        if find(kb_keycode)==continue_key;
            press = 1;
        end
    end
    clear continue_key kb_keycode;
end

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
    ambiguity_resolve = stim_mat(5,i);  % 1 = yes, 0 = no
    response = 0; % first draw stimuli without response
    
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
            disp(' ');
            disp([ num2str(counteroffer) ' CHF | OR | ' num2str(probablity*100) '% chance of ' num2str(risk_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(risk_low) 'CHF' ]);
            end
        elseif stim_mat(21,i) == 2;
            typus = 1; position = 2; % risky trial, counteroffer right
            if SETTINGS.DEBUG_MODE == 1;
            disp(' ');
            disp([ num2str(probablity*100) '% chance of ' num2str(risk_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(risk_low) ' | OR | ' num2str(counteroffer) ' CHF'  ]);
            end
        end
        
    elseif stim_mat(4,i) == 2;
        if stim_mat(21,i) == 1;
            typus = 2; position = 1; % ambigious trial, counteroffer left
            if SETTINGS.DEBUG_MODE == 1;
            disp(' ');
            disp([ num2str(counteroffer) ' CHF | OR | ' num2str(ambiguity_high) ' CHF ? ' num2str(ambiguity_low) 'CHF' ]);
            disp([ 'turns out to be: ' num2str(probablity*100) '% chance of ' num2str(ambiguity_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(ambiguity_low) 'CHF' ]);
            end
        elseif stim_mat(21,i) == 2;
            typus = 2; position = 2; % ambigious trial, counteroffer right
            if SETTINGS.DEBUG_MODE == 1;
            disp(' ');
            disp([ num2str(ambiguity_high) ' CHF ? ' num2str(ambiguity_low) 'CHF | OR | ' num2str(counteroffer) ' CHF' ]);
            disp([ 'turns out to be: ' num2str(probablity*100) '% chance of ' num2str(ambiguity_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(ambiguity_low) 'CHF' ]);
            end
        end
        
    end
    
    %%% USE FUNCTION TO DRAW THE STIMULI
    
    %%% WRITE LOG %%%
    logrec(2,i) = GetSecs-start_time; % time of presention of trial
    ref_time = GetSecs; % get time to meassure response
    if SETTINGS.DEBUG_MODE == 1;
        disp([ 'time: ' num2str(logrec(2,i)) ]);
        if i > 1;
        disp([ 'total stimulus lenght (last): ' num2str(logrec(2,i)-logrec(2,i-1)) ]);
        disp([ 'total stimulus lenght (last) without RT: ' num2str(logrec(2,i)-logrec(2,i-1)-logrec(3,i-1)) ]);
        end
    end
    %%% WRITE LOG %%%
    
    % (1) DRAW THE STIMULUS (before response)
    draw_stims(window, SETTINGS.SCREEN_RES, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response, ambiguity_resolve, 0);
    
    % (X) GET THE RESPONSE
    while response == 0;                    % wait for respsonse
        [~, ~, kb_keycode] = KbCheck;
        
        if find(kb_keycode)==leftkey        % --- left / LINUX: 114 / WIN: 37
            response = 1;
            
            
            %             if S(6,i)==0;                   %fixed amount right
            %                 LOG(1,i) = 1;               %choice was fixed amount
            %             elseif S(6,i)==1;               %fixed amount left
            %                 LOG(1,i) = 2;               %choice was probabilistic option
            %             else
            %                 Screen('CloseALL');
            %                 error('your stimulus matrix (S) seems  to be corrupt!');
            %             end
            %             LOG(2,i)=GetSecs-ref_time;  %write LOG RT
            
            
        elseif find(kb_keycode)==rightkey   % --- right / LINUX: 115 / WIN: 39
            response = 2;
            
            %             if S(6,i)==0;                   %fixed amount right
            %                 LOG(1,i) = 2;               %choice was probabilistic option
            %             elseif S(6,i)==1;               %fixed amount left
            %                 LOG(1,i) = 1;               %choice was fixed amount
            %             else
            %                 Screen('CloseALL');
            %                 error('your stimulus matrix (S) seems  to be corrupt!');
            %             end
            %             LOG(2,i)=GetSecs-ref_time;  %write LOG RT
            
        end
    end
    
    %%% WRITE LOG %%%
    logrec(3,i) = GetSecs-ref_time; % reaction time
    logrec(6,i) = response; % response (1 = left, 2 = right);
    if SETTINGS.DEBUG_MODE == 1; disp([ 'RT: ' num2str(logrec(3,i)) ]); end
    %%% WRITE LOG %%%
    
    % (2) DRAW THE RESPONSE
    draw_stims(window, SETTINGS.SCREEN_RES, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response, ambiguity_resolve, 0);
    
    % (3) REVEAL AMBIGUITY (or visual control) (last input of function)
    WaitSecs(TIMING.selection); % shortly wait before revealing ambiguity
    draw_stims(window, SETTINGS.SCREEN_RES, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response, ambiguity_resolve, 1);
    
    % (X) WAIT AND FLIP BACK TO PRESENTATION CROSS
    WaitSecs(TIMING.outcome); % present final choice
    
    Screen('DrawLine', window, 0, -10, 0, 10, 0, 5);
    Screen('DrawLine', window, 0, 0, -10, 0, 10, 5);   
    Screen(window, 'Flip');

    %%% END OF STIMULI PRESENTATION
    
    warning('insert logfile creation code');
    % log everything relevant that happened this trial
    % (this is done independend of stim_mat for security reason (can be validated later on))
    % logrec(1,i) = probablity;
    % --> CODE
    
    % clear all used variables for security
    clear probablity risk_low risk_high ambiguity_low ambiguity_high counteroffer risk position response typus kb_keycode;
    
    % wait before next trial (insert variable ISI for fMRI here)
    WaitSecs(TIMING.isi);
    
end
clear i leftkey rightkey;

% close the screen
Screen('CloseAll');

%% SAVE RESULTS

disp(' '); disp('saving data...');
save(SAVE_FILE);