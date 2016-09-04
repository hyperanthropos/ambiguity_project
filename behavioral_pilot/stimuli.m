%%  matlab code to create stimuli for experiment
% this function creates a matrix with all relevant stimuli properties which
% can be fed into a task-presentation script

% --- stim_matrix description
% line 01 - stimulus number
% line 02 - trial type (1 = risky, 2 = ambigious)
% line 03 - resolve ambiguity (1 = yes, 2 = no)

% line 04 - risk variance level (1-4; low to high variance)
%               for risk: 25 at 80%, 33 at 60%, 50 at 40%, 100 at 20%
% line 05 - ambiguity variance level (1-4; low to high variance)
%               for ambiguity: 15 vs 25, 10 vs 30, 5 vs 35, 0 vs 40
% line 06 - counteroffer level (1-number of levels; low to high counteroffer)

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

%% function [stim_matrix, stim_nr] = stimuli()

%% SET PARAMETERS FOR STIMULI MATRIX CREATION

clear;

counteroffer.steps = 8;
% counteroffer.var(1) = [];

%               maximum counteroffer (risk vs. ambiguity)
%                   25 vs 25, 33 vs 30, 50 vs 35, 100 vs 40
%                       for variance level 1: 75% - 125%
%                       for variance level 2: 50% - 150%
%                       for variance level 3: 25% - 175%
%                       for variance level 4: 0% - 200%

repeats = 4;

risk_probs = [.8 .6 .4 .2];
risk_values = [25 33 50 100];
ambi_lo_values = [15 10 5 0];
ambi_hi_values = [25 30 35 40];

stim_nr = (length(risk_probs)+length(ambi_lo_values))*counteroffer.steps*repeats;

sessions = 2;

ISI = 8;



%% COMPARE MEAN VARIANCE APPROACH TO UTILITY FUNCTIONS

% mean variance of risky trials
for i = 1:4;
    [mvar(i), ev(i)] = mean_variance(risk_probs(i), risk_values(i));
end

% mean variance for ambiguous trials
for i = 1:4;
    [mvar(i+4), ev(i+4)] = mean_variance(.25*.8, 15);
end





%% end function code
% end