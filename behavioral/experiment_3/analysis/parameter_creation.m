%% SCRIPT TO ANALYZE PILOT DATA
% analysis script for experiment_3 (!)
% this script creates parametes for further statistical analysis
% it needs logfiles created by the behavioral pilot presentation.m
% script

% unprocessed data is stored into two structures:
% RESULT_SEQ sorting trials as they were presented
% RESULT_SORT sorting trials according to their design stucture

% the matrices within these structures are sorted according to this:
% LINE 01 - trial number
% LINE 02 - trial presentation time
% LINE 03 - reaction time

% LINE 04 - choice: 1 = risky option; 2 = ambiguous option;
% LINE 05 - [not applicable]
% LINE 06 - choice: 1 = left, 2 = right
% LINE 07 - [not applicable]
% LINE 08 - [not applicable]
% LINE 09 - position of risky (non ambiguous) offer: 1 = left, 2 = right

% LINE 10 - probability of high amount
% LINE 11 - probability of low amount
% LINE 12 - risky amount high
% LINE 13 - risky amount low
% LINE 14 - ambiguous amount high
% LINE 15 - ambiguous amount low
% LINE 16 - [not applicable]

% LINE 17 - stimulus number (sorted)
% LINE 18 - session 1 or 2 (number of repeat of the same variation of stimuli)
% LINE 19 - risk variance level (1-15; low to high variance)
% LINE 20 - ambiguity variance level (1-15; low to high variance)
% LINE 21 - [not applicable]
% LINE 22 - expected value level (1-6; low to high expected value)
% LINE 23 - expected value of probabilistic offers

%% SETUP
clear; close('all'); clc;

% pause after each subject to see output
PAUSE = true; % 1 = pause; 2 = 3 seconds delay

% set subjects to analyse
PART{1} = 1:28; % subjects first batch
PART{2} = 1:27; % subjects second batch

% design specification
EV_LEVELS = 6; % how many steps of expected value variation
VAR_NR = 15; % how many steps of variance variation
SESSIONS = 2; % how many sessions were recorded
REPEATS_NR = 2; % how many times was one full variation repeated

EV = 7.25 * [1 2 3 4 5 6]; % what are the expected values of gambles
TRIAL_NR = 90; % how many trials was one variance variation

% logfile handling
EXPERIMENT = 3; % behavioral data experiment identifier
SKIP_LOAD = true; % skip loading of individual files

%% DATA HANDLING

% set directories
DIR.home = pwd;
DIR.input = fullfile(DIR.home, 'behavioral_results');
DIR.output = fullfile(DIR.home, 'analysis_results');
DIR.temp = fullfile(DIR.home, 'temp_data');

% load data
if SKIP_LOAD ~= 1;
    counter = 0;
    
    % for both batches of participants 
    for iBatch = 1:2; 
        % run for every participant in the group
        for part = PART{iBatch};
            counter = counter+1;
            
            % combine 4 repeats of both sessions into one file
            temp_logrec_full = [];
            temp_logrec_sorted_full = [];
            for sess = 1:SESSIONS;
                load_file = fullfile(DIR.input, [ 'exp_' num2str(EXPERIMENT) '_' sprintf('%03d', iBatch) '_part_' sprintf('%03d', part) '_sess_' num2str(sess) '.mat'] );
                load(load_file, 'logrec', 'sorted_logrec');
                temp_logrec_full = cat(2, temp_logrec_full, logrec);
                temp_logrec_sorted_full = cat(2, temp_logrec_sorted_full, sorted_logrec);
            end
            
            % save participantns into a structure
            RESULT_SEQ.part{counter}.mat = temp_logrec_full;
            RESULT_SORT.part{counter}.mat = temp_logrec_sorted_full;
            
        end % end participant loop
    end % end batch loop
    
    % create temp directory to save data structure and save
    if exist(DIR.temp, 'dir') ~= 7; mkdir(DIR.temp); end
    save(fullfile(DIR.temp, 'temp.mat'), 'RESULT_SEQ', 'RESULT_SORT');
    
    clear load_file part sess logrec sorted_logrec temp_logrec_full temp_logrec_sorted_full counter iBatch;
    
else
    
    % if data is already sorted into the structures it can be loaded here
    load(fullfile(DIR.temp, 'temp.mat'));
    
end
clear SKIP_LOAD;

% unify PART variable
PART = 1:length(PART{1})+length(PART{2});

% create result directory if it doesn't exist
if exist(DIR.output, 'dir') ~= 7; mkdir(DIR.output); end

%% DATA PREPROCESSING

for sub = PART
    for repeat = 1:REPEATS_NR;
        % create sub matrices for each repeat
        x = RESULT_SORT.part{sub}.mat; % get matrix of a participant
        y = mat2cell(x, size(x, 1), ones(1, REPEATS_NR)*TRIAL_NR); % split matrix into repeats
        RESULT_SORT.part{sub}.repeat{repeat}.mat = y{repeat};
        for ev_level = 1:EV_LEVELS;
            % sort repeats into EV levels and trial types
            RESULT_SORT.part{sub}.repeat{repeat}.EV{ev_level} = y{repeat}(:, y{repeat}(22,:)==ev_level);
        end
    end
end

clear x y sub repeat ev_level;

%% FIXED VALUES INDPENDENT OF SUBJECT AND REPEAT NUMBER

% fixed attributes corresponding to choice matrix
% (EV, variance)
x = RESULT_SORT.part{1}.repeat{1}.mat;
y = NaN(1,TRIAL_NR);
for i = 1:TRIAL_NR % calc mean variance of trials
   y(i) = mean_variance(.5, x(14,i), .5, x(15,i)); % using matched ambiguous offers
