function [ ] = wrapper_experiment_2( sub_nr )
% wrapper function to be called from mother pc to control the experiment
% this code is used for behavioral experiment 2(!)
% on clients.
% dependencies: presentation.m, stimuli.m, mean_variance.m, draw_stims.m,
% create_reward_file.m
% this function should be started remotely and sets basic settings to
% control the presentation.m function (see this file for further details)

%% SETTINGS

% if activated this reduces the trial number to training lenghts in all sessions for testing purposes
SETTINGS.TEST_FLAG = 0; 
% if activated button mappings for linux (not windows, as default) are used
SETTINGS.LINUX_MODE = 0; 

%%% fixed settings
TARGET_PATH = 'N:\client_write\SFW_ambiguity\results'; % copies to a windows machine
PARTICIPANT_NR = sub_nr;

%% PREPARE AND CONFRIM

% prepare file structure and save file
home = pwd;
savedir = fullfile(home, 'logfiles');
if exist(savedir, 'dir') ~= 7; mkdir(savedir); end % create savedir if it doesn't exist
save_file_0 = fullfile(savedir, [ 'exp_2_part_' sprintf('%03d', PARTICIPANT_NR) '_sess_' num2str(0) '.mat'] ); % training save
save_file_1 = fullfile(savedir, [ 'exp_2_part_' sprintf('%03d', PARTICIPANT_NR) '_sess_' num2str(1) '.mat'] );
save_file_2 = fullfile(savedir, [ 'exp_2_part_' sprintf('%03d', PARTICIPANT_NR) '_sess_' num2str(2) '.mat'] );
if exist(save_file_1, 'file')==2 || exist(save_file_2, 'file')==2; % check if savefiles exist
    display(' '); display('a logfile for this subjects already exists! do you want to overwrite?');
    overwrite = input('enter = no / ''yes'' = yes : ');
    if strcmp(overwrite, 'yes');
        display(' '); display('will continue and overwrite...');
    else
        error('security shutdown initiated! - check logfiles or choose annother participant number or session!');
    end
end
delete(fullfile(savedir, '*'));
clear overwrite;

% security check for settings
disp(' '); disp('SETTINGS ARE:'); disp(' ');
disp(SETTINGS);
disp(['participant number: ' num2str(PARTICIPANT_NR)]);  disp(' ');
disp(' '); disp('PRESS ENTER TO CONTINUE...'); pause;

% create replicable randomization
randomisation = RandStream('mt19937ar', 'Seed', PARTICIPANT_NR);
RandStream.setGlobalStream(randomisation);
clear randomisation;

%% START PRESENTATION SESSIONS

% PRESENT TRAINING
presentation(0, 0, save_file_0, SETTINGS); % session, ambiguity, save destination

% WAIT TOGETHER FOT SESSION 1 (press F)

% PRESENT SESSION 1
presentation(1, save_file_1, SETTINGS); % session, ambiguity, save destination

% WAIT TOGETHER FOT SESSION 2 (press G)

% PRESENT SESSION 2
presentation(2, save_file_2, SETTINGS); % session, ambiguity, save destination

%% FINISH AND COPY LOGFILES

fprintf('\nthe experiment is finished, please wait for files to by copied...');
mkdir(TARGET_PATH);
copyfile(fullfile(savedir, '*'), fullfile(TARGET_PATH));
disp('done.'); disp(' ');

% create reward file
disp('selecting random trial for reward...');
% run function to create and copy the reward info txt
create_reward_file(savedir, save_file_1, save_file_2, TARGET_PATH, PARTICIPANT_NR);
disp(' ');
disp('THANK YOU, THE EXPERIMENT IS FINISHED NOW!');

%% end function
end
