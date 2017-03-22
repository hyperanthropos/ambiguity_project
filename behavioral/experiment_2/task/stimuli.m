function [matrix, stim_nr] = stimuli( steps, diag )
% this code is used for behavioral experiment 2(!)
% matlab code to create stimuli for experiment
% this function creates a matrix with all relevant stimuli properties which
% can be fed into a task-presentation script
%
% --- stim_matrix description
% line 01 - presentation number (sequential)
%
% line 03 - stimulus number (randomized)
% line 04 - trial type (1 = risky, 2 = ambigious)
%
% line 06 - risk variance level (1 to n; low to high variance)
% line 07 - ambiguity variance level (1 to n; low to high variance)
% line 08 - counteroffer level (1 to number of levels; low to high counteroffer)
%
% line 10 - option 1 - probability of offer [ line 6 ]
% line 11 - option 1 - lower value risk [ line 6 ]
% line 12 - option 1 - upper value risk [ line 6 ]
% line 13 - option 1 - lower value ambiguity [ line 7 ]
% line 14 - option 1 - upper value ambiguity [ line 7 ]
% line 15 - option 2 - counteroffer value [ line 8 ] (variable, matched to expected value (EV))
%
% line 21 - position of counteroffer (left, right)
% line 22 - position of higher offer (up or down) (higher offer = probabilistic in risky trials)
%
% --- further notes:
%   -   different expected values (EV) are used for different trials
%   -   it is assumed that EV is still matched between risky and ambiguous
%       trials - and calculation is based on ambiguous values and repeated,
%       as risky values input might be approximated 
%   -   this function does not set up propper randomization - this has to be
%       initialized before in a wrapper / presentation script

%% SET PARAMETERS AND PREPARE MATRIX CREATION

DIAG = diag; % run diagnostics of stimuli range
X.steps = steps; % steps of counteroffer value (this must be matched to levels of risk and ambiguity)

% BASIC TRIAL CONTENT - created adjust_variance.m function in the "assisting scripts" folder

% ambiguitly levels low
X.AVL = [8     7     6     5     4     3     2     1     0    32    28    24    20    16    12     8     4     0]; % ambiguitly levels low
% ambiguitly levels high
X.AVH = [9    10    11    12    13    14    15    16    17    36    40    44    48    52    56    60    64    68]; % ambiguitly levels high
% risky probabilities for low offers
X.RPL = [0.1800    0.2600    0.3400    0.4200    0.5000    0.5800    0.6600    0.7400    0.8200    0.1800    0.2600    0.3400    0.4200    0.5000   0.5800    0.6600    0.7400    0.8200]; % probability low value
% risky probabilities for high offer
X.RPH = [0.8200    0.7400    0.6600    0.5800    0.5000    0.4200    0.3400    0.2600    0.1800    0.8200    0.7400    0.6600    0.5800    0.5000   0.4200    0.3400    0.2600    0.1800]; % probability high value
% risky value levels high
X.RVH = [8.7343    9.3891   10.2944   11.4784   13.0000   14.9633   17.5562   21.1529   26.6422   34.9370   37.5565   41.1774   45.9135   52.0000   59.8531   70.2248   84.6116  106.5687]; % probability values low
% risky value levels low
X.RVL = [7.4328    5.9694    5.0168    4.3870    4.0000    3.8197    3.8347    4.0544    4.5176   29.7313   23.8777   20.0674   17.5480   16.0000   15.2788   15.3387   16.2175   18.0703]; % probability values high

X.RN = length(X.RPH); % number of risky levels
X.AN = length(X.AVH); % number of ambiguous level
if X.RN ~= X.AN; % check if they are equal
    error('currently number of risky and ambiguous trials must be matched!');
end
stim_nr = (X.RN+X.AN)*X.steps; % number of stimuli

% expected value for trials
X.EV = (X.AVL+X.AVH)/2;

% CREATE COUNTEROFFERS RANGE

% create percentage value of highest / lowest possible counteroffer
% in realtion to expected value, so that the counteroffer is never lower
% than the low uncertain or higher than the high uncertain amount
% (assuming risk and ambiguity have the same number of variance levels)
perc_bound(1,:) = max([X.RVL;X.AVL])./X.EV; % maximum of lowest offer divided by EV
perc_bound(2,:) = min([X.RVH;X.AVH])./X.EV; % minimum of highest offer divided by EV

% set variance later used to scale counteroffers
for i = 1:X.AN;
    X.var{i} = perc_bound(:,i);
end

%% DIAGNOSTIC: COMPARE MEAN VARIANCE APPROACH TO UTILITY FUNCTIONS

