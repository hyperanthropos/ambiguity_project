%% SCRIPT TO TEST MODEL PREDICTIONS
% simulate subjects preferences according to utility functions
% script needs parameters.mat from experiment 2 analyisis in a "exp2_data"
% subfolder
% needs mean_variance function to calculate statistical moments

%% DATA HANDLING
clear; close all; clc;

DIR.home = pwd;
DIR.input = fullfile(DIR.home, 'exp2_data');

%% CREATE TRIALS TO APPLY MODELS TO (same trials as in experiment 2)

% in order to be calculatable for sone theories ambiguous trials feature a
% 50/50 probabilty, that however assumes strong assumptions that should not
% be made by a proper model.

% general parameters
VAR_NR = 9; % how many steps of variance variation
EV_LEVELS = 2; % how many steps of expected value variation
EV = [8.5 34]; % what were the expected values of all gambles

% specific trials
nTrials = VAR_NR*EV_LEVELS*2;

% trials are sorted: risk ev1, risk ev2, ambi ev1, ambi ev2 | low to high variance
TRIALS.type = [ones(1,VAR_NR*EV_LEVELS),ones(1,VAR_NR*EV_LEVELS)*2];

risk = ([0.8200    0.7400    0.6600    0.5800    0.5000    0.4200    0.3400    0.2600    0.1800    0.8200    0.7400    0.6600    0.5800    0.5000   0.4200    0.3400    0.2600    0.1800]); % probability high value
ambi = ones(1,VAR_NR*EV_LEVELS)*.5;
TRIALS.prob_h = [risk,ambi];

risk = [8.7343    9.3891   10.2944   11.4784   13.0000   14.9633   17.5562   21.1529   26.6422   34.9370   37.5565   41.1774   45.9135   52.0000   59.8531   70.2248   84.6116  106.5687]; % risky value levels high
ambi = [9    10    11    12    13    14    15    16    17    36    40    44    48    52    56    60    64    68]; % ambiguitly levels high
TRIALS.val_h = [risk,ambi];

risk = ([0.1800    0.2600    0.3400    0.4200    0.5000    0.5800    0.6600    0.7400    0.8200    0.1800    0.2600    0.3400    0.4200    0.5000   0.5800    0.6600    0.7400    0.8200]); % probability low value
ambi = ones(1,VAR_NR*EV_LEVELS)*.5;
TRIALS.prob_l = [risk,ambi];

risk =  [7.4328    5.9694    5.0168    4.3870    4.0000    3.8197    3.8347    4.0544    4.5176   29.7313   23.8777   20.0674   17.5480   16.0000   15.2788   15.3387   16.2175   18.0703]; % risky value levels low
ambi = [8     7     6     5     4     3     2     1     0    32    28    24    20    16    12     8     4     0]; % ambiguitly levels low
TRIALS.val_l = [risk,ambi];

TRIALS.mat(1,:) = TRIALS.type; % 1 risky, 2 ambigous
TRIALS.mat(2,:) = TRIALS.prob_h; % probability of high amount
TRIALS.mat(3,:) = TRIALS.val_h; % high amount
TRIALS.mat(4,:) = TRIALS.prob_l; % prob. of low amount
TRIALS.mat(5,:) = TRIALS.val_l; % low amount

clear x;

%% DEFINE UTILITY FUNCTIONS AND PARAMETERS

%%% --- --- --- START MODEL SETUP

% set utility function to calculate subjective value

% separate models for risk and ambiguity or mixed model with same
% parameters for risk and ambiguity
model_type = 'mixed'; % separate or mixed

% define separate models
utility_function_risk = 'hyperbolic';
utility_function_ambi = 'modelOne';

% define mixed model
utility_function_mixed = 'modelThree';

% set paramters for separate utitlity functions
PARAMETERS.risk.hyperbolic = 1.4; % (>1 is risk averse)
PARAMETERS.ambi.hyperbolic = 1.6; % (>1 is risk averse)

PARAMETERS.risk.prospect = .96; % (<1 is risk averse)
PARAMETERS.ambi.prospect = .92; % (<1 is risk averse)

PARAMETERS.risk.meanvariance = -.015; % (<0 is risk averse)
PARAMETERS.ambi.meanvariance = -.025; % (<0 is risk averse)

PARAMETERS.risk.modelOne = -.2; % (<0 is risk averse)
PARAMETERS.ambi.modelOne = -.4; % (<0 is risk averse)

