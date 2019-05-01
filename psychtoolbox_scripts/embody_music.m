function embody_music(subjectCode)

    %stop sync
    KbName('UnifyKeyNames');                    %use unified keyboard key names (multi-OS compatibility)
    Screen('Preference','VisualDebugLevel',1);  %make sure to get errors printed 
    Screen('Preference', 'Verbosity', 1)
    Screen('Preference', 'SkipSyncTests', 1)
    
    %randomize seed
    rng shuffle

    %CONTROL CLIP TIME, SIZE
    fromTime=0;     % second to start in movie
    toTime=inf;     % second to stop in movie
    soundvolume=1;  % 0 to 1
    
    %DEFINE COLORS
    black = [0 0 0];
    white = [255 255 255];
    gray  = [200 200 200];
    red = [255 0 0];
    blue = [0,200,255];
    defaultFont = 'Helvetica';
    backgroundColor = black;
    textColor = white;
    
    %DEFINE FIXATION CROSS
    fixationsize = 5;
    fixationlines = [-fixationsize-1 fixationsize 0 0;0 0 -fixationsize fixationsize];
    fixationwidth = 1;
    fixationcolor = white;

    %Initialize the sound drive
    InitializePsychSound
    
    %Set up logfile
    logfilename = sprintf('%s_music.txt',subjectCode); %s is subject codename
    fprintf('Opening logfile: %s\n',logfilename); %prints to screen
    logfile = fopen([pwd '/logfiles/' logfilename],'a');
    fprintf(logfile,'## MUSIC LOG FOR SUBJECT %s\n',subjectCode);
    fprintf (logfile, '## %s\n',datestr(now));  %datestr(now) gives the current date and time in default format
    fprintf (logfile, '## trial\tstimname\ttaskfirst\tstimstart\tstimend\tselfemo\tselfintens\totheremo\totherintens\tlike\tfamiliar\n');
 
    %OPEN THE SCREEN
    [w,rect]=Screen('OpenWindow', max(Screen('screens')), 0);
    
    %SAVE SCREEN DIMENSIONS
    screenX = rect(3);
    screenY = rect(4);
    xcenter = screenX/2; 
    ycenter = screenY/2;
    Screen('TextSize' ,w, 38);
    Screen('TextFont',w,'Helvetica');
    
    %randomize the order of self vs. other
    order = [1 2 1 2 1 2 1 2];
    totaltrial = [0 2 4 6 8 10 12 14];
    taskorder = order(randperm(8))
    
    registerpage = sprintf('http://cortex.usc.edu/embody_music/autoregister.php?userID=%s',subjectCode);
    web(registerpage, '-browser')
    
    %Experiment start time
    %DRAW FIXATION
    Screen('FillRect', w,backgroundColor); 
    %Screen('DrawLines',w,fixationlines,fixationwidth,fixationcolor,[xcenter ycenter]);
    expStart = Screen('Flip',w);
%     expStart; 
     
    %define the path for music    
    songdir = [pwd '/music'];
    songfilelist = dir(songdir);
    songfileNames = {songfilelist(:).name}; 
    
     %remove hidden files 
    for i = 1:3
       songfileNames{i} = [];    
    end
    
    songfileNames = songfileNames(~cellfun(@isempty, songfileNames));
    
    %set up audio order/paths 
    %shuffle fileNames
    songfileOrder = randperm(numel(songfileNames)); %assigns random numbers
    songOrder = songfileNames(songfileOrder) % .wav titles randomized
    
    %Save the trial order
    counter = 0; 
    outfilenametest = sprintf([pwd '/trialorder_music/%s_trialorder.mat'],subjectCode); 
    if exist(outfilenametest) == 2
        counter = 0 + 1;
        outfilename = sprintf('%s_trialorder_%d.mat',subjectCode,counter);    
    else 
        outfilename = sprintf('%s_trialorder.mat',subjectCode);
    end
    
    save([pwd '/trialorder_music/' outfilename],'songOrder');

    
    %% Loop through each file: 
    for i = 1:length(songOrder)
        songfileName = songOrder{i};
        songpath = sprintf('%s/%s',songdir, songfileName); 
        fprintf('%s\n',songfileName);
