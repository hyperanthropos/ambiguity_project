% script to match variance of risky offers to ambiguous trials
% uses the symbolic math toolbox
clear; close all; clc;

%% add mean variance function from parrent folder
home = pwd;
cd ..;
addpath(pwd);
cd(home);

%% setup & parameters

DISPLAY_SOLUTION = 1;

% 9 desired steps of variance variation;
var_steps = 9;
% 2 desired orthogonal expected value levels;
ev_steps = 2;
ev_values = [8.5 34]; % good possible EVs = [8.5 17 25.5 34]

%% calculate variance for ambigous trials$

% calculate trials number
nTrials = var_steps*ev_steps;

% create matrix with all values used for construction on trials
all_vals = NaN(ev_steps, var_steps*2); % preallocate
for ev_level = 1:ev_steps;
    all_vals(ev_level,:) = linspace(0, ev_values(ev_level)*2, 18);
end

% sort into ambiguity trials
AVL = []; % ambiguitly levels low
AVH = []; % ambiguitly levels high
for ev_level = 1:ev_steps;
    AVL = [AVL, fliplr(all_vals(ev_level,1:var_steps)) ]; %#ok<AGROW>
    AVH = [AVH, all_vals(ev_level,var_steps+1:var_steps*2) ]; %#ok<AGROW>
end

% rewrite results from above
X.AVL = [8     7     6     5     4     3     2     1     0    32    28    24    20    16    12     8     4     0]; % ambiguitly levels low
X.AVH = [9    10    11    12    13    14    15    16    17    36    40    44    48    52    56    60    64    68]; % ambiguitly levels high

% calulate desired varianve for each trial
var_goal = NaN(1,nTrials);
for iTrial = 1:nTrials;
    var_goal(iTrial) = mean_variance( .5, X.AVL(iTrial), .5, X.AVH(iTrial) );
end

% calulate desired EV for each trial
EV_goal = kron(ev_values, ones(1,var_steps));

%% calculate values to match to ambiguous variance structure
disp('CALCULATING SOLUTION...');  disp(' ');

% define probabilites of risky trials
p_low = .18:.08:.82;
p_high = fliplr(.18:.08:.82);

% rewrite results from above
X.RPH = [0.1800    0.2600    0.3400    0.4200    0.5000    0.5800    0.6600    0.7400    0.8200];
X.RPL = [0.8200    0.7400    0.6600    0.5800    0.5000    0.4200    0.3400    0.2600    0.1800];

% solve the problem
syms v1 v2;

for iTrial = 1:nTrials;
    
    eqn_ev = v1*X.RPH(iTrial) + v2*X.RPL(iTrial) == EV_goal(iTrial); % ev should match goal
    eqn_var = ((v1-EV_goal(iTrial)) ^2) * X.RPH(iTrial) + ((v2-EV_goal(iTrial))^2) * X.RPL(iTrial) == var_goal(i); % variance should match to goal
    
    [sol_v1, sol_v2] = solve(eqn_var, eqn_ev, v1, v2);
    
    if DISPLAY_SOLUTION == 1
        disp([ '--- p = ' num2str(p1(i)) ' & ' num2str(p2(i)) ]);
        disp(sol_v1);
        disp(sol_v2);
    end
    
end

keyboard;

%% test solution
disp('TESTING SOLUTION...');
disp([ 'goal variance = ' num2str(var_goal) ]); disp(' ');

X.RVH = [22.5 , (10*6^(1/2))/3+20 , (15*6^(1/2))/2+20 , 60];    % probability values high
% 22.50 28.17 38.37 60.00
X.RVL = [10 , 20-5*6^(1/2) , 20-5*6^(1/2) , 10];                % probability values low
% 10.00 7.75 7.75 10.00

for i = 1:4;
    
    disp([ '--- p = ' num2str(p1(i)) ' & ' num2str(p2(i)) ]);
    
    [var, ev] = mean_variance( p1(i), X.RVH(i), p2(i), X.RVL(i) );
    disp([ 'var = ' num2str(var) ', ev = ' num2str(ev) ]); disp(' ');
    
end