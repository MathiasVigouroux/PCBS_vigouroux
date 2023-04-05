% Clear the workspace
clear;
close all;
sca;
rng("default");
rng("shuffle");

% Skip the synchronization problem
Screen('Preference', 'SkipSyncTests', 1);
                                                  
%-----------
%% Definition of the parameters
%-----------------
% Parameters of the participant
Id= 'Id1714'; % identifiant of the participant
                            
% Parameters for the foreperiods
nb_block = 4;
nb_fp = 120;
begining_block_waiting = 2; % time to wait at the begining
inter_block_waiting = 120;
mean_ = 2.5;
min_sigma = 0.04;
max_sigma = 1.1;
ordered_sigma_list = logspace(log10(min_sigma), log10(max_sigma), nb_block);
min_freq = 450;
max_freq = 950;
ordered_freq_list = logspace(log10(min_freq), log10(max_freq), nb_block);
feed_back_duration = 1;
%ordered_sigma_list= [0.1 0.6 1.1]; % the linear change of the 3 std 
%ordered_freq_list = [450 7050 1050]; %linear change for the sound 

% Parameters for the training
mean_train = 2.5;
sigma_train = 0.25;
freq_train = mean([min_freq max_freq]);%frequency of the sound for the training, we take the mean of the sound
nb_fp_train = 7;

%Parameter of the ITI
min_iti = 1; %we have to add one to this minimum iti because we show a feedback
mean_iti = 1.5; % mean for the variable part of the ITI
mean_iti = mean_iti * 2 ; % we have to multiply it by two because we will then use it in a uniform distribution (divide by two)
% the final mean will then be equal to min_iti + mean_iti (the one before
% the multiplication)

% Parameters for the reproduction task.
nb_repro = 30; % nb of Foreperiod asked to reproduced try to see if there is a trend

% Parameters for the sound
% Number of channels and Frequency of the sound
nrchannels = 2;
freq = 44100; % frequency of the auditory stimulu (not the tone)
repetitions = 1; % how many times do we wish to play the sound
beepLengthSecs = 0.1; % length of the beep
tone_fade = 10; % fading duration (need to be in ms)
startCue = 0;% Start immediately at the very begining of the launching
% of the experiment (we have a 5 sec all the time)
    
% Parameters for the visual
% Get the centre coordinate of the window
 % image presentation rectangles
 smImSq = [0 0 1500 1000];

EyeTribeInit(60,1000); % init EyeTribe at 60Hz and 60 seconds buffer


% Parameters for the behavioral pressing
too_early_delay =0.02;
enter_mac =44;% Button pressing
enter_window = 32;% Button pressing
very_good_rt =0.2; % this the upper value for the very good rt
middle_rt = 0.4; % the middle rt is the upper bound for the middle rt and lower bound for the bad rt (red)
too_long = 2; %time after whch we display an instruction and break the loop saying that it is too long
% Folder for the instrcutions
instruc_folder = 'K:/Matlab_Project/Code_behavioral/Instruct_bayes/';
%--------------
%% Initialisation of the list
%--------------
% Initialisation of an empty entire experiment
Whole_expe = []; % I will have a whole experience array at the end

