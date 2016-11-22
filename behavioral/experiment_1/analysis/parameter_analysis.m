%% SCRIPT TO ANALYSE PARAMTERS
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
DRAW = [1 2 3];
% 01 | INDIVIDUAL SUBJECTS RISK AND AMBIGUITY ATTITUDE
% 02 | COMPARISON OF RESOLVED / UNRESOLVED GROUPS
% 03 | COMPOSITE GROUP SUMMARY

% set subjects to analyse
PART{1} = 1:23; % subjects where ambiguity was not resolved
PART{2} = 1:21; % subjects where ambiguity was resolved

% set group to analyze
GROUP = 1; % 1 = ambiguity not resolved; 2 = ambiguity resolved

% exclude subjects for certain reasons
EXCLUDE_SUBS = 0;
% unresolved exclude candidates
% #4 = obvious maladaptive strategie at varlevel 4
% #22 = extremly risk averse
exclude{1}.vec = [4 22];
% resolved exclude candidates
% #1 very risk seeking
% #11 very risk averse (but still a pattern)
exclude{2}.vec = [1 11];

% design specification
REPEATS_NR = 4; % how many times was one cycle repeated
VAR_NR = 4; % how many steps of variance variation
EV = 20; % what is the expected value of all gambles

%% DATA HANDLING

% set directories
DIR.home = pwd;
DIR.input = fullfile(DIR.home, 'analysis_results');

% load data
load(fullfile(DIR.input, 'parameters.mat'), 'PARAM');

% exclude subjects from subject vector
if EXCLUDE_SUBS == 1;
    for i = 1:2;
        PART{i}(exclude{i}.vec) = [];
    end
end
clear i exclude;

%% FIGURE 1: INDIVIDUAL SUBJECTS RISK AND AMBIGUITY ATTITUDE

% 4D matrix of premium paramters:
% (var,repeat,type,sub)

if sum(DRAW == 1);
    
    figure('Name', 'F1: single subject per timepoint and variance', 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 1 1]);
    for sub = PART{GROUP};
        
        if GROUP == 1;
            x = squeeze(mean(PARAM.premiums.ce.control(:,:,:,sub),1)); % over time
            y = squeeze(mean(PARAM.premiums.ce.control(:,:,:,sub),2)); % over variance
        elseif GROUP == 2;
            x = squeeze(mean(PARAM.premiums.ce.resolved(:,:,:,sub),2)); % over time
            y = squeeze(mean(PARAM.premiums.ce.resolved(:,:,:,sub),2)); % over variance
        end
        
        % plot single subjects over time
        subplot(10,5,sub);
        plot( x, 'LineWidth', 2 ); hold on; box off;
        plot( ones(1,VAR_NR)*EV, '--k', 'LineWidth', 2 );
        legend('R', 'A', 'N', 'Location', 'westoutside');
        axis([1 VAR_NR 0 1]); axis('auto y');
        xlabel('time');
        
        % plot single subjects over variance
        subplot(10,5,sub+25);
        plot( y, 'LineWidth', 2 ); hold on; box off;
        plot( ones(1,VAR_NR)*EV, '--k', 'LineWidth', 2 );
        legend('R', 'A', 'N', 'Location', 'westoutside');
        axis([1 VAR_NR 0 1]); axis('auto y');
        xlabel('variance');
        
    end
    
    clear x y sub;
    
end

%% FIGURE 2: COMPARISON OF RESOLVED / UNRESOLVED GROUPS

% 4D matrix of premium paramters:
% (var,repeat,type,sub)

