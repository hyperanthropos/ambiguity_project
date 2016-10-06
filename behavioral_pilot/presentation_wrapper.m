function [ ] = presentation_wrapper( sub_nr )
% wrapper function to be called from mother pc to control the experiment
% on clients

%% SETTINGS

% most important setting: is ambiguity going to be resolved?
AMBIGUITY = 1;

% if activated this reduces the trial number to training lenghts in all sessions for testing purposes
SETTINGS.TEST_FLAG = 1; 
% if activated button mappings for linux (not windows, as default) are used
SETTINGS.LINUX_MODE = 1; 

target_path = 'N:\client_write\SFW_ambiguity\results'; % copies to a windows machine
participant_nr = sub_nr;

%% PREPARE AND CONFRIM

% prepare file structure and save file
home = pwd;
savedir = fullfile(home, 'logfiles');
if exist(savedir, 'dir') ~= 7; mkdir(savedir); end % create savedir if it doesn't exist
save_file_0 = fullfile(savedir, [ 'part_' sprintf('%03d', participant_nr) '_sess_' num2str(0) '_ambiguity_' num2str(AMBIGUITY)  '.mat'] ); % training save
save_file_1 = fullfile(savedir, [ 'part_' sprintf('%03d', participant_nr) '_sess_' num2str(1) '_ambiguity_' num2str(AMBIGUITY)  '.mat'] );
save_file_2 = fullfile(savedir, [ 'part_' sprintf('%03d', participant_nr) '_sess_' num2str(2) '_ambiguity_' num2str(AMBIGUITY)  '.mat'] );
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
disp(' '); disp('SETTINGS ARE:');
disp(['participant number: ' num2str(participant_nr)]);
if AMBIGUITY == 1;
    disp('ambiguity resolved for this subject: YES');
else
    disp('ambiguity resolved for this subject: NO');
end
disp(' '); disp('PRESS ENTER TO CONTINUE...'); pause;

% create replicable randomization
randomisation = RandStream('mt19937ar', 'Seed', participant_nr + 10000*AMBIGUITY);
RandStream.setGlobalStream(randomisation);
clear randomisation;

%% START PRESENTATION SESSIONS

% present training session
% presentation(0, 0, save_file_0, SETTINGS); % session, ambiguity, save destination

% wait together for session 1 (press F)
fprintf('\nthank you, the training is now finished. please have a short break.');
continue_key = 70; % this is key 'F'
press = 0;
clear continue_key kb_keycode;

% present session 1
% presentation(1, AMBIGUITY, save_file_1, SETTINGS); % session, ambiguity, save destination

% wait together for session 2 (press G)
fprintf('\nthank you, half of the experiment is now finished. please have a short break.');
continue_key = 71; % this is key 'G'
press = 0;
clear continue_key kb_keycode;

% present session 2
% presentation(2, AMBIGUITY, save_file_2, SETTINGS); % session, ambiguity, save destination

%% FINISH AND COPY LOGFILES

fprintf('\nthe experiment is finished, please wait for files to by copied...');
mkdir(target_path);
copyfile(fullfile(savedir, '*'), fullfile(target_path));
disp('done.');
fprintf('\nselecting random trial for reward...');

warning('insert code');

disp(' done.');
fprintf('\nTHANK YOU, THE EXPERIMENT IS FINISHED NOW.');

%% end function
end