% Initialisation of the lists for the std and freq that are shuffled (we need to have
% the same shuffling
sigma_list =zeros(1,nb_block);
freq_list = zeros(1,nb_block);

% Initialisation of the trackers for the time stamps
total_cue_stop=[];
total_target_start =[];

%total false alert
total_false_alert =[];

% Initialisation of the list of Response Time
total_rt = [];

% Initialisation of the list for the Eye data
dataEyeTribe=[];
%---------------
%% Creation of the  real Foreperiods

%---------------
% We start by creating the shuffled sigma list and freq
idx = randperm(length(ordered_sigma_list));% creation of the shuffling array

for iBlock=1: length(sigma_list)
    sigma_list(iBlock)=ordered_sigma_list(idx(iBlock));
    freq_list(iBlock) = ordered_freq_list(idx(iBlock));
end

for iBlock = 1: length(sigma_list)
    % creation of the distribution
    sigma_ = sigma_list(iBlock);
    pd = makedist('Normal','mu',mean_,'sigma',sigma_);
    block = transpose(random(pd,[nb_fp,1]));
    Whole_expe = [Whole_expe; block];

end
          
ITI = rand(height(Whole_expe),width(Whole_expe))*mean_iti+min_iti; % the ITI is the intertrial interval, I decided to take it longer than the forperiods in order to make the difference

%---------------
%% Creation of the training Foreperiods
%---------------

pd_train = makedist('Normal','mu', mean_train,'sigma',sigma_train);
train_block = transpose(random(pd_train,[nb_fp_train,1]));

ITI_train = rand(1,nb_fp_train)*mean_iti+min_iti;

%---------------
%% Creation of the reproduction task
%---------------

%The only relevant list is the ITI

ITI_repro = rand(1,nb_repro)*(mean_iti)+min_iti + feed_back_duration; % we havce to add the feedback uration because we doon't have the feedback in here 

%---------------
%% Creation of the design matrix file
%---------------
% In this section we create the design matrix, i.e. a document that follow
% the experimental data of the participant.
%we will now use the clock (I have to ask if I can use the clock in the
%name of the data storing document
format shortg;
time_clock = clock;
time_string = string(time_clock(1))+'-'+string(time_clock(2))+'-'+string(time_clock(3))+'-'+string(time_clock(4))+'-'+string(time_clock(5));
% This file will allwo to follow the experiment
filename_block = sprintf('K:/Matlab_Project/Code_behavioral/Data_participants/%s_implicit_mean_%s_time_%s.csv',...
        Id, string(mean_),time_string)  ; %we are creating the file in here

% Open the file 
fd_block = fopen(filename_block,'a');

% Creation of the txt file
fprintf(fd_block, 'Block; Nb_of_trial; Mean; Std; Presented_foreperiod; Too_early; Too_long; Start_time_Cue; Stop_time_cue; Start_time_target; Stop_time_target; ITI; Actual_FP; Response_time;\n');
% we create the header of the file, I decided to use a .csv file because of
% the ease of this format to handle data and it is a non-proprietray data
% format

                     
%---------------
%% Creation of the file for the explicit task
%---------------
% In this section we create the task that will follow the reprodcution task

filename_repro = sprintf('K:/Matlab_Project/Code_behavioral/Data_participants/%s_explicit_mean_%s_time_%s.csv',...
        Id, string(mean_),time_string)  ; %we are creating the file in here

% Open the file 
fd_repro = fopen(filename_repro,'a');

% Creation of the txt file
fprintf(fd_repro, 'Nb_of_trial; Mean; Std; Tone_freq; Start_time_Cu; Stop_time_cue; ITI; Pressing_button; Created_foreperiod; \n');
% we create the header of the file, I decided to use a .csv file because of
% the ease of this format to handle data and it is a non-proprietray data
% format
              

%-------------------------
%% Eye Tracking setup
%---------------------------

% check EyeTribe connexion
% offer possibility of (unplug/)replug device
[ retVal, ETversion, ETtrackerstate, ETframerate, ETiscalibrated, ETiscalibrating ] = EyeTribeGetServerState();
iRetries = 0;
if ETtrackerstate ~= 0
    fprintf('Eyetribe device not found or bad connexion.\nPlease try to replug device.\n');
    while ETtrackerstate ~= 0
        iRetries = iRetries + 1;
        WaitSecs(1);
         fprintf('.');
        [ retVal, ETversion, ETtrackerstate, ETframerate, ETiscalibrated, ETiscalibrating ] = EyeTribeGetServerState();
        if iRetries > 30
            EyeTribeUnInit();
            error('EyeTribe : connexion error');
        end
    end
end
EyeTribeStart();


%---------------
%% Sound Setup
%---------------
% In this section I dive into the creation of the Audio Machine that will
% be used to present the auditory tones
% Initialize Sounddriver
InitializePsychSound(1);

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
% Warning : the half of the audio volume used here is the half of the
% current setting (i.e. it won't be 50 % of the whole device)
PsychPortAudio('Volume', pahandle, 0.5);

% Make a target beep which we will play back to the user
% The target tone was decided to always be same following the previous
% experiment (see Elisa 2021) 
myBeep_target = MakeBeep(2000, beepLengthSecs, freq);
myBeep_target = fade_me(myBeep_target,freq,tone_fade,tone_fade);
%------------------
%% Screen Setup
%------------------
% In this section I dive into the creation of the Visual Machine that will
% be used to present the fixation cross and a feed back (change of the
% color of the cross depending on the RT)
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
[window, windowRect] = PsychImaging('OpenWindow', screenNumber,black);%,[0 0 500 300] );

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);        

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Setup the text type for the window
Screen('TextSize', window, 36);

% hide the cursor

HideCursor();

% Fixation cross
[xCenter, yCenter] = RectCenter(windowRect);
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;
%-----------------
%% Preliminary instructions
%-----------------
           
[smallIm, xOffsetsigS, yOffsetsigS] = CenterRect(smImSq, windowRect);

Instru('Instruct_bayes.001.png',instruc_folder,window, smallIm,true);   
Instru('Instruct_bayes.016.png',instruc_folder,window, smallIm,true);   


%----
%% Eye tracker calibration
%--------

EyeTribeCheckCenterPsy( window ,true ); % display eye position and wait for eyes in centre box. 2nd parameters force display if true. if false and eyes positions is ok, the centering screen is not displayed and function return without waiting
Instru('Instruct_bayes.017.png',instruc_folder,window, smallIm,true);   
EyeTribeCalibratePsy( window, 9, 900 ); % EyeTribe calibration with 9 points (9, 12, 16 are possible) . 900 ms on each point
[ retVal,result,deg,degl,degr ] = EyeTribePrintCalibrationResult( ); % get calibration results. Should be retVal = 0, result = 1 if OK. Next values are error for both eyes, error for left eye, error for right eye
fprintf('Calibration Result : %d %d %f %f %f\n', retVal, result, deg, degl, degr);
if result ~= 1
	warning('Eyetribe : Calibration failed !');
end
%----
%% Experimental instructions
%------

Instru('Instruct_bayes.002.png',instruc_folder,window, smallIm,true);  
Instru('Instruct_bayes.003.png',instruc_folder,window, smallIm,true);  
Instru('Instruct_bayes.004.png',instruc_folder,window, smallIm,true);   
Instru('Instruct_bayes.005.png',instruc_folder,window, smallIm,true);  
Instru('Instruct_bayes.006.png',instruc_folder,window, smallIm,true); 
%-------------
%% Training phase
%-------------

% Make a beep which we will play back to the user
myBeep_train = MakeBeep(freq_train, beepLengthSecs, freq);
myBeep_train = fade_me(myBeep_train,freq,tone_fade,tone_fade);

% set good quality antialiasing
Screen('DrawLines', window, allCoords,...
lineWidthPix, white, [xCenter yCenter], 2);
% Flip to the screen
Screen('Flip', window);

WaitSecs(begining_block_waiting); % wait a little at the begining of the experiment
for trial = 1:nb_fp_train
    % Draw the fixation cross in white, set it to the center of our screen and
    % set good quality antialiasing
    Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);

    % Flip to the screen
    Screen('Flip', window);
    
    % Fill the audio playback buffer with the audio data, doubled for stereo
    % presentation
    PsychPortAudio('FillBuffer', pahandle, [myBeep_train; myBeep_train]);
    % Start audio playback
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    EyeTribeSetCurrentScene(1);
    % Wait for the beep to end. Here we use an improved timing method suggested
    % by Mario.
    % See: https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/messages/20863
    % For more details.
    [cue_actualStartTime, ~, ~, cue_estStopTime] = PsychPortAudio('Stop', pahandle, 1, 1);
    
    % Compute new start time for follow-up beep, beepPauseTime after end of
    % previous one
    % Length of the foreperiod between beeps
    Foreperiod = train_block(trial);
    
    startCue= cue_actualStartTime + Foreperiod;
    % Tackling the false alert 
    while GetSecs < startCue - too_early_delay
        [keyIsDown_FA, seconds_FA, keyCode] = KbCheck;

        if keyCode(enter_mac)  
            Instru('Instruct_bayes.007.png',instruc_folder,window, smallIm,false); 
                EyeTribeSetCurrentMark(1997);
                WaitSecs(0.8);
                EyeTribeSetCurrentMark(0);
                Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
                Screen('Flip', window);
        

        elseif keyCode(enter_window)
                Instru('Instruct_bayes.007.png',instruc_folder,window, smallIm,false); 
                EyeTribeSetCurrentMark(1997);
                WaitSecs(0.8);
                EyeTribeSetCurrentMark(0);
                Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
                Screen('Flip', window);        
        end

    end 

    % Fill the audio playback buffer with the audio data, doubled for stereo
    % presentation
    PsychPortAudio('FillBuffer', pahandle, [myBeep_target; myBeep_target]);
    % Start audio playback
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    EyeTribeSetCurrentScene(0);
    % Wait for stop of playback
    [target_actualStartTime, ~, ~, target_estStopTime] = PsychPortAudio('Stop', pahandle, 1, 1);
    response= false;
    [keyIsDown, seconds, keyCode] = KbCheck;
    while response==false 
        [keyIsDown, seconds, keyCode] = KbCheck;
        rt_train = seconds - target_estStopTime;
        if rt_train > too_long
            EyeTribeSetCurrentMark(1998);
            Instru('Instruct_bayes.015.png',instruc_folder,window, smallIm,false);
            WaitSecs(1);
            EyeTribeSetCurrentMark(0);
            break
        end

        if keyCode(enter_mac) 
            response =true;
            EyeTribeSetCurrentMark(2000);
        

        elseif keyCode(enter_window)
           response =true;
           EyeTribeSetCurrentMark(2000);
        end
         
    end 
                                    
    
    if rt_train <= very_good_rt 
        EyeTribeSetCurrentMark(100);
        % Draw text
        Screen('DrawLines', window, allCoords,...
        lineWidthPix, [0 1 0], [xCenter yCenter], 2);

    elseif (rt_train> very_good_rt) && (rt_train<=middle_rt)
        EyeTribeSetCurrentMark(101);
        % Draw text
        Screen('DrawLines', window, allCoords,...
        lineWidthPix, [1 1 0], [xCenter yCenter], 2);

    elseif rt_train>middle_rt
        EyeTribeSetCurrentMark(102);
        % Draw text
        Screen('DrawLines', window, allCoords,...
        lineWidthPix, [1 0 0], [xCenter yCenter], 2);

    end

    Screen('Flip', window);
    WaitSecs(feed_back_duration);
    EyeTribeSetCurrentMark(0);
    


    startCue = seconds + ITI(iBlock,trial);

