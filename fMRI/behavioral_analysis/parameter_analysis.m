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
DRAW = 3; %[1 2 3 4];
% 01 | INDIVIDUAL SUBJECTS RISK AND AMBIGUITY ATTITUDE
% 02 | COMPARISON OF RESOLVED / UNRESOLVED GROUPS
% 03 | COMPOSITE GROUP SUMMARY
% 04 | ANALYSIS OF RT

% set subjects to analyse
PART = 1:40; % subjects where ambiguity was not resolved

% insert code to select only RA or RS subs
warning('implement this');

% set sub-sample to analyse
SAMPLE = 'all';

% set group to analyze
GROUP = 1; % 1 = ambiguity not resolved; 2 = ambiguity resolved
warning('clean this');




% % % % exclude subjects for certain reasons
% % % EXCLUDE_SUBS = 0;
% % % % exclude candidates
% % % % #4 = obvious maladaptive strategie at varlevel 4
% % % % #22 = extremly risk averse
% % % exclude.vec = [4 22];

% set graphs to 'bar' or 'line' plots where applicable 
BAR_LINE = 'line';

% design specification
REPEATS_NR = 3; % how many times was one cycle repeated
VAR_NR = 5; % how many steps of variance variation
EV = 22.5; % what is the expected value of all gambles

%% DATA HANDLING

% set directories
DIR.home = pwd;
DIR.input = fullfile(DIR.home, 'analysis_results');

% add function for "barrwitherr"
addpath(SUBFUNCTIONS_PATH);

% load data
load(fullfile(DIR.input, 'parameters.mat'), 'PARAM');

% select sample to analyse
switch SAMPLE
    case 'all'
        
        PART = PART;
        
    case 'RA'
        
        PART = PART;
        
    case 'RS';
        
        PART = PART;
        
    otherwise
        error('the ''SAMPLE'' variable set under SETUP does not point to a valide sub sample');
end

% % % % exclude subjects from subject vector
% % % if EXCLUDE_SUBS == 1;
% % %     for i = 1:2;
% % %         PART(exclude{i}.vec) = [];
% % %     end
% % % end


clear i exclude;

%% FIGURE 1: INDIVIDUAL SUBJECTS RISK AND AMBIGUITY ATTITUDE

% 4D matrix of premium paramters:
% (var,repeat,type,sub) | type: 1 = risky trials; 2 = ambiguous trials


warning('add difference line also here');

if sum(DRAW == 1);
    
    figure('Name', 'F1: single subject per timepoint and variance', 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 1 1]);
    for sub = PART;
        
            x = squeeze(nanmean(PARAM.premiums.ce(:,:,:,sub),1)); % over time
            y = squeeze(nanmean(PARAM.premiums.ce(:,:,:,sub),2)); % over variance

        % plot single subjects over variance
        subplot(5,8,sub);
        plot( y, 'LineWidth', 2 ); hold on; box off;
        plot( ones(1,VAR_NR)*EV, '--k', 'LineWidth', 2 );
        % legend('R', 'A', 'N', 'Location', 'westoutside');
        axis([1 VAR_NR 0 1]); axis('auto y');
        xlabel(['sub ' num2str(sub) ': variance']);
        
    end
    
    clear x y sub;
    
end

%% FIGURE 2: COMPARISON OF RESOLVED / UNRESOLVED GROUPS

% 4D matrix of premium paramters:
% (var,repeat,type,sub) | type: 1 = risky trials; 2 = ambiguous trials

if sum(DRAW == 2);
    
    % setup for figure 2
    axis_scale = [.5 3.5 10 25]; % scale fot axis
    
    % open figure
    figure('Name', 'F2: mean over time for variance levels between groups', 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 .5 1]);
    
    % plot for both groups independend of "GROUPS" setting (control left, resolved right)
    for group = 1;
        
        data = nanmean(PARAM.premiums.ce(:,:,:,:), 1);
        
        % plot mean preference over time
        x = squeeze( nanmean( data,4 ) ); % calulate mean over subs
        x_se = squeeze( nanstd( data,1,4 )./(size(PART,2))^.5); % calculate se
        
        subplot(2,1,group);
        plot( x, 'LineWidth', 3 ); box off; hold on;
        errorbar(x, x_se);
        plot( ones(1,REPEATS_NR)*EV, '--k' , 'LineWidth', 2 );
        axis(axis_scale); legend('R', 'A'); xlabel('time');

            title('over time');
        
        % plot mean preference over time for each variance level
        for varlevel = 1:VAR_NR;
            
                data = nanmean(PARAM.premiums.ce(varlevel,:,:,:), 1);
                subplot(2, VAR_NR ,VAR_NR+varlevel);

            
            x = squeeze( nanmean( data,4 ) ); % calulate mean over subs
            x_se = squeeze( nanstd( data,1,4 )./(size(PART,2))^.5 ); % calculate se
            
            plot( x, 'LineWidth', 3 ); box off; hold on;
            errorbar(x, x_se);
            plot( ones(1,REPEATS_NR)*EV, '--k' , 'LineWidth', 2 );
            axis(axis_scale); legend('R', 'A'); xlabel('time');
            
                title(['control var: ' num2str(varlevel)]);
            
        end
  
    end
    
    clear group data x x_se varlevel axis_scale;
    
