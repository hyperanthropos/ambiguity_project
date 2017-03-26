function [ ] = draw_stims( window, screen_resolution, probability, risk_low, risk_high, ambiguity_low, ambiguity_high, position, response )
% function to draw the stimuli on the screen with Psychtoolbox
% this code is used for behavioral experiment 3(!)
% position: 1 = risky offer left; 2 = risky offer right;
% response: 0 = before response; 1 = left; 2 = right;

%% SETUP STIMULUS CREATION

% set colors used
color1 = ones(1,3)*180*255; % white                 for fixed offers
color2 = ones(1,3)*120; % dark gray                 for probabilistic offer part 1
color3 = ones(1,3)*200; % light gray                for probabilistic offer 2
color4 = (color2+color3)/2; % inbetween gray        for ambiguous offers
probtextcolor = [150 0 0]; % something red          for probability numbers text
problinecolor = [0 0 0]; % black                    for probability line

% chose color scheme: all "white"; "gray" for uncertain offers;
color_scheme = 'white';

% use Swiss Francs abbreviation "Fr."
use_abbreviation = 1; % 1 = use; 2 = do not use
switch use_abbreviation
    case 1
        abbrev_add = ' Fr.';
    case 0
        abbrev_add = [];
end

% display probabilities (in fact, with colors the probability is
% represented well without numbers too)
disp_prob = 1;

%% PREPARING TO DRAW

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
 
        if strcmp(disp_text(end), '%') || strcmp(disp_text(end), '?') && disp_prob == 1; % user a different color for % values
            textcolor = probtextcolor;
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

%% (1) DRAW SPECIFIC TRIAL

% convert probability into coordinates (between -200 & 200)
if isfinite(probability)
    prob_coordspace = linspace(200, -200, 100+1);
    index = uint8(probability*100+1); % confirm transformation to index is integer
    prob_coord = prob_coordspace(index);
else
    prob_coord = 0; % no probabilitly divider is shown
end

% define areas to color (upper left, lower left, upper right, lower right)
rect = [ -130-2, prob_coord, -300+1, -200+1; -130-2, 200-2, -300+1, prob_coord; 300-2, prob_coord, 130+1, -200+1; 300-2, 200-2, 130+1, prob_coord]; % rects to fill with color

% color the boxes
switch color_scheme
    case 'white' % no colors
        rect_c = [color1; color1; color1; color1];
    case 'gray' % gray tones for uncertain offers
        
        switch position
            case 1 % risky offer left
                rect_c = [color2; color3; color4; color4];
            case 2 % risky offer right
                rect_c = [color4; color4; color2; color3];
        end 
end
Screen(window, 'FillRect', rect_c', rect');

% define correct sidess
switch position
    case 1 % risky offer left
        side_risky = 'left';  
        side_ambi = 'right';
    case 2 % risky offer right
        side_risky = 'right';  
        side_ambi = 'left';
end

%%% RISKY SIDE %%%
% display risk value of probability
disp_text = [ sprintf('%.1f', risk_high) abbrev_add ];
draw_text(POSITION.under, side_risky);
% display risk value of inverse probability
disp_text = [ sprintf('%.1f', risk_low) abbrev_add ];
draw_text(POSITION.upper, side_risky);

if disp_prob == 1;
    % display probabilities in %
    disp_text = [num2str(probability*100) '%'];
    draw_text(POSITION.low, side_risky);
    % display risk value of inverse probability
    disp_text = [num2str(100-probability*100) '%'];
    draw_text(POSITION.high, side_risky);
end

% add probability line
if position == 1; % risky offer left
    Screen('DrawLine', window, problinecolor, -300+1, prob_coord, -130-2, prob_coord, 5); % probability line left
elseif position == 2; % risky offer right
    Screen('DrawLine', window, problinecolor, 300-2, prob_coord, 130+1, prob_coord, 5); % probability line right
end

%%% AMBIGUOUS SIDE %%%
% display high ambiguity
disp_text = [ sprintf('%.1f', ambiguity_high) abbrev_add ];
draw_text(POSITION.under, side_ambi);
% display low ambiguity
disp_text = [ sprintf('%.1f', ambiguity_low) abbrev_add ];
draw_text(POSITION.upper, side_ambi);

if disp_prob == 1;
    % display unkwon probabilities in (pseudo) %
    disp_text = '??%';
    draw_text(POSITION.low, side_ambi);
    draw_text(POSITION.high, side_ambi);
else
    disp_text = '???';
    draw_text(POSITION.mid, side_ambi);
end

%% (2) DRAW THE RESPONSE INDICATION

if response ~= 0;
    
    switch response
        case 1 % draw response left
                % larger borders
                Screen('DrawLine', window, [0 128 0], -320-3, 257, -110+2, 257, 5);
                Screen('DrawLine', window, [0 128 0], -320, 257, -320, -257, 5);
                Screen('DrawLine', window, [0 128 0], -110+2, -257, -320-3, -257, 5);
                Screen('DrawLine', window, [0 128 0], -110, -257, -110, 257, 5);
        case 2 % draw response right
                % larger borders
                Screen('DrawLine', window, [0 128 0], 320+2, 257, 110-3, 257, 5);
                Screen('DrawLine', window, [0 128 0], 320, 257, 320, -257, 5);
                Screen('DrawLine', window, [0 128 0], 110-3, -257, 320+2, -257, 5);
                Screen('DrawLine', window, [0 128 0], 110, -257, 110, 257, 5);  
    end
    
    % recolor fixation cross (back to normal)
    Screen('DrawLine', window, 0, -10, 0, 10, 0, 5);
    Screen('DrawLine', window, 0, 0, -10, 0, 10, 5);
    
end

%% BRING ON THE SCREEN
Screen(window, 'Flip');

%% END FUNCTION
end
