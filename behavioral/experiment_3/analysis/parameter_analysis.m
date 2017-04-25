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
DRAW = [1 2];
% 01 | BINARY CHOICE ANANLYSIS
% 02 | SWITCHPOINT ANALYSIS

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

for repeat = 1:REPEATS_NR;
    if sum(DRAW == 1);
        
        figure('Name', ['F1: binary decision analysis | repeat: ' num2str(repeat) ] , 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 1 1]);
        
        % colors
        l_blue = [.8 .8 1];
        l_red = [1 .8 .8];
        bar_gray = [.2 .2 .2];
        
        % max choices
        max_c = length(PART);
        
        % recode risk = 1 / ambiguity = -1
        x = PARAM.choice_matrix.choice(:,:,:,repeat);
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

%% FIGURE 2: ???

% used parameter specifications
% PARAM.switchpoint             (ev_level,sub,repeat)

if sum(DRAW == 2);
    
    
    
end

