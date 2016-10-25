%% SCRIPT TO ANALYSE PARAMTERS
% this script analyses parameters on the group level, creates figures and
% runs statistical tests
% reads data from parameter_creation script

% clean the field
clear; close all; clc;

%% SETUP

% set figures you want to draw
% 01 | INDIVIDUAL SUBJECTS RISK AND AMBIGUITY ATTITUDE
DRAW = [1 2 3 4];

% set subjects to analyse
PART{1} = 1:23; % subjects where ambiguity was not resolved
PART{2} = 1:21; % subjects where ambiguity was resolved

% set group to analyze
GROUP = 2; % 1 = ambiguity not resolved; 2 = ambiguity resolved

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
    
    figure('Name', 'single subject per timepoint and variance', 'Color', 'w', 'units', 'normalized', 'outerposition', [0 0 1 1]);
    for sub = PART{GROUP};
        
        if GROUP == 1;
            x = squeeze(mean(PARAM.premiums.ce.control(:,:,:,sub),1)); % over time
            y = squeeze(mean(PARAM.premiums.ce.control(:,:,:,sub),2)); % over variance
        elseif GROUP == 2;
            x = squeeze(mean(PARAM.premiums.ce.resolved(:,:,:,sub),2)); % over time
            y = squeeze(mean(PARAM.premiums.ce.resolved(:,:,:,sub),2)); % over variance
        end
        
        subplot(10,5,sub);
        plot( x, 'LineWidth', 2 ); hold on; box off;
        plot( ones(1,VAR_NR)*EV, 'k', 'LineWidth', 2 );
        legend('R', 'A', 'N', 'Location', 'westoutside');
        axis([1 VAR_NR 0 1]); axis('auto y');
        xlabel('time');
        
        subplot(10,5,sub+25);
        plot( y, 'LineWidth', 2 ); hold on; box off;
        plot( ones(1,VAR_NR)*EV, 'k', 'LineWidth', 2 );
        legend('R', 'A', 'N', 'Location', 'westoutside');
        axis([1 VAR_NR 0 1]); axis('auto y');
        xlabel('variance');
        
    end
    
    clear x y sub;
    
end

%% OTHER HACKED IN STUFF

% % variance_levels to analyse
% varanal = [1 2 3 4];

