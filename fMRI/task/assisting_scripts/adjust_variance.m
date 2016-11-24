% script to match variance of risky offers to ambiguous trials
% uses the symbolic math toolbox
clear; close all; clc;

%% add mean variance function from dependencies folder
cd ..;
home = pwd;
addpath(fullfile(home, 'dependencies'));
addpath(fullfile(home, 'assisting_scripts'));
cd(fullfile(home, 'assisting_scripts'));

%% calculate variance for ambigous trials
solution = 'five'; % chose solution for "four" or "five" variance levels
use_zero_ambiguity = 'yes'; % start ambiguous trials at 0 or not

switch solution
    case 'five'
        switch use_zero_ambiguity
            case 'yes';       
                X.AVL = [20 15 10 5 0];        % ambiguitly levels low
                X.AVH = [25 30 35 40 45];      % ambiguitly levels high
            case 'no';
                X.AVL = [25 20 15 10 5];        % ambiguitly levels low
                X.AVH = [30 35 40 45 50];      % ambiguitly levels high
        end
        levels = 5;
    case 'four'
        X.AVL = [15 10 5 0];        % ambiguitly levels low
        X.AVH = [25 30 35 40];      % ambiguitly levels high
        levels = 4;
end

% calculate goal variance and expected value
goal_var = NaN(1,levels);
goal_ev = NaN(1,levels);
for i = 1:levels;
    goal_var(i) = mean_variance( .5, X.AVL(i), .5, X.AVH(i) );
    goal_ev(i) = (X.AVL(i)+X.AVH(i))./2;
end

%% calculate values to match to ambiguous variance structure
disp('***** CALCULATING SOLUTION...');  disp(' ');

DISPLAY_SOLUTION = 1;

% set correct probability level for solution
switch solution
    case 'five'
        p1 = [.8 .65 .5 .35 .2];
        p2 = [.2 .35 .5 .65 .8];
    case 'four'
        p1 = [.8 .6 .4 .2];
        p2 = [.2 .4 .6 .8];
end

% solve the problem
syms v1 v2;
for i = 1:levels;
    
    eqn_ev = v1*p1(i) + v2*p2(i) == goal_ev;  % ev should be 20
    eqn_var = ((v1-goal_ev(i)) ^2) * p1(i) + ((v2-goal_ev(i))^2) * p2(i) == goal_var(i); % variance should match to goal
    
    [sol_v1, sol_v2] = solve(eqn_var, eqn_ev, v1, v2);
    % [sol_v1, sol_v2] = vpasolve(eqn_var, eqn_ev, v1, v2);
    
    if DISPLAY_SOLUTION == 1
        disp([ '--- p = ' num2str(p1(i)) ' & ' num2str(p2(i)) ]);
        disp(sol_v1);
        disp(sol_v2);
    end
    
end

%% test solution
disp('***** TESTING SOLUTION...'); disp(' ');
disp([ 'goal variance = ' num2str(goal_var) ]); 
disp([ 'goal expected value  = ' num2str(goal_ev) ]); disp(' ');

switch solution
    case 'five'
        
        switch use_zero_ambiguity  
            case 'yes';
                X.RVH = [95/4, (15*91^(1/2))/26+45/2, 35, (5*91^(1/2))/2+45/2, 135/2];                 % probability values high
                % 23.8 28.0 35.0 46.3 67.5
                X.RVL = [35/2, 45/2-(15*91^(1/2))/14, 10, 45/2-(35*91^(1/2))/26, 45/4];                % probability values low
                % 17.5 12.3 10.0 9.7 11.3
            case 'no';
                X.RVH = [115/4,  (15*91^(1/2))/26+55/2, 40,  (5*91^(1/2))/2 + 55/2,  145/2];           % probability values high
                % 28.8 33.0 40.0 51.3 72.5
                X.RVL = [45/2,  55/2-(15*91^(1/2))/14, 15,  55/2 - (35*91^(1/2))/26, 65/4];            % probability values low
                % 22.5 17.3 15 14.7 16.3
        end
        
    case 'four'
        
        X.RVH = [22.5 , (10*6^(1/2))/3+20 , (15*6^(1/2))/2+20 , 60];    % probability values high
        % 22.50 28.17 38.37 60.00
        X.RVL = [10 , 20-5*6^(1/2) , 20-5*6^(1/2) , 10];                % probability values low
        % 10.00 7.75 7.75 10.00
        
end

for i = 1:levels;
    disp([ '--- p = ' num2str(p1(i)) ' & ' num2str(p2(i)) ]);
    
    [var, ev] = mean_variance( p1(i), X.RVH(i), p2(i), X.RVL(i) );
    disp([ 'var = ' num2str(var) ', ev = ' num2str(ev) ]); disp(' ');
end
