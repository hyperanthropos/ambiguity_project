function [ ] = draw_stims( window, screen_resolution, probability, risk_low, risk_high, ambiguity_low, ambiguity_high, counteroffer, typus, position, response, ambiguity_resolve, resolve )
% function to draw the stimuli on the screen with Psychtoolbox
% typus: 1 = risky; 2 ambiguous;
% position: 1 = counteroffer left; 2 = counteroffer right;
% response: 0 = before response; 1 = left; 2 = right;

%% START STIMULUS CREATION

% set colors used
color_scheme = 1;
switch color_scheme
    case 1
        color1 = [244, 244, 244]; % light gray              for fixed offers
        color2 = [150, 150, 150]; % dark gray               for probabilistic / ambiguous offers
        color3 = [244, 244, 244]; % light gray              for probability numbers text
        problinecolor = [244, 244, 244]; % light gray       for probability line
    case 2
        color1 = ones(1,3)*180; % dark gray                 for fixed offers backgorund
        color2 = ones(1,3)*244; % light gray                for probabilistic / ambiguous offers background
        color3 = ones(1,3)*90; % very dark gray             for probability numbers text
        problinecolor = 0; % black                          for probability line
end

% use Swiss Francs abbreviation "Fr."
use_abbreviation = 1; % 1 = use; 2 = do not use
switch use_abbreviation
    case 1
        abbrev_add = ' Fr.';
    case 0
        abbrev_add = [];
end    

% define positions for text (left)
POSITION.upper =    [-215, -230];
POSITION.high =     [-215, -160];
POSITION.mid =      [-215, 0];
POSITION.low =      [-215, 160];
POSITION.under =    [-215, 230];

% define nested function to draw text
    screenres = screen_resolution/2;

    function [ ] = draw_text( coords, side )
        
        % some text functions do not work correctly after screen translation
        % setting screen back to default and later back to origin again
        Screen('glTranslate', window, -screenres(1), -screenres(2), 0);

        offset = Screen(window, 'TextBounds', disp_text)/2;
 
        if strcmp(disp_text(end), '%'); % user a different color for % values
            textcolor = color3;
        else
            textcolor = 0;
        end
        
        if strcmp(side, 'left')
            Screen(window, 'DrawText', disp_text, screenres(1)+coords(1)-offset(3), screenres(2)+coords(2)-offset(4), textcolor);
            % same outcomem preserved to use in case of compatibility issues
            % DrawFormattedText(window, disp_text, screenres(1)+coords(1)-offset(3), screenres(2)+coords(2)+offset(4), textcolor);
        elseif strcmp(side, 'right')
            Screen(window, 'DrawText', disp_text, screenres(1)+coords(1)*-1-offset(3), screenres(2)+coords(2)-offset(4), textcolor);
            % same outcomem preserved to use in case of compatibility issues
            % DrawFormattedText(window, disp_text, screenres(1)+coords(1)-offset(3), screenres(2)+coords(2)+offset(4), textcolor);
        end
        
        % going back to origin
        Screen('glTranslate', window, screenres(1), screenres(2), 0);
       
    end

%% (0) DRAW THE BASE TRIAL STRUCTURE

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

%% (1) DRAW SPECIFIC TRIAL

% convert probability into coordinates (between -200 & 200)
prob_coordspace = linspace(200, -200, 100+1);
prob_coord = prob_coordspace(probability*100+1);

% define areas to color
rect = [ -130-2, 200-2, -300+1, -200+1; 300-2, 200-2, 130+1, -200+1]; % rects to fill with color

% draw the trial
switch position
    case 1 % counteroffer left
        % color the boxes
        rect_c = [color1; color2]; % colors
        Screen(window, 'FillRect', rect_c', rect');
        % display counteroffer
        disp_text = [ sprintf('%.1f', counteroffer) abbrev_add ];
        draw_text(POSITION.mid, 'left');
        
        side = 'right';
        
    case 2 % counteroffer right
        % color the boxes
        rect_c = [color2; color1]; % colors
        Screen(window, 'FillRect', rect_c', rect');
        % display counteroffer
        disp_text = [ sprintf('%.1f', counteroffer) abbrev_add ];
        draw_text(POSITION.mid, 'right')
        
        side = 'left';
        
end

