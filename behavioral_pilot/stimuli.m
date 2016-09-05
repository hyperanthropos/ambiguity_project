%function [matrix, stim_nr] = stimuli( reveal_ambiguity )
clear; close all; clc;
% matlab code to create stimuli for experiment
% this function creates a matrix with all relevant stimuli properties which
% can be fed into a task-presentation script pu
%
% --- stim_matrix description
% line 01 - presentation number (sequential)
% line 02 - repeat number
% line 03 - stimulus number (randomized)
% line 04 - trial type (1 = risky, 2 = ambigious)
% line 05 - resolve ambiguity (1 = yes, 2 = no)
%
% line 06 - risk variance level (1-4; low to high variance)
%               for risk: 25 at 80%, 33 at 60%, 50 at 40%, 100 at 20%
% line 07 - ambiguity variance level (1-4; low to high variance)
%               for ambiguity: 15 vs 25, 10 vs 30, 5 vs 35, 0 vs 40
% line 08 - counteroffer level (1-number of levels; low to high counteroffer)
%
% line 10 - option 1 - probability of offer [ line 6 ] (80%, 60%, 40%, 20%)
% line 11 - option 1 - lower value risk [ line 6 ] (always 0 for risk)
% line 12 - option 1 - upper value risk [ line 6 ] (25, 33, 50, 100 for risk)
% line 13 - option 1 - lower value ambiguity [ line 7 ] (15, 10, 5, 0 for ambigutiy)
% line 14 - option 1 - upper value ambiguity [ line 7 ] (25, 30, 35, 40 for ambiguity)
% line 15 - option 2 - counteroffer value [ line 8 ] (variable, matched to 20 expected value (EV)
%
% line 20 - ISI (time until next decision)
% line 21 - position of counteroffer (left, right)
% line 22 - position of lower level (up or down)
%
% --- further notes:
% - expected value (EV) of all trials is fixed to 20 value units
% - this funtion does not set up propper randomization - this has to be
% initialized before in a wrapper / presentation script

%% SET PARAMETERS FOR STIMULI MATRIX CREATION

SKIP_DIAG = 0; % skip diagnostics of stimuli range


repeats = 3;
isi = 1;

X.steps = 8;            % steps of counteroffer value (this must be matched to levels of risk and ambiguity)
                        % maximum counteroffer (risk vs. ambiguity): 25 vs 25, 33 vs 30, 50 vs 35, 100 vs 40
X.var{1} = [0.75 1.25];     % for variance level 1: 75% - 125%
X.var{2} = [0.50 1.50];     % for variance level 2: 50% - 150%
X.var{3} = [0.25 1.75];     % for variance level 3: 25% - 175%
X.var{4} = [0.00 2.00];     % for variance level 4: 0% - 200% 

X.RP = [.8 .6 .4 .2]; % risky probability levels
X.RV = [25 100/3 50 100]; % risky value levels
X.RN = 4; % number of risky levels
X.AVL = [15 10 5 0]; % ambiguitly levels low
X.AVH = [25 30 35 40]; % ambiguitly levels high
X.AN = 4; % number of ambiguous levels

stim_nr = (length(X.RP)+length(X.AVL))*X.steps*repeats;

%% DIAGNOSTIC: COMPARE MEAN VARIANCE APPROACH TO UTILITY FUNCTIONS

if SKIP_DIAG ~= 1;
    % --- --- --- SKIP THIS DIAGNOSTIC SECTION --- --- --- %
    
    % set risk parameters for
    K.mvar = -1/180;        % mean variance (<0 is risk averse)
    K.hyp = 1.5;            % hyperbolic discounting (>1 is risk averse)
    K.pros = 0.95;          % prospect theory (<1 is risk averse)
    scale = [12 20];        % axis scale
    
    % SUBJECTIVE VALUE ACCORDING TO MEAN VARIANCE
    % mean variance of risky trials
    mvar = NaN(2,4);
    for i = 1:4;
        [mvar(1, i)] = mean_variance(X.RP(i), X.RV(i));
    end
    % mean variance for ambiguous trials
    for i = 1:4;
        [mvar(2, i)] = mean_variance( .5, X.AVL(i), .5, X.AVH(i) );
    end
    % subjective value according to k parameter
    sv.mvar = ones(2,4)*20 + mvar * K.mvar;
    
    % SUBJECTIVE VALUE ACCORDING TO HYPERBOLIC DISCOUNTING
    odds = (1-X.RP)./X.RP;                                          % transform p to odds
    sv.hyp(1,:) = X.RV./(1+K.hyp.*odds);                            % subjective value of risky offers
    odds = [1 1 1 1];                                               % odds are equal for ambiguous offers
    sv.hyp(2,:) = X.AVL./(1+K.hyp.*odds) + X.AVH./(1+K.hyp.*odds);  % subjective value of ambiguous offers
    
    % SUBJECTIVE VALUE ACCORDING TO PROSPECT THEORY DISCOUNTING
    sv.pros(1,:) = X.RP.*X.RV.^K.pros;
    sv.pros(2,:) = .5.*X.AVL.^K.pros + .5.*X.AVH.^K.pros;
    
    % PLOT AND COMPARE SV
    figs.fig1 = figure('Color', [1 1 1]);
    set(figs.fig1,'units','normalized','outerposition',[0 .6 .5 .6]);
    subplot(2,2,1);
    plot(sv.mvar(1,:), 'k-', 'linewidth', 2); box('off'); hold on;
    plot(sv.hyp(1,:), 'r-', 'linewidth', 2);
    plot(sv.pros(1,:), 'b-', 'linewidth', 2);
    axis([.5 4.5 scale]); xlabel('variance'); ylabel('expected value');
    legend('mvar - risk', 'hyp - risk', 'pros - risk', 'location', 'southwest');
    subplot(2,2,2);
    plot(sv.mvar(2,:), 'k--', 'linewidth', 2); box('off'); hold on;
    plot(sv.hyp(2,:), 'r--', 'linewidth', 2);
    plot(sv.pros(2,:), 'b--', 'linewidth', 2);
    axis([.5 4.5 scale]); xlabel('variance'); ylabel('expected value');
    legend('mvar - ambi', 'hyp - ambi', 'pros - ambi', 'location', 'southwest');
    subplot(2,3,4);
    plot(sv.mvar(1,:), 'k-', 'linewidth', 2); box('off'); box('off'); hold on;
    plot(sv.mvar(2,:), 'k--', 'linewidth', 2); box('off');
    axis([.5 4.5 scale]); title('mean variance'); xlabel('variance'); ylabel('expected value');
    legend('risk', 'ambiguity', 'location', 'southwest');
    subplot(2,3,5);
    plot(sv.hyp(1,:), 'r-', 'linewidth', 2); box('off'); box('off'); hold on;
    plot(sv.hyp(2,:), 'r--', 'linewidth', 2); box('off');
    axis([.5 4.5 scale]); title('hyperbolic'); xlabel('variance'); ylabel('expected value');
    legend('risk', 'ambiguity', 'location', 'southwest');
    axis([.5 4.5 scale]);
    subplot(2,3,6);
    plot(sv.pros(1,:), 'b-', 'linewidth', 2); box('off'); box('off'); hold on;
    plot(sv.pros(2,:), 'b--', 'linewidth', 2); box('off');
    axis([.5 4.5 scale]); title('prospect theory'); xlabel('variance'); ylabel('expected value');
    legend('risk', 'ambiguity', 'location', 'southwest');
    
    % --- --- --- END SKIP THIS SECTION --- --- --- %
end

%% CREATE MATRIX TO REPEAT

% create one repeat
trials_risky = 1:X.RN*X.steps;
trials_ambigous = X.RN*X.steps+1:X.RN*X.steps+X.AN*X.steps;

r_matrix(3,:) =  1:X.RN*X.steps+X.AN*X.steps;                             % line 03 - stimulus number (randomized)
r_matrix(4,trials_risky) = ones(1, X.RN*X.steps);                         % line 04 - trial type (1 = risky, 2 = ambigious)
r_matrix(4,trials_ambigous) = ones(1, X.AN*X.steps)*2;                    % line 04 - trial type (1 = risky, 2 = ambigious)

r_matrix(6,trials_risky) = kron(1:X.RN, ones(1,X.steps));                 % line 06 - risk variance level (1-4; low to high variance)
r_matrix(6,trials_ambigous) = repmat(1:X.RN, 1, X.steps);                 % line 06 - risk variance level (1-4; low to high variance)
r_matrix(7,trials_risky) = repmat(1:X.AN, 1, X.steps);                    % line 07 - ambiguity variance level (1-4; low to high variance)
r_matrix(7,trials_ambigous) = kron(1:X.AN, ones(1,X.steps));              % line 07 - ambiguity variance level (1-4; low to high variance)
r_matrix(8,:) = repmat(1:X.steps, 1, X.AN+X.RN);                          % line 08 - counteroffer level (1-number of levels; low to high counteroffer)

r_matrix(10,trials_risky) = kron(X.RP, ones(1,X.steps));                  % line 10 - option 1 - probability of offer [ line 6 ] (80%, 60%, 40%, 20%)
r_matrix(10,trials_ambigous) = repmat(X.RP, 1, X.steps);                  % line 10 - option 1 - probability of offer [ line 6 ] (80%, 60%, 40%, 20%)
r_matrix(11,:) = zeros(1, X.RN*X.steps+X.AN*X.steps);                     % line 11 - option 1 - lower value risk [ line 6 ] (always 0 for risk)
r_matrix(12,trials_risky) = kron(X.RV, ones(1,X.steps));                  % line 12 - option 1 - upper value risk [ line 6 ] (25, 33, 50, 100 for risk)
r_matrix(12,trials_ambigous) = repmat(X.RV, 1, X.steps);                  % line 12 - option 1 - upper value risk [ line 6 ] (25, 33, 50, 100 for risk)
r_matrix(13,trials_risky) = repmat(X.AVL, 1, X.steps);                    % line 13 - option 1 - lower value ambiguity [ line 7 ] (15, 10, 5, 0 for ambigutiy)
r_matrix(13,trials_ambigous) =  kron(X.AVL, ones(1,X.steps));             % line 13 - option 1 - lower value ambiguity [ line 7 ] (15, 10, 5, 0 for ambigutiy)
r_matrix(14,trials_risky) = repmat(X.AVH, 1, X.steps);                    % line 14 - option 1 - upper value ambiguity [ line 7 ] (25, 30, 35, 40 for ambiguity)
r_matrix(14,trials_ambigous) =  kron(X.AVH, ones(1,X.steps));             % line 14 - option 1 - upper value ambiguity [ line 7 ] (25, 30, 35, 40 for ambiguity)

% create counteroffers
counteroffers = [];
for i = 1:X.RN;
counteroffers = cat(2, counteroffers, linspace(X.var{i}(1), X.var{i}(2), X.steps));
end
for i = 1:X.AN;
counteroffers = cat(2, counteroffers, linspace(X.var{i}(1), X.var{i}(2), X.steps));
end

r_matrix(15,:) = counteroffers;                                           % line 15 - option 2 - counteroffer value [ line 8 ] (variable, matched to 20 expected value (EV)

%% DIAGNOSTIC: PLOT STIMULUS MATRIX



%% RANDOMIZE AND REPEAT MATRIX 



if reveal_ambiguity == 1;
    % code
end


% lines to do after repeated
% 1 2 5

keyboard;

%% end function code
%end