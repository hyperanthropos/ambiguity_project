%% SCRIPT TO ANALYSE PARAMTERS
% analysis script for experiment_2 (!)
% this script analyses parameters on the group level, creates figures and
% runs statistical tests
% reads data from parameter_creation script

% clean the field
clear; close all; clc;

% this script needs the function "barwitherr", which makes ploting error
% bars easier:
SUBFUNCTIONS_PATH = '/home/fridolin/DATA/MATLAB/downloaded_functions';

%% SETUP

% set figures you want to draw
DRAW = [1 2];
% 01 | INDIVIDUAL SUBJECTS RISK AND AMBIGUITY ATTITUDE
% 02 | GROUP SUMMARY

% set subjects to analyse
PART = 1:52;

% exclude subjects for certain reasons
EXCLUDE = false;
EXCLUDE_SUBS = [1 2 3 4 5]; % exclude candidates
% this format allows to use an auto-generated exclude vector (e.g. exclude all risk averse)

% design specification
VAR_NR = 9; % how many steps of variance variation
EV_LEVELS = 2; % how many steps of expected value variation
EV = [8.5 34]; % what were the expected values of all gambles

%% DATA HANDLING

% set directories
DIR.home = pwd;
DIR.input = fullfile(DIR.home, 'analysis_results');

% load data
load(fullfile(DIR.input, 'parameters.mat'), 'PARAM');

% exclude subjects from subject vector
exclude_vec = EXCLUDE_SUBS;
if EXCLUDE == 1
        PART(exclude_vec) = [];
end
clear i exclude_vec;

%% FIGURE 1: INDIVIDUAL SUBJECTS RISK AND AMBIGUITY ATTITUDE

% 5D matrix of premium paramters:
% (var_level,ev_level,type,sub,[repeat])

if sum(DRAW == 1);
    for ev_level = 1:EV_LEVELS;
        
        figure('Name', ['F1: EV: ' num2str(EV(ev_level)) ' | single subject variance respsonse'], 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 1 1]);
        for sub = PART;
            
            x = squeeze(PARAM.premiums.ce(:,ev_level,:,sub)); % EV 1
            
            % plot single subjects over time
            subplot(9,6,sub);
            plot( x, 'LineWidth', 2 ); hold on; box off;
            plot( ones(1,VAR_NR)*EV(ev_level), '--k', 'LineWidth', 2 );
            axis([1 VAR_NR 0 1]); axis('auto y');
            xlabel('variance');
            
        end
        
        % plot subject mean in same figure and show a legend
        x = mean(squeeze(PARAM.premiums.ce(:,ev_level,:,:)), 3);
        subplot(15,6,90);
        plot( x, 'LineWidth', 2 ); hold on; box off;
        plot( ones(1,VAR_NR)*EV(ev_level), '--k', 'LineWidth', 2 );
        legend('R', 'A', 'N', 'Location', 'westoutside');
        axis([1 VAR_NR 0 1]); axis('auto y');
        xlabel('variance');
        
        clear x y sub;
        
    end
end

%% FIGURE 2: COMPOSITE GROUP SUMMARY

% 5D matrix of premium paramters:
% (var_level,ev_level,type,sub,[repeat])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% GOOD TILL HERE %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if sum(DRAW == 2);
    
    % add function for "barrwitherr"
    addpath(SUBFUNCTIONS_PATH);
    axis_scale = [.5 4.5 10 22];
    
    figure('Name', 'F3: group summary', 'Color', 'w', 'units', 'normalized', 'outerposition', [0 .5 .6 .5]);
    
    % prepare data to plot
    data = PARAM.premiums.ce.control(:,:,:,PART);

    % data for all subjects
    data_persub = mean(mean(data, 1),2);
    x = squeeze(data_persub); % x(1,:) = risk; x(2,:) = ambiguity
    
    % mean data of all repeats (var, risk/ambi, sub)
    data_allrep = mean(data, 2);
    y = squeeze(data_allrep);
    
    % --- PANEL 1: overall preference for risk / ambiguity
    subplot(1,3,1);
    h = barwitherr(std(x, 1, 2)./(size(PART,2))^.5, mean(x, 2)); hold on; box off;
    plot( [EV EV], '--k' , 'LineWidth', 2 );
    axis(axis_scale); axis('auto x'); ylabel('subjective value');
    set(gca, 'xtick',[1 2] ); set(gca, 'xticklabels', {'risk','ambiguity'} );
    set(h(1), 'FaceColor', [.5 .5 .5]);
    
    % --- PANLEL 2: overall correlation of risk & ambiguity
    subplot(1,3,2);
    scatter(x(1,:), x(2,:));
    h = lsline; set(h, 'LineWidth', 2); hold on;
    scatter(x(1,:), x(2,:), 'k', 'MarkerFaceColor', 'k' );
    xlabel('SV risk'); ylabel('SV ambiguity');
 
    % --- PANEL 3: preference for different variance levels
    subplot(1,3,3);
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
    plot( ones(1,VAR_NR)*EV, '--k' , 'LineWidth', 2 );
    axis(axis_scale); axis('auto x'); ylabel('subjective value');
    legend('risk', 'ambiguity');
    set(gca, 'xtick', 1:4 );
    xlabel('variance');
    
    %%% EXTRA FIGURE 3.1: correlation over all variance levels
    figure('Name', 'F3.1: correlation for different variance levels', 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 .6 .4]);
    for varlevel = 1:4;
        % reselect data for ceratin variance level only
        data_persub = mean(mean(data(varlevel,:,:,:), 1),2);
        x = squeeze(data_persub);
        % plot
        subplot(1,4,varlevel);
        scatter(x(1,:), x(2,:));
        h = lsline; set(h, 'LineWidth', 2); hold on;
        scatter(x(1,:), x(2,:), 'k', 'MarkerFaceColor', 'k' );
        xlabel('SV risk'); ylabel('SV ambiguity');
    end
    
    clear data data_persub data_allrep x y varlevel axis_scale h;
    
end

