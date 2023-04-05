% Clear the workspace
clear;
close all;
sca;

% Skip the synchronization problem
Screen('Preference', 'SkipSyncTests', 1);

%---------------
%% Creation of the Forperiods

%---------------
Whole_expe = []; % I will have a whole experience array at the end
% Defining hyperparameters
ITI = 3; % the ITI is the intertrial interval, I decided to take it longer than the forperiods in order to make the difference
% Here I only have one block for the moment
% Defining the satistical parameters of the distirbution of the forperiods
% for the first block


mean_ = 3;
sigma_= 0.9;


% initialisation of the parameters of the f
% creation of the distribution
pd = makedist('Normal','mu',mean_,'sigma',sigma_);

nb_fp = 5;
B1 = transpose(random(pd,[nb_fp,1])); % we have 

plot(B1);


%---------------
%% Creation of the design matrix file
%---------------

Initials = "MV";
%we will now use the clock
format shortg;
time_clock = clock;

time_string = string(time_clock(1))+':'+string(time_clock(2))+':'+string(time_clock(3))+':'+string(time_clock(4))+':'+string(time_clock(5));
% This file will allwo to follow the experiment
filename_block = sprintf('%s_mean_%d_std_%s_time_%s.txt',...
        Initials, mean_,string(sigma_),time_string)  ; %we are creating the file in here

% Open the file 
fd_block = fopen(filename_block,'a');
%---------------
%% Sound Setup
%---------------
% Initialize Sounddriver
InitializePsychSound(1);

% Number of channels and Frequency of the sound
nrchannels = 2;
freq = 48000;

% How many times do we wish to play the sound
repetitions = 1;

% Length of the beep
beepLengthSecs = 0.05;

%Fading duration
tone_fade = 10; %need to be in ms



% Start immediately after an ITI at the very begining of the launching
% of the experiment
startCue = ITI;

%time stamp of the presentation of the stimulus
target_stop = zeros(1,nb_fp);
cue_stop= zeros(1,nb_fp);

% recordng the participants RT
rt = zeros(1,nb_fp);

% Should we wait for the device to really start (1 = yes)
% INFO: See help PsychPortAudio
waitForDeviceStart = 1;

% Open Psych-Audio port, with the follow arguements
% (1) [] = default sound device
% (2) 1 = sound playback only
% (3) 1 = default level of latency
% (4) Requested frequency in samples per second
% (5) 2 = stereo putput
pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);

% Set the volume to half for this demo
PsychPortAudio('Volume', pahandle, 0.5);

% Make a beep which we will play back to the user
myBeep_cue = MakeBeep(500, beepLengthSecs, freq);
myBeep_cue = fade_me(myBeep_cue,freq,tone_fade,tone_fade);


% Make a beep which we will play back to the user
myBeep_target = MakeBeep(1000, beepLengthSecs, freq);
myBeep_target = fade_me(myBeep_target,freq,tone_fade,tone_fade);
%------------------
%% Screen Setup
%------------------

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);


% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);



% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Setup the text type for the window
Screen('TextSize', window, 36);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Draw text
DrawFormattedText(window, 'Basic instruction : press space as quick as possible after the 2nd bip. Now, press space to start.', 'center', 'center', [1 1 1]);
% Flip to the screen
Screen('Flip', window);

% Wait for a key press
KbStrokeWait;

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

% Button pressing
enter_mac =44;
enter_window = 32;

% False alert array
false_alert =  zeros(1,nb_fp);

%------------------
%% Presenting the foreperiods
%------------------
for trial = 1:nb_fp
    % Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
    Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);

% Flip to the screen
    Screen('Flip', window);
    % Fill the audio playback buffer with the audio data, doubled for stereo
% presentation
    PsychPortAudio('FillBuffer', pahandle, [myBeep_cue; myBeep_cue]);
    % Start audio playback
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    
    % Wait for the beep to end. Here we use an improved timing method suggested
    % by Mario.
    % See: https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/messages/20863
    % For more details.
    [cue_actualStartTime, ~, ~, cue_estStopTime] = PsychPortAudio('Stop', pahandle, 1, 1);
    cue_stop(trial) = cue_estStopTime;
    
    % Compute new start time for follow-up beep, beepPauseTime after end of
    % previous one
    % Length of the foreperiod between beeps
    Foreperiod = B1(trial);
    
    startCue= cue_estStopTime + Foreperiod;
    % Tackling the false alert 
    while GetSecs < startCue
                [keyIsDown_FA, seconds_FA, keyCode] = KbCheck;

        if keyCode(enter_mac) 
            false_alert(trial) =1;
            DrawFormattedText(window, 'Answered too soon, wait for the cue tone to answer', 'center', 'center', [1 1 1]);
            % Flip to the screen
            Screen('Flip', window);
        

        elseif keyCode(enter_window)
           false_alert(trial) =1;
           DrawFormattedText(window, 'Answered too soon, wait for the cue tone to answer', 'center', 'center', [1 1 1]);
            % Flip to the screen
            Screen('Flip', window);
        end

    end 


    % Fill the audio playback buffer with the audio data, doubled for stereo
% presentation
    PsychPortAudio('FillBuffer', pahandle, [myBeep_target; myBeep_target]);
    % Start audio playback
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    
    % Wait for stop of playback
    [target_actualStartTime, ~, ~, target_estStopTime] = PsychPortAudio('Stop', pahandle, 1, 1);
    response= false;

    [keyIsDown, seconds, keyCode] = KbCheck;
    while response==false 
        [keyIsDown, seconds, keyCode] = KbCheck;

        if keyCode(enter_mac) 
            response =true;
        end

        if keyCode(enter_window)
           response =true;
        end

    end 


    %disp([keyIsDown, seconds, keyCode]);
    target_stop(trial) =  target_estStopTime;
    rt(trial) = seconds - target_estStopTime;
    startCue = seconds + ITI;
    fprintf(fd_block, '#   Nb_of_trial: %d ; Mean: %d ; Std: %d ; Presented_foreperiod: %u ; Too early : %d, Start_time_Cue: %u ; Stop_time_cue: %u ; Start_time_target: %u ; Stop_time_target: %u ; Response_time :%u;\n', trial, mean_, sigma_ , Foreperiod,false_alert(trial),cue_actualStartTime,cue_estStopTime,target_actualStartTime,target_estStopTime,rt(trial));
    if rt(trial) <= 0.1  

        % Draw text
        Screen('DrawLines', window, allCoords,...
        lineWidthPix, [0 1 0], [xCenter yCenter], 2);
    elseif (rt(trial)> 0.1) && (rt(trial)<=2)
        % Draw text
        Screen('DrawLines', window, allCoords,...
        lineWidthPix, [1 1 0], [xCenter yCenter], 2);
    elseif rt(trial)>0.2
        % Draw text
        Screen('DrawLines', window, allCoords,...
        lineWidthPix, [1 0 0], [xCenter yCenter], 2);
    end
    % Flip to the screen
    %DrawFormattedText(window, 'You have just pressed the button', 'center', 'center', [1 1 1]);

    Screen('Flip', window);
    WaitSecs(1);

end

actual_fp = target_stop-cue_stop;     
%plot(actual_fp);
plot(rt);

% Close the audio device
PsychPortAudio('Close', pahandle);
%-----
%% Exit the visual frame 


% Draw text
DrawFormattedText(window, 'End of the presentation, press space to exit', 'center', 'center', [1 1 1]);

% Flip to the screen
Screen('Flip', window);

% Wait for a key press
KbStrokeWait();

% Clear the screen
sca;