%         fprintf('%s\n',songpath);
        
        %DRAW FIXATION
        Screen('FillRect', w,backgroundColor); 
        Screen('DrawLines',w,fixationlines,fixationwidth,fixationcolor,[xcenter ycenter]);
        Screen('Flip',w);

        %PRESENT START Screen
        if i == 1;
            text = 'Thank you for agreeing to participate in our study! \n\nYou are now going to LISTEN to several short clips of music. \n\nAfter each, you will be asked to identify where on your body you felt an emotional response as well as where on the body the performer(s) felt an emotional response  \n\nWhen you are ready to begin, press any key';
            Screen('FillRect', w,backgroundColor); 
            wrapAt = 50;
            DrawFormattedText(w, text,'centerblock', 'center',textColor, wrapAt);
            Screen('Flip',w);
            %WaitSecs(.5);
            fprintf('Waiting for keypress to start...\n');
            KbWait(-1);

            text = 'When you are ready, press any key to continue to the first music clip';
            Screen('FillRect',w,backgroundColor);
            wrapAt = 50;
            DrawFormattedText(w,text,'centerblock','center',textColor,wrapAt);
            Screen('Flip',w);
            %WaitSecs(2) 
            fprintf('Waiting for keypress to present music clip...\n')
            KbWait(-1);
        end

        %Read in sound data from file
        [soundData,freq] = audioread(songpath);
%       fprintf('playing...');
%       t=Screen('Flip', w);

        %prepare song data 
        soundData = soundData';
        numchannels = size(soundData,1);
        if numchannels < 2
            soundData = [soundData; soundData];
            numchannels = 2;
        end
        
        %Screen before listening
        text = 'Listen';
        Screen('FillRect', w,backgroundColor); 
        wrapAt = 50;
        DrawFormattedText(w, text,'centerblock', 'center',textColor, wrapAt);
        
        %open the audio driver
        pahandle = PsychPortAudio('Open',[], [], 0, freq, numchannels);
        
        %Fill the buffer
        PsychPortAudio('Fillbuffer',pahandle,soundData); 
        
        %play the sound
        playTime = PsychPortAudio('Start',pahandle, [], [],1);
        soundStartTime = playTime-expStart;
        fprintf('Sound started playing %.2f seconds after start of script\n',soundStartTime);
