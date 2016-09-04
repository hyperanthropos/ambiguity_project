%%  matlab code to create stimuli for experiment
% this function creates a matrix with all relevant stimuli properties which
% can be fed into a task-presentation script

% --- stim_matrix description
% line 01 - presentation number (sequential)
% line 02 - repeat number (randomized)
% line 03 - stimulus number (randomized)
% line 04 - trial type (1 = risky, 2 = ambigious)
% line 05 - resolve ambiguity (1 = yes, 2 = no)

% line 06 - risk variance level (1-4; low to high variance)
%               for risk: 25 at 80%, 33 at 60%, 50 at 40%, 100 at 20%
% line 07 - ambiguity variance level (1-4; low to high variance)
%               for ambiguity: 15 vs 25, 10 vs 30, 5 vs 35, 0 vs 40
% line 08 - counteroffer level (1-number of levels; low to high counteroffer)

% line 10 - option 1 - probability of offer [ line 4 ] (80%, 60%, 40%, 20%)
% line 11 - option 1 - lower value risk [ line 4 ] (always 0 for risk) 
% line 12 - option 1 - upper value risk [ line 4 ] (25, 33, 50, 100 for risk)
% line 13 - option 1 - lower value ambiguity [ line 5 ] (15, 10, 5, 0 for ambigutiy) 
% line 14 - option 1 - upper value ambiguity [ line 5 ] (25, 30, 35, 40 for ambiguity)
% line 15 - option 2 - counteroffer value (variable, matched to 20 expected value (EV)

%%%%% randomisation and timing
% line 20 - ISI (time until next decision)
% line 21 - position of counteroffer (left, right)
% line 22 - position of lower level (up or down)

% further notes:
% - expected value (EV) of all trials is fixed to 20 value units
% - this funtion does not set up propper randomization - this has to be 
% initialized before in a wrapper / presentation script

%% start function code

%% function [matrix, stim_nr] = stimuli()

%% SET PARAMETERS FOR STIMULI MATRIX CREATION

clear;

sessions = 2;
repeats = 4;
ISI = 8;

X.steps = 8;        % steps of counteroffer value (this must be matched to levels of risk and ambiguity)
% counteroffer.var(1) = [];

%               maximum counteroffer (risk vs. ambiguity)
%                   25 vs 25, 33 vs 30, 50 vs 35, 100 vs 40
%                       for variance level 1: 75% - 125%
%                       for variance level 2: 50% - 150%
%                       for variance level 3: 25% - 175%
%                       for variance level 4: 0% - 200%

X.RP = [.8 .6 .4 .2]; % risky probability levels
X.RV = [25 33 50 100]; % risky value levels
X.RN = 4; % number of risky levels
X.AVL = [15 10 5 0]; % ambiguitly levels low
X.AVH = [25 30 35 40]; % ambiguitly levels high
X.AN = 4; % number of ambiguous levels

stim_nr = (length(X.RP)+length(X.AVL))*X.steps*repeats;



%% COMPARE MEAN VARIANCE APPROACH TO UTILITY FUNCTIONS

% mean variance of risky trials
mvar = NaN(2,4);
for i = 1:4;
    [mvar(1, i)] = mean_variance(X.RP(i), X.RV(i));
end

% mean variance for ambiguous trials
for i = 1:4;
    [mvar(2, i)] = mean_variance(   .25*X.RP(1), X.AVL(i), .25*(1-X.RP(1)), X.AVH(i), ...
                                    .25*X.RP(2), X.AVL(i), .25*(1-X.RP(2)), X.AVH(i), ...
                                    .25*X.RP(3), X.AVL(i), .25*(1-X.RP(3)), X.AVH(i), ...
                                    .25*X.RP(4), X.AVL(i), .25*(1-X.RP(4)), X.AVH(i)           );
end

bar(mvar')
legend('risk', 'ambiguity', 'location', 'northwest');

%% CREATE MATRIX

% create one repeat
trials_risky = 1:X.RN*X.steps;
trials_ambigous = X.RN*X.steps+1:X.RN*X.steps+X.AN*X.steps;

matrix(3,:) =  1:X.RN*X.steps+X.AN*X.steps;                             % line 03 - stimulus number (randomized)
matrix(4,trials_risky) = ones(1, X.RN*X.steps);                         % line 04 - trial type (1 = risky, 2 = ambigious)
matrix(4,trials_ambigous) = ones(1, X.AN*X.steps)*2;                    % line 04 - trial type (1 = risky, 2 = ambigious)

matrix(6,trials_risky) = kron(1:X.RN, ones(1,X.steps));                 % line 06 - risk variance level (1-4; low to high variance)
matrix(6,trials_ambigous) = repmat(1:X.RN, 1, X.steps);                 % line 06 - risk variance level (1-4; low to high variance)
matrix(7,trials_risky) = repmat(1:X.AN, 1, X.steps);                    % line 07 - ambiguity variance level (1-4; low to high variance)
matrix(7,trials_ambigous) = kron(1:X.AN, ones(1,X.steps));              % line 07 - ambiguity variance level (1-4; low to high variance)                                                             
matrix(8,:) = repmat(1:X.steps, 1, X.AN+X.RN);                          % line 08 - counteroffer level (1-number of levels; low to high counteroffer)

% matrix(10,:) = [];        % line 10 - option 1 - probability of offer [ line 4 ] (80%, 60%, 40%, 20%)

% lines to do after repeated
% 1 2 5



%% end function code
% end