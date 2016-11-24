% script to match variance of risky offers to ambiguous trials
% uses the symbolic math toolbox
clear; close all; clc;

%% add mean variance function from dependencies folder
home = pwd;
cd ..;
addpath('dependencies');
addpath(pwd);
cd(home);

%% calculate variance for ambigous trials
X.AVL = [15 10 5 0];        % ambiguitly levels low
X.AVH = [25 30 35 40];      % ambiguitly levels high

goal = NaN(1,4);
for i = 1:4;
    goal(i) = mean_variance( .5, X.AVL(i), .5, X.AVH(i) );
end

%% calculate values to match to ambiguous variance structure
disp('CALCULATING SOLUTION...');  disp(' ');

DISPLAY_SOLUTION = 1;

p1 = [.8 .6 .4 .2];
p2 = [.2 .4 .6 .8];

syms v1 v2;

for i = 1:4;
    
    eqn_ev = v1*p1(i) + v2*p2(i) == 20;                                 % ev should be 20
    eqn_var = ((v1-20) ^2) * p1(i) + ((v2-20)^2) * p2(i) == goal(i);    % variance should match to goal
    
    [sol_v1, sol_v2] = solve(eqn_var, eqn_ev, v1, v2);
    
    if DISPLAY_SOLUTION == 1
        disp([ '--- p = ' num2str(p1(i)) ' & ' num2str(p2(i)) ]);
        disp(sol_v1);
        disp(sol_v2);
    end
    
end

%% test solution
disp('TESTING SOLUTION...');
disp([ 'goal variance = ' num2str(goal) ]); disp(' ');

X.RVH = [22.5 , (10*6^(1/2))/3+20 , (15*6^(1/2))/2+20 , 60];    % probability values high
% 22.50 28.17 38.37 60.00
X.RVL = [10 , 20-5*6^(1/2) , 20-5*6^(1/2) , 10];                % probability values low
% 10.00 7.75 7.75 10.00

for i = 1:4;
    
    disp([ '--- p = ' num2str(p1(i)) ' & ' num2str(p2(i)) ]);
    
    [var, ev] = mean_variance( p1(i), X.RVH(i), p2(i), X.RVL(i) );
    disp([ 'var = ' num2str(var) ', ev = ' num2str(ev) ]); disp(' ');
    
end