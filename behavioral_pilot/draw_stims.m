function [ ] = draw_stims( window, probablity, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response, ambiguity_resolve, resolve )
% function to draw the stimuli on the screen with Psychtoolbox
% typus: 1 = risky; 2 ambiguous;
% position: 1 = counteroffer left; 2 = counteroffer right;
% response: 0 = before response; 1 = left; 2 = right;

%% START STIMULUS CREATION

color1 = [244, 244, 244]; % light gray              for probabilities
color2 = [150, 150, 150]; % dark gray               for probabilities
color3 = [197, 197, 197]; % inbetween gray          for fixed values
color4 = [256, 256, 256]; % white                   for ambiguity

%% (1) DRAW THE BASE TRIAL STRUCTURE

%%% BASIC STRUCTURE

% fixation cross
Screen('DrawLine', window, [0 128 0], -10, 0, 10, 0, 5);
Screen('DrawLine', window, [0 128 0], 0, -10, 0, 10, 5);

% bar lines - left box
Screen('DrawLine', window, 0, -300-3, 200, -130+2, 200, 5);
Screen('DrawLine', window, 0, -300, 200, -300, -200, 5);
Screen('DrawLine', window, 0, -130+2, -200, -300-3, -200, 5);
Screen('DrawLine', window, 0, -130, -200, -130, 200, 5);
% bar lines - right box
Screen('DrawLine', window, 0, 300+2, 200, 130-3, 200, 5);
Screen('DrawLine', window, 0, 300, 200, 300, -200, 5);
Screen('DrawLine', window, 0, 130-3, -200, 300+2, -200, 5);
Screen('DrawLine', window, 0, 130, -200, 130, 200, 5);

% draw markers at 20% intervals
markers = 0;
if markers == 1;
Screen('DrawLine', window, [0 0 0], -310, 200, -300, 200, 5);
Screen('DrawLine', window, [0 0 0], -310, 120, -300, 120, 5);
Screen('DrawLine', window, [0 0 0], -310, 40, -300, 40, 5);
Screen('DrawLine', window, [0 0 0], -310, -40, -300, -40, 5);
Screen('DrawLine', window, [0 0 0], -310, -120, -300, -120, 5);
Screen('DrawLine', window, [0 0 0], -310, -200, -300, -200, 5);

Screen('DrawLine', window, [0 0 0], -130, 200, -120, 200, 5);
Screen('DrawLine', window, [0 0 0], -130, 120, -120, 120, 5);
Screen('DrawLine', window, [0 0 0], -130, 40, -120, 40, 5);
Screen('DrawLine', window, [0 0 0], -130, -40, -120, -40, 5);
Screen('DrawLine', window, [0 0 0], -130, -120, -120, -120, 5);
Screen('DrawLine', window, [0 0 0], -130, -200, -120, -200, 5);

Screen('DrawLine', window, [0 0 0], 310, 200, 300, 200, 5);
Screen('DrawLine', window, [0 0 0], 310, 120, 300, 120, 5);
Screen('DrawLine', window, [0 0 0], 310, 40, 300, 40, 5);
Screen('DrawLine', window, [0 0 0], 310, -40, 300, -40, 5);
Screen('DrawLine', window, [0 0 0], 310, -120, 300, -120, 5);
Screen('DrawLine', window, [0 0 0], 310, -200, 300, -200, 5);

Screen('DrawLine', window, [0 0 0], 130, 200, 120, 200, 5);
Screen('DrawLine', window, [0 0 0], 130, 120, 120, 120, 5);
Screen('DrawLine', window, [0 0 0], 130, 40, 120, 40, 5);
Screen('DrawLine', window, [0 0 0], 130, -40, 120, -40, 5);
Screen('DrawLine', window, [0 0 0], 130, -120, 120, -120, 5);
Screen('DrawLine', window, [0 0 0], 130, -200, 120, -200, 5);
end

%%% DRAW SPECIFIC TRIAL

% convert probability into coordinates (between -200 & 200)
prob_coordspace = linspace(200, -200, 100+1);
prob_coord = prob_coordspace(probablity*100+1);

switch typus
    
    case 1 % riky trial
        
        switch position
            case 1 % counteroffer left
                                
                rect = [300-2, 200-2, 130+1, prob_coord; 300-2, prob_coord, 130+1, -200+1; -130-2, 200-2, -300+1, -200+1]; % rects to fill with color
                rect_c = [color2; color1; color3]; % colors
                Screen(window, 'FillRect', rect_c', rect'); 
                Screen('DrawLine', window, 0, 300, prob_coord, 130, prob_coord, 5); % probability line   
                
                % ---> insert values presentation              

            case 2 % counteroffer right
                
                rect = [-300+1, 200-2, -130-2, prob_coord; -300+1, prob_coord, -130-2, -200+1; 130+1, 200-2, 300-1, -200+1];  % rects to fill with color
                rect_c = [color2; color1; color3]; % colors
                Screen(window, 'FillRect', rect_c', rect'); 
                Screen('DrawLine', window, 0, -300, prob_coord, -130, prob_coord, 5);  % probability line
                
                % ---> insert values presentation
                
        end
        
    case 2 % ambiguous trial
        
        switch position
            case 1 % counteroffer left
                
                rect = [300-2, 200-2, 130+1, -200+1; -130-2, 200-2, -300+1, -200+1]; % rects to fill with color
                rect_c = [color4; color3]; % colors
                Screen(window, 'FillRect', rect_c', rect'); 
                
                % ---> insert values presentation    
                
            case 2 % counteroffer right
                
                rect = [-300+1, 200-2, -130-2, -200+1; 130+1, 200-2, 300-1, -200+1];  % rects to fill with color
                rect_c = [color4; color3]; % colors
                Screen(window, 'FillRect', rect_c', rect'); 
                
                % ---> insert values presentation    
                
        end
        
end

%% (2) DRAW THE RESPONSE INDICATION

if response ~= 0;
    
    switch response
        case 1 % draw response left
            
            Screen('DrawLine', window, [0 128 0], -320-3, 220, -110+2, 220, 5);
            Screen('DrawLine', window, [0 128 0], -320, 220, -320, -220, 5);
            Screen('DrawLine', window, [0 128 0], -110+2, -220, -320-3, -220, 5);
            Screen('DrawLine', window, [0 128 0], -110, -220, -110, 220, 5);
            
        case 2 % draw response right
            
            Screen('DrawLine', window, [0 128 0], 320+2, 220, 110-3, 220, 5);
            Screen('DrawLine', window, [0 128 0], 320, 220, 320, -220, 5);
            Screen('DrawLine', window, [0 128 0], 110-3, -220, 320+2, -220, 5);
            Screen('DrawLine', window, [0 128 0], 110, -220, 110, 220, 5);
            
    end
    
    % recolor fixation cross (back to normal)
    Screen('DrawLine', window, 0, -10, 0, 10, 0, 5);
    Screen('DrawLine', window, 0, 0, -10, 0, 10, 5);
    
end

%% (3) REVEAL AMBIGUITY
  
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