%         playTime
        %expStart
        Screen('Flip',w);
        WaitSecs((length(soundData)/freq));
        stimEnd = GetSecs;
        soundEndTime = stimEnd- expStart;    
      
        %Direct to Body Map 
        DrawFormattedText(w, 'Please direct your attention to the computer screen to your LEFT. \n\nPress any key to continue.','centerblock', 'center',textColor, wrapAt);
        wrapAt = 70;
        Screen('Flip',w);
        %WaitSecs(1)
        KbWait(-1,2);   
        
        selftext = 'Now, you are going to color the regions of the body whose activity you feel increasing or getting stronger in YOUR BODY when you listened to the piece of music. \n\nOn the LEFT body, color the regions whose activity you feel increasing or getting stronger in YOUR BODY while listening to the piece of music. \n\nOn the RIGHT body, color the regions whose activity you feel decreasing or getting weaker in YOURSELF while listening to the piece of music. \n\nOnce you have finished, select "Click here when done" on the Macbook.'; 
        charactertext = 'Now, you are going to color the regions of the body where you believe THE PERFORMER(S) of the piece of music is/are feeling activity. \n\nOn the LEFT body, color the regions whose activity you feel increasing or getting stronger in THE PERFORMER(S). \n\nOn the RIGHT body, color the regions whose activity you feel decreasing or getting weaker in the performer(s). \n\nOnce you have finished, select "Click here when done" on the Macbook.';
        
        %randomize order of self vs. other ratings
        task = taskorder(i);
        trial_1 = totaltrial(i); 
        percent_1 = (trial_1/16)*100;
        trial_2 = trial_1 + 1; 
        percent_2 = (trial_2/16)*100; 
        fname = songfileName(1:end-4)
        if task == 1
            filename_1 = sprintf('%s_self',fname);
            filename_2 = sprintf('%s_other',fname);
        elseif task == 2
            filename_1 = sprintf('%s_other',fname);
            filename_2 = sprintf('%s_self',fname);
        end
        trialpage_1 = sprintf('http://cortex.usc.edu/embody_music/paintannotate.php?perc=%.2f&userID=%s&presentation=%d&filename=%s',percent_1,subjectCode,trial_1,filename_1);
        trialpage_2 = sprintf('http://cortex.usc.edu/embody_music/paintannotate.php?perc=%.2f&userID=%s&presentation=%d&filename=%s',percent_2,subjectCode,trial_2,filename_2);
        
        if task == 1
            taskfirst = 'self';
            fprintf('\nSelf-rating first...\n'); 
            trialnum = sprintf('Trial %d.1',i);
            fprintf('Self Rating First...\n');
            DrawFormattedText(w, selftext,'centerblock', 'center',textColor, wrapAt);
            DrawFormattedText(w,trialnum,'centerblock',150,red);
            startDraw1 = Screen('Flip',w);
            
            %launch webpage
            web(trialpage_1,'-browser')
            
            while GetSecs - startDraw1 <= 240;
                [clicks,x1,y1,whichButton] = GetClicks();
                if x1 > 878 && x1 < 1082 && y1 > 664 && y1 < 693;
                    fprintf('%.2f\t%.2f\n',x1,y1);
                    break
                end
            end
            
            trialnum = sprintf('Trial %d.2',i);
            DrawFormattedText(w,charactertext,'centerblock', 'center',textColor, wrapAt);
            DrawFormattedText(w,trialnum,'centerblock',150,red);
            startDraw2 = Screen('Flip',w);
            
            %launch second webpage
            web(trialpage_2, '-browser')
            
            while GetSecs - startDraw2 <= 240;
                [clicks,x2,y2,whichButton] = GetClicks();
                if x2 > 878 && x2 < 1082 && y2 > 664 && y2 < 693;
                    fprintf('%.2f\t%.2f\n',x2,y2);
                    break
                end
            end
            
        elseif task == 2
            taskfirst = 'other';
            trialnum = sprintf('Trial %d.1',i);
            fprintf('Character Rating First...\n');
            DrawFormattedText(w, charactertext,'centerblock', 'center',textColor, wrapAt);
            DrawFormattedText(w,trialnum,'centerblock',150,red);
            startDraw1 = Screen('Flip',w);
            
            %launch second webpage
            web(trialpage_1, '-browser')
            
            while GetSecs - startDraw1 <= 240;
                [clicks,x1,y1,whichButton] = GetClicks();
                if x1 > 878 && x1 < 1082 && y1 > 664 && y1 < 693;
                    fprintf('%.2f\t%.2f\n',x1,y1);
                    break
                end
            end
            
            trialnum = sprintf('Trial %d.2',i);
            DrawFormattedText(w,selftext,'centerblock', 'center',textColor, wrapAt);
            DrawFormattedText(w,trialnum,'centerblock',150,red);
            startDraw2 = Screen('Flip',w);
            
            %launch second webpage
            web(trialpage_2, '-browser')
            
            while GetSecs - startDraw2 <= 240;
                [clicks,x2,y2,whichButton] = GetClicks();
                if x2 > 872 && x2 < 1088 && y2 > 658 && y2 < 702;
                    fprintf('%.2f\t%.2f\n',x2,y2);
                    break
                end
            end
        end
       
        DrawFormattedText(w,'Great job. \n\nNow, direct your attention back to THIS screen for a few more questions. \n\nPress any key to continue.' ,'centerblock', 'center',textColor, wrapAt);
        Screen('Flip',w);
        fprintf('Waiting for keypress to start...\n');
        %WaitSecs(1)
        KbWait(-1,2); 
        %Screen('FillRect', w,backgroundColor);
        
        %Question centering
        quesCenter = (rect(4)/2) - 100; 
        ansCentery = (rect(4)/2) + 50;
        ansCenterx = (rect(3)/2) - 150;
        
        %COLLECT RESPONSE
        %define valid responses
        oneCode=KbName('1!');
        twoCode=KbName('2@');
        threeCode=KbName('3#');
        fourCode=KbName('4$');
        fiveCode=KbName('5%');
        sixCode=KbName('6^');
        responseScreenTime = 15;
        
        % 1. Self emotion question
        selfques = 'What specific emotion did YOU feel when listening to the clip';
        emoansw = '1 - Sad\n\n2 - Happy\n\n3 - Angry\n\n4 - Calm\n\n5 - Fear\n\n6 - I felt more than one of these emotions fairly strongly';  
        emoansw2 = '1 - Sad\n\n2 - Happy\n\n3 - Angry\n\n4 - Calm\n\n5 - Fear\n\n6 - The performer felt more than one of these emotions fairly strongly';  
        Screen('FillRect', w,backgroundColor);
        wrapAt = 65; 
        DrawFormattedText(w, selfques,'center', quesCenter,textColor, wrapAt);
        DrawFormattedText(w, emoansw, ansCenterx , ansCentery, textColor, wrapAt); 
        starTime = Screen('Flip',w); %starTime is the timing when the rating question is presented
        fprintf('Getting emotion felt in self...\n');
        
        self_emoresponse = 'none';
        reactionTime = 0;
        index=1;
        hitindex = 0;
        
        while GetSecs - starTime <=responseScreenTime
             [ keyIsDown, timeSecs, keyCode ] = KbCheck;
             if keyIsDown
                 index=find(keyCode);
                 if (length(index) > 1)
                     index = 27;
                    return;
                 else
                     if (index==oneCode || index==twoCode || index==threeCode || index==fourCode || index==fiveCode || index==sixCode)
                         hitindex = index;
                         break;
                     end
                 end
             end
        end
        
        if (hitindex>1)
            self_emoresponse = KbName(hitindex);
            reactionTime = timeSecs - starTime;