% % % axis_scale_1 = [.5 4.5 10 22];
% % % axis_scale_2 = [.5 4.5 10 22];
% % % 
% % % figure('Color', 'w');
% % % for sub = PART{1};
% % %     subplot(10,5,sub);
% % %     plot( squeeze( sum(PARAM.premiums.ce.control(varanal,:,:,sub),1)./size(varanal,2) ), 'LineWidth', 2 ); hold on; box off;
% % %     plot( [20, 20, 20, 20], '--k' );
% % %     axis(axis_scale_1);
% % %     %legend('R', 'A', 'R-A');
% % % end
% % % 
% % % for sub = PART{2};
% % %     subplot(10,5,sub+25);
% % %     plot( squeeze( sum(PARAM.premiums.ce.resolved(varanal,:,:,sub),1)./size(varanal,2) ), 'LineWidth', 2 ); hold on; box off;
% % %     plot( [20, 20, 20, 20], '--k' );
% % %     axis(axis_scale_1);
% % %     %legend('R', 'A', 'R-A');
% % % end
% % % 
% % % figure('Name', ' ','Color', 'w');
% % % 
% % % data = sum(PARAM.premiums.ce.control(varanal,:,:,:), 1)./size(varanal,2);
% % % %data = data-repmat(data(:,1,1,:), 1, REPEATS_NR, 2); % center all data to repeat 1 risk preference
% % % x = squeeze( sum( data,4 )./size(PART{1},2) );
% % % x_se = squeeze( std( data,1,4 )./(size(PART{1},2))^.5 );
% % % y = sum( data(:,:,1,:)-data(:,:,2,:), 4)./PART{1}(end);
% % % subplot(2,2,1);
% % % plot( x, 'LineWidth', 3 ); box off; hold on;
% % % errorbar(x, x_se);
% % % plot( [20 20 20 20], '--k' , 'LineWidth', 3 );
% % % axis(axis_scale_2);
% % % legend('R', 'A');
% % % title('control');
% % % 
% % % data = sum(PARAM.premiums.ce.resolved(varanal,:,:,:), 1)./size(varanal,2);
% % % %data = data-repmat(data(:,1,1,:), 1, REPEATS_NR, 2); % center all data to repeat 1 risk preference
% % % x = squeeze( sum( data,4 )./size(PART{2},2) );
% % % x_se = squeeze( std( data,1,4 )./(size(PART{2},2))^.5 );
% % % y = sum( data(:,:,1,:)-data(:,:,2,:), 4)./PART{2}(end);
% % % subplot(2,2,2);
% % % plot( x, 'LineWidth', 3 ); box off; hold on;
% % % errorbar(x, x_se);
% % % plot( [20 20 20 20], '--k' , 'LineWidth', 3 );
% % % axis(axis_scale_2);
% % % legend('R', 'A');
% % % title('resolved');
% % % 
% % % for varanal = 1:4;
% % %     
% % % data = sum(PARAM.premiums.ce.control(varanal,:,:,:), 1)./size(varanal,2);
% % % %data = data-repmat(data(:,1,1,:), 1, REPEATS_NR, 2); % center all data to repeat 1 risk preference
% % % x = squeeze( mean( data,4 ) );
% % % x_se = squeeze( std( data,1,4 )./(size(PART{1},2))^.5 );
% % % y = sum( data(:,:,1,:)-data(:,:,2,:), 4)./PART{1}(end);
% % % subplot(2,8,8+varanal);
% % % plot( x, 'LineWidth', 3 ); box off; hold on;
% % % errorbar(x, x_se);
% % % plot( [20 20 20 20], '--k' , 'LineWidth', 3 );
% % % axis(axis_scale_2);
% % % legend('R', 'A');
% % % title('control');
% % % 
% % % data = sum(PARAM.premiums.ce.resolved(varanal,:,:,:), 1)./size(varanal,2);
% % % %data = data-repmat(data(:,1,1,:), 1, REPEATS_NR, 2); % center all data to repeat 1 risk preference
% % % x = squeeze( sum( data,4 )./size(PART{2},2) );
% % % x_se = squeeze( std( data,1,4 )./(size(PART{2},2))^.5 );
% % % y = sum( data(:,:,1,:)-data(:,:,2,:), 4)./PART{2}(end);
% % % subplot(2,8,12+varanal);
% % % plot( x, 'LineWidth', 3 ); box off; hold on;
% % % errorbar(x, x_se);
% % % plot( [20 20 20 20], '--k' , 'LineWidth', 3 );
% % % axis(axis_scale_2);
% % % legend('R', 'A');
% % % title('resolved');
% % % 
% % % end

%% NEXT FIGURE CORRELATIONS

% % variance_levels to analyse
% varanal = [1 2 3 4];

% % % (var,repeat,type,sub)
% % addpath('/home/fridolin/DATA/MATLAB/downloaded_functions');
% % 
% % figure('Color', 'w');
% % 
% % axis_scale_1 = [.5 4.5 10 22];
% % 
% % data = PARAM.premiums.ce.resolved(:,:,:,PART{2});
% % % data = PARAM.premiums.ce.control(:,:,:,PART{1});
% % 
% % % overall preference risk / ambiguity
% % data_persub = mean(mean(data, 1),2);
% % X = squeeze(data_persub);
% % 
% % subplot(1,3,1);
% % barwitherr(std(X, 1, 2)./23^.5, mean(X, 2)); hold on; box off;
% % plot( [20 20], '--k' , 'LineWidth', 3 );
% % axis(axis_scale_1); axis('auto x');
% % 
% % % preference for variance levels
% % data_allrep = mean(data, 2);
% % X = squeeze(data_allrep);
% % 
% % subplot(1,3,3);
% % barwitherr(std(X, 1, 3)./23^.5, mean(X, 3)); hold on; box off;
% % plot( [20 20 20 20], '--k' , 'LineWidth', 3 );
% % axis(axis_scale_1); axis('auto x');
% % legend('risk', 'ambiguity');
% % 
% % % overall correlation risk / ambiguity
% % data_persub = mean(mean(data, 1),2);
% % X = squeeze(data_persub);
% % 
% % subplot(1,3,2);
% % scatter(X(1,:), X(2,:));
% % xlabel('risk'); ylabel('ambiguity');
% % lsline;
% % 
% % % % correlation over all variance levels
% % % for varlevel = 1:4;
% % %     
% % % data_persub = mean(mean(data(varlevel,:,:,:), 1),2);  
% % % X = squeeze(data_persub);
% % %     
% % % subplot(2,4,4+varlevel);
% % % scatter(X(1,:), X(2,:));
% % % xlabel('risk'); ylabel('ambiguity');
% % % lsline;
% % %     
% % % end