% set paramters for mixed utitlity functions
PARAMETERS.mixed.modelTwo(1) = -.25; % reaction to variance
PARAMETERS.mixed.modelTwo(2) = 1.2; % reaction to probabilites
PARAMETERS.mixed.modelTwo(3) = .1; % reaction to EV
PARAMETERS.mixed.modelTwo(4) = .5; % reaction to probabilites

PARAMETERS.mixed.modelThree(1) = .4; % reaction to variance
PARAMETERS.mixed.modelThree(2) = -.75; % precision for probabilites
PARAMETERS.mixed.modelThree(3) = 1; % precision for information

% PARAMETERS.mixed.modelThree(1) = .2; % reaction to variance
% PARAMETERS.mixed.modelThree(2) = -.9; % precision for probabilites
% PARAMETERS.mixed.modelThree(3) = 2; % precision for information

%%% --- --- --- END MODEL SETUP

%% CALCULATE SUBJECTIVE VALUE FOR TEST TRIALS

sv = NaN(1,nTrials);
for iTrial = 1:nTrials
    
    % select models and parameters
    switch model_type
        case 'separate'
            if TRIALS.type(iTrial) == 1; % risky
                utility_function = utility_function_risk;
                funparam = PARAMETERS.risk;
            elseif TRIALS.type(iTrial) == 2; % ambiguous
                utility_function = utility_function_ambi;
                funparam = PARAMETERS.ambi;
            end
        case'mixed'
            utility_function = utility_function_mixed;
            funparam = PARAMETERS.mixed;
    end
        
    X.PH = TRIALS.prob_h(iTrial);
    X.PL = TRIALS.prob_l(iTrial);
    X.VH = TRIALS.val_h(iTrial);
    X.VL = TRIALS.val_l(iTrial);
    
    [mvar,ev] = mean_variance(X.PH, X.VH, X.PL, X.VL);
    
    switch utility_function
        case 'hyperbolic'
            odds_high = (1-X.PH)./X.PH; % transform p to odds for high value prob
            odds_low = (1-X.PL)./X.PL; % transform p to odds for low value prob
            sv(iTrial) = X.VH ./ (1+funparam.hyperbolic.*odds_high) + X.VL ./ (1+funparam.hyperbolic.*odds_low); % subjective value of offer
        case 'prospect'
            sv(iTrial) = X.PH.*X.VH.^funparam.prospect + X.PL.*X.VL.^funparam.prospect; % subjective value of offer
        case 'meanvariance'
            sv(iTrial) = ev + mvar * funparam.meanvariance;
        case 'modelOne'
            sv(iTrial) = ev + sqrt(mvar) * funparam.modelOne;
        case 'modelTwo'
            % combine modelOne + hyperbolic model
            odds_high = ((1-X.PH)./X.PH)^funparam.modelTwo(4);
            odds_low = ((1-X.PL)./X.PL)^funparam.modelTwo(4);
            % seperate components of decision
            c1 = X.VH ./ (1+funparam.modelTwo(2).*odds_high) + (sqrt(mvar) * funparam.modelTwo(1));
            c2 = X.VL ./ (1+funparam.modelTwo(2).*odds_low) + (sqrt(mvar) * funparam.modelTwo(1));
            sv(iTrial) = (c1+c2) + funparam.modelTwo(3)*ev;
        case 'modelThree'
            prob_switch = 1; % is probability present
            % seperate components of decision
            c1_1 = (X.PL./(1-X.PL));
            % c1_1 = ((1-X.PH)./(X.PH));
            c1_2 = prob_switch + funparam.modelThree(3);
            c1_3 = c1_2 + funparam.modelThree(2) * log(c1_2) * c1_1;
            c1 = ev- funparam.modelThree(1) * (sqrt(mvar) / c1_2) ^ c1_3;
            % subjective value
            sv(iTrial) = c1;
        otherwise
            error('utitity function not found - check spelling');
    end
    
end

clear c1 c2 utility_function iTrial X odds_high odds_low mvar PARAMETER;

%% DERIVE PARAMETERS OF FUNCTIONS ON AVERAGED UTILITY FUNCTION OF EXPERIMENT 2

%%% --- LOAD DATA

% set subjects to analyse
% PART = 25;
% PART = 11;
PART = 1:52;
EXCLUDE = true;
EXCLUDE_SUBS = [];
% subjects with ceiling effects (3 extreme choices aversive choices in last 3 variance levels of EV 34)
% EXCLUDE_SUBS = [1 5 7 13 16 19 29 31 32 34 38 40 44 47 48];

% exclude subjects from subject vector
exclude_vec = EXCLUDE_SUBS;
if EXCLUDE == 1
    PART(exclude_vec) = [];