switch typus
    case 1 % riky trial
        % display risk value of probability
        disp_text = [ sprintf('%.1f', risk_high) abbrev_add ];
        draw_text(POSITION.under, side);
        % display risk value of inverse probability
        disp_text = [ sprintf('%.1f', risk_low) abbrev_add ];
        draw_text(POSITION.upper, side);
        % add probability line
        if position == 1; % counteroffer left
            Screen('DrawLine', window, problinecolor, 300-2, prob_coord, 130+1, prob_coord, 5); % probability line right
        elseif position == 2; % counteroffer right
            Screen('DrawLine', window, problinecolor, -300+1, prob_coord, -130-2, prob_coord, 5); % probability line left
        end
        
    case 2 % ambiguous trial
        % display high ambiguity
        disp_text = [ sprintf('%.1f', ambiguity_high) abbrev_add ];
        draw_text(POSITION.under, side);
        % display low ambiguity
        disp_text = [ sprintf('%.1f', ambiguity_low) abbrev_add ];
        draw_text(POSITION.upper, side);
        if resolve ~= 1; % display ambiguity marker only before choice
            disp_text = '???';
            draw_text(POSITION.mid, side);
        end
        
end

%% (2) DRAW THE RESPONSE INDICATION

if response ~= 0;
    
    switch response
        case 1 % draw response left
            if position == 1 % counteroffer left
                % tiny borders
                Screen('DrawLine', window, [0 128 0], -320-3, 220, -110+2, 220, 5);
                Screen('DrawLine', window, [0 128 0], -320, 220, -320, -220, 5);
                Screen('DrawLine', window, [0 128 0], -110+2, -220, -320-3, -220, 5);
                Screen('DrawLine', window, [0 128 0], -110, -220, -110, 220, 5);
            elseif position == 2 % counteroffer right
                % larger borders
                Screen('DrawLine', window, [0 128 0], -320-3, 257, -110+2, 257, 5);
                Screen('DrawLine', window, [0 128 0], -320, 257, -320, -257, 5);
                Screen('DrawLine', window, [0 128 0], -110+2, -257, -320-3, -257, 5);
                Screen('DrawLine', window, [0 128 0], -110, -257, -110, 257, 5);
            end

        case 2 % draw response right
            if position == 2 % counteroffer right
                % tiny borders
                Screen('DrawLine', window, [0 128 0], 320+2, 220, 110-3, 220, 5);
                Screen('DrawLine', window, [0 128 0], 320, 220, 320, -220, 5);
                Screen('DrawLine', window, [0 128 0], 110-3, -220, 320+2, -220, 5);
                Screen('DrawLine', window, [0 128 0], 110, -220, 110, 220, 5);
            elseif position == 1 % counteroffer left
                % larger borders
                Screen('DrawLine', window, [0 128 0], 320+2, 257, 110-3, 257, 5);
                Screen('DrawLine', window, [0 128 0], 320, 257, 320, -257, 5);
                Screen('DrawLine', window, [0 128 0], 110-3, -257, 320+2, -257, 5);
                Screen('DrawLine', window, [0 128 0], 110, -257, 110, 257, 5);
            end     
    end
    
    % recolor fixation cross (back to normal)
    Screen('DrawLine', window, 0, -10, 0, 10, 0, 5);
    Screen('DrawLine', window, 0, 0, -10, 0, 10, 5);
    
end

%% (3) REVEAL AMBIGUITY

if resolve == 1;
    
    % set where content will be revealed
    if position == 1; % counteroffer left
        side = 'right';
    elseif position == 2; % counteroffer right
        side = 'left';
    end
    
    % draw the revelation
    if typus == 1 || ambiguity_resolve == 1 % if risky trial or resolved ambiguous trial
        
        % display probabilities in %
        disp_text = [num2str(probability*100) '%'];
        draw_text(POSITION.low, side);
        % display risk value of inverse probability
        disp_text = [num2str(100-probability*100) '%'];
        draw_text(POSITION.high, side);
        
        % add probability line
        if position == 1; % counteroffer left
            Screen('DrawLine', window, problinecolor, 300-2, prob_coord, 130+1, prob_coord, 5); % probability line
        elseif position == 2; % counteroffer right
            Screen('DrawLine', window, problinecolor, -300+1, prob_coord, -130-2, prob_coord, 5);  % probability line
        end
        
    elseif typus == 2 && ambiguity_resolve == 0 % if unresolved ambiguous trial
        
        % display unkwon probabilities in (pseudo) %
        disp_text = '??%';
        draw_text(POSITION.low, side);
        draw_text(POSITION.high, side);
        
    else
        
        error('this should not happen');
        
    end
    
end

% BRING ON THE SCREEN
Screen(window, 'Flip');

%% END FUNCTION
end
