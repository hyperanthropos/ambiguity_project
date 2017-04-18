%% SCRIPT TO ANALYZE PILOT DATA
% analysis script for experiment_2 (!)
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

% LINE 04 - choice: 1 = fixed option; 2 = risky/ambiguous option
% LINE 05 - choice: 1 = fixed, risky; 2 = risky; 3 = fixed, ambiguous; 4 = ambiguous
% LINE 06 - choice: 1 = left, 2 = right
% LINE 07 - trial type: 1 = risky, 2 = ambiguous
% LINE 08 - [not applicable]
% LINE 09 - position of counteroffer: 1 = left, 2 = right

% LINE 10 - probability of high amount
% LINE 11 - probability of low amount
% LINE 12 - risky amount high
% LINE 13 - risky amount low
% LINE 14 - ambiguous amount high
% LINE 15 - ambiguous amount low
% LINE 16 - counteroffer amount

% LINE 17 - stimulus number (sorted)
% LINE 18 - [not applicable]
% LINE 19 - risk variance level (1-n; low to high variance)
% LINE 20 - ambiguity variance level (1-n; low to high variance)
% LINE 21 - counteroffer level (1-number of levels; low to high counteroffer)
% LINE 22 - expected value level (1-n; low to high expected value)
% LINE 23 - expected value of probabilistic offer

%% SETUP
clear; close('all'); clc;

% pause after each subject to see output
PAUSE = true; % 1 = pause; 2 = 3 seconds delay

% set subjects to analyse
PART{1} = 1:28; % subjects first batch
PART{2} = 1:24; % subjects second batch

% design specification
EV_LEVELS = 2; % how many steps of expected value variation
VAR_NR = 9; % how many steps of variance variation
COUNTER_NR = 12; % how many steps of counteroffer variation
SESSIONS = 1; % how many sessions were recorded
REPEATS_NR = 1; % how many times was one full variation repeated

EV = [8.5 34]; % what are the expected values of gambles
TRIAL_NR = 216; % how many trials was one variance variation

% logfile handling
EXPERIMENT = 2; % behavioral data experiment identifier
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
        for ev_level = 1:EV_LEVELS;
            % add repeats indicator
            RESULT_SORT.part{sub}.mat(18,:) = kron(1:REPEATS_NR, ones(1,TRIAL_NR*EV_LEVELS));
            % create sub matrices for each repeat
            x = RESULT_SORT.part{sub}.mat; % get matrix of a participant
            y = mat2cell(x, size(x, 1), ones(1, REPEATS_NR)*TRIAL_NR*2); % split matrix into repeats
            % sort repeats into EV levels and trial types
            RESULT_SORT.part{sub}.repeat{repeat}.EV{ev_level}.all = y{repeat}(:, y{repeat}(22,:)==ev_level);
            RESULT_SORT.part{sub}.repeat{repeat}.EV{ev_level}.risk = y{repeat}(:, y{repeat}(22,:)==ev_level & y{repeat}(7,:) == 1);
            RESULT_SORT.part{sub}.repeat{repeat}.EV{ev_level}.ambi = y{repeat}(:, y{repeat}(22,:)==ev_level & y{repeat}(7,:) == 2);
        end
    end
end

clear x y sub repeat ev_level;

