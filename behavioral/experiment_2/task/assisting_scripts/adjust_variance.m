% this code is used for behavioral experiment 2(!)
% script to match variance of risky offers to ambiguous trials
% uses the symbolic math toolbox
clear; close all; clc;

%% add mean variance function from parrent folder
home = pwd;
cd ..;
addpath(pwd);
cd(home);

%% setup & parameters

% output multiple solutions
DISPLAY_SOLUTION = 0;

% 9 desired steps of variance variation;
var_steps = 9;
% 2 desired orthogonal expected value levels;
ev_steps = 2;
ev_values = [8.5 34]; % good possible EVs = [8.5, 17, 25.5, 34, ...]

%% calculate variance for ambigous trials$

% calculate trials number
nTrials = var_steps*ev_steps;

% create matrix with all values used for construction on trials
all_vals = NaN(ev_steps, var_steps*2); % preallocate
for ev_level = 1:ev_steps;
    all_vals(ev_level,:) = linspace(0, ev_values(ev_level)*2, 18);
end

% sort into ambiguity trials
X.AVL = []; % ambiguitly levels low
X.AVH = []; % ambiguitly levels high
for ev_level = 1:ev_steps;
    X.AVL = [X.AVL, fliplr(all_vals(ev_level,1:var_steps)) ];
    X.AVH = [X.AVH, all_vals(ev_level,var_steps+1:var_steps*2) ];
end

% calulate desired varianve for each trial
var_goal = NaN(1,nTrials);
for iTrial = 1:nTrials;
    var_goal(iTrial) = mean_variance( .5, X.AVL(iTrial), .5, X.AVH(iTrial) );
end

% calulate desired EV for each trial
EV_goal = kron(ev_values, ones(1,var_steps));

%% calculate values to match to ambiguous variance structure
disp(' '); disp('+++++ CALCULATING SOLUTION...');  disp(' ');

% define probabilites of risky trials
p_low_range = .18:.08:.82;
p_low = repmat(p_low_range, 1, ev_steps);
p_high_range = fliplr(.18:.08:.82);
p_high = repmat(p_high_range, 1, ev_steps);

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
    solution_vec = ones(1,nTrials); % in this case the first solution is always the best
    
    X.RVH(iTrial) = double( sol_v1(solution_vec(iTrial)) );
    X.RVL(iTrial) = double( sol_v2(solution_vec(iTrial)) );
    
end

%% test solution
disp(' '); disp('+++++ TESTING SOLUTION...'); disp(' ');

for iTrial = 1:nTrials;
    
    disp([ '--- p = ' num2str(X.RPH(iTrial)) ' & ' num2str(X.RPL(iTrial)) ' | EV = ' num2str(EV_goal(iTrial))]);
    
    disp([ 'goal variance = ' num2str(var_goal(iTrial)) ]);
    
    [var, ev] = mean_variance( X.RPH(iTrial), X.RVH(iTrial), X.RPL(iTrial), X.RVL(iTrial) );
    disp([ 'var = ' num2str(var) ', ev = ' num2str(ev) ]); disp(' ');
    
end

%% show all calculated trials
disp(' '); disp('+++++ SHOWING FINAL CALCULATED TRIALS...'); disp(' ');

final_set = array2table([X.RVL; X.RPL; X.RPH; X.RVH; NaN(1,nTrials); X.AVL; X.AVH]', ...
    'VariableNames', {'R_low', 'p2', 'p1', 'R_high', 'x', 'A_low', 'A_high'});

disp(final_set);

% rewrite results from above
X.AVL = [8     7     6     5     4     3     2     1     0    32    28    24    20    16    12     8     4     0]; % ambiguitly levels low
X.AVH = [9    10    11    12    13    14    15    16    17    36    40    44    48    52    56    60    64    68]; % ambiguitly levels high

X.RPL = [0.1800    0.2600    0.3400    0.4200    0.5000    0.5800    0.6600    0.7400    0.8200    0.1800    0.2600    0.3400    0.4200    0.5000   0.5800    0.6600    0.7400    0.8200]; % probability low value
X.RPH = [0.8200    0.7400    0.6600    0.5800    0.5000    0.4200    0.3400    0.2600    0.1800    0.8200    0.7400    0.6600    0.5800    0.5000   0.4200    0.3400    0.2600    0.1800]; % probability high value

X.RVH = [8.7343    9.3891   10.2944   11.4784   13.0000   14.9633   17.5562   21.1529   26.6422   34.9370   37.5565   41.1774   45.9135   52.0000   59.8531   70.2248   84.6116  106.5687]; % probability values low
X.RVL = [7.4328    5.9694    5.0168    4.3870    4.0000    3.8197    3.8347    4.0544    4.5176   29.7313   23.8777   20.0674   17.5480   16.0000   15.2788   15.3387   16.2175   18.0703]; % probability values high
