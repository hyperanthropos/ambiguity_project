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
% 01 | GROUP SUMMARY
% 02 | ???

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

%% FIGURE 1: GROUP SUMMARY

% used parameter specifications
% PARAM.switchpoint             (ev_level,sub,repeat)
% PARAM.choice_matrix.choice    (ev_level,variance,sub,repeat) | 1 = risky option; 2 = ambiguous option
% PARAM.choice_matrix.RT        (ev_level,variance,sub,repeat)

if sum(DRAW == 1);
    
    

end

%% FIGURE 2: ???

% ???
% ???

if sum(DRAW == 2);
    
    
    
end

