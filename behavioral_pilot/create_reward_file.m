function [ ] = create_reward_file( savedir, save_file_1, save_file_2, TARGET_PATH, PARTICIPANT_NR, AMBIGUITY )
% function to select a random trial and create a textfile to give to
% participants for outpayment transparency

%% SELECT TRIAL, CREATE AND COPY TEXT FILE

% select session and trial for outpayment
reward_session = randi(2);
if reward_session == 1;
    load(save_file_1, 'logrec'); 
elseif reward_session == 2;
    load(save_file_2, 'logrec'); 
end
reward_trial = randi(size(logrec, 2));

% start diary
diary_file = fullfile(savedir, [ 'reward_file_part_' sprintf('%03d', PARTICIPANT_NR) '_ambiguity_' num2str(AMBIGUITY) '.txt'] );
diary(diary_file);
diary on;

% print content
disp([ 'this is participant number: ' num2str(PARTICIPANT_NR) ]);
disp(' ');
disp('the following trial has been randomly selected:');
disp([ 'session: ' num2str(reward_session) ' | trial: ' num2str(reward_trial) ]);
disp(' ');
disp('you had to decide between:');
disp(' ');
disp([ num2str(logrec(16,reward_trial)) 'CHF for sure.' ]);
disp('OR');
if logrec(7,reward_trial) == 1; % risky trial
    disp([ num2str( logrec(10,reward_trial)*100 ) '% chance to get ' num2str( logrec(12,reward_trial) ) 'CHF and ' num2str( logrec(11,reward_trial)*100 ) '% chance to get ' num2str( logrec(13,reward_trial) ) 'CHF' ]);
elseif logrec(7,reward_trial) == 2; % ambiguous trial
    disp([ 'an ambiguous amount of either ' num2str( logrec(14,reward_trial) ) 'CHF or ' num2str(logrec(15,reward_trial)) 'CHF' ]);
end
disp(' ');
if logrec(5,reward_trial) == 1 || 3; % fixed amount
    disp([ 'you decided for the ' num2str(logrec(16,reward_trial)) 'CHF for sure.']);
elseif logrec(5,reward_trial) == 2; % risky amount
    disp('you decided for:');
    disp([ num2str( logrec(10,reward_trial)*100 ) '% chance to get ' num2str( logrec(12,reward_trial) ) 'CHF and ' num2str( logrec(11,reward_trial)*100 ) '% chance to get ' num2str( logrec(13,reward_trial) ) 'CHF' ]);
    disp(' ');
    disp('please roll a dice to determine what you will get');
elseif logrec(5,reward_trial) == 4; % ambiguous amount
    disp('you decided for:');
    disp([ 'an ambiguous amount of either ' num2str( logrec(14,reward_trial) ) 'CHF or ' num2str(logrec(15,reward_trial)) 'CHF' ]);
    disp('...which turns out to be:');
    disp([ num2str( logrec(10,reward_trial)*100 ) '% chance to get ' num2str( logrec(14,reward_trial) ) 'CHF and ' num2str( logrec(11,reward_trial)*100 ) '% chance to get ' num2str( logrec(15,reward_trial) ) 'CHF' ]);
    disp('please roll a dice to determine what you will get');
end

% finish diary & copy to mother pc
diary off;
copyfile(diary_file, TARGET_PATH);
% create an additional copy to be deleted after printed out in order to
% stay in control when results come in quickly in a row
if exist(fullfile(TARGET_PATH, 'delete'), 'dir') ~= 7; mkdir(fullfile(TARGET_PATH, 'delete')); end % create directory if it doesn't exist
copyfile(diary_file, fullfile(TARGET_PATH, 'delete'));

%% end function
end

