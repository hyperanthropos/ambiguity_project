function [ ] = draw_stims( window, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response, ambiguity_resolve, resolve )
% function to draw the stimuli on the screen with Psychtoolbox
% typus: 1 = risky; 2 ambiguous;
% position: 1 = counteroffer left; 2 = counteroffer right;
% response: 0 = before response; 1 = left; 2 = right;

%% START STIMULUS CREATION

%%% (1) DRAW THE BASE TRIAL STRUCTURE

% fixation cross
Screen('DrawLine', window, [0 128 0], -10, 0, 10, 0, 5);
Screen('DrawLine', window, [0 128 0], 0, -10, 0, 10, 5);

% bar lines
Screen('DrawLine', window, 0, -300, 200, -130, 200, 5);
Screen('DrawLine', window, 0, -300, 200, -300, -200, 5);
Screen('DrawLine', window, 0, -130, -200, -300, -200, 5);
Screen('DrawLine', window, 0, -130, -200, -130, 200, 5);

Screen('DrawLine', window, 0, 300, 200, 130, 200, 5);
Screen('DrawLine', window, 0, 300, 200, 300, -200, 5);
Screen('DrawLine', window, 0, 130, -200, 300, -200, 5);
Screen('DrawLine', window, 0, 130, -200, 130, 200, 5);

%%% DRAW SPECIFIC TRIAL

switch typus
    
    case 1 % riky trial
        
        switch position
            case 1 % counteroffer left
                % draw
            case 2 % counteroffer right
                % draw
        end
        
    case 2 % ambiguous trial
        
        switch position
            case 1 % counteroffer left
                % draw
            case 2 % counteroffer right
                % draw
        end
        
end

%%% (2) DRAW THE RESPONSE INDICATION

if response ~= 0;
    
    switch response
        case 1 % draw response left
            
            Screen('DrawLine', window, [0 128 0], -323, 220, -108, 220, 5);
            Screen('DrawLine', window, [0 128 0], -320, 220, -320, -220, 5);
            Screen('DrawLine', window, [0 128 0], -108, -220, -323, -220, 5);
            Screen('DrawLine', window, [0 128 0], -110, -220, -110, 220, 5);
            
        case 2 % draw response right
            
            Screen('DrawLine', window, [0 128 0], 322, 220, 107, 220, 5);
            Screen('DrawLine', window, [0 128 0], 320, 220, 320, -220, 5);
            Screen('DrawLine', window, [0 128 0], 107, -220, 322, -220, 5);
            Screen('DrawLine', window, [0 128 0], 110, -220, 110, 220, 5);
            
    end
    
    % recolor fixation cross (back to normal)
    Screen('DrawLine', window, 0, -10, 0, 10, 0, 5);
    Screen('DrawLine', window, 0, 0, -10, 0, 10, 5);
    
end

%%% (3) REVEAL AMBIGUITY
  
if resolve == 1;
    
    switch ambiguity_resolve
        case 0 % do not resolve (visual control)
            
            Screen('DrawLine', window, [0 128 50], 322, 150, 16, 100, 5);
            
            switch position
                case 1 % counteroffer left
                    % draw
                case 2 % counteroffer right
                    % draw
            end
                   
        case 1 % resolve ambiguity
            
            Screen('DrawLine', window, [98 128 0], 230, 55, 90, 200, 5);
     
            switch position
                case 1 % counteroffer left
                    % draw
                case 2 % counteroffer right
                    % draw
            end
            
    end
  
end

% BRING ON THE SCREEN
Screen(window, 'Flip');

