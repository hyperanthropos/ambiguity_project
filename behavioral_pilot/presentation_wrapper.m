clear; close all; clc;

%% FETCH SETTINGS

participant_nr = 1;
ambiguity = 1;

%% PREPARE AND CONFRIM

% prepare file structure and save file
home = pwd;
savedir = fullfile(home, 'logfiles');
if exist(savedir, 'dir') ~= 7; mkdir(savedir); end % create savedir if it doesn't exist
save_file_1 = fullfile(savedir, [ 'part_' sprintf('%03d', participant_nr) '_sess_' num2str(1) '_ambiguity_' num2str(ambiguity)  '.mat'] );
save_file_2 = fullfile(savedir, [ 'part_' sprintf('%03d', participant_nr) '_sess_' num2str(2) '_ambiguity_' num2str(ambiguity)  '.mat'] );
if exist(save_file_1, 'file')==2 || exist(save_file_2, 'file')==2; % check if savefiles exist
    display(' '); display('a logfile for this subjects already exists! do you want to overwrite?');
    overwrite = input('enter = no / ''yes'' = yes : ');
    if strcmp(overwrite, 'yes');
        display(' '); display('will continue and overwrite...');
    else
        error('security shutdown initiated! - check logfiles or choose annother participant number or session!');
    end
end
clear overwrite;         

% security check for settings
disp(' '); disp('SETTINGS ARE:');
disp(['participant number: ' num2str(participant_nr)]);
if ambiguity == 1;
    disp('ambiguity resolved for this subject: YES');
else
    disp('ambiguity resolved for this subject: NO');
end
disp(' '); disp('PRESS ENTER TO CONTINUE...'); pause; 

% create replicable randomization 
randomisation = RandStream('mt19937ar', 'Seed', PARTICIPANT_NR + 1000*SESSION + 10000*AMBIGUITY);
RandStream.setGlobalStream(randomisation);
clear randomisation;

%% START PRESENTATION SESSIONS

% present session 1
presentation(1, ambiguity, save_file_1); % session, ambiguity, save destination

% present session 2
presentation(2, ambiguity, save_file_2); % session, ambiguity, save destination

%% FINISH AND COPY LOGFILES

disp(' '); disp('the experiment is finished, please wait for files to by copied...');

% copy files
% ---> insert code