end

%% FIGURE 3: COMPOSITE GROUP SUMMARY

% 4D matrix of premium paramters:
% (var,repeat,type,sub) | type: 1 = risky trials; 2 = ambiguous trials

if sum(DRAW == 3);
    
    % scale axis
    axis_scale = [1 2 10 25];
    
    % open figure
    figure('Name', 'F3: group summary', 'Color', 'w', 'units', 'normalized', 'outerposition', [0 .5 .7 .5]);
    
    % prepare data to plot
    data = PARAM.premiums.ce(:,:,:,PART);
    
    % data for all subjects
    data_persub = nanmean(mean(data, 1),2);
    x = squeeze(data_persub); % x(1,:) = risk; x(2,:) = ambiguity
    
    % mean data of all repeats (var, risk/ambi, sub)
    data_allrep = nanmean(data, 2);
    y = squeeze(data_allrep);
    
    % difference ambiguity minus risk over all repeats
    z = y(:,2,:) - y(:,1,:);
    
    % --- PANEL 1: overall preference for risk / ambiguity
    subplot(1,4,1);
    h = barwitherr(nanstd(x, 1, 2)./(size(PART,2))^.5, nanmean(x, 2)); hold on; box off;
    plot( [EV EV], '--k' , 'LineWidth', 2 );
    axis(axis_scale); axis('auto x'); ylabel('subjective value');
    set(gca, 'xtick',[1 2] ); set(gca, 'xticklabels', {'risk','ambiguity'} );
    set(h(1), 'FaceColor', [.5 .5 .5]);
    
    % --- PANLEL 2: overall correlation of risk & ambiguity
    subplot(1,4,2);
    scatter(x(1,:), x(2,:));
    h = lsline; set(h, 'LineWidth', 2); hold on;
    scatter(x(1,:), x(2,:), 'k', 'MarkerFaceColor', 'k' );
    xlabel('SV risk'); ylabel('SV ambiguity');
 
    % --- PANEL 3: preference for different variance levels
    subplot(1,4,3);
    switch BAR_LINE
        case 'line';
            h = errorbar(nanmean(y, 3), nanstd(y, 1, 3)./(size(PART,2))^.5, 'LineWidth', 2); hold on; box off;
            set(h(1), 'Color', [.0 .0 .8]); set(h(2), 'Color', [.8 .0 .0]);
        case 'bar';
            h = barwitherr(nanstd(y, 1, 3)./(size(PART,2))^.5, nanmean(y, 3)); hold on; box off;
            set(h(1), 'FaceColor', [.0 .0 .8]); set(h(2), 'FaceColor', [.8 .0 .0]);
    end
    plot( ones(1,VAR_NR)*EV, '--k' , 'LineWidth', 2 );
    axis(axis_scale); axis('auto x'); ylabel('subjective value');
    legend('risk', 'ambiguity');
    set(gca, 'xtick', 1:5 );
    xlabel('variance');
    
    % --- PANEL 4: individual within subject preference difference
    subplot(1,4,4);
    switch BAR_LINE
        case 'line';
            h = errorbar(nanmean(z, 3), nanstd(z, 1, 3)./(size(PART,2))^.5, 'LineWidth', 2); hold on; box off;
            set(h, 'Color', [.4 .4 .4]);
        case 'bar';
            h = barwitherr(nanstd(z, 1, 3)./(size(PART,2))^.5, nanmean(z, 3)); hold on; box off;
            set(h(1), 'FaceColor', [.4 .4 .4]);
    end
    plot( zeros(1,VAR_NR), '--k' , 'LineWidth', 2 );
    axis([1 2 -8 2]); axis('auto x'); ylabel('SV: ambiguity - risk');
    legend('difference', 'neutral'); set(gca, 'xtick', 1:5 ); xlabel('variance');

    %%% EXTRA FIGURE 3.1: correlation over all variance levels
    figure('Name', 'F3.1: correlation for different variance levels', 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 .6 .4]);
    for varlevel = 1:VAR_NR;
        % reselect data for ceratin variance level only
        data_persub = nanmean(nanmean(data(varlevel,:,:,:), 1),2);
        x = squeeze(data_persub);
        % plot
        subplot(1,VAR_NR,varlevel);
        scatter(x(1,:), x(2,:));
        h = lsline; set(h, 'LineWidth', 2); hold on;
        scatter(x(1,:), x(2,:), 'k', 'MarkerFaceColor', 'k' );
        xlabel('SV risk'); ylabel('SV ambiguity');
    end

    clear data data_persub data_allrep x y z varlevel axis_scale h;
    
