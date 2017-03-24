% this code is used for behavioral experiment 3(!)
% script to match variance of risky offers to ambiguous trials
% uses the symbolic math toolbox
clear; close all; clc;

%% add mean variance function from parrent folder
home = pwd;
cd ..;
addpath(pwd);
cd(home);

%% setup & parameters

DISPLAY_SOLUTION = 0; % output multiple solutions
TEST_SOLUTION = 1; % proof that final values are matched in EV and variance

var_steps = 15; % desired steps of variance variation
ev_base = 7.25; % expected value for trials
% to be multiplied with EV factors in stimuli creation script
% suggested scaling factors for 7.25 are [1 2 3 4 5 6]
% = EV of 7.25, 14.5, 21.75, 29, 36.25, 43.5; mean ~ 25

%% calculate variance for ambigous trials

% calculate trials number
nTrials = var_steps;

% create matrix with all values used for construction on trials
all_vals = linspace(0, ev_base*2, var_steps*2);

% sort into ambiguity trials
X.AVL = fliplr(all_vals(1:var_steps));
X.AVH = all_vals(var_steps+1:var_steps*2);

% calulate desired varianve for each trial
var_goal = NaN(1,nTrials);
for iTrial = 1:nTrials;
    var_goal(iTrial) = mean_variance( .5, X.AVL(iTrial), .5, X.AVH(iTrial) );
end

% calulate desired EV for each trial
EV_goal = kron(ev_base, ones(1,var_steps));

%% calculate values to match to ambiguous variance structure
disp(' '); disp('+++++ CALCULATING SOLUTION...');  disp(' ');

% define probabilites of risky trials

p_range = [.15 .85];

p_low = linspace(p_range(1), p_range(2), var_steps);
p_high = fliplr(linspace(p_range(1), p_range(2), var_steps));

X.RPL = p_low;
X.RPH = p_high;

% solve the problem
syms v1 v2;

for iTrial = 1:nTrials;
    
    % define equations
    eqn_ev = v1*X.RPH(iTrial) + v2*X.RPL(iTrial) == EV_goal(iTrial); % ev should match goal
    eqn_var = ((v1-EV_goal(iTrial)) ^2) * X.RPH(iTrial) + ((v2-EV_goal(iTrial))^2) * X.RPL(iTrial) == var_goal(iTrial); % variance should match to goal
    
    % solve
    [sol_v1, sol_v2] = solve(eqn_var, eqn_ev, v1, v2);
    
    % display solutions
    if DISPLAY_SOLUTION == 1
        disp([ '--- p = ' num2str(X.RPH(iTrial)) ' & ' num2str(X.RPL(iTrial)) ' | EV = ' num2str(EV_goal(iTrial)) ]);
        disp([double(sol_v1), double(sol_v2)]);
    end
    
    % pick best solution
    solution_vec = [1 1 1 1 1 1 1 1 1 1 1 1 1 2 1]; % done by hand
    
    X.RVH(iTrial) = double( sol_v1(solution_vec(iTrial)) );
    X.RVL(iTrial) = double( sol_v2(solution_vec(iTrial)) );
    
end

%% show all calculated trials
disp(' '); disp('+++++ SHOWING FINAL CALCULATED TRIALS...'); disp(' ');

final_set = array2table([X.RVL; X.RPL; X.RPH; X.RVH; NaN(1,nTrials); X.AVL; X.AVH]', ...
    'VariableNames', {'R_low', 'p2', 'p1', 'R_high', 'x', 'A_low', 'A_high'});

disp(final_set);

% rewrite results from above
X.AVL = linspace(7, 0, 15); % ambiguitly levels low
X.AVH = linspace(7.5, 14.5, 15); % ambiguitly levels high

X.RPL = linspace(.15, .85, 15); % probability low value
X.RPH = linspace(.85, .15, 15); % probability high value

X.RVH = [7.3550    7.6250    7.9717    8.3956    8.9010    9.4954   10.1897   11.0000   11.9486   13.0675   14.4045   16.0333   18.0753   20.7500   24.5085]; % probability values low
X.RVL = [6.6549    5.7500    5.0849    4.5768    4.1838    3.8820    3.6570    3.5000    3.4057    3.3716    3.3976    3.4857    3.6416    3.8750   4.2044]; % probability values high

%% test solution
if TEST_SOLUTION == 1;
    disp(' '); disp('+++++ TESTING SOLUTION...'); disp(' ');
    
    for iTrial = 1:nTrials;
        
        disp([ '--- p = ' num2str(X.RPH(iTrial)) ' & ' num2str(X.RPL(iTrial)) ]);
        
        disp([ 'goal variance = ' num2str(var_goal(iTrial)) ' | goal ev = ' num2str(EV_goal(iTrial)) ]);
        
        [var, ev] = mean_variance( X.RPH(iTrial), X.RVH(iTrial), X.RPL(iTrial), X.RVL(iTrial) );
        disp([ 'var = ' num2str(var) ' | ev = ' num2str(ev) ]); disp(' ');
        
    end
end

