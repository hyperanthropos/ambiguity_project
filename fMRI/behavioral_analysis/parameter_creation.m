%% SCRIPT TO ANALYZE fMRI BEHAVIORAL DATA
% this script creates parametes for further statistical analysis
% it needs logfiles created by the fmri task "start_exp.m" script

% unprocessed data is stored into two structures:
    % RESULT_SEQ sorting trials as they were presented
    % RESULT_SORT sorting trials according to their design stucture

    % and contains this information:
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

% this script creates the following parameters from the data:

    % REACTION TIMES
        % PARAM.RT.mean(var_level,repeat,1:2,sub) | 1 = risky trials; 2 = ambiguous trials
        %   contains mean RT for different variance levels
        % PARAM.RT.prob(var_level,repeat,1:2,sub) | 1 = risky trials; 2 = ambiguous trials
        %   contains mean RT for all trials where probabilistic (risky/ambiguous) option was chosen
        % PARAM.RT.fixed(var_level,repeat,1:2,sub) | 1 = risky trials; 2 = ambiguous trials
        %   contains mean RT for all trials where fixed (counteroffer) option was chosen

    % RISK PREMIUMS
        % PARAM.premiums.abs_gambles(:,repeat,1:2,sub) | 1 = risky trials; 2 = ambiguous trials
        %   contains the number of how often the risky / ambiguous option was chosen over all variance levels
        % PARAM.premiums.ce(var_level,repeat,2,sub) | 1 = risky trials; 2 = ambiguous trilas
        %   contains the certainty equivalent of the risky / ambigious option in CHF
        %       ce < EV = risk averse; ce > EV = risk seeking
        % PARAM.premiums.premium
        %   contains the risk premium factor between ce and EV
        %       premium > 0 = risk averse; premium < 0 risk seeking
        
%% TO DO LIST

% features
% ...

% corrections
warning('you really have to find a good way to treat missing values - they are not accounted for yet');

% optimisations
% the first transformation of parameter creation parts (like in RT) within the "repeat loop" is used several times in the script and could be implemented on a more global level

%% SETUP
clear; close('all'); clc;

% save and overwrite parameter file
SAVE = 1;

% pause after each subject to see output
PAUSE = 0; % 1 = pause; 2 = 3 seconds delay

% set subjects to analyse
PART = 1:40; 

% design specification
REPEATS_NR = 3; % how many times was one cycle repeated (number of sessions)
VAR_NR = 5; % how many steps of variance variation
COUNTER_NR = 12; % how many steps of counteroffer variation
TRIAL_NR = 120; % how many trials was one cycle
EV = 22.5; % what is the expected value of all gambles

% skip loading of individual files
SKIP_LOAD = 1;

%% DATA HANDLING

% set directories
DIR.home = pwd;
DIR.input = fullfile(DIR.home, 'behavioral_results');
DIR.output = fullfile(DIR.home, 'analysis_results');
DIR.temp = fullfile(DIR.home, 'temp_data');

% load data
if SKIP_LOAD ~= 1;

    % run for every participant in the group
    for part = PART;
        
        % combine 3 sessions (repeats) into one file
        temp_logrec_full = [];
        temp_logrec_sorted_full = [];
        for sess = 1:3;
            load_file = fullfile(DIR.input, [ 'part_' sprintf('%03d', part) '_sess_' num2str(sess) '.mat'] );
            load(load_file, 'logrec', 'sorted_logrec');
            temp_logrec_full = cat(2, temp_logrec_full, logrec);
            temp_logrec_sorted_full = cat(2, temp_logrec_sorted_full, sorted_logrec);
        end
        
        % save participantns into a structure
        RESULT_SEQ.part{part}.mat = temp_logrec_full;
        RESULT_SORT.part{part}.mat = temp_logrec_sorted_full;
        
    end % end participant loop
    
    % create temp directory to save data structure and save
    if exist(DIR.temp, 'dir') ~= 7; mkdir(DIR.temp); end
    save(fullfile(DIR.temp, 'temp.mat'), 'RESULT_SEQ', 'RESULT_SORT');
    
    clear load_file part ambiguity sess logrec sorted_logrec temp_logrec_full temp_logrec_sorted_full;
    
else
    
    % if data is already sorted into the structures it can be loaded here
    load(fullfile(DIR.temp, 'temp.mat'));
    
end
clear SKIP_LOAD;

