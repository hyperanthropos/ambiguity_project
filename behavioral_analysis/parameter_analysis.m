%% SCRIPT TO ANALYSE PARAMTERS
% this script analyses parameters on the group level, creates figures and
% runs statistical tests

clear; close all; clc;

%% SETUP

% set subjects to analyse
PART{1} = 1:23; % subjects where ambiguity was not resolved
PART{2} = 1:21; % subjects where ambiguity was resolved

% excluding subjects with extreme values
% PART{1} = [1:21 23]; % subjects where ambiguity was not resolved
% PART{2} = [1:3 5:10 12:21]; % subjects where ambiguity was resolved

% variance_levels to analyse
varanal = [1 2 3 4];

% VERY INTERESTING INTERACTION OF RISK / AMBIGUTIY IN VAR LEVEL 1 AND 4

% design specification
REPEATS_NR = 4; % how many times was one cycle repeated

%% DATA HANDLING

% set directories
DIR.home = pwd;
DIR.input = fullfile(DIR.home, 'analysis_results');

% load data
load(fullfile(DIR.input, 'parameters.mat'), 'PARAM');

%% GROUPS ANALYSIS OF PARAMETERS

% % % figure('Color', 'w');
% % % for sub = PART{1};
% % %     subplot(10,5,sub);
% % %     plot( squeeze(PARAM.premiums.abs_gambles.control(:,:,:,sub)) ); hold on; box off;
% % %     plot( (PARAM.premiums.abs_gambles.control(:,:,1,sub)-PARAM.premiums.abs_gambles.control(:,:,2,sub))', 'r' );
% % %     %legend('R', 'A', 'R-A');
% % % end
% % % 
% % % for sub = PART{2};
% % %     subplot(10,5,sub+25);
% % %     plot( squeeze(PARAM.premiums.abs_gambles.resolved(:,:,:,sub)) ); hold on; box off;
% % %     plot( (PARAM.premiums.abs_gambles.resolved(:,:,1,sub)-PARAM.premiums.abs_gambles.resolved(:,:,2,sub))', 'r' );
% % %     %legend('R', 'A', 'R-A');
% % % end
% % % 
% % % axis_scale_1 = [.5 4.5 -5 5];
% % % axis_scale_2 = [.5 4.5 -5 5];
% % % 
% % % figure('Name', ' ','Color', 'w');
% % % 
% % % data = PARAM.premiums.abs_gambles.control;
% % % data = data-repmat(data(:,1,1,:), 1, REPEATS_NR, 2); % center all data to repeat 1 risk preference
% % % x = squeeze( sum( data,4 )./PART{1}(end) );
% % % y = sum( data(:,:,1,:)-data(:,:,2,:), 4)./PART{1}(end);
% % % subplot(1,4,1);
% % % plot( x, 'LineWidth', 3 ); box off;
% % % axis(axis_scale_1);
% % % legend('R', 'A');
% % % subplot(1,4,2);
% % % plot( y', 'r', 'LineWidth', 3  ); box off;
% % % axis(axis_scale_2);
% % % legend('R-A');
% % % title('control');
% % % 
% % % data = PARAM.premiums.abs_gambles.resolved;
% % % data = data-repmat(data(:,1,1,:), 1, REPEATS_NR, 2); % center all data to repeat 1 risk preference
% % % x = squeeze( sum( data,4 )./PART{2}(end) );
% % % y = sum( data(:,:,1,:)-data(:,:,2,:), 4)./PART{2}(end);
% % % subplot(1,4,3);
% % % plot( x, 'LineWidth', 3 ); box off;
% % % axis(axis_scale_1);
% % % legend('R', 'A');
% % % subplot(1,4,4);
% % % plot( y', 'r', 'LineWidth', 3  ); box off;
% % % axis(axis_scale_2);
% % % legend('R-A');
% % % title('resolved');

%% OTHER HACKED IN STUFF

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

% (var,repeat,type,sub)
addpath('/home/fridolin/DATA/MATLAB/downloaded_functions');

figure('Color', 'w');

axis_scale_1 = [.5 4.5 10 22];

data = PARAM.premiums.ce.resolved;

% overall preference risk / ambiguity
data_persub = mean(mean(data, 1),2);
X = squeeze(data_persub);

subplot(1,3,1);
barwitherr(std(X, 1, 2)./23^.5, mean(X, 2)); hold on; box off;
plot( [20 20], '--k' , 'LineWidth', 3 );
axis(axis_scale_1); axis('auto x');

% preference for variance levels
data_allrep = mean(data, 2);
X = squeeze(data_allrep);

subplot(1,3,3);
barwitherr(std(X, 1, 3)./23^.5, mean(X, 3)); hold on; box off;
plot( [20 20 20 20], '--k' , 'LineWidth', 3 );
axis(axis_scale_1); axis('auto x');
legend('risk', 'ambiguity');

% overall correlation risk / ambiguity
data_persub = mean(mean(data, 1),2);
X = squeeze(data_persub);

subplot(1,3,2);
scatter(X(1,:), X(2,:));
xlabel('risk'); ylabel('ambiguity');
lsline;

% % correlation over all variance levels
% for varlevel = 1:4;
%     
% data_persub = mean(mean(data(varlevel,:,:,:), 1),2);  
% X = squeeze(data_persub);
%     
% subplot(2,4,4+varlevel);
% scatter(X(1,:), X(2,:));
% xlabel('risk'); ylabel('ambiguity');
% lsline;
%     
% end
















data_allrep = mean(data, 1);
mean(data,4)
std(data, 1, 4)

    