end
EyeTribeSetCurrentScene(0); %clear marker 
[ retVal, dataEye, overFlow ] = EyeTribeGetDataSimple();
if overFlow>0
    fprintf('overflow\n');
end
%if overFlow > 0 , a warning is displayed in console. Datas should be
%retrieved more often or use EyeTribeSetBufferTime function. Internal buffer lasts 60 seconds (default setting)
dataEyeTribe=[dataEyeTribe;dataEye]; % concatenate data

Instru('Instruct_bayes.019.png',instruc_folder,window, smallIm,true);     
EyeTribeCheckCenterPsy( window ,true ); % display eye position and wait for eyes in centre box. 2nd parameters force display if true. if false and eyes positions is ok, the centering screen is not displayed and function return without waiting  
Instru('Instruct_bayes.008.png',instruc_folder,window, smallIm,true); 

%-------------
%% Whole experience
%-------------

for iBlock= 1:height(Whole_expe)
    

    sigma_ = sigma_list(iBlock);
    B1 = Whole_expe(iBlock,:);

    %------------------
    % One block 
    %------------------
    %time stamp of the presentation of the stimulus
    
    cue_stop= zeros(1,nb_fp);
    target_start = zeros(1,nb_fp);

    % recordng the participants RT
    rt_list = zeros(1,nb_fp);
    % False alert array
    false_alert =  zeros(1,nb_fp);

    % Make a beep which we will play back to the user
    myBeep_cue = MakeBeep(freq_list(iBlock), beepLengthSecs, freq);
    myBeep_cue = fade_me(myBeep_cue,freq,tone_fade,tone_fade);

    % set good quality antialiasing
    Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);
    % Flip to the screen
    Screen('Flip', window);

    WaitSecs(begining_block_waiting); % wait a little at the begining of the experiment
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
        
        % Wait for the beep to end.
        [cue_actualStartTime, ~, ~, cue_estStopTime] = PsychPortAudio('Stop', pahandle, 1, 1);
        EyeTribeSetCurrentScene(iBlock*10);
        cue_stop(trial) = cue_estStopTime;
        
        % Compute new start time for follow-up beep, beepPauseTime after end of
        % previous one
        % Length of the foreperiod between beeps
        Foreperiod = B1(trial);
        
        startCue= cue_estStopTime + Foreperiod;
        % Tackling the false alert
        while GetSecs < startCue - too_early_delay
            [keyIsDown_FA, seconds_FA, keyCode] = KbCheck;
         
                   
            if keyCode(enter_mac) 
                false_alert(trial) = false_alert(trial) + 1;
                Instru('Instruct_bayes.007.png',instruc_folder,window, smallIm,false); 
                EyeTribeSetCurrentMark(1997);
                WaitSecs(0.8);
                EyeTribeSetCurrentMark(0);                Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
                Screen('Flip', window);

    
            elseif keyCode(enter_window)
               false_alert(trial) = false_alert(trial) + 1;
               Instru('Instruct_bayes.007.png',instruc_folder,window, smallIm,false); 
                EyeTribeSetCurrentMark(1997);
                WaitSecs(0.8);
                EyeTribeSetCurrentMark(0);                Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
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
        EyeTribeSetCurrentScene(iBlock*10+1);
        response= false ;
        didnt_ans = 0;
        while response==false 
            [keyIsDown, seconds, keyCode] = KbCheck;
            rt = seconds - target_estStopTime;
            if rt > too_long
                didnt_ans =1;
                Instru('Instruct_bayes.015.png',instruc_folder,window, smallIm,false); 
                WaitSecs(1);  
                EyeTribeSetCurrentMark(1998);
                WaitSecs(1);
                EyeTribeSetCurrentMark(0);
                break
            end

            if keyCode(enter_mac) 
                response =true;
                EyeTribeSetCurrentMark(2000);

            end
    
            if keyCode(enter_window)
               response =true;
               EyeTribeSetCurrentMark(2000);

            end
    
        end 
                                
        %disp([keyIsDown, seconds, keyCode]);
        target_start(trial) =  target_actualStartTime;
        rt_list(trial) = seconds - target_estStopTime; % in the response time I decided to remove the bip

         if rt_list(trial) <= very_good_rt 
    
            % Draw text
            Screen('DrawLines', window, allCoords,...
            lineWidthPix, [0 1 0], [xCenter yCenter], 2);
            EyeTribeSetCurrentMark(100);
        elseif (rt_list(trial)> very_good_rt) && (rt_list(trial)<=middle_rt)
            % Draw text
            Screen('DrawLines', window, allCoords,...
            lineWidthPix, [1 1 0], [xCenter yCenter], 2);
            EyeTribeSetCurrentMark(101);
        elseif rt_list(trial)>middle_rt
            % Draw text
            Screen('DrawLines', window, allCoords,...
            lineWidthPix, [1 0 0], [xCenter yCenter], 2);
            EyeTribeSetCurrentMark(102);
         end

        actual_fp = target_actualStartTime - cue_estStopTime;
        startCue = seconds + ITI(iBlock,trial);
        fprintf(fd_block, '%d; %d; %d; %s; %u; %d; %d; %u; %u; %u; %u; %u; %u; %u;\n', iBlock, trial, mean_, string(sigma_),Foreperiod,false_alert(trial),didnt_ans, cue_actualStartTime,cue_estStopTime,target_actualStartTime,target_estStopTime,ITI(iBlock,trial), actual_fp, rt_list(trial));
       
    
        Screen('Flip', window);
        WaitSecs(feed_back_duration);
        EyeTribeSetCurrentMark(0);
    
    end
    total_rt = [total_rt ; rt_list]; %this is the complete RT table
    total_cue_stop = [total_cue_stop ; cue_stop];
    total_target_start =[total_target_start ; target_start];
    total_false_alert = [total_false_alert ; false_alert];
    EyeTribeSetCurrentScene(0);
    if iBlock ~=nb_block
        Instru('Instruct_bayes.009.png',instruc_folder,window, smallIm,false); 
        WaitSecs(inter_block_waiting);
        Instru('Instruct_bayes.018.png',instruc_folder,window, smallIm,true);
        EyeTribeCheckCenterPsy( window ,true );
        Instru('Instruct_bayes.010.png',instruc_folder,window, smallIm,true);         
    end
 
    [ retVal, dataEye, overFlow ] = EyeTribeGetDataSimple();
    if overFlow>0
        fprintf('overflow\n');
    end
    %if overFlow > 0 , a warning is displayed in console. Datas should be
    %retrieved more often or use EyeTribeSetBufferTime function. Internal buffer lasts 60 seconds (default setting)
    dataEyeTribe=[dataEyeTribe;dataEye]; % concatenate data
    
