%% code to present the experiment
% dependencies: stimuli.m, mean_variance.m
clear; close all; clc;

%% SET PARAMETERS

session = 1;

%% CREATE STIMULI MATRIX

STIMS.reveal_amb = 0;                           % 1 = yes, 0 = no
STIMS.steps = 18;
STIMS.repeats = 3;
STIMS.diagnostic_graphs = 0;

[stim_mat, stim_nr] = stimuli(STIMS.reveal_amb, STIMS.steps, STIMS.repeats, STIMS.diagnostic_graphs);

%% PRESENT STIMULI

for i = 1:stim_nr;
    
    probablity = stim_mat(10,i)*100;
    risk_low = stim_mat(11,i);
    risk_high = stim_mat(12,i);
    ambiguity_low = stim_mat(13,i);
    ambiguity_high = stim_mat(14,i);
    counteroffer = stim_mat(15,i);
    
    if stim_mat(4,i) == 1; % risky trial
        
        disp(' ');
        disp([ num2str(counteroffer) ' CHF or ' num2str(probablity) '% chance of ' num2str(risk_high) ' CHF and ' num2str(100-probablity) '% chance of ' num2str(risk_low) 'CHF' ]);
        
    elseif stim_mat(4,i) == 2; % ambigious trial
        
        disp(' ');
        disp([ num2str(counteroffer) ' CHF or ' num2str(ambiguity_high) ' CHF ? ' num2str(ambiguity_low) 'CHF' ]);
        disp([ 'turns out to be: ' num2str(probablity) '% chance of ' num2str(ambiguity_high) ' CHF and ' num2str(100-probablity) '% chance of ' num2str(ambiguity_low) 'CHF' ])
        
    else
        error('problem with stimuli matrix specificaton');
    end
    
end