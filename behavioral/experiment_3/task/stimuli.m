function [matrix, stim_nr] = stimuli( diag )
% this code is used for behavioral experiment 3(!)
% matlab code to create stimuli for experiment
% this function creates a matrix with all relevant stimuli properties which
% can be fed into a task-presentation script
%
% --- stim_matrix description
% line 01 - presentation number (sequential)
%
% line 03 - stimulus number (randomized)
%
% line 05 - EV levels (low to high expected value)
% line 06 - risk variance level (1 to n; low to high variance)
% line 07 - ambiguity variance level (1 to n; low to high variance)
%
% line 10 - probability of higher offer [ line 6 ]
% line 11 - lower value risk [ line 6 ]
% line 12 - upper value risk [ line 6 ]
% line 13 - lower value ambiguity [ line 7 ]
% line 14 - upper value ambiguity [ line 7 ]
%
% line 17 - EV of probabilistic offers [ line 5 ]
%
% line 21 - position of risky (non ambiguous) offer (1 = left; 2 = right)
% line 22 - position of higher offer (up or down) (higher offer = probabilistic in risky trials)
%
% --- further notes:
%   -   risk and ambiguity are directly compared without counteroffers
%   -   this function does not set up propper randomization - this has to be
%       initialized before in a wrapper / presentation script

%% SET PARAMETERS AND PREPARE MATRIX CREATION

DIAG = diag; % run diagnostics of stimuli range

% BASIC TRIAL CONTENT - created with adjust_variance.m function in the "assisting scripts" folder

% sacling factors for expected value levels
X.ev_factors = [1 2 3 4 5 6];

% ambiguitly levels low
X.AVL = linspace(7, 0, 15); % ambiguitly levels low
% ambiguitly levels high
X.AVH = linspace(7.5, 14.5, 15); % ambiguitly levels high
% risky probabilities for low offers
X.RPL = linspace(.15, .85, 15); % probability low value
% risky probabilities for high offer
X.RPH = linspace(.85, .15, 15); % probability high value
% risky value levels high
X.RVH = [7.3550    7.6250    7.9717    8.3956    8.9010    9.4954   10.1897   11.0000   11.9486   13.0675   14.4045   16.0333   18.0753   20.7500   24.5085]; % probability values low
% risky value levels low
X.RVL = [6.6549    5.7500    5.0849    4.5768    4.1838    3.8820    3.6570    3.5000    3.4057    3.3716    3.3976    3.4857    3.6416    3.8750   4.2044]; % probability values high

% define numbers for calculations
X.EN = length(X.ev_factors); % number of ev levels
X.RN = length(X.RPH); % number of risky levels
X.AN = length(X.AVH); % number of ambiguous level
if X.RN ~= X.AN; % check if they are equal
    error('number of risky and ambiguous trials must be matched for direct comparisons!');
end
X.MN = (X.AN+X.RN)/2; % number of risky/ambiguous matches
stim_nr = X.MN*X.EN; % number of stimuli

%% CREATE SORTED MATRIX

r_matrix(3,1:stim_nr) = 1:stim_nr;                                      % line 03 - stimulus number (randomized)

r_matrix(5,1:stim_nr) = kron(1:X.EN, ones(1,X.MN));                     % line 05 - EV levels (low to high expected value)
r_matrix(6,1:stim_nr) = repmat(1:X.RN, 1, X.EN);                        % line 06 - risk variance level (low to high variance)
r_matrix(7,1:stim_nr) = repmat(1:X.AN, 1, X.EN);                        % line 07 - ambiguity variance level (low to high variance)

r_matrix(10,1:stim_nr) = repmat(X.RPH, 1, X.EN);                        % line 10 - probability of higher offer [ line 6 ]
r_matrix(11,1:stim_nr) = kron(X.ev_factors, X.RVL);                     % line 11 - lower value risk [ line 6 ]
r_matrix(12,1:stim_nr) = kron(X.ev_factors, X.RVH);                     % line 12 - upper value risk [ line 6 ]
r_matrix(13,1:stim_nr) = kron(X.ev_factors, X.AVL);                     % line 13 - lower value ambiguity [ line 7 ]
r_matrix(14,1:stim_nr) = kron(X.ev_factors, X.AVH);                     % line 14 - upper value ambiguity [ line 7 ]