%             KbWait(-1,2);
        else 
            fprintf('No response recorded, moving on...\n');
            DrawFormattedText(w, 'NO RECORDED RESPONSE\nMoving on\n','center', 'center',red, wrapAt);
            wrapAt = 70;
            Screen('Flip',w);
            WaitSecs(2) 
        end 
        
        fprintf('response: %s  DONE.\n',self_emoresponse);
        WaitSecs(.5); 
        
        % 2 . Self intensity question 
        self_intensresponse = 'none';
        reactionTime = 0;
        index=1;
        hitindex = 0;
        
        question = 'How strongly did YOU feel this emotion';
        intenans = '1 - Very little\n\n2 - Somewhat\n\n3 - Moderately\n\n4 - Quite a lot\n\n5 - Very strongly';  
        Screen('FillRect', w,backgroundColor); 
        DrawFormattedText(w, question,'center', quesCenter,textColor, wrapAt);
        DrawFormattedText(w, intenans, ansCenterx , ansCentery, textColor); 
        starTime = Screen('Flip',w); %starTime is the timing when the rating question is presented
        fprintf('Getting intensity rating of felt self emotion...\n');
        
        while GetSecs - starTime <=responseScreenTime
             [ keyIsDown, timeSecs, keyCode ] = KbCheck;
             if keyIsDown
                 index=find(keyCode);
                 if (length(index) > 1)
                     index = 27;
                    return;
                 else
                     if (index==oneCode || index==twoCode || index==threeCode || index==fourCode || index==fiveCode)
                         hitindex = index;
                         break;
                     end
                 end
             end
        end
        
        if (hitindex>1)
            self_intensresponse = KbName(hitindex);
            reactionTime = timeSecs - starTime;
