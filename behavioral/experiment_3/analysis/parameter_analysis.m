%% SCRIPT TO ANALYSE PARAMTERS
% analysis script for experiment_3 (!)
% this script analyses parameters on the group level, creates figures and
% runs statistical tests
% reads data from parameter_creation script

% clean the field
clear; close all; clc;

% this script needs the function "barwitherr", which makes ploting error
% bars easier:
SUBFUNCTIONS_PATH = '/home/fridolin/DATA/MATLAB/downloaded_functions';

%% SETUP

% set figures you want to draw
DRAW = [1 2 3];
% 01 | BINARY CHOICE ANANLYSIS
% 02 | SWITCHPOINT ANALYSIS

% for which repeats you want figures
DRAW_REPEATS = 1;

% set subjects to analyse
PART = 1:55;

% exclude subjects for certain reasons
EXCLUDE = false;
EXCLUDE_SUBS = [1 2 3 4 5]; % exclude candidates
% this format allows to use an auto-generated exclude vector (e.g. exclude all risk averse)

% design specification
VAR_NR = 15; % how many steps of variance variation
EV_LEVELS = 6; % how many steps of expected value variation
EV = 7.25 * [1 2 3 4 5 6]; % what were the expected values of all gambles
REPEATS_NR = 2; % how many times was one full variation repeated

%% DATA HANDLING

% set directories
DIR.home = pwd;
DIR.input = fullfile(DIR.home, 'analysis_results');

% load data
load(fullfile(DIR.input, 'parameters.mat'), 'PARAM');

% load data from experiment 2 for comparions
cd ..; cd ..;
exp2_data = load('experiment_2/analysis/analysis_results/parameters.mat', 'PARAM');
cd(DIR.home);

% exclude subjects from subject vector
exclude_vec = EXCLUDE_SUBS;
if EXCLUDE == 1
        PART(exclude_vec) = [];
end
clear i exclude_vec;

%% FIGURE 1: BINARY ANALYSIS GROUP SUMMARY

% used parameter specifications
% PARAM.choice_matrix.choice    (ev_level,variance,sub,repeat) | 1 = risky option; 2 = ambiguous option
% PARAM.choice_matrix.RT        (ev_level,variance,sub,repeat)