% create result directory if it doesn't exist
if exist(DIR.output, 'dir') ~= 7; mkdir(DIR.output); end

%% DATA PREPROCESSING

% create matrix for each session
for sub = PART
    for repeat = 1:REPEATS_NR;
        %%% add sessions from 1 to 3
        RESULT_SORT.part{sub}.mat(18,:) = kron(1:REPEATS_NR, ones(1,TRIAL_NR));
        %%% create sub matrices for each repeat
        x = RESULT_SORT.part{sub}.mat; % get matrix of a participant
        y = mat2cell(x, size(x, 1), ones(1, REPEATS_NR)*TRIAL_NR); % split matrix into the 3 repeats
        RESULT_SORT.part{sub}.repeat{repeat}.all = y{repeat};
        RESULT_SORT.part{sub}.repeat{repeat}.risk = y{repeat}(:, y{repeat}(7,:) == 1);
        RESULT_SORT.part{sub}.repeat{repeat}.ambi = y{repeat}(:, y{repeat}(7,:) == 2);
    end
end

clear x y sub resolved repeat;

%% START LOOP OVER SUBJECTS AND CREATE A FIGURE

for sub = PART
    % print output and create figure
    fprintf(['analysing subject subject ' num2str(sub) ' ... ']);
    
    %% PARAMETER SECTION 0: REACTION TIME
    
    % necessary lines fot this parameter
    % LINE 03 - reaction time
    % LINE 04 - choice: 1 = fixed option; 2 = risky/ambiguous option
    
    %% --- CREATE PARAMETER
    
    for repeat = 1:REPEATS_NR;
        
        risk_trials = RESULT_SORT.part{sub}.repeat{repeat}.risk;
        ambi_trials = RESULT_SORT.part{sub}.repeat{repeat}.ambi;
        % sort into variance levels
        risk_trials_var = mat2cell(risk_trials, size(risk_trials, 1), ones(1, VAR_NR)*COUNTER_NR );
        ambi_trials_var = mat2cell(ambi_trials, size(ambi_trials, 1), ones(1, VAR_NR)*COUNTER_NR );
        
        for var_level = 1:VAR_NR;
            
            x = risk_trials_var{var_level};
            
            PARAM.RT.mean(var_level,repeat,1,sub) = nanmean( x(3,:) );
            PARAM.RT.prob(var_level,repeat,1,sub) = nanmean( x(3,x(4,:)==2) ); % RT of chosen probabilistic trials (risky)
            PARAM.RT.fixed(var_level,repeat,1,sub) = nanmean( x(3,x(4,:)==1) ); % RT of chosen fixed trials (counteroffer)
            
            x = ambi_trials_var{var_level};
            
            PARAM.RT.mean(var_level,repeat,2,sub) = nanmean( x(3,:) );
            PARAM.RT.prob(var_level,repeat,2,sub) = nanmean( x(3,x(4,:)==2) ); % RT of chosen probabilistic trials (ambiguous)
            PARAM.RT.fixed(var_level,repeat,2,sub) = nanmean( x(3,x(4,:)==1) ); % RT of chosen fixed trials (counteroffer)   
            
        end
    end
    
    %% PARAMETERS SECTION 1: RISK / AMBIGUITY PREMIUMS
    
    % necessary lines fot this parameter
    % LINE 04 - choice: 1 = fixed option; 2 = risky/ambiguous option
    % LINE 07 - trial type: 1 = risky, 2 = ambiguous
    % LINE 16 - counteroffer amount
    % LINE 19 - risk variance level (1-4; low to high variance)
    % LINE 20 - ambiguity variance level (1-4; low to high variance
    
    %% --- CREATE PARAMETER
    
    for repeat = 1:REPEATS_NR;
        
        risk_trials = RESULT_SORT.part{sub}.repeat{repeat}.risk;
        ambi_trials = RESULT_SORT.part{sub}.repeat{repeat}.ambi;
        risk_choices = risk_trials(4,:)==2; % at which trials risky offer was chosen
        ambi_choices = ambi_trials(4,:)==2; % at which trials ambiguous offer was chosen
        
        risk_trials_var = mat2cell(risk_trials, size(risk_trials, 1), ones(1, VAR_NR)*COUNTER_NR );
        ambi_trials_var = mat2cell(ambi_trials, size(ambi_trials, 1), ones(1, VAR_NR)*COUNTER_NR );
        
        PARAM.premiums.abs_gambles(:,repeat,1,sub) = sum(risk_choices);
        PARAM.premiums.abs_gambles(:,repeat,2,sub) = sum(ambi_choices);
        
        for var_level = 1:VAR_NR;
            x = sum(risk_trials_var{var_level}(4,:)==2); % how many risky trials were chosen in that variance level
            % caclulate certainty equivalent
            if x == 0; % no risky trials were chosen
                ce = risk_trials_var{var_level}(16,1); % take lowest value
            elseif x == COUNTER_NR;  % only risky trials were chosen
                ce = risk_trials_var{var_level}(16,COUNTER_NR); % take highest value
            else
                ce = (risk_trials_var{var_level}(16,x)+risk_trials_var{var_level}(16,x+1))/2;
            end
            PARAM.premiums.ce(var_level,repeat,1,sub) = ce;
            PARAM.premiums.premium(var_level,repeat,1,sub) = 1-(ce./EV);
        end
        
        for var_level = 1:VAR_NR;
            x = sum(ambi_trials_var{var_level}(4,:)==2); % how many ambiguous trials were chosen in that variance level
            % caclulate certainty equivalent
            if x == 0; % no ambiguous trials were chosen
                ce = ambi_trials_var{var_level}(16,1); % take lowest value
            elseif x == COUNTER_NR;  % only ambiguous trials were chosen
                ce = ambi_trials_var{var_level}(16,COUNTER_NR); % take highest value
            else
                ce = (ambi_trials_var{var_level}(16,x)+ambi_trials_var{var_level}(16,x+1))/2;
            end
            PARAM.premiums.ce(var_level,repeat,2,sub) = ce;
            PARAM.premiums.premium(var_level,repeat,2,sub) = 1-(ce./EV);
        end
           
    end
    
    %% --- CREATE FIGURE 1
    
    %%% %%% %%% %%% %%%
    %%% GOOD UNTIL HERE...
    %%% %%% %%% %%% %%%
    
    FIGS.fig1 = figure('Name', [ 'subject: ' num2str(sub) ], 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 .5 1]);
    axisscale = [.5 5.5 5 38];
    
    for repeat = 1:REPEATS_NR;
        
        risk_trials = RESULT_SORT.part{sub}.repeat{repeat}.risk;
        ambi_trials = RESULT_SORT.part{sub}.repeat{repeat}.ambi;
        risk_choices = risk_trials(4,:)==2; % at which trials risky offer was chosen
        ambi_choices = ambi_trials(4,:)==2; % at which trials ambiguous offer was chosen
        
        risk_trials_var = mat2cell(risk_trials, size(risk_trials, 1), ones(1, VAR_NR)*COUNTER_NR );
        ambi_trials_var = mat2cell(ambi_trials, size(ambi_trials, 1), ones(1, VAR_NR)*COUNTER_NR );
        
        % risky trials
        subplot(2,4,repeat);
        scatter(risk_trials(19,:), risk_trials(16,:), 'k'); box off; hold on;
        scatter(risk_trials(19,risk_choices==0), risk_trials(16,risk_choices==0), 'b', 'MarkerFaceColor', 'b');
        
        plot( PARAM.premiums.ce(:,repeat,1,sub), '--k', 'LineWidth', 3); box off; hold on;
        
        axis(axisscale);
        xlabel('variance'); title([' T' num2str(repeat) ' (risk)' ]);
        ylabel('counteroffer value');
        
        % ambiguous trials
        subplot(2,4,repeat+4);
        scatter(ambi_trials(20,:), ambi_trials(16,:), 'k'); box off; hold on;
        scatter(ambi_trials(20,ambi_choices==0), ambi_trials(16,ambi_choices==0), 'r', 'MarkerFaceColor', 'r');
        
        plot( PARAM.premiums.ce(:,repeat,2,sub), '--k', 'LineWidth', 3); box off; hold on;
        
        axis(axisscale);
        xlabel('variance'); title([' T' num2str(repeat)  ' (ambiguity)' ]);
        ylabel('counteroffer value');
        
    end
    
    %%% plot parameter
    subplot(2,4,4);
    
    plot( sum(PARAM.premiums.ce(:,:,1,sub), 1)/VAR_NR, 'b', 'LineWidth', 3); box off; hold on;
    plot( sum(PARAM.premiums.ce(:,:,2,sub), 1)/VAR_NR, 'r', 'LineWidth', 3);
    plot( ones(1, REPEATS_NR)*EV, ':k', 'LineWidth', 2);
    
    axis([.5 3.5 5 25]);
    xlabel('timepoints'); title('mean aversion'); legend('risk', 'ambiguity', 'neutrality');
    ylabel('subjective value');
    
    subplot(2,4,8);
    
    plot( sum(PARAM.premiums.ce(:,:,1,sub), 1)/VAR_NR, 'b', 'LineWidth', 3); box off; hold on;
    plot( sum(PARAM.premiums.ce(:,:,2,sub), 1)/VAR_NR, 'r', 'LineWidth', 3);
    plot( ones(1, REPEATS_NR)*EV, ':k', 'LineWidth', 2);
    
    axis([.5 3.5 5 25]);
    xlabel('timepoints'); title('mean aversion'); legend('risk', 'ambiguity', 'neutrality');
    ylabel('subjective value');
    
    %% --- CREATE FIGURE 2
    
    % sorting variance rather than repeats
    FIGS.fig2 = figure('Name', [ 'subject: ' num2str(sub) ], 'Color', 'w', 'units', 'normalized', 'outerposition', [.5 .5 .5 1]);
    axisscale = [.5 3.5 5 38];
    
    x = RESULT_SORT.part{sub}.mat;
    for varlevel = 1:VAR_NR;
        %%% create data to plot
        selector = x(7,:)==1 & x(19,:)==varlevel;
        varmat_risk = x(:,selector);
        selector = x(7,:)==2 & x(20,:)==varlevel;
        varmat_ambi = x(:,selector);
        
        %%% plot parameter
        % risky trials
        subplot(2,6,varlevel);
        scatter(varmat_risk(18,:), varmat_risk(16,:), 'k'); box off; hold on;
        scatter(varmat_risk(18,varmat_risk(4,:)==1), varmat_risk(16,varmat_risk(4,:)==1), 'b', 'MarkerFaceColor', 'b');
        
        plot( PARAM.premiums.ce(varlevel,:,1,sub), '--k', 'LineWidth', 3); box off; hold on;
        
        axis(axisscale);
        xlabel('timepoints'); title([' variance ' num2str(varlevel)  ' (risk)' ]);
        ylabel('counteroffer value');
        
        % ambiguous trials
        subplot(2,6,varlevel+6);
        scatter(varmat_ambi(18,:), varmat_ambi(16,:), 'k'); box off; hold on;
        scatter(varmat_ambi(18,varmat_ambi(4,:)==1), varmat_ambi(16,varmat_ambi(4,:)==1), 'r', 'MarkerFaceColor', 'r');
        
        plot( PARAM.premiums.ce(varlevel,:,2,sub), '--k', 'LineWidth', 3); box off; hold on;
        
        axis(axisscale);
        xlabel('timepoints'); title([' variance ' num2str(varlevel)  ' (ambiguity)' ]);
        ylabel('counteroffer value');
        
    end
    
    subplot(2,6,6);
    
    plot( sum(PARAM.premiums.ce(:,:,1,sub), 2)/REPEATS_NR, 'b', 'LineWidth', 3); box off; hold on;
    plot( sum(PARAM.premiums.ce(:,:,2,sub), 2)/REPEATS_NR, 'r', 'LineWidth', 3);
    plot( ones(1, VAR_NR)*EV, ':k', 'LineWidth', 2);
    
    axis([.5 5.5 5 25]);
    xlabel('variance'); title('mean aversion'); legend('risk', 'ambiguity', 'neutrality');
    ylabel('subjective value');
    
    subplot(2,6,12);
    
    plot( sum(PARAM.premiums.ce(:,:,1,sub), 2)/REPEATS_NR, 'b', 'LineWidth', 3); box off; hold on;
    plot( sum(PARAM.premiums.ce(:,:,2,sub), 2)/REPEATS_NR, 'r', 'LineWidth', 3);
    plot( ones(1, VAR_NR)*EV, ':k', 'LineWidth', 2);
    
    axis([.5 5.5 5 25]);
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

clear sub;

%% SAVE CALCULATED PARAMETERS

if SAVE == 1;
    save(fullfile(DIR.output, 'parameters.mat'), 'PARAM', 'RESULT_SEQ', 'RESULT_SORT');
end

% END OF SCRIPT
disp('thank you, come again!');


