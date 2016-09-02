%%  matlab code to create stimuli for experiment
% this function creates a matrix with all relevant stimuli properties which
% can be fed into a task-presentation script

% --- stim_matrix description
% line 1 - stimulus number
% line 2 - trial type (1 = risky, 2 = ambigious)
% line 3 - resolve ambiguity (1 = yes, 2 = no)

% line 4 - risk variance level (1-4; low to high variance)
%               for risk: 25 at 80%, 33 at 60%, 50 at 40%, 100 at 20%
% line 5 - ambiguity variance level (1-4; low to high variance)
%               for ambiguity: 15 vs 25, 10 vs 30, 5 vs 35, 0 vs 40
% line 6 - counteroffer level (1-number of levels; low to high counteroffer)
%               maximum counteroffer (risk vs. ambiguity)
%                   25 vs 25, 33 vs 30, 50 vs 35, 100 vs 40
%                       for variance level 1: 75% - 125%
%                       for variance level 2: 50% - 150%
%                       for variance level 3: 25% - 175%
%                       for variance level 4: 0% - 200%

% we need a function to calculate the variance for each trial !!!
%       e.g.: 60% 50 & 40% 0 vs. 25% 80% 15 and 20% 25; 25% 60% 15 and 40% 20 ...

% line 6 - option 1 - probability of offer [ line 4 ] (20%, 40%, 60%, 80%)
% line 7 - option 1 - lower value [ line 4 ] (0 for risk; 15, 10, 5, 0 for ambigutiy) 
% line 8 - option 2 - counteroffer value (variable, matched to 20 expected value (EV)



%%% OLD STYLE (being updated)
% line1 - probability option 1
% line2 - amount option 1
% line3 - probability option 2
% line4 - amount option 2
% line5 - ISI
% line6 - position of fixed ammount
% line8 - regressor probability (line 1)
% line9 - regressor probabilistic amount (line 2)
% line10 - regressor matched amount variaton (line 4)

% further notes:
% - expected value (EV) of all trials is fixed to 20 value units
% - this funtion does not set up propper randomization - this has to be 
% initialized before in a wrapper / presentation script

%% start function code

function [stim_matrix, stim_nr] = stimuli()

%% SET PARAMETERS FOR STIMULI MATRIX CREATION

stim_nr = 100;      % number of trials to generate






%% 







% end function code
end