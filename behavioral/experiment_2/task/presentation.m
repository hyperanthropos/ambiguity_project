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
% LINE 07 - trial type: 1 = risky, 2 = ambiguous
% LINE 08 - ambiguity resolved: 1 = yes, 0 = no, 3 = does not apply (risky trial)
% LINE 09 - position of counteroffer: 1 = left, 2 = right
% LINE 10 - probability of high amount
% LINE 11 - probability of low amount
% LINE 12 - risky amount high
% LINE 13 - risky amount low
% LINE 14 - ambiguous amount high
% LINE 15 - ambiguous amount low
% LINE 16 - counteroffer amount

% LINE 17 - stimulus number (sorted)
% LINE 18 - number of repeat of the same variation of stimuli
% LINE 19 - risk variance level (1-4; low to high variance)
% LINE 20 - ambiguity variance level (1-4; low to high variance
% LINE 21 - counteroffer level (1-number of levels; low to high counteroffer)

% stimuli.m has more information about the stimuli created
% (matching, diagnostics, ...)
% draw_stims.m features additional settings for visual presentation
% (colors, visual control variants, ...)

%% SET PARAMETERS

SESSION = SESSION_IN;               % which session (1 or 2) or 0 for training
AMBIGUITY = AMBIGUITY_IN;           % resolve ambiguity, 1 = yes, 0 = no
SAVE_FILE = SAVE_FILE_IN;           % where to save

VISUAL_PRESET = 1;                  % set visual presentation of stimuli matching (risky and ambiguous offers)        
                                    % 1 = with colors; 2 = without colors;

% FURTHER SETTINGS

SETTINGS.DEBUG_MODE = 0;                            % display trials in command window and some diagnotcis
SETTINGS.WINDOW_MODE = 0;                           % set full screen or window for testing
SETTINGS.TEST_MODE = SETTINGS_IN.TEST_FLAG;         % show reduced number of trials (training number) for each session

SETTINGS.LINUX_MODE = SETTINGS_IN.LINUX_MODE;       % set button mapping for linux or windows system
SETTINGS.BUTTON_BOX = 0;                            % set button mapping for fMRI button box ( has to be set on "12345" )

SETTINGS.SCREEN_NR = max(Screen('Screens'));        % set screen to use
                                                    % run Screen('Screens') to check what is available on your machine
SETTINGS.SCREEN_RES = [1280 1024];                  % set screen resolution (centered according to this input)
                                                    % test with Screen('Resolution', SETTINGS.SCREEN_NR)

% TIMING SETTINGS

TIMING.pre_time = .0;       % time to show recolored fixation cross to prepare action
TIMING.selection = .3;      % time to show selected choice before revealing (not revealing) probabilities
TIMING.outcome = 2;         % time to shwo the actual outcome (resolved probabilities or control)
TIMING.isi = .3;            % time to wait before starting next trial with preparatory fixation cross
                            % put within the stim_nr loop, for variable ITI

% create zero timing for test mode                            
if SETTINGS.TEST_MODE == 1;
    TIMING.pre_time = .0;       % time to show recolored fixation cross to prepare action
    TIMING.selection = .0;      % time to show selected choice before revealing (not revealing) probabilities
    TIMING.outcome = 0;         % time to shwo the actual outcome (resolved probabilities or control)
    TIMING.isi = .0;            % time to wait before starting next trial with preparatory fixation cross
end

%% CREATE STIMULI MATRIX

% current design: 12 steps of variation with 2 repeats; 192 trials, ca. 15min (x 2 sessions)
% alternative: 16 steps of variation with 3 repeats; 384 trials, ca. 32min (x 1 sessions)

STIMS.reveal_amb = AMBIGUITY;                           % 1 = yes, 0 = no
STIMS.steps = 12;
STIMS.repeats = 2;
STIMS.diagnostic_graphs = 0;
STIMS.session = SESSION;

% never reveal ambiguity in training (session = 0) + shorten trial number
if SESSION == 0;
    STIMS.steps = 1;
    STIMS.repeats = 1;
    STIMS.reveal_amb = 0;
end

% create matrix
[stim_mat, stim_nr] = stimuli(STIMS.steps, STIMS.repeats, STIMS.diagnostic_graphs);

% display time calulations
if STIMS.diagnostic_graphs == 1;
    reaction_time = 2;
    disp([ num2str(stim_nr) ' trials will be presented, taking approximately ' ...
        num2str( (TIMING.pre_time + reaction_time + TIMING.selection + TIMING.outcome + TIMING.isi)*stim_nr/60 ) ' minutes.' ]);
end

% prepare and preallocate log
logrec = NaN(21,stim_nr);

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
            disp([ 'turns out to be: ' num2str(probablity*100) '% chance of ' num2str(ambiguity_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(ambiguity_low) 'CHF' ]);
            end
        elseif stim_mat(21,i) == 2;
            typus = 2; position = 2; % ambigious trial, counteroffer right
            if SETTINGS.DEBUG_MODE == 1;
            disp([ num2str(ambiguity_high) ' CHF ? ' num2str(ambiguity_low) 'CHF | OR | ' num2str(counteroffer) ' CHF' ]);
            disp([ 'turns out to be: ' num2str(probablity*100) '% chance of ' num2str(ambiguity_high) ' CHF and ' num2str(100-probablity*100) '% chance of ' num2str(ambiguity_low) 'CHF' ]);
            end
        end
        
    end
    
    %%% WRITE LOG %%%
    logrec(7,i) = typus; % trial type: 1 = risky, 2 = ambiguous
    if typus == 2;
        logrec(8,i) = ambiguity_resolve; % ambiguity resolved: 1 = yes, 0 = no
    elseif typus == 1;
        logrec(8,i) = 3; % ambiguity resolved: 3 = does not apply (risky trial)
    end
    logrec(9,i) = position; % position of counteroffer: 1 = left, 2 = right

    logrec(2,i) = GetSecs-start_time; % time of presention of trial
    ref_time = GetSecs; % get time to meassure response
    %%% WRITE LOG %%%
    
    %%% USE FUNCTION TO DRAW THE STIMULI
    
    % select function to draw stimuli
    switch VISUAL_PRESET;
        case 1
            draw_function = @draw_stims_colors;
        case 2
            draw_function = @draw_stims;
        otherwise
            error('invalid visual presentation - change VISUAL_PRESET flag');
    end
    
    % (1) DRAW THE STIMULUS (before response)
    draw_function(window, SETTINGS.SCREEN_RES, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response, ambiguity_resolve, 0);
    
    % view logfile debug info
    if SETTINGS.DEBUG_MODE == 1;
        disp(' ');
        disp([ 'trial type: 1 = risky, 2 = ambiguous: ' num2str(logrec(7,i)) ]);
        disp([ 'ambiguity resolved: 1 = yes, 0 = no, NaN = risky trial: ' num2str(logrec(8,i)) ]);
        disp([ 'position of counteroffer: 1 = left, 2 = right: ' num2str(logrec(9,i)) ]);
        disp(' ');
        disp([ 'time: ' num2str(logrec(2,i)) ]);
        if i > 1;
            disp([ 'total stimulus lenght (last): ' num2str(logrec(2,i)-logrec(2,i-1)) ]);
            disp([ 'total stimulus lenght (last) without RT: ' num2str(logrec(2,i)-logrec(2,i-1)-logrec(3,i-1)) ]);
        end
    end
    
    % (X) GET THE RESPONSE
    while response == 0;                    % wait for respsonse
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
   
    % (2) DRAW THE RESPONSE
    draw_function(window, SETTINGS.SCREEN_RES, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response, ambiguity_resolve, 0);
    
    % (3) REVEAL AMBIGUITY (or visual control) (last input of function)
    WaitSecs(TIMING.selection); % shortly wait before revealing ambiguity
    draw_function(window, SETTINGS.SCREEN_RES, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response, ambiguity_resolve, 1);
    
    % (X) WAIT AND FLIP BACK TO PRESENTATION CROSS
    WaitSecs(TIMING.outcome); % present final choice
    
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
    
    % wait before next trial (insert variable ISI for fMRI here)
    WaitSecs(TIMING.isi);
    
end
clear i leftkey rightkey;

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
sorted_stim_mat = sortrows(stim_mat', [2 3])';  %#ok<NASGU> (this is created to be included in the save file)
sorted_logrec = sortrows(logrec', [18 17])';    %#ok<NASGU> (this is created to be included in the save file)

% ...and save
disp(' '); disp('saving data...');
save(SAVE_FILE);

%% end function
end