for repeat = DRAW_REPEATS;
    if sum(DRAW == 1);
        
        figure('Name', ['F1: binary decision analysis | repeat: ' num2str(repeat) ] , 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 1 1]);
        
        % colors
        l_blue = [.8 .8 1];
        l_red = [1 .8 .8];
        bar_gray = [.2 .2 .2];
        
        % max choices
        max_c = length(PART);
        
        % recode risk = 1 / ambiguity = -1
        x = PARAM.choice_matrix.choice(:,:,PART,repeat);
        x(x==2)=-1;
        
        % surf
        subplot(2,3,1);
        surf(mean(x,3)); colormap(flipud(jet)); hold on;
        h(1) = surf(zeros(6,15));
        set(h(1), 'FaceColor', [.8 .8 .8]);
        xlabel('variance'); ylabel('expected value');
        
        %%% plot variance
        subplot(2,3,2);
        bar(mean(sum(x==1,3),1), 'FaceColor', l_blue); hold on;
        bar(-mean(sum(x==-1,3),1), 'FaceColor', l_red);
        bar(mean(sum(x,3),1), 'FaceColor', bar_gray);
        plot(1:15, ones(1,15)*max_c, '-b', 'LineWidth', 3);
        plot(1:15, ones(1,15)*-max_c,'-r', 'LineWidth', 3);
        xlabel('variance'); ylabel('relative / abs. sum of choices');
        
        subplot(2,2,4);
        bar(sum(x==1,3)', 'FaceColor', l_blue); hold on;
        bar(-sum(x==-1,3)', 'FaceColor', l_red);
        bar(sum(x,3)', 'FaceColor', bar_gray);
        plot(1:15, ones(1,15)*max_c, '-b', 'LineWidth', 3);
        plot(1:15, ones(1,15)*-max_c,'-r', 'LineWidth', 3);
        xlabel('variance'); ylabel('relative / abs. sum of choices');
        
        %%% plot EV
        subplot(2,3,3);
        bar(mean(sum(x==1,3),2), 'FaceColor', l_blue); hold on;
        bar(-mean(sum(x==-1,3),2), 'FaceColor', l_red);
        bar(mean(sum(x,3),2), 'FaceColor', bar_gray);
        plot(1:6, ones(1,6)*max_c, '-b', 'LineWidth', 3);
        plot(1:6, ones(1,6)*-max_c,'-r', 'LineWidth', 3);
        xlabel('expected value'); ylabel('relative / abs. sum of choices');
        
        subplot(2,2,3);
        bar(sum(x==1,3), 'FaceColor', l_blue); hold on;
        bar(-sum(x==-1,3), 'FaceColor', l_red);
        bar(sum(x,3), 'FaceColor', bar_gray);
        plot(1:6, ones(1,6)*max_c, '-b', 'LineWidth', 3);
        plot(1:6, ones(1,6)*-max_c, '-r', 'LineWidth', 3);
        xlabel('expected value'); ylabel('relative / abs. sum of choices');
        
        clear x h l_blue l_red bar_gray repeat max_c;
        
    end
end

%% FIGURE 2: PLOT EXP 3 RESPONSE OVER VARIANCE AND PROB LEVELS AND COMPARE WITH EXP 2 RESPONSE

% used parameter specifications
% PARAM.choice_matrix.choice            (ev_level,variance,sub,repeat) | 1 = risky option; 2 = ambiguous option
% PARAM.choice_matrix.RT                (ev_level,variance,sub,repeat)
% PARAM.choice_matrix.fixed.mvar        (EV, variance)
% PARAM.choice_matrix.fixed.prob_high   (EV, variance)
% PARAM.choice_matrix.fixed.EV          (EV, variance)

for repeat = DRAW_REPEATS;
    if sum(DRAW == 2);
        
        figure('Name', ['F2: normalize over variance and probability | repeat: ' num2str(repeat) ] , 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 1 1]);
        
        %%% PREPARE DATA
        
        % create choice frequency matrix (EV, var)
        x = PARAM.choice_matrix.choice(:,:,PART,repeat);
        x(x==2)=-1; % recode risk = 1 / ambiguity = -1
        choice_freq = sum(x,3);
       
        clear x;
        
        % create choice, mvar, prob, ev matrix
        ch_var_pr_ev(1,:) = choice_freq(:);
        ch_var_pr_ev(2,:) = log(PARAM.choice_matrix.fixed.mvar(:));
        ch_var_pr_ev(3,:) = PARAM.choice_matrix.fixed.prob_high(:);
        ch_var_pr_ev(4,:) = PARAM.choice_matrix.fixed.EV(:);
        
        %%% PLOT DATA
        
        % relationship between mean variance and probability
        subplot(2,3,1);
        x = log(PARAM.choice_matrix.fixed.mvar);
        surf(x); box off;
        
        xlabel('probability (variance)');
        ylabel('expected value levels');
        zlabel('mean variance [log]');
        title('outcome variance over EV levels');
        
        clear x;
        
        % plot decisions over actual variance
        subplot(2,3,2);
        x = sortrows(ch_var_pr_ev',2)';
        plot(x(2,:), x(1,:), 'LineWidth', 2); box off; hold on;
        scatter(x(2,:), x(1,:), 'k');
        xlabel('mean variance [log]');
        ylabel('sum of risky choices');
        title('choices sorted by mean variance');
        
        clear x;
        
        % plot decisions over actual variance for each EV level
        subplot(2,3,3);
        x(:,:,1) = log(PARAM.choice_matrix.fixed.mvar);
        x(:,:,2) = choice_freq;
        for i = 1:6;
        plot(x(i,:,1), x(i,:,2), 'LineWidth', 2); hold on; box off;
        end
        xlabel('mean variance [log]');
        ylabel('sum of risky choices');
        title('choices by variance for each EV level');
        
        clear x;
        
        % plot decisions over variance and probability
        subplot(2,3,4);
        x = ch_var_pr_ev;
        % normalize choice vector for marker size
        marker_size = ( x(1,:)-min(x(1,:)) ) / ( max(x(1,:))-min(x(1,:)) );
        scatter3(x(2,:), x(3,:), x(1,:), 1+marker_size*40, 'MarkerFaceColor', 'b'); hold on;
        plot(x(2,:), x(3,:), 'k')
        xlabel('mean variance [log]');
        ylabel('probability of high amount');
        zlabel('sum of risky choices');
        
        clear x marker size;
        
    end
end

%% FIGURE 3: COMPARISON WITH EXP 2 RESPONSE OVER VARIANCE AND PROBABILITY LEVELS

% used parameter specifications
% PARAM.choice_matrix.choice            (ev_level,variance,sub,repeat) | 1 = risky option; 2 = ambiguous option
% PARAM.choice_matrix.RT                (ev_level,variance,sub,repeat)
% PARAM.choice_matrix.fixed.mvar        (EV, variance)
% PARAM.choice_matrix.fixed.prob_high   (EV, variance)
% PARAM.choice_matrix.fixed.EV          (EV, variance)

for repeat = DRAW_REPEATS;
    if sum(DRAW == 3);
        
        figure('Name', ['F3: comparision with data from experiment 2 | repeat: ' num2str(repeat) ] , 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 1 1]);
        
        
        % needs factor transormation in behav 2 data - how much more likely to take
        % A/R
        
        % 1 response profile comparing to mvar
        % 1 response profile comparing to prob
        
        
    end
end

