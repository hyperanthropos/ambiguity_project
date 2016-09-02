%%  matlab code to create stimuli for experiment
% this function creates a matrix with all relevant stimuli properties which
% can be fed into a task-presentation script

% --- stim_matrix description
% line 1 - stimulus number
% line 2 - trial type (1 = risky, 2 = ambigious)
% line 3 - resolve ambiguity (1 = yes, 2 = no)

% line 4 - variance level (1-4; low to high variance)
%               for risk: 25 at 80%, 33 at 60%, 50 at 40%, 100 at 20%
%               for ambiguity: 15 vs 25, 10 vs 30, 5 vs 35, 0 vs 40


%%% OLD STYLE (being updated)
% line1 - probability option 1
% line2 - amount option 1
% line3 - probability option 2
% line4 - amount option 2
% line5 - ISI
% line6 - position of fixed ammount
% line7 - stimulus number
% line8 - regressor probability (line 1)
% line9 - regressor probabilistic amount (line 2)
% line10 - regressor matched amount variaton (line 4)

% further notes:
% - expected value of all trials is fixed to 20 value units
% - this funtion does not set up propper randomization - this has to be 
% initialized before in a wrapper / presentation script

%% start function code

function [stim_matrix, stim_nr] = stimuli()

%% SET PARAMETERS FOR STIMULI MATRIX CREATION

stim_nr = 100;      % number of trials to generate






%% 







% end function code
end