if DIAG == 1;
    % --- --- --- SKIP THIS DIAGNOSTIC SECTION --- --- --- %
    
    % set risk parameters for
    K.mvar = -1/60;        % mean variance (<0 is risk averse)
    K.hyp = 1.6;            % hyperbolic discounting (>1 is risk averse)
    K.pros = 0.92;          % prospect theory (<1 is risk averse)
    scale = [00 40];        % axis scale
    
    % SUBJECTIVE VALUE ACCORDING TO MEAN VARIANCE
    % mean variance of risky trials
    mvar = NaN(2,X.RN);
    for i = 1:X.RN;
        [mvar(1, i)] = mean_variance(X.RPH(i), X.RVH(i), X.RPL(i), X.RVL(i));
    end
    % mean variance for ambiguous trials
    for i = 1:X.AN;
        [mvar(2, i)] = mean_variance( .5, X.AVL(i), .5, X.AVH(i) );
    end
    % subjective value according to k parameter
    SV.mvar = ones(2,X.AN).*repmat(X.EV, 2, 1) + mvar * K.mvar;
    
    % SUBJECTIVE VALUE ACCORDING TO HYPERBOLIC DISCOUNTING
    odds_high = (1-X.RPH)./X.RPH;                                               % transform p to odds for high value prob
    odds_low = (1-X.RPL)./X.RPL;                                                % transform p to odds for low value prob
    SV.hyp(1,:) = X.RVH./(1+K.hyp.*odds_high) + X.RVL./(1+K.hyp.*odds_low);     % subjective value of risky offers
    odds = ones(1,X.AN);                                                        % odds are equal for ambiguous offers
    SV.hyp(2,:) = X.AVL./(1+K.hyp.*odds) + X.AVH./(1+K.hyp.*odds);              % subjective value of ambiguous offers
    
    % SUBJECTIVE VALUE ACCORDING TO PROSPECT THEORY DISCOUNTING
    SV.pros(1,:) = X.RPH.*X.RVH.^K.pros + X.RPL.*X.RVL.^K.pros;                 % subjective value of risky offers
    SV.pros(2,:) = .5.*X.AVL.^K.pros + .5.*X.AVH.^K.pros;                       % subjective value of ambiguous offers
    
    % PLOT AND COMPARE SV
    % figure setup
    scalemax = X.AN+.5;
    xname = ['variance | EVs: ' num2str(X.EV(1)) ' to ' num2str(X.EV(end))];
    % draw figure
    figs.fig1 = figure('Color', [1 1 1]);
    set(figs.fig1,'units','normalized','outerposition',[0 0 1 1]);
    subplot(3,2,1);
    plot(SV.mvar(1,:), 'k-', 'linewidth', 2); box('off'); hold on;
    plot(SV.hyp(1,:), 'r-', 'linewidth', 2);
    plot(SV.pros(1,:), 'b-', 'linewidth', 2);
    axis([.5 scalemax scale]); xlabel(xname); ylabel('subjective value');
    legend('mvar - risk', 'hyp - risk', 'pros - risk', 'location', 'northwest');
    subplot(3,2,2);
    plot(SV.mvar(2,:), 'k--', 'linewidth', 2); box('off'); hold on;
    plot(SV.hyp(2,:), 'r--', 'linewidth', 2);
    plot(SV.pros(2,:), 'b--', 'linewidth', 2);
    axis([.5 scalemax scale]); xlabel(xname); ylabel('subjective value');
    legend('mvar - ambi', 'hyp - ambi', 'pros - ambi', 'location', 'northwest');
    subplot(3,3,4);
    plot(SV.mvar(1,:), 'k-', 'linewidth', 2); box('off'); box('off'); hold on;
    plot(SV.mvar(2,:), 'k--', 'linewidth', 2); box('off');
    axis([.5 scalemax scale]); xlabel(xname); ylabel('subjective value');
    legend('risk', 'ambiguity', 'location', 'northwest');
    subplot(3,3,5);
    plot(SV.hyp(1,:), 'r-', 'linewidth', 2); box('off'); box('off'); hold on;
    plot(SV.hyp(2,:), 'r--', 'linewidth', 2); box('off');
    axis([.5 scalemax scale]); xlabel(xname); ylabel('subjective value');
    legend('risk', 'ambiguity', 'location', 'northwest');
    axis([.5 scalemax scale]);
    subplot(3,3,6);
    plot(SV.pros(1,:), 'b-', 'linewidth', 2); box('off'); box('off'); hold on;
    plot(SV.pros(2,:), 'b--', 'linewidth', 2); box('off');
    axis([.5 scalemax scale]); title('prospect theory'); xlabel(xname); ylabel('subjective value');
    legend('risk', 'ambiguity', 'location', 'northwest');
   
    % COMPARE: EXPECTED VALUE, VARIANCE, ABSOLUTE VALUE, DIFFERENCE VALUE, EV DIFFERENCE
    % expected value
    subplot(3,5,11);
    COMP.ev = ones(2,X.AN)*20;
    bar(COMP.ev');
    title('expected value'); xlabel('variance');
    % variance
    subplot(3,5,12);
    COMP.var = mvar;
    bar(COMP.var');
    title('variance'); xlabel('variance');
    % absolute value
    subplot(3,5,13);
    COMP.av(1,:) = X.RVH + X.RVL;
    COMP.av(2,:) = X.AVH + X.AVL;
    bar(COMP.av');
    title('abs. value'); xlabel('variance');
    % difference value
    subplot(3,5,14);
    COMP.dv(1,:) = X.RVH - X.RVL;
    COMP.dv(2,:) = X.AVH - X.AVL;
    bar(COMP.dv');
    title('diff. value'); xlabel('variance');
    % exp. val difference
    subplot(3,5,15);
    COMP.dv(1,:) = X.RVH.*X.RPH - X.RVL.*X.RPL;
    COMP.dv(2,:) = X.AVH*.5 - X.AVL*.5;
    bar(COMP.dv');
    title('exp. val. diff'); xlabel('variance');
    
    % --- --- --- END SKIP THIS SECTION --- --- --- %
end

%% CREATE SORTED MATRIX

trials_risky = 1:X.RN*X.steps;
trials_ambiguous = X.RN*X.steps+1:X.RN*X.steps+X.AN*X.steps;

r_matrix(3,:) = 1:X.RN*X.steps+X.AN*X.steps;                              % line 03 - stimulus number (randomized)
r_matrix(4,trials_risky) = ones(1, X.RN*X.steps);                         % line 04 - trial type (1 = risky, 2 = ambigious)
r_matrix(4,trials_ambiguous) = ones(1, X.AN*X.steps)*2;                   % line 04 - trial type (1 = risky, 2 = ambigious)

r_matrix(6,trials_risky) = kron(1:X.RN, ones(1,X.steps));                 % line 06 - risk variance level (1-4; low to high variance)
r_matrix(6,trials_ambiguous) = NaN(1,X.AN*X.steps);                       % line 06 - risk variance level (1-4; low to high variance)
r_matrix(7,trials_risky) = NaN(1,X.RN*X.steps);                           % line 07 - ambiguity variance level (1-4; low to high variance)
r_matrix(7,trials_ambiguous) = kron(1:X.AN, ones(1,X.steps));             % line 07 - ambiguity variance level (1-4; low to high variance)
r_matrix(8,:) = repmat(1:X.steps, 1, X.AN+X.RN);                          % line 08 - counteroffer level (1-number of levels; low to high counteroffer)

r_matrix(10,trials_risky) = kron(X.RPH, ones(1,X.steps));                 % line 10 - option 1 - probability of offer [ line 6 ]
r_matrix(10,trials_ambiguous) = NaN(1,X.AN*X.steps);                      % line 10 - option 1 - probability of offer [ line 6 ]
r_matrix(11,trials_risky) = kron(X.RVL, ones(1,X.steps));                 % line 11 - option 1 - lower value risk [ line 6 ]
r_matrix(11,trials_ambiguous) = NaN(1,X.AN*X.steps);                      % line 11 - option 1 - lower value risk [ line 6 ]
r_matrix(12,trials_risky) = kron(X.RVH, ones(1,X.steps));                 % line 12 - option 1 - upper value risk [ line 6 ]
r_matrix(12,trials_ambiguous) = NaN(1,X.AN*X.steps);                      % line 12 - option 1 - upper value risk [ line 6 ]
r_matrix(13,trials_risky) = NaN(1,X.RN*X.steps);                          % line 13 - option 1 - lower value ambiguity [ line 7 ]
r_matrix(13,trials_ambiguous) =  kron(X.AVL, ones(1,X.steps));            % line 13 - option 1 - lower value ambiguity [ line 7 ]
r_matrix(14,trials_risky) = NaN(1,X.RN*X.steps);                          % line 14 - option 1 - upper value ambiguity [ line 7 ]
r_matrix(14,trials_ambiguous) =  kron(X.AVH, ones(1,X.steps));            % line 14 - option 1 - upper value ambiguity [ line 7 ]

% create counteroffers (stepswise variation around EV)
counteroffers = [];
for i = 1:X.AN;
    counteroffers = cat(2, counteroffers, linspace(X.var{i}(1), X.var{i}(2), X.steps)*X.EV(i));
end
counteroffers = repmat(counteroffers, 1, 2); % duplicate for risky trials

r_matrix(15,:) = counteroffers;                                           % line 15 - option 2 - counteroffer value [ line 8 ] (variable, matched to 20 expected value (EV)

r_matrix(21,:) = randi(2, 1, stim_nr);                                    % line 21 - position of counteroffer (left, right)
r_matrix(22,:) = randi(2, 1, stim_nr);                                    % line 22 - position of higher offer (up or down) (higher offer = probabilistic in risky trials)

%% DIAGNOSTIC: PLOT STIMULUS MATRIX

if DIAG == 1;
    % --- --- --- SKIP THIS DIAGNOSTIC SECTION --- --- --- %
    
    % plot trials and funtcions
    figs.fig2 = figure('Color', [1 1 1]);
    set(figs.fig2,'units','normalized','outerposition',[0 0 1 1]);
    
    subplot(2,2,1);
    % plot counteroffers
    scatter(r_matrix(6,trials_risky), r_matrix(15, trials_risky)./kron(X.EV, ones(1,X.steps))); box off; hold on;
    % plot predictions by utility theories
    plot(SV.mvar(1,:)./X.EV, 'k-', 'linewidth', 2);
    plot(SV.hyp(1,:)./X.EV, 'r-', 'linewidth', 2);
    plot(SV.pros(1,:)./X.EV, 'b-', 'linewidth', 2);
    legend('single trial', 'mvar', 'hyp', 'pros', 'location', 'northwest');
    % plot ranges of max offered values within gambles
    plot(X.RVH./X.EV, 'k--', 'linewidth', 1);
    plot(X.RVL./X.EV, 'k--', 'linewidth', 1);
    xlabel(xname); ylabel('expected value ratio'); title('risky trials');
    axis([.5 scalemax -.1 2.5]); 
    
    subplot(2,2,2);
    % plot counteroffers
    scatter(r_matrix(7,trials_ambiguous), r_matrix(15,trials_ambiguous)./kron(X.EV, ones(1,X.steps))); box off; hold on;
    % plot predictions by utility theories
    plot(SV.mvar(2,:)./X.EV, 'k--', 'linewidth', 2);
    plot(SV.hyp(2,:)./X.EV, 'r--', 'linewidth', 2);
    plot(SV.pros(2,:)./X.EV, 'b--', 'linewidth', 2);
    legend('single trial', 'mvar', 'hyp', 'pros', 'location', 'northwest');
    % plot ranges of max offered values within gambles
    plot(X.AVH./X.EV, 'k--', 'linewidth', 1);
    plot(X.AVL./X.EV, 'k--', 'linewidth', 1);
    xlabel(xname); ylabel('expected value ratio'); title('ambiguous trials');
    axis([.5 scalemax -.1 2.5]);

    % plot the same plots without normalisation to see EV differences
    subplot(2,2,3);
    scatter(r_matrix(6,trials_risky), r_matrix(15, trials_risky)); box off; hold on;
    plot(SV.mvar(1,:), 'k-', 'linewidth', 2);
    plot(SV.hyp(1,:), 'r-', 'linewidth', 2);
    plot(SV.pros(1,:), 'b-', 'linewidth', 2);
    legend('single trial', 'mvar', 'hyp', 'pros', 'location', 'northwest');
    plot(X.RVH, 'k--', 'linewidth', 1);
    plot(X.RVL, 'k--', 'linewidth', 1);
    xlabel(xname); ylabel('counteroffer value'); title('risky trials');
    axis([.5 scalemax -5 80]);
    subplot(2,2,4);
    scatter(r_matrix(7,trials_ambiguous), r_matrix(15,trials_ambiguous)); box off; hold on;
    plot(SV.mvar(2,:), 'k--', 'linewidth', 2);
    plot(SV.hyp(2,:), 'r--', 'linewidth', 2);
    plot(SV.pros(2,:), 'b--', 'linewidth', 2);
    legend('single trial', 'mvar', 'hyp', 'pros', 'location', 'northwest');
    plot(X.AVH, 'k--', 'linewidth', 1);
    plot(X.AVL, 'k--', 'linewidth', 1);
    xlabel(xname); ylabel('counteroffer value'); title('ambiguous trials');
    axis([.5 scalemax -5 80]);

    % --- --- --- END SKIP THIS SECTION --- --- --- %
end

%% RANDOMIZE AND COMPLETE MATRIX 

% randomize matrix
matrix = r_matrix(:,randperm(stim_nr));    

% complete matrix
matrix(1,:) = 1:stim_nr;                                                   % line 01 - presentation number (sequential)

% fill unused lines with NaN for security
matrix(2,:) = NaN(1,stim_nr);
matrix(5,:) = NaN(1,stim_nr);
matrix(9,:) = NaN(1,stim_nr);
matrix(16:20,:) = NaN(5,stim_nr);

% derandomize
% sorted_matrix = sortrows(matrix', 3)';

%% end function code
end