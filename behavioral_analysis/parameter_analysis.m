%% SCRIPT TO ANALYSE PARAMTERS
% this script analyses parameters on the group level, creates figures and
% runs statistical tests

%% SETUP

% design specification
REPEATS_NR = 4; % how many times was one cycle repeated

%% DATA HANDLING

% set directories
DIR.home = pwd;
DIR.output = fullfile(DIR.home, 'analysis_results');

% load data
load(fullfile(DIR.output, 'parameters.mat'), 'PARAM');

%% GROUPS ANALYSIS OF PARAMETERS

