%% SCRIPT TO ANALYSE PARAMTERS
% this script analyses parameters on the group level, creates figures and
% runs statistical tests

clear; close all; clc;

%% SETUP

% set subjects to analyse
PART{1} = 1:23; % subjects where ambiguity was not resolved
PART{2} = 1:21; % subjects where ambiguity was resolved

% design specification
REPEATS_NR = 4; % how many times was one cycle repeated

%% DATA HANDLING

% set directories
DIR.home = pwd;
DIR.input = fullfile(DIR.home, 'analysis_results');

% load data
load(fullfile(DIR.input, 'parameters.mat'), 'PARAM');

%% GROUPS ANALYSIS OF PARAMETERS

figure('Color', 'w');
for sub = PART{1};
    subplot(5,5,sub);
    plot( squeeze(PARAM.premiums.abs_gambles.control(:,:,:,sub)) ); hold on; box off;
    plot( (PARAM.premiums.abs_gambles.control(:,:,1,sub)-PARAM.premiums.abs_gambles.control(:,:,2,sub))', 'r' );
    %legend('R', 'A', 'R-A');
end

figure('Color', 'w');
for sub = PART{2};
    subplot(5,5,sub);
    plot( squeeze(PARAM.premiums.abs_gambles.resolved(:,:,:,sub)) ); hold on; box off;
    plot( (PARAM.premiums.abs_gambles.resolved(:,:,1,sub)-PARAM.premiums.abs_gambles.resolved(:,:,2,sub))', 'r' );
    %legend('R', 'A', 'R-A');
end

axis_scale_1 = [.5 4.5 -5 5];
axis_scale_2 = [.5 4.5 -5 5];

figure('Name', 'CONTROL','Color', 'w');
data = PARAM.premiums.abs_gambles.control;
data = data-repmat(data(:,1,:,:), 1, REPEATS_NR, 1);
x = squeeze( sum( data,4 )./PART{1}(end) );
y = sum( data(:,:,1,:)-data(:,:,2,:), 4)./PART{1}(end);
subplot(1,2,1);
plot( x, 'LineWidth', 3 ); box off;
axis(axis_scale_1);
legend('R', 'A');
subplot(1,2,2);
plot( y', 'r', 'LineWidth', 3  ); box off;
axis(axis_scale_2);
legend('R-A');

figure('Name', 'AMBIGUTIY RESOLVED', 'Color', 'w');
data = PARAM.premiums.abs_gambles.resolved;
data = data-repmat(data(:,1,:,:), 1, REPEATS_NR, 1);
x = squeeze( sum( data,4 )./PART{2}(end) );
y = sum( data(:,:,1,:)-data(:,:,1,:), 4)./PART{2}(end);
subplot(1,2,1);
plot( x, 'LineWidth', 3 ); box off;
axis(axis_scale_1);
legend('R', 'A');
subplot(1,2,2);
plot( y', 'r', 'LineWidth', 3  ); box off;
axis(axis_scale_2);
legend('R-A');