%             KbWait(-1,2);
        else 
            fprintf('No response recorded, moving on...\n');
            DrawFormattedText(w, 'NO RECORDED RESPONSE\nMoving on\n','center', 'center',red, wrapAt);
            wrapAt = 70;
            Screen('Flip',w);
            WaitSecs(2)
        end 
               
        fprintf('response: %s  DONE.\n',self_intensresponse);
        WaitSecs(.5); 
        
        % 3. Other name emotion question 
        otherques = 'What specific emotion do you think THE PERFORMER(S) of the piece was/were feeling'; 
        Screen('FillRect', w,backgroundColor); 
        DrawFormattedText(w, otherques,'center', quesCenter,textColor, wrapAt);
        DrawFormattedText(w, emoansw2, ansCenterx , ansCentery, textColor); 
        starTime = Screen('Flip',w); %starTime is the timing when the rating question is presented
        fprintf('Getting other felt emotion...\n');
        
        other_emoresponse = 'none';
        reactionTime = 0;
        index=1;
        hitindex = 0;
        
        while GetSecs - starTime <=responseScreenTime
             [ keyIsDown, timeSecs, keyCode ] = KbCheck;
             if keyIsDown
                 index=find(keyCode);
                 if (length(index) > 1)
                     index = 27;
                    return;
                 else
                     if (index==oneCode || index==twoCode || index==threeCode || index==fourCode || index==fiveCode || index==sixCode)
                         hitindex = index;
                         break;
                     end
                 end
             end
        end
        
        if (hitindex>1)
            other_emoresponse = KbName(hitindex);
            reactionTime = timeSecs - starTime;
%             KbWait(-1,2);
        else 
            fprintf('No response recorded, moving on...\n');
            DrawFormattedText(w, 'NO RECORDED RESPONSE\nMoving on\n','center', 'center',red, wrapAt);
            wrapAt = 70;
            Screen('Flip',w);
            WaitSecs(2)
        end 
        
        fprintf('response: %s  DONE.\n',other_emoresponse);
        WaitSecs(.5); 
        
        % 4. Other emotion intensity question 
        question = 'How strongly do you think THE PERFORMER(S) felt this emotion';
        Screen('FillRect', w,backgroundColor); 
        DrawFormattedText(w, question,'center', quesCenter,textColor, wrapAt);
        DrawFormattedText(w, intenans, ansCenterx , ansCentery, textColor); 
        starTime = Screen('Flip',w); %starTime is the timing when the rating question is presented
        fprintf('Getting intensity rating of other felt emotion...\n');
        
        other_intensresponse = 'none';
        reactionTime = 0;
        index=1;
        hitindex = 0;
        
        while GetSecs - starTime <=responseScreenTime
             [ keyIsDown, timeSecs, keyCode ] = KbCheck;
             if keyIsDown
                 index=find(keyCode);
                 if (length(index) > 1)
                     index = 27;
                    return;
                 else
                     if (index==oneCode || index==twoCode || index==threeCode || index==fourCode || index==fiveCode)
                         hitindex = index;
                         break;
                     end
                 end
             end
        end
        
        if (hitindex>1)
            other_intensresponse = KbName(hitindex);
            reactionTime = timeSecs - starTime;
%             KbWait(-1,2);
        else 
            fprintf('No response recorded, moving on...\n');
            DrawFormattedText(w, 'NO RECORDED RESPONSE\nMoving on\n','center', 'center',red, wrapAt);
            wrapAt = 70;
            Screen('Flip',w);
            WaitSecs(2)
        end 
        
        fprintf('response: %s  DONE.\n',other_intensresponse);
        WaitSecs(.5); 
        
        
        % 5. PRESENT Enjoy QUESTION 
        likeques = 'How much did you like listening to this piece of music?';
        likeansw = '1 - Strongly dislike\n\n2 - Slightly dislike\n\n3 - Neither like nor dislike\n\n4 - Moderately like\n\n5 - Strongly like\n';  
        Screen('FillRect', w,backgroundColor); 
        DrawFormattedText(w, likeques,'center', quesCenter,textColor, wrapAt);
        DrawFormattedText(w, likeansw, ansCenterx , ansCentery, textColor); 
        likestarTime = Screen('Flip',w); %starTime is the timing when the rating question is presented
        fprintf('Getting rating for like question...\n');
        
        likeresp = 'none';
        reactionTime = 0;
        index=1;
        hitindex = 0;
        
        while GetSecs - likestarTime <=responseScreenTime
             [ keyIsDown, timeSecs, keyCode ] = KbCheck;
             if keyIsDown
                 index=find(keyCode);
                 if (length(index) > 1)
                     index = 27;
                    return;
                 else
                     if (index==oneCode || index==twoCode || index==threeCode || index==fourCode || index==fiveCode)
                         hitindex = index;
                         break;
                     end
                 end
             end
        end
        
        if (hitindex>1)
            likeresp = KbName(hitindex);
            reactionTime = timeSecs - starTime;
