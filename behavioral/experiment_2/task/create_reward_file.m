function [ ] = create_reward_file( savedir, save_file, TARGET_PATH, PARTICIPANT_NR, run_nr )
% this code is used for behavioral experiment 2(!)
% function to select a random trial and create a textfile to give to
% participants for outpayment transparency

%% SELECT TRIAL, CREATE AND COPY TEXT FILE

% load log and select 2 (different) trials for outpayment
load(save_file, 'logrec');
reward_trial(1) = randi(size(logrec, 2));
reward_trial(2) = randi(size(logrec, 2));
while reward_trial(1) == reward_trial(2)
    reward_trial(2) = randi(size(logrec, 2));
end

% start diary
diary_file = fullfile(savedir, [ sprintf('%03d', run_nr) '_reward_file_part_' sprintf('%03d', PARTICIPANT_NR) '.txt' ] );
diary(diary_file);
diary on;

% print content
disp([ 'this is participant number: ' num2str(PARTICIPANT_NR) ]);
% select 2 trials to offer avarage outpayment after the experiment
for i = 1:2
    disp(' ');
    if i == 1;
        disp('the following trial has been randomly selected:');
    elseif i == 2;
        disp(' ');
        disp('----------------------------- OPTIONAL REWARD (AVERAGE OF 2) -----------------------------');
        disp(' ');
        disp('another trial has been randomly selected:');
    end
    disp([ 'trial: ' num2str(reward_trial(i)) ]);
    disp(' ');
    disp('you had to decide between:');
    disp(' ');
    disp([ num2str(logrec(16,reward_trial(i))) ' CHF for sure.' ]);
    disp('OR');
    if logrec(7,reward_trial(i)) == 1; % risky trial
        disp([ num2str( logrec(10,reward_trial(i))*100 ) '% chance to get ' num2str( logrec(12,reward_trial(i)) ) ' CHF and ' num2str( logrec(11,reward_trial(i))*100 ) '% chance to get ' num2str( logrec(13,reward_trial(i)) ) ' CHF' ]);
    elseif logrec(7,reward_trial(i)) == 2; % ambiguous trial
        disp([ 'an ambiguous amount of either ' num2str( logrec(14,reward_trial(i)) ) ' CHF or ' num2str(logrec(15,reward_trial(i))) ' CHF' ]);
    end
    disp(' ');
    if logrec(5,reward_trial(i)) == 1 || logrec(5,reward_trial(i)) == 3; % fixed amount
        disp([ 'you decided for the ' num2str(logrec(16,reward_trial(i))) ' CHF for sure.']);
    elseif logrec(5,reward_trial(i)) == 2; % risky amount
        disp('you decided for:');
        disp([ num2str( logrec(10,reward_trial(i))*100 ) '% chance to get ' num2str( logrec(12,reward_trial(i)) ) ' CHF and ' num2str( logrec(11,reward_trial(i))*100 ) '% chance to get ' num2str( logrec(13,reward_trial(i)) ) ' CHF' ]);
        disp(' ');
        disp('please roll a dice to determine what you will get');
    elseif logrec(5,reward_trial(i)) == 4; % ambiguous amount
        disp('you decided for:');
        disp([ 'an ambiguous amount of either ' num2str( logrec(14,reward_trial(i)) ) ' CHF or ' num2str(logrec(15,reward_trial(i))) ' CHF' ]);
        disp(' ');
        disp('please roll a dice to determine what you will get');
    end
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

