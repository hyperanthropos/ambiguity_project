function [ ] = presentation_wrapper( sub_nr )
% wrapper function to be called from mother pc to control the experiment
% on clients.
% dependencies: presentation.m, stimuli.m, mean_variance.m, draw_stims.m
% this function should be started remotely and sets basic settings to
% control the presentation.m function (see this file for further details)

%% SETTINGS

% most important setting: is ambiguity going to be resolved?
AMBIGUITY = 1;

% if activated this reduces the trial number to training lenghts in all sessions for testing purposes
SETTINGS.TEST_FLAG = 1; 
% if activated button mappings for linux (not windows, as default) are used
SETTINGS.LINUX_MODE = 1; 

%%% fixed settings
TARGET_PATH = 'N:\client_write\SFW_ambiguity\results'; % copies to a windows machine
PARTICIPANT_NR = sub_nr;

%% PREPARE AND CONFRIM

% prepare file structure and save file
home = pwd;
savedir = fullfile(home, 'logfiles');
if exist(savedir, 'dir') ~= 7; mkdir(savedir); end % create savedir if it doesn't exist
save_file_0 = fullfile(savedir, [ 'part_' sprintf('%03d', PARTICIPANT_NR) '_sess_' num2str(0) '_ambiguity_' num2str(AMBIGUITY)  '.mat'] ); % training save
save_file_1 = fullfile(savedir, [ 'part_' sprintf('%03d', PARTICIPANT_NR) '_sess_' num2str(1) '_ambiguity_' num2str(AMBIGUITY)  '.mat'] );
save_file_2 = fullfile(savedir, [ 'part_' sprintf('%03d', PARTICIPANT_NR) '_sess_' num2str(2) '_ambiguity_' num2str(AMBIGUITY)  '.mat'] );
if exist(save_file_1, 'file')==2 || exist(save_file_2, 'file')==2; % check if savefiles exist
    display(' '); display('a logfile for this subjects already exists! do you want to overwrite?');
    overwrite = input('enter = no / ''yes'' = yes : ');
    if strcmp(overwrite, 'yes');
        display(' '); display('will continue and overwrite...');
        delete(fullfile(savedir, '*'));
    else
        error('security shutdown initiated! - check logfiles or choose annother participant number or session!');
    end
end
clear overwrite;

% security check for settings
disp(' '); disp('SETTINGS ARE:'); disp(' ');
disp(SETTINGS);
disp(['participant number: ' num2str(PARTICIPANT_NR)]);  disp(' ');
if AMBIGUITY == 1;
    disp('ambiguity resolved for this subject: YES');
else
    disp('ambiguity resolved for this subject: NO');
end
disp(' '); disp('PRESS ENTER TO CONTINUE...'); pause;

% create replicable randomization
randomisation = RandStream('mt19937ar', 'Seed', PARTICIPANT_NR + 10000*AMBIGUITY);
RandStream.setGlobalStream(randomisation);
clear randomisation;

%% START PRESENTATION SESSIONS

% PRESENT TRAINING
presentation(0, 0, save_file_0, SETTINGS); % session, ambiguity, save destination

% WAIT TOGETHER FOT SESSION 1 (press F)

% PRESENT SESSION 1
presentation(1, AMBIGUITY, save_file_1, SETTINGS); % session, ambiguity, save destination

% WAIT TOGETHER FOT SESSION 2 (press G)

% PRESENT SESSION 2
presentation(2, AMBIGUITY, save_file_2, SETTINGS); % session, ambiguity, save destination

%% FINISH AND COPY LOGFILES

fprintf('\nthe experiment is finished, please wait for files to by copied...');
mkdir(TARGET_PATH);
copyfile(fullfile(savedir, '*'), fullfile(TARGET_PATH));
disp('done.');
fprintf('\nselecting random trial for reward...');






warning('insert code');

% SOME OLD CODE TO ADAPT
% % transform logfile to rewardfile
% reward = S_LOG;
% reward(5,:) = reward(12,:);
% reward(2:6,:) = reward(1:5,:);
% reward(1,:) = 1:size(reward, 2);
% reward = reward(1:6,:);
% 
% diary(['logfiles/reward_' num2str(sprintf('%03d', VP_NR)) '_' num2str(VP_TIME)  '_' num2str(VP_SESSION) '.txt']);
% diary on;
% display([num2str(VP_NR) '_' num2str(VP_SESSION)]);
% display(reward);
% diary off;






disp(' done.'); disp(' ');
fprintf('THANK YOU, THE EXPERIMENT IS FINISHED NOW.');

%% end function
end