end

%% FIGURE 4: ANALYSIS OF RTs

% 4D matrix of RT paramters:
% (var,repeat,type,sub) | type: 1 = risky trials; 2 = ambiguous trials

if sum(DRAW == 4);
    
    % scale axis
    axis_scale = [1 2 1.5 3];
    
    % open figure
    figure('Name', 'F4: RT analysis', 'Color', 'w', 'units', 'normalized', 'outerposition', [0 .5 .5 .5]);
    
    % prepare data to plot
    data = PARAM.RT.mean(:,:,:,PART);
    data_allrep = nanmean(data,2); % mean of all repeats
    x = squeeze(data_allrep); % x(1,:) = risk; x(2,:) = ambiguity
    
    data = PARAM.RT.prob(:,:,:,PART);
    data_allrep = nanmean(data,2); % mean of all repeats
    y = squeeze(data_allrep); % x(1,:) = risk; x(2,:) = ambiguity
    
    data = PARAM.RT.fixed(:,:,:,PART);
    data_allrep = nanmean(data,2); % mean of all repeats
    z = squeeze(data_allrep); % x(1,:) = risk; x(2,:) = ambiguity
    
    % --- PANLEL 1: mean RT between groups over variance
    subplot(1,3,1);
    switch BAR_LINE
        case 'line';
            h = errorbar(nanmean(x, 3), nanstd(x, 1, 3)./(size(PART,2))^.5, 'LineWidth', 2); hold on; box off;
            set(h(1), 'Color', [.0 .0 .8]); set(h(2), 'Color', [.8 .0 .0]);
        case 'bar';
            h = barwitherr(nanstd(x, 1, 3)./(size(PART,2))^.5, nanmean(x, 3)); hold on; box off;
            set(h(1), 'FaceColor', [.0 .0 .8]); set(h(2), 'FaceColor', [.8 .0 .0]);
    end
    axis(axis_scale); axis('auto x'); ylabel('reaction time');
    legend('risk', 'ambiguity'); set(gca, 'xtick', 1:5 );
    xlabel('variance'); title('all trials');
    
    % --- PANLEL 2: probabilistic choices only: mean RT between groups over variance
    subplot(1,3,2);
    switch BAR_LINE
        case 'line';
            h = errorbar(nanmean(y, 3), nanstd(y, 1, 3)./(size(PART,2))^.5, 'LineWidth', 2); hold on; box off;
            set(h(1), 'Color', [.0 .0 .8]); set(h(2), 'Color', [.8 .0 .0]);
        case 'bar';
            h = barwitherr(nanstd(y, 1, 3)./(size(PART,2))^.5, nanmean(y, 3)); hold on; box off;
            set(h(1), 'FaceColor', [.0 .0 .8]); set(h(2), 'FaceColor', [.8 .0 .0]);
    end
    axis(axis_scale); axis('auto x'); ylabel('reaction time');
    legend('risk', 'ambiguity'); set(gca, 'xtick', 1:5 );
    xlabel('variance'); title('probabilistic choices');
    
    % --- PANLEL 3: fixed choices only: mean RT between groups over variance
    subplot(1,3,3);
    switch BAR_LINE
        case 'line';
            h = errorbar(nanmean(z, 3), nanstd(z, 1, 3)./(size(PART,2))^.5, 'LineWidth', 2); hold on; box off;
            set(h(1), 'Color', [.0 .0 .8]); set(h(2), 'Color', [.8 .0 .0]);
        case 'bar';
            h = barwitherr(nanstd(z, 1, 3)./(size(PART,2))^.5, nanmean(z, 3)); hold on; box off;
            set(h(1), 'FaceColor', [.0 .0 .8]); set(h(2), 'FaceColor', [.8 .0 .0]);
    end
    axis(axis_scale); axis('auto x'); ylabel('reaction time');legend('risk', 'ambiguity'); set(gca, 'xtick', 1:5 );
    xlabel('variance'); title('save choices');

    clear axis_scale h data data_allrep x y z;
    
end

