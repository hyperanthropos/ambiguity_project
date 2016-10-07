function [matrix, stim_nr] = stimuli( reveal_ambiguity, steps, repeat, diag, session )
% matlab code to create stimuli for experiment
% this function creates a matrix with all relevant stimuli properties which
% can be fed into a task-presentation script
%
% --- stim_matrix description
% line 01 - presentation number (sequential)
% line 02 - repeat number
% line 03 - stimulus number (randomized)
% line 04 - trial type (1 = risky, 2 = ambigious)
% line 05 - resolve ambiguity (1 = yes, 0 = no)
%
% line 06 - risk variance level (1-4; low to high variance)
%               for risk: 25 at 80%, 33 at 60%, 50 at 40%, 100 at 20%
% line 07 - ambiguity variance level (1-4; low to high variance)
%               for ambiguity: 15 vs 25, 10 vs 30, 5 vs 35, 0 vs 40
% line 08 - counteroffer level (1-number of levels; low to high counteroffer)
%
% line 10 - option 1 - probability of offer [ line 6 ] (80%, 60%, 40%, 20%)
% line 11 - option 1 - lower value risk [ line 6 ] (10.00 07.75 07.75 10.00 for risk)
% line 12 - option 1 - upper value risk [ line 6 ] (22.50 28.17 38.37 60.00 for risk)
% line 13 - option 1 - lower value ambiguity [ line 7 ] (15, 10, 5, 0 for ambigutiy)
% line 14 - option 1 - upper value ambiguity [ line 7 ] (25, 30, 35, 40 for ambiguity)
% line 15 - option 2 - counteroffer value [ line 8 ] (variable, matched to 20 expected value (EV)
%
% line 20 - ISI (time until next decision)
% line 21 - position of counteroffer (left, right)
% line 22 - position of higher offer (up or down) (higher offer = probabilistic in risky trials)
%
% --- further notes:
%   -   expected value (EV) of all trials is fixed to one value
%   -   this funtion does not set up propper randomization - this has to be
%       initialized before in a wrapper / presentation script

%% SET PARAMETERS FOR STIMULI MATRIX CREATION

DIAG = diag;                % run diagnostics of stimuli range

isi = 1;                        % mean ISI between trials (for future fMRI optimisation)
repeats = repeat;               % how many times should one set be repeated

X.steps = steps;                % steps of counteroffer value (this must be matched to levels of risk and ambiguity)
                                    % maximum counteroffer (risk vs. ambiguity): 22.5 vs 25, 28.2 vs 30, 38.4 vs 35, 60 vs 40
                                    % minimum counteroffer (risk vs. ambiguity): 10 vs 15, 7.8 vs 10, 7.8 vs 5, 10 vs 0
                                    % combined: 15 - 22.5; 10 - 28.2; 7.8 - 35; 10 - 40; 
                                    % in % [0.750 1.125]; [0.500 1.410]; [0.390 1.750]; [0.500 2.000];
X.var{1} = [0.750 1.125];                                         % for variance level 1: 75% - 125% (15 - 25)
X.var{2} = [0.500 1.330];                                         % for variance level 2: 50% - 150% (10 - 30)
X.var{3} = [0.390 1.540];                                         % for variance level 3: 25% - 175% (5 - 35)
X.var{4} = [0.500 1.750];                                         % for variance level 4: 0% - 200% (0 - 40)

X.RPH = [.8 .6 .4 .2];                                          % risky probabilities for high offer
X.RVH = [22.5 , (10*6^(1/2))/3+20 , (15*6^(1/2))/2+20 , 60];    % risky value levels high
X.RPL = 1-X.RPH;                                                % risky probabilities for low offers
X.RVL = [10 , 20-5*6^(1/2) , 20-5*6^(1/2) , 10];                % risky value levels low
X.RN = 4;                                                       % number of risky levels
X.AVL = [15 10 5 0];                                            % ambiguitly levels low
X.AVH = [25 30 35 40];                                          % ambiguitly levels high
X.AN = 4;                                                       % number of ambiguous levels

X.EV = 20;                                                      % expected value (has to matched to X.RPH, X.RVH, X.AVL, X.AVH

stim_nr = (length(X.RPH)+length(X.AVL))*X.steps*repeats;

% check parameters for balanced design
if mod(X.steps, X.RN);
    warning('your number of steps for the counteroffer is unbalanced given the steps of variation in probabilities');
    disp([ 'you have ' num2str(X.RN) ' levels of risk and ' num2str(X.steps) ' matched counteroffers!' ]);
end

%% DIAGNOSTIC: COMPARE MEAN VARIANCE APPROACH TO UTILITY FUNCTIONS

if DIAG == 1;
    % --- --- --- SKIP THIS DIAGNOSTIC SECTION --- --- --- %
    
    % set risk parameters for
    K.mvar = -1/60;        % mean variance (<0 is risk averse)
    K.hyp = 1.6;            % hyperbolic discounting (>1 is risk averse)
    K.pros = 0.92;          % prospect theory (<1 is risk averse)
    scale = [00 20];        % axis scale
    
    % SUBJECTIVE VALUE ACCORDING TO MEAN VARIANCE
    % mean variance of risky trials
    mvar = NaN(2,4);
    for i = 1:4;
        [mvar(1, i)] = mean_variance(X.RPH(i), X.RVH(i), X.RPL(i), X.RVL(i));
    end
    % mean variance for ambiguous trials
    for i = 1:4;
        [mvar(2, i)] = mean_variance( .5, X.AVL(i), .5, X.AVH(i) );
    end
    % subjective value according to k parameter
    SV.mvar = ones(2,4)*20 + mvar * K.mvar;
    
    % SUBJECTIVE VALUE ACCORDING TO HYPERBOLIC DISCOUNTING
    odds_high = (1-X.RPH)./X.RPH;                                               % transform p to odds for high value prob
    odds_low = (1-X.RPL)./X.RPL;                                                % transform p to odds for low value prob
    SV.hyp(1,:) = X.RVH./(1+K.hyp.*odds_high) + X.RVL./(1+K.hyp.*odds_low);     % subjective value of risky offers
    odds = [1 1 1 1];                                                           % odds are equal for ambiguous offers
    SV.hyp(2,:) = X.AVL./(1+K.hyp.*odds) + X.AVH./(1+K.hyp.*odds);              % subjective value of ambiguous offers
    
    % SUBJECTIVE VALUE ACCORDING TO PROSPECT THEORY DISCOUNTING
    SV.pros(1,:) = X.RPH.*X.RVH.^K.pros + X.RPL.*X.RVL.^K.pros;                 % subjective value of risky offers
    SV.pros(2,:) = .5.*X.AVL.^K.pros + .5.*X.AVH.^K.pros;                       % subjective value of ambiguous offers
    
    % PLOT AND COMPARE SV
    figs.fig1 = figure('Color', [1 1 1]);
    set(figs.fig1,'units','normalized','outerposition',[0 .8 .5 .8]);
    subplot(3,2,1);
    plot(SV.mvar(1,:), 'k-', 'linewidth', 2); box('off'); hold on;
    plot(SV.hyp(1,:), 'r-', 'linewidth', 2);
    plot(SV.pros(1,:), 'b-', 'linewidth', 2);
    axis([.5 4.5 scale]); xlabel('variance'); ylabel('expected value');
    legend('mvar - risk', 'hyp - risk', 'pros - risk', 'location', 'southwest');
    subplot(3,2,2);
    plot(SV.mvar(2,:), 'k--', 'linewidth', 2); box('off'); hold on;
    plot(SV.hyp(2,:), 'r--', 'linewidth', 2);
    plot(SV.pros(2,:), 'b--', 'linewidth', 2);
    axis([.5 4.5 scale]); xlabel('variance'); ylabel('expected value');
    legend('mvar - ambi', 'hyp - ambi', 'pros - ambi', 'location', 'southwest');
    subplot(3,3,4);
    plot(SV.mvar(1,:), 'k-', 'linewidth', 2); box('off'); box('off'); hold on;
    plot(SV.mvar(2,:), 'k--', 'linewidth', 2); box('off');
    axis([.5 4.5 scale]); title('mean variance'); xlabel('variance'); ylabel('expected value');
    legend('risk', 'ambiguity', 'location', 'southwest');
    subplot(3,3,5);
    plot(SV.hyp(1,:), 'r-', 'linewidth', 2); box('off'); box('off'); hold on;
    plot(SV.hyp(2,:), 'r--', 'linewidth', 2); box('off');
    axis([.5 4.5 scale]); title('hyperbolic'); xlabel('variance'); ylabel('expected value');
    legend('risk', 'ambiguity', 'location', 'southwest');
    axis([.5 4.5 scale]);
    subplot(3,3,6);
    plot(SV.pros(1,:), 'b-', 'linewidth', 2); box('off'); box('off'); hold on;
    plot(SV.pros(2,:), 'b--', 'linewidth', 2); box('off');
    axis([.5 4.5 scale]); title('prospect theory'); xlabel('variance'); ylabel('expected value');
    legend('risk', 'ambiguity', 'location', 'southwest');
   
    % COMPARE: EXPECTED VALUE, VARIANCE, ABSOLUTE VALUE, DIFFERENCE VALUE, EV DIFFERENCE
    % expected value
    subplot(3,5,11);
    COMP.ev = ones(2,4)*20;
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

%% CREATE MATRIX TO REPEAT

trials_risky = 1:X.RN*X.steps;
trials_ambiguous = X.RN*X.steps+1:X.RN*X.steps+X.AN*X.steps;

r_matrix(3,:) =  1:X.RN*X.steps+X.AN*X.steps;                             % line 03 - stimulus number (randomized)
r_matrix(4,trials_risky) = ones(1, X.RN*X.steps);                         % line 04 - trial type (1 = risky, 2 = ambigious)
r_matrix(4,trials_ambiguous) = ones(1, X.AN*X.steps)*2;                   % line 04 - trial type (1 = risky, 2 = ambigious)

r_matrix(6,trials_risky) = kron(1:X.RN, ones(1,X.steps));                 % line 06 - risk variance level (1-4; low to high variance)
r_matrix(6,trials_ambiguous) = repmat(1:X.RN, 1, X.steps);                % line 06 - risk variance level (1-4; low to high variance)
r_matrix(7,trials_risky) = repmat(1:X.AN, 1, X.steps);                    % line 07 - ambiguity variance level (1-4; low to high variance)
r_matrix(7,trials_ambiguous) = kron(1:X.AN, ones(1,X.steps));             % line 07 - ambiguity variance level (1-4; low to high variance)
r_matrix(8,:) = repmat(1:X.steps, 1, X.AN+X.RN);                          % line 08 - counteroffer level (1-number of levels; low to high counteroffer)

r_matrix(10,trials_risky) = kron(X.RPH, ones(1,X.steps));                 % line 10 - option 1 - probability of offer [ line 6 ] (80%, 60%, 40%, 20%)
r_matrix(10,trials_ambiguous) = repmat(X.RPH, 1, X.steps);                % line 10 - option 1 - probability of offer [ line 6 ] (80%, 60%, 40%, 20%)
r_matrix(11,trials_risky) = kron(X.RVL, ones(1,X.steps));                 % line 11 - option 1 - lower value risk [ line 6 ] (always 0 for risk)
r_matrix(11,trials_ambiguous) = repmat(X.RVL, 1, X.steps);                % line 11 - option 1 - lower value risk [ line 6 ] (always 0 for risk)
r_matrix(12,trials_risky) = kron(X.RVH, ones(1,X.steps));                 % line 12 - option 1 - upper value risk [ line 6 ] (25, 33, 50, 100 for risk)
r_matrix(12,trials_ambiguous) = repmat(X.RVH, 1, X.steps);                % line 12 - option 1 - upper value risk [ line 6 ] (25, 33, 50, 100 for risk)
r_matrix(13,trials_risky) = repmat(X.AVL, 1, X.steps);                    % line 13 - option 1 - lower value ambiguity [ line 7 ] (15, 10, 5, 0 for ambigutiy)
r_matrix(13,trials_ambiguous) =  kron(X.AVL, ones(1,X.steps));            % line 13 - option 1 - lower value ambiguity [ line 7 ] (15, 10, 5, 0 for ambigutiy)
r_matrix(14,trials_risky) = repmat(X.AVH, 1, X.steps);                    % line 14 - option 1 - upper value ambiguity [ line 7 ] (25, 30, 35, 40 for ambiguity)
r_matrix(14,trials_ambiguous) =  kron(X.AVH, ones(1,X.steps));            % line 14 - option 1 - upper value ambiguity [ line 7 ] (25, 30, 35, 40 for ambiguity)

% create counteroffers
counteroffers = [];
for i = 1:X.RN;
counteroffers = cat(2, counteroffers, linspace(X.var{i}(1), X.var{i}(2), X.steps)*X.EV);
end
for i = 1:X.AN;
counteroffers = cat(2, counteroffers, linspace(X.var{i}(1), X.var{i}(2), X.steps)*X.EV);
end

r_matrix(15,:) = counteroffers;                                           % line 15 - option 2 - counteroffer value [ line 8 ] (variable, matched to 20 expected value (EV)

r_matrix(20,:) = ones(1,stim_nr/repeats)*isi;                             % line 20 - ISI (time until next decision)
r_matrix(21,:) = randi(2, 1, stim_nr/repeats);                            % line 21 - position of counteroffer (left, right)
r_matrix(22,:) = randi(2, 1, stim_nr/repeats);                            % line 22 - position of higher offer (up or down) (higher offer = probabilistic in risky trials)

%% DIAGNOSTIC: PLOT STIMULUS MATRIX

if DIAG == 1;
    % --- --- --- SKIP THIS DIAGNOSTIC SECTION --- --- --- %
    
    % plot trials and funtcions
    figs.fig2 = figure('Color', [1 1 1]);
    set(figs.fig2,'units','normalized','outerposition',[0 .6 .5 .6]);
    
    subplot(1,2,1);
    scatter(r_matrix(6,trials_risky), r_matrix(15, trials_risky)/X.EV); box off; hold on;
    plot(SV.mvar(1,:)./20, 'k-', 'linewidth', 2);
    plot(SV.hyp(1,:)./20, 'r-', 'linewidth', 2);
    plot(SV.pros(1,:)./20, 'b-', 'linewidth', 2);
    
    legend('single trial', 'mvar', 'hyp', 'pros', 'location', 'northwest');
    axis([.5 4.5 -.1 2.1]); xlabel('variance'); ylabel('expected value ratio');
    set(gca, 'XTick', 1:4); set(gca, 'XTickLabel', {'80%','60%', '40%', '20%'});
    
    subplot(1,2,2);
    scatter(r_matrix(7,trials_ambiguous), r_matrix(15,trials_ambiguous)/X.EV); box off; hold on;
    plot(SV.mvar(2,:)./20, 'k--', 'linewidth', 2);
    plot(SV.hyp(2,:)./20, 'r--', 'linewidth', 2);
    plot(SV.pros(2,:)./20, 'b--', 'linewidth', 2);
    
    legend('single trial', 'mvar', 'hyp', 'pros', 'location', 'northwest');
    axis([.5 4.5 -.1 2.1]); xlabel('variance'); ylabel('expected value ratio');
    set(gca, 'XTick', 1:4); set(gca, 'XTickLabel', {'15 vs 25', '10 vs 30', '5 vs 35', '0 vs 40'});
    
    %%% EXPECTED RESULTS
    neutral = ones(1,9);
    risky_experimental = [.8 .82 .83 .87];
    risky_control = [.81 .8 .81 .84];
    ambigous_control = [.6 .61 .61 .62];
    ambigous_experimental = [.58 .63 .72 .79];
    
    figs.fig3 = figure('Color', [1 1 1]);
    set(figs.fig3,'units','normalized','outerposition',[0 .4 .3 .4]);
    
    plot(1:9, neutral, 'k', 'linewidth', 2); hold on; box off;
    plot([6 7 8 9], risky_experimental(1,1:4), 'b-*', 'linewidth', 2);
    plot([1 2 3 4], risky_control(1,1:4), 'b--*', 'linewidth', 2);
    plot([6 7 8 9], ambigous_experimental(1,1:4), 'r-*', 'linewidth', 2);
    plot([1 2 3 4], ambigous_control(1,1:4), 'r--*', 'linewidth', 2);    
    
    axis([.5 9.5 0 1.1]); xlabel('time'); ylabel('risk preference');
    set(gca, 'XTick', 1.5:5:9.5); set(gca, 'XTickLabel', {'control', 'experimental'})
    legend('neutral', 'risk experimental', 'risk control', 'ambiguity experimental', 'ambiguity control', 'location', 'southwest');  
    
    % --- --- --- END SKIP THIS SECTION --- --- --- %
end

%% RANDOMIZE AND REPEAT MATRIX 

% randomize and repeat r_matrix
repeat_size = size(r_matrix, 2);

matrix = [];
for i = 1:repeats;
    matrix = cat(2, matrix, r_matrix(:,randperm(repeat_size)) );    
end

% complete matrix
matrix(1,:) = 1:stim_nr;                                                  % line 01 - presentation number (sequential)
matrix(2,:) = kron(1:repeats, ones(1,stim_nr/repeats));                   % line 02 - repeat number

% set if ambiguity is resolved 
if reveal_ambiguity == 1;
    matrix(5,:) = ones(1, stim_nr);                                       % line 05 - resolve ambiguity (1 = yes, 0 = no)
else
    matrix(5,:) = zeros(1, stim_nr);                                      % line 05 - resolve ambiguity (1 = yes, 0 = no) 
end
% first repeat in first session is never revealed
if session == 1; 
    matrix(5,1:repeat_size) = zeros(1, repeat_size);
end

% fill unused lines with NaN for security
matrix(9,:) = NaN(1,stim_nr);
matrix(16:19,:) = NaN(4,stim_nr);

% derandomize
% sorted_matrix = sortrows(matrix', [2 3])';


%% end function code
end