end
PARAM.choice_matrix.fixed.mvar = reshape(y, VAR_NR,EV_LEVELS)'; % variance
PARAM.choice_matrix.fixed.prob_high = reshape(x(10,:), VAR_NR,EV_LEVELS)'; % probability of higher offer
PARAM.choice_matrix.fixed.EV = reshape(x(23,:), VAR_NR,EV_LEVELS)'; % expected value

clear x y;

%% START LOOP OVER SUBJECTS AND CREATE A FIGURE

for sub = PART
    % print outpout and create figure
    fprintf(['analysing subject ' num2str(sub) ' ... ']);
    
    %% PARAMETER SECTION 0: REACTION TIME
    
    %% --- CREATE PARAMETER
    
    % ... (insert code)
    
    %% PARAMETERS SECTION 1: SWITCHPOINT AND CHOICE MATRIX ANALYSIS
    
    % necessary lines fot this parameter
    % LINE 03 - reaction time
    % LINE 04 - choice: 1 = risky option; 2 = ambiguous option;
    % LINE 19 - risk variance level (1-15; low to high variance)
    % LINE 20 - ambiguity variance level (1-15; low to high variance)
    % LINE 21 - [not applicable]
    % LINE 22 - expected value level (1-6; low to high expected value)
    
    %% --- CREATE PARAMETER
    
    for repeat = 1:REPEATS_NR;
        
        x = RESULT_SORT.part{sub}.repeat{repeat}.mat;
        
        % save choice matrix as parameter for later processing
        % (EV, variance, sub) | 1 = risky option; 2 = ambiguous option
        PARAM.choice_matrix.choice(:,:,sub,repeat) = reshape(x(4,:), VAR_NR,EV_LEVELS)';
        PARAM.choice_matrix.RT(:,:,sub,repeat) = reshape(x(3,:), VAR_NR,EV_LEVELS)';

        % calculate switschpoint from risk-averse --> ambiguity-averse
        % or switchpoint: ambiguity preference --> risk preference
        for ev_level = 1:EV_LEVELS;
            
            trials = RESULT_SORT.part{sub}.repeat{repeat}.EV{ev_level};
            ambi_choices = trials(4,:)==2; % trials at which ambiguous offer was chosen
            x = sum(ambi_choices); % how many ambiguous trials were chosen in that EV level
            ce = x+.5; % take interpolated value
            
            PARAM.switchpoint(ev_level,sub,repeat) = ce;
            
        end
    end
    
    %% --- CREATE FIGURE 1

    FIGS.fig1 = figure('Name', [ 'subject' num2str(sub) ' | choice matrix ' ], 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 .5 1]);
    
    for repeat = 1:REPEATS_NR;
        
        PLOT.EVs = RESULT_SORT.part{sub}.repeat{repeat}.mat(23,:);
        PLOT.var = RESULT_SORT.part{sub}.repeat{repeat}.mat(20,:);
        PLOT.risk = RESULT_SORT.part{sub}.repeat{repeat}.mat(4,:) == 1;
        PLOT.ambi = RESULT_SORT.part{sub}.repeat{repeat}.mat(4,:) == 2;
        
        % plot decisions
        subplot(2,2,2+2*(repeat-1));    
        scatter(PLOT.EVs, PLOT.var, 'k'); box off; hold on;
        scatter(PLOT.EVs(PLOT.risk), PLOT.var(PLOT.risk), 'b', 'MarkerFaceColor', 'b');
        scatter(PLOT.EVs(PLOT.ambi), PLOT.var(PLOT.ambi),'r', 'MarkerFaceColor', 'r');
        plot( EV, PARAM.switchpoint(:,sub,repeat), '-*k', 'LineWidth', 3); box off; hold on;
        plot( EV, ones(1, EV_LEVELS)*ceil(VAR_NR/2), '--k', 'LineWidth', 2); box off; hold on;
        xlabel('expected value'); ylabel('variance'); title(['repeat: ' num2str(repeat)]);
        
        subplot(2,2,1+2*(repeat-1));
        graphstyle = 'matrix';
        switch graphstyle
            case 'scatter'
                scatter(PLOT.var, PLOT.EVs, 'k'); box off; hold on;
                scatter(PLOT.var(PLOT.risk), PLOT.EVs(PLOT.risk), 'b', 'MarkerFaceColor', 'b');
                scatter(PLOT.var(PLOT.ambi), PLOT.EVs(PLOT.ambi), 'r', 'MarkerFaceColor', 'r');
                ylabel('expected value'); xlabel('variance'); title(['repeat: ' num2str(repeat)]);
            case 'matrix'
                imagesc(PARAM.choice_matrix.choice(:,:,sub,repeat)); colormap jet; 
                ylabel('expected value'); xlabel('variance'); title(['repeat: ' num2str(repeat)]);
        end
        
    end

    % END PARAMETER 2
    clear repeat ambi_choices ce ev_level trials x PLOT;
    
    %% PARAMTER SECTION 3: --- (ADD FURTHER PARAMETER HERE WHEN NEEDED)
    
    %% --- CREATE PARAMETER
    
    % ... (insert code)
    
    %% END LOOP OVER SUBJECTS
    
    %%% UPDATE FIGURE AND CLOSE
    disp('done.');
    if PAUSE == 1;
        drawnow;
        pause;
    elseif PAUSE == 2;
        drawnow;
        pause(3);
    end
    close all;
    
end

clear sub;

%% SAVE CALCULATED PARAMETERS

save(fullfile(DIR.output, 'parameters.mat'), 'PARAM');

% END OF SCRIPT
disp('thank you, come again!');