%             KbWait(-1,2);
        else 
            fprintf('No response recorded, moving on...\n');
            DrawFormattedText(w, 'NO RECORDED RESPONSE\nMoving on\n','center', 'center',red, wrapAt);
            wrapAt = 70;
            Screen('Flip',w);
            WaitSecs(2)
        end 
               
        fprintf('response: %s  DONE.\n',likeresp);
        WaitSecs(.5); 
        
        % 5. PRESENT FAMILIARITY QUESTION 
        famques = 'How familiar were you with the piece of music you just heard';
        famansw = '1 - Not at all familiar\n\n2 - Slightly familiar\n\n3 - Somewhat familiar\n\n4 - Moderately familiar\n\n5 - Extremely familiar\n';  
        Screen('FillRect', w,backgroundColor); 
        DrawFormattedText(w, famques,'center', quesCenter,textColor, wrapAt);
        DrawFormattedText(w, famansw, ansCenterx , ansCentery, textColor); 
        famstarTime = Screen('Flip',w); %starTime is the timing when the rating question is presented
        fprintf('Getting rating for familiarity question...\n');
        
        famresp = 'none';
        reactionTime = 0;
        index=1;
        hitindex = 0;
        
        while GetSecs - famstarTime <=responseScreenTime
             [ keyIsDown, timeSecs, keyCode ] = KbCheck;
             if keyIsDown
                 index=find(keyCode);
                 if (length(index) > 1)
                     index = 27;
                    return;
                 else
                     if (index==oneCode || index==twoCode || index==threeCode || index==fourCode || index==fiveCode)
                         hitindex = index;
                         break;
                     end
                 end
             end
        end
        
        if (hitindex>1)
            famresp = KbName(hitindex);
            reactionTime = timeSecs - starTime;
%             KbWait(-1,2);
        else 
            fprintf('No response recorded, moving on...\n');
            DrawFormattedText(w, 'NO RECORDED RESPONSE\nMoving on\n','center', 'center',red, wrapAt);
            wrapAt = 70;
            Screen('Flip',w);
            WaitSecs(2)
        end 
               
        fprintf('response: %s  DONE.\n',famresp);
        WaitSecs(.5); 
        
        %Write to log file 
        fprintf(logfile,'%d\t%s\t%s\t%3f\t%3f\t%s\t%s\t%s\t%s\t%s\t%s\n',i,songfileName,taskfirst,soundStartTime,soundEndTime,self_emoresponse,self_intensresponse,other_emoresponse, other_intensresponse, likeresp,famresp);
        
        DrawFormattedText(w,'Well done! \n\nNow, please press any key when you are ready for the next music clip.' ,'centerblock', 'center',textColor, wrapAt);
        Screen('Flip',w);
        fprintf('Trial #%d completed. Moving on.\n\n',i);
        %WaitSecs(1)
        KbWait(-1,2); 
        %Screen('FillRect', w,backgroundColor);
    end 
    
    text = 'You have completed this portion of the study.\n\n Please await further instructions.';
    Screen('FillRect',w,backgroundColor); 
    wrapAt = 50;
    DrawFormattedText(w, text,'centerblock', 'center',textColor, wrapAt);
    Screen('Flip',w);
    WaitSecs(10)
    fprintf('Successfully completed Music portion.\n\n',i);
%     KbWait(-1);
    
    %close
    Screen('CloseAll');
    
end

    
    
    