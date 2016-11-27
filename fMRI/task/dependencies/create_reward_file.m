function [ ] = create_reward_file( PARTICIPANT_NR, savedir )
% function to select a random trials and create a textfile to give to
% participants for outpayment transparency

%% SELECT TRIAL, CREATE AND COPY TEXT FILE

nr_of_sessions = 3;

% start diary
diary_file = fullfile(savedir, [ 'reward_file_part_' sprintf('%03d', PARTICIPANT_NR) '.txt'] );
diary(diary_file);
diary on;

% print content
disp([ 'this is participant number: ' num2str(PARTICIPANT_NR) ]);
disp(' ');
disp('the following trials have been randomly selected:');
disp(' ');
disp('+++++ +++++ +++++ +++++ +++++ +++++ +++++ +++++ +++++ +++++ +++++ +++++ ');
disp(' ');

% print on trial per session
for session = 1:nr_of_sessions;
    
    reward_trial = randi(size(logrec, 2));
    load(fullfile(savedir, [ 'part_' sprintf('%03d', PARTICIPANT_NR) '_sess_' num2str(session) '.mat'] ));
    
    disp([ 'session: ' num2str(session) ' | trial: ' num2str(reward_trial) ]);
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
    if logrec(5,reward_trial) == 1 || logrec(5,reward_trial) == 3; % fixed amount
        disp([ 'you decided for the ' num2str(logrec(16,reward_trial)) 'CHF for sure.']);
    elseif logrec(5,reward_trial) == 2; % risky amount
        disp('you decided for:');
        disp([ num2str( logrec(10,reward_trial)*100 ) '% chance to get ' num2str( logrec(12,reward_trial) ) 'CHF and ' num2str( logrec(11,reward_trial)*100 ) '% chance to get ' num2str( logrec(13,reward_trial) ) 'CHF' ]);
        disp(' ');
        disp('please roll a dice to determine what you will get');
    elseif logrec(5,reward_trial) == 4; % ambiguous amount
        disp('you decided for:');
        disp([ 'an ambiguous amount of either ' num2str( logrec(14,reward_trial) ) 'CHF or ' num2str(logrec(15,reward_trial)) 'CHF' ]);
        disp(' ');
        disp('please roll a dice to determine what you will get');
    end
    disp(' ');
    disp('+++++ +++++ +++++ +++++ +++++ +++++ +++++ +++++ +++++ +++++ +++++ +++++ ');
    disp(' ');
    
end

% finish diary
diary off;

%% end function
end