%% START LOOP OVER SUBJECTS AND CREATE A FIGURE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% GOOD TILL HERE %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for resolved = 1:2; % 2 = resolved
    for sub = PART{resolved}
        % print outpout and create figure
        fprintf(['analysing subject condition ' num2str(resolved) ' - subject ' num2str(sub) ' ... ']);
        
        %% PARAMETER SECTION 0: REACTION TIME
        
        %% --- CREATE PARAMETER
        
        % ... (insert code)
        
        %% PARAMETERS SECTION 1: RISK / AMBIGUITY PREMIUMS
        
        % necessary lines fot this parameter
        % LINE 04 - choice: 1 = fixed option; 2 = risky/ambiguous option
        % LINE 07 - trial type: 1 = risky, 2 = ambiguous
        % LINE 16 - counteroffer amount
        % LINE 19 - risk variance level (1-4; low to high variance)
        % LINE 20 - ambiguity variance level (1-4; low to high variance
        
        %% --- CREATE PARAMETER
        for repeat = 1:REPEATS_NR;
            
            risk_trials = RESULT_SORT.ambi{resolved}.part{sub}.repeat{repeat}.risk;
            ambi_trials = RESULT_SORT.ambi{resolved}.part{sub}.repeat{repeat}.ambi;
            risk_choices = risk_trials(4,:)==2; % at which trials risky offer was chosen
            ambi_choices = ambi_trials(4,:)==2; % at which trials ambiguous offer was chosen
            
            risk_trials_var = mat2cell(risk_trials, size(risk_trials, 1), ones(1, VAR_NR)*COUNTER_NR );
            ambi_trials_var = mat2cell(ambi_trials, size(ambi_trials, 1), ones(1, VAR_NR)*COUNTER_NR );
            
            if resolved == 1;
                PARAM.premiums.abs_gambles.control(:,repeat,1,sub) = sum(risk_choices);
                PARAM.premiums.abs_gambles.control(:,repeat,2,sub) = sum(ambi_choices);
                
                for var_level = 1:VAR_NR;
                    x = sum(risk_trials_var{var_level}(4,:)==2); % how many risky/ambiguous trials were chosen in that variance level
                    % caclulate certainty equivalent
                    if x == 0; % no risky/ambiguous trials were chosen
                        ce = risk_trials_var{var_level}(16,1); % take lowest value
                    elseif x == COUNTER_NR;  % only risky/ambiguous trials were chosen
                        ce = risk_trials_var{var_level}(16,COUNTER_NR); % take highest value
                    else
                        ce =(risk_trials_var{var_level}(16,x)+risk_trials_var{var_level}(16,x+1))/2;
                    end
                    PARAM.premiums.ce.control(var_level,repeat,1,sub) = ce;
                end
                
                for var_level = 1:VAR_NR;
                    x = sum(ambi_trials_var{var_level}(4,:)==2); % how many risky/ambiguous trials were chosen in that variance level
                    % caclulate certainty equivalent
                    if x == 0; % no risky/ambiguous trials were chosen
                        ce = ambi_trials_var{var_level}(16,1); % take lowest value
                    elseif x == COUNTER_NR;  % only risky/ambiguous trials were chosen
                        ce = ambi_trials_var{var_level}(16,COUNTER_NR); % take highest value
                    else
                        ce =(ambi_trials_var{var_level}(16,x)+ambi_trials_var{var_level}(16,x+1))/2;
                    end
                    PARAM.premiums.ce.control(var_level,repeat,2,sub) = ce;
                end
                
            elseif resolved == 2;
                PARAM.premiums.abs_gambles.resolved(:,repeat,1,sub) = sum(risk_choices);
                PARAM.premiums.abs_gambles.resolved(:,repeat,2,sub) = sum(ambi_choices);
                
                for var_level = 1:VAR_NR;
                    x = sum(risk_trials_var{var_level}(4,:)==2); % how many risky/ambiguous trials were chosen in that variance level
                    % caclulate certainty equivalent
                    if x == 0; % no risky/ambiguous trials were chosen
                        ce = risk_trials_var{var_level}(16,1); % take lowest value
                    elseif x == COUNTER_NR;  % only risky/ambiguous trials were chosen
                        ce = risk_trials_var{var_level}(16,COUNTER_NR); % take highest value
                    else
                        ce =(risk_trials_var{var_level}(16,x)+risk_trials_var{var_level}(16,x+1))/2;
                    end
                    PARAM.premiums.ce.resolved(var_level,repeat,1,sub) = ce;
                end
                
                for var_level = 1:VAR_NR;
                    x = sum(ambi_trials_var{var_level}(4,:)==2); % how many risky/ambiguous trials were chosen in that variance level
                    % caclulate certainty equivalent
                    if x == 0; % no risky/ambiguous trials were chosen
                        ce = ambi_trials_var{var_level}(16,1); % take lowest value
                    elseif x == COUNTER_NR;  % only risky/ambiguous trials were chosen
                        ce = ambi_trials_var{var_level}(16,COUNTER_NR); % take highest value
                    else
                        ce =(ambi_trials_var{var_level}(16,x)+ambi_trials_var{var_level}(16,x+1))/2;
                    end
                    PARAM.premiums.ce.resolved(var_level,repeat,2,sub) = ce;
                end
                
            end
        end
        
        %% --- CREATE FIGURE 1
        
        FIGS.fig1 = figure('Name', [ num2str(sub) '-' num2str(resolved) ], 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 .5 1]);
        axisscale = [.5 4.5 5 38];
        
        for repeat = 1:REPEATS_NR;
            
            risk_trials = RESULT_SORT.ambi{resolved}.part{sub}.repeat{repeat}.risk;
            ambi_trials = RESULT_SORT.ambi{resolved}.part{sub}.repeat{repeat}.ambi;
            risk_choices = risk_trials(4,:)==2; % at which trials risky offer was chosen
            ambi_choices = ambi_trials(4,:)==2; % at which trials ambiguous offer was chosen
            
            risk_trials_var = mat2cell(risk_trials, size(risk_trials, 1), ones(1, VAR_NR)*COUNTER_NR );
            ambi_trials_var = mat2cell(ambi_trials, size(ambi_trials, 1), ones(1, VAR_NR)*COUNTER_NR );
            
            % risky trials
            subplot(2,5,repeat);
            scatter(risk_trials(19,:), risk_trials(16,:), 'k'); box off; hold on;
            scatter(risk_trials(19,risk_trials(4,:)==1), risk_trials(16,risk_choices==0), 'b', 'MarkerFaceColor', 'b');
            if resolved == 1;
                plot( PARAM.premiums.ce.control(:,repeat,1,sub), '--k', 'LineWidth', 3); box off; hold on;
            elseif resolved == 2;
                plot( PARAM.premiums.ce.resolved(:,repeat,1,sub), '--k', 'LineWidth', 3); box off; hold on;
            end
            axis(axisscale);
            xlabel('variance'); title([' T' num2str(repeat) ' (risk)' ]);
            ylabel('counteroffer value');

            % ambiguous trials
            subplot(2,5,repeat+5);
            scatter(ambi_trials(20,:), ambi_trials(16,:), 'k'); box off; hold on;
            scatter(ambi_trials(20,ambi_trials(4,:)==1), ambi_trials(16,ambi_choices==0), 'r', 'MarkerFaceColor', 'r');
            if resolved == 1;
                plot( PARAM.premiums.ce.control(:,repeat,2,sub), '--k', 'LineWidth', 3); box off; hold on;
            elseif resolved == 2;
                plot( PARAM.premiums.ce.resolved(:,repeat,2,sub), '--k', 'LineWidth', 3); box off; hold on;
            end
            axis(axisscale);
            xlabel('variance'); title([' T' num2str(repeat)  ' (ambiguity)' ]);
            ylabel('counteroffer value');
            
        end
        
        %%% plot parameter
        subplot(2,5,5);
        if resolved == 1;
            plot( sum(PARAM.premiums.ce.control(:,:,1,sub), 1)/VAR_NR, 'b', 'LineWidth', 3); box off; hold on;
            plot( sum(PARAM.premiums.ce.control(:,:,2,sub), 1)/VAR_NR, 'r', 'LineWidth', 3);
            plot( ones(1, REPEATS_NR)*EV, ':k', 'LineWidth', 2);
        elseif resolved == 2;
            plot( sum(PARAM.premiums.ce.resolved(:,:,1,sub), 1)/VAR_NR, 'b', 'LineWidth', 3); box off; hold on;
            plot( sum(PARAM.premiums.ce.resolved(:,:,2,sub), 1)/VAR_NR, 'r', 'LineWidth', 3);
            plot( ones(1, REPEATS_NR)*EV, ':k', 'LineWidth', 2);
        end
        axis([.5 4.5 5 25]);
        xlabel('timepoints'); title('mean aversion'); legend('risk', 'ambiguity', 'neutrality');
        ylabel('subjective value');
        
        subplot(2,5,10);
        if resolved == 1;
            plot( sum(PARAM.premiums.ce.control(:,:,1,sub), 1)/VAR_NR, 'b', 'LineWidth', 3); box off; hold on;
            plot( sum(PARAM.premiums.ce.control(:,:,2,sub), 1)/VAR_NR, 'r', 'LineWidth', 3);
            plot( ones(1, REPEATS_NR)*EV, ':k', 'LineWidth', 2);
        elseif resolved == 2;
            plot( sum(PARAM.premiums.ce.resolved(:,:,1,sub), 1)/VAR_NR, 'b', 'LineWidth', 3); box off; hold on;
            plot( sum(PARAM.premiums.ce.resolved(:,:,2,sub), 1)/VAR_NR, 'r', 'LineWidth', 3);
            plot( ones(1, REPEATS_NR)*EV, ':k', 'LineWidth', 2);
        end
        axis([.5 4.5 5 25]);
        xlabel('timepoints'); title('mean aversion'); legend('risk', 'ambiguity', 'neutrality');
        ylabel('subjective value');
        
        %% --- CREATE FIGURE 2 
        
        % sorting variance rather than repeats
        FIGS.fig2 = figure('Name', [ num2str(sub) '-' num2str(resolved) ], 'Color', 'w', 'units', 'normalized', 'outerposition', [.5 .5 .5 1]);
        
        x = RESULT_SORT.ambi{resolved}.part{sub}.mat;
        for varlevel = 1:VAR_NR;
            %%% create data to plot
            selector = x(7,:)==1 & x(19,:)==varlevel;
            varmat_risk = x(:,selector);
            selector = x(7,:)==2 & x(20,:)==varlevel;
            varmat_ambi = x(:,selector);
            
            %%% plot parameter
            % risky trials
            subplot(2,5,varlevel);
            scatter(varmat_risk(18,:), varmat_risk(16,:), 'k'); box off; hold on;
            scatter(varmat_risk(18,varmat_risk(4,:)==1), varmat_risk(16,varmat_risk(4,:)==1), 'b', 'MarkerFaceColor', 'b');
            if resolved == 1;
                plot( PARAM.premiums.ce.control(varlevel,:,1,sub), '--k', 'LineWidth', 3); box off; hold on;
            elseif resolved == 2;
                plot( PARAM.premiums.ce.resolved(varlevel,:,1,sub), '--k', 'LineWidth', 3); box off; hold on;
            end
            axis(axisscale);
            xlabel('timepoints'); title([' variance ' num2str(varlevel)  ' (risk)' ]);
            ylabel('counteroffer value');

            % ambiguous trials
            subplot(2,5,varlevel+5);
            scatter(varmat_ambi(18,:), varmat_ambi(16,:), 'k'); box off; hold on;
            scatter(varmat_ambi(18,varmat_ambi(4,:)==1), varmat_ambi(16,varmat_ambi(4,:)==1), 'r', 'MarkerFaceColor', 'r');
            if resolved == 1;
                plot( PARAM.premiums.ce.control(varlevel,:,2,sub), '--k', 'LineWidth', 3); box off; hold on;
            elseif resolved == 2;
                plot( PARAM.premiums.ce.resolved(varlevel,:,2,sub), '--k', 'LineWidth', 3); box off; hold on;
            end
            axis(axisscale);
            xlabel('timepoints'); title([' variance ' num2str(varlevel)  ' (ambiguity)' ]);
            ylabel('counteroffer value');
            
        end
        
        subplot(2,5,5);
        if resolved == 1;
            plot( sum(PARAM.premiums.ce.control(:,:,1,sub), 2)/REPEATS_NR, 'b', 'LineWidth', 3); box off; hold on;
            plot( sum(PARAM.premiums.ce.control(:,:,2,sub), 2)/REPEATS_NR, 'r', 'LineWidth', 3);
            plot( ones(1, VAR_NR)*EV, ':k', 'LineWidth', 2);
        elseif resolved == 2;
            plot( sum(PARAM.premiums.ce.resolved(:,:,1,sub), 2)/REPEATS_NR, 'b', 'LineWidth', 3); box off; hold on;
            plot( sum(PARAM.premiums.ce.resolved(:,:,2,sub), 2)/REPEATS_NR, 'r', 'LineWidth', 3);
            plot( ones(1, VAR_NR)*EV, ':k', 'LineWidth', 2);
        end
        axis([.5 4.5 5 25]);
        xlabel('variance'); title('mean aversion'); legend('risk', 'ambiguity', 'neutrality');
        ylabel('subjective value');
        
        subplot(2,5,10);
        if resolved == 1;
            plot( sum(PARAM.premiums.ce.control(:,:,1,sub), 2)/REPEATS_NR, 'b', 'LineWidth', 3); box off; hold on;
            plot( sum(PARAM.premiums.ce.control(:,:,2,sub), 2)/REPEATS_NR, 'r', 'LineWidth', 3);
            plot( ones(1, VAR_NR)*EV, ':k', 'LineWidth', 2);
        elseif resolved == 2;
            plot( sum(PARAM.premiums.ce.resolved(:,:,1,sub), 2)/REPEATS_NR, 'b', 'LineWidth', 3); box off; hold on;
            plot( sum(PARAM.premiums.ce.resolved(:,:,2,sub), 2)/REPEATS_NR, 'r', 'LineWidth', 3);
            plot( ones(1, VAR_NR)*EV, ':k', 'LineWidth', 2);
        end
        axis([.5 4.5 5 25]);
        xlabel('variance'); title('mean aversion'); legend('risk', 'ambiguity', 'neutrality');
        ylabel('subjective value');

        % END PARAMETER 1
        clear repeat risk_trials ambi_trials risk_choices ambi_choices;
        
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
end

clear sub resolved;

%% SAVE CALCULATED PARAMETERS

save(fullfile(DIR.output, 'parameters.mat'), 'PARAM');

% END OF SCRIPT
disp('thank you, come again!');


