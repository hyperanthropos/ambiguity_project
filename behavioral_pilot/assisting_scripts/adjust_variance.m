% script to match variance of risky offers to ambiguous trials
clear; close all; clc;

%% add mean variance function from parrent folder
home = pwd;
cd ..;
addpath(pwd);
cd(home);
  
%% calculate variance for ambigous trials
X.AVL = [15 10 5 0];        % ambiguitly levels low
X.AVH = [25 30 35 40];      % ambiguitly levels high

% mean variance for ambiguous trials
for i = 1:4;
    goal(i) = mean_variance( .5, X.AVL(i), .5, X.AVH(i) );
end

%% calculate values to match to ambiguous variance structure

% missing symbolic math toolbox
ver

disp(goal);

ev = 20;
p1 = .8;
p2 = .2;

syms v1; syms v2;


variance = (v1-ev) ^2 * p1 + (v2-ev)^2 * p2 == 25
exp_value = v1*p1 + v2*p2