end
clear i exclude_vec;

% load data
load(fullfile(DIR.input, 'parameters.mat'), 'PARAM');

%%% --- FIT UTILITY FUNCTION

% create mean data for variance levels
% uses 5D matrix of premium paramters (var_level,ev_level,type,sub,[repeat])
risk_ev{1} = mean(PARAM.premiums.ce(:,1,1,:),4)';
risk_ev{2} = mean(PARAM.premiums.ce(:,2,1,:),4)';
ambi_ev{1} = mean(PARAM.premiums.ce(:,1,2,:),4)';
ambi_ev{2} = mean(PARAM.premiums.ce(:,2,2,:),4)';

% create x data to it functions
x_data.mvar_ev{1} = PARAM.premiums.fixed.mvar(:,1)';
x_data.mvar_ev{2} = PARAM.premiums.fixed.mvar(:,2)';
x_data.prob_low_ev{1} = 1-PARAM.premiums.fixed.prob_high(:,1)'; % inverse so that variance is rising with higher numbers
x_data.prob_low_ev{1} = 1-PARAM.premiums.fixed.prob_high(:,2)'; % inverse so that variance is rising with higher numbers
x_data.varlevel_ev{1} = 1:VAR_NR;
x_data.varlevel_ev{2} = 1:VAR_NR;

% ---> insert code
% cftool

%% PLOT ACTUAL RESULTS FROM EXPERIMENT 2 AS REFERENCE

% set axes (multiples of ev for y axis)
axis_scale = [.5 VAR_NR+.5 0 1 ];

% draw figure
FIGS.fig1 = figure('Name', 'model predictions', 'Color', 'w', 'units', 'normalized', 'outerposition', [.0 .5 .6 .5]);
for ev_level = 1:EV_LEVELS;
    
    new_axis = axis_scale.*[ 1 1 EV(ev_level) EV(ev_level) ];
    
    % prepare data to plot
    % (var_level,ev_level,type,sub,[repeat])
    data = PARAM.premiums.ce(:,ev_level,:,PART);
    
    % mean data of all repeats (var, risk/ambi, sub)
    data_allrep = mean(data, 2);
    y = squeeze(data_allrep);
    
    % plot the data
    subplot(1,2,ev_level);
    h = errorbar(mean(y, 3), std(y, 1, 3)./(size(PART,2))^.5, 'LineWidth', 2); hold on; box off;
    set(h(1), 'Color', [.0 .0 .8], 'LineStyle', '--');
    set(h(2), 'Color', [.8 .0 .0], 'LineStyle', '--');
    plot( ones(1,VAR_NR)*EV(ev_level), '--k' , 'LineWidth', 2 );
    axis(new_axis); axis('auto x'); ylabel('subjective value');
    xlabel('variance');
    
end
clear PARAM axis_scale new_axis y h data data_allrep ev_level;

%% PLOT UTILTY FUNCTION OVER STIMULI SPACE

% select data (risk ev1, risk ev2, ambi ev1, ambi ev2)
risk_data_all_ev = sv(1:nTrials/2);
ambi_data_all_ev = sv(nTrials/2+1:nTrials);
risk_data(1,:) = risk_data_all_ev(1:VAR_NR); % ev level 1
risk_data(2,:) = risk_data_all_ev(VAR_NR+1:VAR_NR*2); % ev level 2
ambi_data(1,:) = ambi_data_all_ev(1:VAR_NR); % ev level 1
ambi_data(2,:) = ambi_data_all_ev(VAR_NR+1:VAR_NR*2); % ev level 2

% ...and plot it over the experimental dataset
for ev_level = 1:EV_LEVELS;
    subplot(1,2,ev_level);
    h(1) = plot(risk_data(ev_level,:), 'LineWidth', 2, 'Color', [.0 .0 .8]);
    h(2) = plot(ambi_data(ev_level,:), 'LineWidth', 2, 'Color', [.8 .0 .0]);
    switch model_type
        case 'separate'
            legend('risk-data', 'ambiguity-data', 'neutrality', ['risk-' utility_function_mixed], ['ambiguity-' utility_function_mixed], 'Location', 'southwest');
        case'mixed'
            legend('risk-data', 'ambiguity-data', 'neutrality', ['risk-' utility_function_mixed], ['ambiguity-' utility_function_mixed], 'Location', 'southwest');
    end
    legend('boxoff'); set(gca, 'xtick', 1:VAR_NR );
    axis('auto y');
end

clear risk_data_all_ev ambi_data_all_ev risk_data ambi_data h ev_level;

% END OF SCRIPT