r_matrix(17,1:stim_nr) = (r_matrix(13,:)+r_matrix(14,:))/2;             % line 17 - EV of probabilistic offers [ line 5 ]

r_matrix(21,:) = randi(2, 1, stim_nr);                                  % line 21 - position of risky offer (1 = left; 2 = right)
r_matrix(22,:) = randi(2, 1, stim_nr);                                  % line 22 - position of higher offer (up or down) (higher offer = probabilistic in risky trials)

%% DIAGNOSTIC: COMPARE MEAN VARIANCE APPROACH TO UTILITY FUNCTIONS

if DIAG == 1;
    % --- --- --- SKIP THIS DIAGNOSTIC SECTION --- --- --- %
    
    % set risk parameters for
    K.mvar = -1/60;         % mean variance (<0 is risk averse)
    K.hyp = 2.0;            % hyperbolic discounting (>1 is risk averse)
    K.pros = 0.92;          % prospect theory (<1 is risk averse)
    
    % SUBJECTIVE VALUE ACCORDING TO MEAN VARIANCE
    % mean variance of risky trials
    mvar = NaN(2,stim_nr);
    for i = 1:stim_nr;
        [mvar(1, i)] = mean_variance(r_matrix(10,i), r_matrix(12,i), (1-r_matrix(10,i)), r_matrix(11,i));
    end
    % mean variance for ambiguous trials
    for i = 1:stim_nr;
        [mvar(2, i)] = mean_variance( .5, r_matrix(13,i), .5, r_matrix(14,i) );
    end
    % subjective value according to k parameter
    SV.mvar = ones(2,stim_nr).*repmat(r_matrix(17,:), 2, 1) + mvar * K.mvar;
    
    % SUBJECTIVE VALUE ACCORDING TO HYPERBOLIC DISCOUNTING
    odds_high = (1-r_matrix(10,:))./r_matrix(10,:); % transform p to odds for high value prob
    odds_low = (1-(1-r_matrix(10,:)))./(1-r_matrix(10,:)); % transform p to odds for low value prob
    SV.hyp(1,:) = r_matrix(12,:)./(1+K.hyp.*odds_high) + r_matrix(11,:)./(1+K.hyp.*odds_low); % subjective value of risky offers
    odds = ones(1,stim_nr);  % odds are equal for ambiguous offers
    SV.hyp(2,:) = r_matrix(13,:)./(1+K.hyp.*odds) + r_matrix(14,:)./(1+K.hyp.*odds); % subjective value of ambiguous offers
    
    % SUBJECTIVE VALUE ACCORDING TO PROSPECT THEORY DISCOUNTING
    SV.pros(1,:) = r_matrix(10,:).*r_matrix(12,:).^K.pros + (1-r_matrix(10,:)).*r_matrix(11,:).^K.pros; % subjective value of risky offers
    SV.pros(2,:) = .5.*r_matrix(13,:).^K.pros + .5.*r_matrix(14,:).^K.pros; % subjective value of ambiguous offers
    
    % PLOT AND COMPARE SV
    % figure setup
    xname = 'all stimuli, increasing variance, increasing EV';
    % draw figure
    figs.fig1 = figure('Color', [1 1 1]);
    set(figs.fig1,'units','normalized','outerposition',[0 0 1 1]);
    subplot(3,2,1);
    plot(SV.mvar(1,:), 'k-', 'linewidth', 2); box('off'); hold on;
    plot(SV.hyp(1,:), 'r-', 'linewidth', 2);
    plot(SV.pros(1,:), 'b-', 'linewidth', 2);
    xlabel(xname); ylabel('subjective value');
    title('expected SV for risky trials')
    legend('mvar - risk', 'hyp - risk', 'pros - risk', 'location', 'northwest');
    subplot(3,2,2);
    plot(SV.mvar(2,:), 'k--', 'linewidth', 2); box('off'); hold on;
    plot(SV.hyp(2,:), 'r--', 'linewidth', 2);
    plot(SV.pros(2,:), 'b--', 'linewidth', 2);
    xlabel(xname); ylabel('subjective value');
    title('expected SV for ambiguous trials')
    legend('mvar - ambi', 'hyp - ambi', 'pros - ambi', 'location', 'northwest');
    subplot(3,3,4);
    plot(SV.mvar(1,:), 'k-', 'linewidth', 2); box('off'); box('off'); hold on;
    plot(SV.mvar(2,:), 'k--', 'linewidth', 2); box('off');
    title('mean variance approach'); xlabel(xname); ylabel('subjective value');
    legend('risk', 'ambiguity', 'location', 'northwest');
    subplot(3,3,5);
    plot(SV.hyp(1,:), 'r-', 'linewidth', 2); box('off'); box('off'); hold on;
    plot(SV.hyp(2,:), 'r--', 'linewidth', 2); box('off');
    title('hyperbolic discounting'); xlabel(xname); ylabel('subjective value');
    legend('risk', 'ambiguity', 'location', 'northwest');
    subplot(3,3,6);
    plot(SV.pros(1,:), 'b-', 'linewidth', 2); box('off'); box('off'); hold on;
    plot(SV.pros(2,:), 'b--', 'linewidth', 2); box('off');
    title('prospect theory'); xlabel(xname); ylabel('subjective value');
    legend('risk', 'ambiguity', 'location', 'northwest');
   
    % COMPARE: EXPECTED VALUE, VARIANCE, ABSOLUTE VALUE, DIFFERENCE VALUE, EV DIFFERENCE
    % expected value
    subplot(3,5,11);
    COMP.ev = repmat(r_matrix(17,:), 2, 1);
    bar(COMP.ev');
    title('expected value'); xlabel('variance & EV');
    % variance
    subplot(3,5,12);
    COMP.var = mvar;
    bar(COMP.var');
    title('variance'); xlabel('variance & EV');
    % absolute value
    subplot(3,5,13);
    COMP.av(1,:) = r_matrix(12,:) + r_matrix(11,:);
    COMP.av(2,:) = r_matrix(14,:) + r_matrix(13,:);
    bar(COMP.av');
    title('abs. value'); xlabel('variance & EV');
    % difference value
    subplot(3,5,14);
    COMP.dv(1,:) = r_matrix(12,:) - r_matrix(11,:);
    COMP.dv(2,:) = r_matrix(14,:) - r_matrix(13,:);
    bar(COMP.dv');
    title('diff. value'); xlabel('variance & EV');
    % exp. val difference
    subplot(3,5,15);
    COMP.dv(1,:) = r_matrix(12,:).*r_matrix(10,:) - r_matrix(11,:).*(1-r_matrix(10,:));
    COMP.dv(2,:) = r_matrix(14,:)*.5 - r_matrix(13,:)*.5;
    bar(COMP.dv');
    title('exp. val. diff'); xlabel('variance & EV');
    
    % --- --- --- END SKIP THIS SECTION --- --- --- %
end

%% RANDOMIZE AND COMPLETE MATRIX 

% randomize matrix
matrix = r_matrix(:,randperm(stim_nr));    

% complete matrix
matrix(1,:) = 1:stim_nr;                                                % line 01 - presentation number (sequential)

% fill unused lines with NaN for security
matrix(2,:) = NaN(1,stim_nr);
matrix(4,:) = NaN(1,stim_nr);
matrix(8:9,:) = NaN(2,stim_nr);
matrix(15:16,:) = NaN(2,stim_nr);
matrix(18:20,:) = NaN(3,stim_nr);

% derandomize
% sorted_matrix = sortrows(matrix', 3)';

%% end function code
end