end
                                                             
%------------------------
%% Reproduction task 
%------------------------
Instru('Instruct_bayes.020.png',instruc_folder,window, smallIm,true);
EyeTribeCheckCenterPsy( window ,true );
Instru('Instruct_bayes.011.png',instruc_folder,window, smallIm,true);
Instru('Instruct_bayes.012.png',instruc_folder,window, smallIm,true);
Instru('Instruct_bayes.013.png',instruc_folder,window, smallIm,true);

% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
Screen('DrawLines', window, allCoords,...
lineWidthPix, white, [xCenter yCenter], 2);
    
% Flip to the screen
Screen('Flip', window);

repro_freq = freq_list(length(freq_list));
myBeep_repro = MakeBeep(repro_freq, beepLengthSecs, freq);
myBeep_repro = fade_me(myBeep_repro,freq,tone_fade,tone_fade);

sigma_repro = sigma_list(length(sigma_list));
reproduction_fp = zeros(1,nb_repro);

WaitSecs(begining_block_waiting); % wait a little at the begining of the experiment
for repro=1:nb_repro
    % Fill the audio playback buffer with the audio data, doubled for stereo
    % presentation
    PsychPortAudio('FillBuffer', pahandle, [myBeep_repro; myBeep_repro]); %we use the same bip as the last beep
    % Start audio playback
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    EyeTribeSetCurrentScene((nb_block+1)*10);

    [cue_actualStartTime, ~, ~, cue_estStopTime] = PsychPortAudio('Stop', pahandle, 1, 1);
    
    % Check the repro time
    repro_response= false;
    [keyIsDown, seconds, keyCode] = KbCheck;
    while repro_response==false 
       [keyIsDown, seconds, keyCode] = KbCheck;
    
       if keyCode(enter_mac) 
           repro_response =true;
           PsychPortAudio('FillBuffer', pahandle, [myBeep_target; myBeep_target]); % I decided to give a feedback
           PsychPortAudio('Start', pahandle, repetitions, 0, waitForDeviceStart); % I decided to give a feedback
           EyeTribeSetCurrentScene((nb_block+1)*10+1);
       elseif keyCode(enter_window)
          repro_response =true;
          PsychPortAudio('FillBuffer', pahandle, [myBeep_target; myBeep_target]); % I decided to give a feedback
          PsychPortAudio('Start', pahandle, repetitions, 0, waitForDeviceStart); % I decided to give a feedback
          EyeTribeSetCurrentScene((nb_block+1)*10+1);
       end
                        
    end 
    reproduced_fp = seconds - cue_estStopTime;
    fprintf(fd_repro, '%u; %d; %s; %u; %u; %u; %u; %u; %u; \n',repro,mean_,string(sigma_repro),repro_freq,cue_actualStartTime,cue_estStopTime,ITI_repro(repro),seconds, reproduced_fp);
    
    reproduction_fp(repro)= reproduced_fp;
    startCue = seconds + beepLengthSecs + ITI_repro(repro);
        %if overFlow > 0 , a warning is displayed in console. Datas should be
    %retrieved more often or use EyeTribeSetBufferTime function. Internal buffer lasts 60 seconds (default setting)