if sum(DRAW == 2);
    
    % setup for figure 2
    axis_scale = [.5 4.5 10 22]; % scale fot axis
    
    figure('Name', 'F2: mean over time for variance levels between groups', 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 1 1]);
    
    % plot for both groups independend of "GROUPS" setting (control left, resolved right)
    for group = 1:2;
        
        if group == 1;
            data = mean(PARAM.premiums.ce.control(:,:,:,:), 1);
        elseif group == 2;
            data = mean(PARAM.premiums.ce.resolved(:,:,:,:), 1);
        end
        
        % plot mean preference over time
        x = squeeze( mean( data,4 ) ); % calulate mean over subs
        x_se = squeeze( std( data,1,4 )./(size(PART{group},2))^.5); % calculate se
        
        subplot(2,2,group);
        plot( x, 'LineWidth', 3 ); box off; hold on;
        errorbar(x, x_se);
        plot( ones(1,VAR_NR)*EV, '--k' , 'LineWidth', 2 );
        axis(axis_scale); legend('R', 'A'); xlabel('time');
        if group == 1;
            title('control');
        elseif group == 2;
            title('resolved');
        end
        
        % plot mean preference over time for each variance level
        for varlevel = 1:VAR_NR;
            
            if group == 1;
                data = mean(PARAM.premiums.ce.control(varlevel,:,:,:), 1);
                subplot(2, VAR_NR*2+1 ,VAR_NR*2+1+varlevel);
            elseif group == 2;
                data = mean(PARAM.premiums.ce.resolved(varlevel,:,:,:), 1);
                subplot(2, VAR_NR*2+1 ,VAR_NR*2+1+VAR_NR+1+varlevel);
            end
            
            x = squeeze( mean( data,4 ) ); % calulate mean over subs
            x_se = squeeze( std( data,1,4 )./(size(PART{group},2))^.5 ); % calculate se
            
            plot( x, 'LineWidth', 3 ); box off; hold on;
            errorbar(x, x_se);
            plot( ones(1,VAR_NR)*EV, '--k' , 'LineWidth', 2 );
            axis(axis_scale); legend('R', 'A'); xlabel('time');
            if group == 1;
                title(['control var: ' num2str(varlevel)]);
            elseif group == 2;
                title(['resolved var: ' num2str(varlevel)]);
            end
            
        end
  
    end
    
    clear group data x x_se varlevel axis_scale;
    
end

%% FIGURE 3: COMPOSITE GROUP SUMMARY

% 4D matrix of premium paramters:
% (var,repeat,type,sub)

if sum(DRAW == 3);
    
    % add function for "barrwitherr"
    addpath(SUBFUNCTIONS_PATH);
    axis_scale = [.5 4.5 10 22];
    
    figure('Name', 'F3: group summary', 'Color', 'w', 'units', 'normalized', 'outerposition', [0 .5 .6 .5]);
    
    % prepare data to plot
    if GROUP == 1;
        data = PARAM.premiums.ce.control(:,:,:,PART{GROUP});
    elseif GROUP == 2;
        data = PARAM.premiums.ce.resolved(:,:,:,PART{GROUP});
    end
    
    % data for all subjects
    data_persub = mean(mean(data, 1),2);
    x = squeeze(data_persub); % x(1,:) = risk; x(2,:) = ambiguity
    
    % mean data of all repeats (var, risk/ambi, sub)
    data_allrep = mean(data, 2);
    y = squeeze(data_allrep);
    
    % --- PANEL 1: overall preference for risk / ambiguity
    subplot(1,3,1);
    h = barwitherr(std(x, 1, 2)./(size(PART{GROUP},2))^.5, mean(x, 2)); hold on; box off;
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
    h= barwitherr(std(y, 1, 3)./(size(PART{GROUP},2))^.5, mean(y, 3)); hold on; box off;
    plot( ones(1,VAR_NR)*EV, '--k' , 'LineWidth', 2 );
    axis(axis_scale); axis('auto x'); ylabel('subjective value');
    legend('risk', 'ambiguity');
    set(gca, 'xtick',[1:4] ); set(gca, 'xticklabels', {'V1','V2','V3','V4'} );
    set(h(1), 'FaceColor', [.0 .0 .8]);
    set(h(2), 'FaceColor', [.8 .0 .0]);

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

