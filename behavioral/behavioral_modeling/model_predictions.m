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
TRIALS.type = [1];
TRIALS.prob_h = [1];
TRIALS.val_h = [1];
TRIALS.prob_l = [1];
TRIALS.val_l = [1];

TRIALS.mat(1,:) = TRIALS.type; % 1 risky, 2 ambigous
TRIALS.mat(2,:) = TRIALS.prob_h; % probability of high amount
TRIALS.mat(3,:) = TRIALS.val_h; % high amount
TRIALS.mat(4,:) = TRIALS.prob_l; % prob. of low amount
TRIALS.mat(5,:) = TRIALS.val_l; % low amount


%% DEFINE UTILITY FUNCTIONS AND PARAMETERS

% which decision process can be explained with which theory
% --> needs proper model comparison

sv = [];

% + softmax
% --> use fmincon





%% PLOT ACTUAL RESULTS FROM EXPERIMENT 2 AS REFERENCE

%%% --- SETUP

% set subjects to analyse
PART = 1:52;
EXCLUDE = false;
EXCLUDE_SUBS = [];

% exclude subjects from subject vector
exclude_vec = EXCLUDE_SUBS;
if EXCLUDE == 1
    PART(exclude_vec) = [];
end
clear i exclude_vec;

% load data
load(fullfile(DIR.input, 'parameters.mat'), 'PARAM');

%%% --- PLOT RESULTS

% uses 5D matrix of premium paramters   (var_level,ev_level,type,sub,[repeat])

% set axes (multiples of ev for y axis)
axis_scale = [.5 VAR_NR+.5 0.5 1.1 ];

% draw figure
FIGS.fig2_1 = figure('Name', 'F3: group summary', 'Color', 'w', 'units', 'normalized', 'outerposition', [0 .5 .6 .5]);
FIGS.fig2_2 = figure('Name', 'F3.1: correlation for different variance levels', 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 .6 .4]);

for ev_level = 1:EV_LEVELS;
    
    new_axis = axis_scale.*[ 1 1 EV(ev_level) EV(ev_level) ];
    
    % prepare data to plot
    data = PARAM.premiums.ce(:,ev_level,:,PART);
    
    % mean preference over all variance levels
    data_persub = mean(mean(data, 1),2);
    x = squeeze(data_persub); % x(1,:) = risk; x(2,:) = ambiguity
    
    % mean data of all repeats (var, risk/ambi, sub)
    data_allrep = mean(data, 2);
    y = squeeze(data_allrep);
    
    % --- FIGURE 2.1
    figure(FIGS.fig2_1);
    
    % --- PANEL 3: preference for different variance levels
    subplot(2,2,2+2*(ev_level-1));
    bar_or_line = 'line';
    switch bar_or_line
        case 'line';
            h = errorbar(mean(y, 3), std(y, 1, 3)./(size(PART,2))^.5, 'LineWidth', 2); hold on; box off;
            set(h(1), 'Color', [.0 .0 .8]); set(h(2), 'Color', [.8 .0 .0]);
        case 'bar';
            h = barwitherr(std(y, 1, 3)./(size(PART,2))^.5, mean(y, 3)); hold on; box off;
            set(h(1), 'FaceColor', [.0 .0 .8]); set(h(2), 'FaceColor', [.8 .0 .0]);
    end
    clear bar_or_line;
    plot( ones(1,VAR_NR)*EV(ev_level), '--k' , 'LineWidth', 2 );
    axis(new_axis); axis('auto x'); ylabel('subjective value');
    legend('risk', 'ambiguity');
    set(gca, 'xtick', 1:VAR_NR );
    xlabel('variance');
    
end

clear PARAM;

% clear data data_persub data_persub_var data_allrep x y varlevel axis_scale new_axis h;

%% PLOT UTILTY FUNCTION OVER STIMULI SPACE







%% --- SCRATCHPAD ---

% % %     % SUBJECTIVE VALUE ACCORDING TO MEAN VARIANCE
% % %     % mean variance of risky trials
% % %     mvar = NaN(2,stim_nr);
% % %     for i = 1:stim_nr;
% % %         [mvar(1, i)] = mean_variance(r_matrix(10,i), r_matrix(12,i), (1-r_matrix(10,i)), r_matrix(11,i));
% % %     end
% % %     % mean variance for ambiguous trials
% % %     for i = 1:stim_nr;
% % %         [mvar(2, i)] = mean_variance( .5, r_matrix(13,i), .5, r_matrix(14,i) );
% % %     end
% % %     % subjective value according to k parameter
% % %     SV.mvar = ones(2,stim_nr).*repmat(r_matrix(17,:), 2, 1) + mvar * K.mvar;
% % % 
% % %     % SUBJECTIVE VALUE ACCORDING TO HYPERBOLIC DISCOUNTING
% % %     odds_high = (1-r_matrix(10,:))./r_matrix(10,:); % transform p to odds for high value prob
% % %     odds_low = (1-(1-r_matrix(10,:)))./(1-r_matrix(10,:)); % transform p to odds for low value prob
% % %     SV.hyp(1,:) = r_matrix(12,:)./(1+K.hyp.*odds_high) + r_matrix(11,:)./(1+K.hyp.*odds_low); % subjective value of risky offers
% % %     odds = ones(1,stim_nr);  % odds are equal for ambiguous offers
% % %     SV.hyp(2,:) = r_matrix(13,:)./(1+K.hyp.*odds) + r_matrix(14,:)./(1+K.hyp.*odds); % subjective value of ambiguous offers
% % % 
% % %     % SUBJECTIVE VALUE ACCORDING TO PROSPECT THEORY DISCOUNTING
% % %     SV.pros(1,:) = r_matrix(10,:).*r_matrix(12,:).^K.pros + (1-r_matrix(10,:)).*r_matrix(11,:).^K.pros; % subjective value of risky offers
% % %     SV.pros(2,:) = .5.*r_matrix(13,:).^K.pros + .5.*r_matrix(14,:).^K.pros; % subjective value of ambiguous offers