end
[ retVal, dataEye, overFlow ] = EyeTribeGetDataSimple();
if overFlow>0
    fprintf('overflow\n');
end
%if overFlow > 0 , a warning is displayed in console. Datas should be
%retrieved more often or use EyeTribeSetBufferTime function. Internal buffer lasts 60 seconds (default setting)
dataEyeTribe=[dataEyeTribe;dataEye]; % concatenate data
%--------------------------
%% Exit of the experiment 
%--------------------------
WaitSecs(begining_block_waiting);
% Close the audio device
PsychPortAudio('Close', pahandle);

%Close the visual device
Instru('Instruct_bayes.014.png',instruc_folder,window, smallIm,false); 

finish=false ;
while finish==false
[keyIsDown_FA, seconds_FA, keyCode] = KbCheck;
    if keyCode(69)
        finish=true;
        KbStrokeWait;
    end
end
% Clear the screen               
sca;

filename_eye = sprintf('K:/Matlab_Project/Code_behavioral/Data_participants/%s_eye_mean_%s_time_%s.csv',...
        Id, string(mean_),time_string)  ;
writetable(struct2table(dataEyeTribe), filename_eye);
EyeTribeUnInit(); % EyeTribe uninit

Minim_fig(Id, mean_,time_string,ITI,Whole_expe,total_target_start,total_cue_stop,sigma_list,total_rt,total_false_alert);