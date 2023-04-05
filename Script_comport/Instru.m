function Instru(name,instruc_folder, window, smallIm,Kb)
 file = strcat(instruc_folder,name);
 [img, ~, ~] = imread( file); 
texture = Screen('MakeTexture', window, img);
 Screen('DrawTexture', window, texture, [], smallIm);
 Screen('Flip', window);
 if Kb
     % Wait for a key press
       KbStrokeWait;
 end 


 