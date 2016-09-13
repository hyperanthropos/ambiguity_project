participant_nr = 1;
ambiguity = 1;

% security check for settings
disp(' '); disp('SETTINGS ARE:');
disp(['participant number: ' num2str(participant_nr)]);
if ambiguity == 1;
    disp('ambiguity resolved for this subject: YES');
else
    disp('ambiguity resolved for this subject: NO');
end
disp(' '); disp('PRESS ENTER TO CONTINUE...'); pause; 

% include security check for save files
% ---> insert code

% present session 1
presentation(participant_nr, 1, ambiguity);

% present session 2
presentation(participant_nr, 2, ambiguity);

% copy files
% ---> insert code
