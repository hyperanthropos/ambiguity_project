%% SCRIPT TO ANALYZE PILOT DATA
% this script creates parametes for further statistical analysis
% it needs logfiles created by the behavioral pilot presentation.m
% script

% unprocessed data is stored into two structures:
% RESULT_SEQ sorting trials as they were presented
% RESULT_SORT sorting trials according to their design stucture
% where ambiguity is coded as 1 for not resolved group and 2 for resolved group
% ambiguity was resolved for all session excpet the first in the ambiguity group

% the matrices within these structures are sorted according to this:
% LINE 01 - trial number
% LINE 02 - trial presentation time
% LINE 03 - reaction time
% LINE 04 - choice: 1 = fixed option; 2 = risky/ambiguous option
% LINE 05 - choice: 1 = fixed, risky; 2 = risky; 3 = fixed, ambiguous; 4 = ambiguous
% LINE 06 - choice: 1 = left, 2 = right
% LINE 07 - trial type: 1 = risky, 2 = ambiguous
% LINE 08 - ambiguity resolved: 1 = yes, 0 = no, 3 = does not apply (risky trial)
% LINE 09 - position of counteroffer: 1 = left, 2 = right
% LINE 10 - probability of high amount
% LINE 11 - probability of low amount
% LINE 12 - risky amount high
% LINE 13 - risky amount low
% LINE 14 - ambiguous amount high
% LINE 15 - ambiguous amount low
% LINE 16 - counteroffer amount

% LINE 17 - stimulus number (sorted)
% LINE 18 - number of repeat of the same variation of stimuli
% LINE 19 - risk variance level (1-4; low to high variance)
% LINE 20 - ambiguity variance level (1-4; low to high variance
% LINE 21 - counteroffer level (1-number of levels; low to high counteroffer)

%% SETUP
clear; close('all'); clc;

% set subjects to analyse
part_ambi = 1:21;        % subjects where ambiguity was resolved
part_control = 1:23;     % subjects where ambiguity was not resolved

% skip loading of individual files
skip_load = 1;

%% DATA HANDLING

% set directories
DIR.home = pwd;
DIR.input = fullfile(DIR.home, 'behavioral_results');
DIR.output = fullfile(DIR.home, 'analysis_results');
DIR.temp = fullfile(DIR.home, 'temp_data');

% load data
if skip_load ~= 1;
    
    % for both groups (0 = unresolved; 1 = resolved);
    for ambiguity = 0:1;
        
        if ambiguity == 0;
            partloop = part_control;
        elseif ambiguity == 1;
            partloop = part_ambi;
        end
        
        % run for every participant in the group
        for part = partloop;
            
            % combine 4 repeats of both sessions into one file
            temp_logrec_full = [];
            temp_logrec_sorted_full = [];
            for sess = 1:2;
                load_file = fullfile(DIR.input, [ 'part_' sprintf('%03d', part) '_sess_' num2str(sess) '_ambiguity_' num2str(ambiguity) '.mat'] );
                load(load_file, 'logrec', 'sorted_logrec');
                temp_logrec_full = cat(2, temp_logrec_full, logrec);
                temp_logrec_sorted_full = cat(2, temp_logrec_sorted_full, sorted_logrec);
            end
            
            % save participantns into a structure
            RESULT_SEQ.ambi{ambiguity+1}.part{part}.mat = temp_logrec_full;
            RESULT_SORT.ambi{ambiguity+1}.part{part}.mat = temp_logrec_sorted_full;
            
        end % end participant loop
    end % end group loop
    
    % create temp directory to save data structure and save
    if exist(DIR.temp, 'dir') ~= 7; mkdir(DIR.temp); end
    save(fullfile(DIR.temp, 'temp.mat'), 'RESULT_SEQ', 'RESULT_SORT');
    
    clear load_file part ambiguity sess partloop logrec sorted_logrec temp_logrec_full temp_logrec_sorted_full;
    
else
    
    % if data is already sorted into the structs it can be loaded here
    load(fullfile(DIR.temp, 'temp.mat'));
    
end
clear skip_load;

% create result directory if it doesn't exist
if exist(DIR.output, 'dir') ~= 7; mkdir(DIR.output); end

%% DATA PREPROCESSING

% sort risky and ambiguous trials


%% PARAMETER 1: CHOICES OF RISKY AND AMBIGUOUS TRIALS

A = RESULT_SORT.ambi{1}.part{1}.mat






