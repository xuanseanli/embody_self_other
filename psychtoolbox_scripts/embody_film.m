 function embody_film(subjectCode)

    %stop sync
    KbName('UnifyKeyNames');                    %use unified keyboard key names (multi-OS compatibility)
    Screen('Preference','VisualDebugLevel',1);  %make sure to get errors printed 
    Screen('Preference', 'Verbosity', 1)
    Screen('Preference', 'SkipSyncTests', 1)
    
    %set seed
    rng shuffle

    %CONTROL CLIP TIME, SIZE
    fromTime=0;     % second to start in movie
    toTime=inf;     % second to stop in movie
    soundvolume=1;  % 0 to 1
    moviesize=4;    % 1 original, 2 double, 4 fullscreen
    
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
    logfilename = sprintf('%s_film.txt',subjectCode); %s is subject codename
    fprintf('Opening logfile: %s\n',logfilename); %prints to screen
    logfile = fopen([pwd '/logfiles/' logfilename],'a');
    fprintf(logfile,'## FILM LOG FOR SUBJECT %s\n',subjectCode);
    fprintf (logfile, '## %s\n',datestr(now));  %datestr(now) gives the current date and time in default format
    fprintf (logfile, '## trial\tstimname\ttaskfirst\tstimstart\tstimend\tselfemo\tselfintens\totheremo\totherintens\tlike\tfamiliar\n');
    
    %Set up presentation file
%     presfilename = sprintf('/Volumes/MusicProject/Embody/subjects_adults_film/%s/presentation.txt',subjectCode); %s is subject codename
%     fprintf('Making presentation file: %s\n',logfilename); %prints to screen
%     presfile = fopen(presfilename,'a');
   
    %define the path for movie 
    moviedir = [pwd '/film'];
    moviefilelist = dir(moviedir);
    moviefileNames = {moviefilelist(:).name}; 
    
    %movie = Screen('OpenMovie',0, moviename); 
   
    %remove hidden files 
    for i = 1:3
        moviefileNames{i} = [];    
    end
    moviefileNames = moviefileNames(~cellfun(@isempty, moviefileNames));
    
    %shuffle fileNames
    moviefileOrder = randperm(numel(moviefileNames)); %assigns random numbers
    movieOrder = moviefileNames(moviefileOrder) % .mp4 movie titles randomized

    %Save the trial order
    counter = 0; 
    outfilenametest = sprintf([pwd '/trialorder_film/%s_trialorder.mat'],subjectCode); 
    if exist(outfilenametest) == 2
        counter = 0 + 1;
        outfilename = sprintf('%s_trialorder_%d.mat',subjectCode,counter);
    else 
        outfilename = sprintf('%s_trialorder.mat',subjectCode);
    end
    
    save([pwd '/trialorder_film/' outfilename],'movieOrder');

    
    %get the character for each movie 
    characters = {'THE MAN','THE WOMAN','THE MAN','THE GIRL','THE MAN','THE WOMAN','THE MAN','THE MOTHER'};
    characterOrder = characters(moviefileOrder);
    
    %get still screenshot images for each movie 
    imagedir = [pwd '/still_image'];
    imagelist = dir(imagedir);
    imagefileNames = {imagelist(:).name};
    for i = 1:3
        imagefileNames{i} = [];    
    end
    imagefileNames = imagefileNames(~cellfun(@isempty, imagefileNames));
    imageorder = imagefileNames(moviefileOrder); 

    %OPEN THE SCREEN
    [w,rect]=Screen('OpenWindow', max(Screen('screens')), 0);
    
    %SAVE SCREEN DIMENSIONS
    screenX = rect(3);
    screenY = rect(4);
    xcenter = screenX/2; 
    ycenter = screenY/2;
    Screen('TextSize' ,w, 38);
    Screen('TextFont',w,'Helvetica');
    
    %Experiment start time
    %DRAW FIXATION
    Screen('FillRect', w,backgroundColor); 
    %Screen('DrawLines',w,fixationlines,fixationwidth,fixationcolor,[xcenter ycenter]);
    expStart = Screen('Flip',w);
%     expStart
    
    %randomize the order of self vs. other
    order = [1 2 1 2 1 2 1 2]; 
    totaltrial = [0 2 4 6 8 10 12 14];
    taskorder = order(randperm(8))
    
    registerpage = sprintf('http://cortex.usc.edu/embody_film/autoregister.php?userID=%s',subjectCode);
    web(registerpage, '-browser')
    
    %% MOVIES
    
    for i = 1:length(movieOrder)
        moviename = movieOrder{i};
        character = characterOrder{i};
        moviepath = sprintf('%s/%s',moviedir, moviename); 
        fprintf('%s\n',moviename);
        fprintf('%s\n',moviepath);
        [movie,dur,fps,width,height]=Screen('OpenMovie', w, moviepath);
        Screen('SetMovieTimeIndex', movie, fromTime);
       
        % deal with movie size
%         moviesize = 1;
%         if moviesize==1, movierect=[];
%         else
%             movierect=moviesize*[width height];
%             ratio=max(movierect./rect(3:4));
%             if ratio>1, movierect=movierect/ratio; end
%             movierect=CenterRect([0 0 movierect],rect);
%         end
        
        sourcerect = [0 0 width height];
        h = (rect(3)/width)*height; 
%         destinrect = [0 0 rect(3) h];
        offset = (rect(4)-h)/2;
        destinrect = [0 (0+offset) rect(3) (h+offset)];

        
        %PRESENT START Screen
        if i == 1  
            text = 'Thank you for agreeing to participate in our study!\n\nYou are now going to WATCH several film clips. \n\nAfter each, you will be asked to identify where on your body you felt an emotional response as well as where on the body you think the character portrayed in the film felt an emotional response. \n\n When you are ready to begin, press any key';
            Screen('FillRect',w,backgroundColor); 
            wrapAt = 50;
            DrawFormattedText(w, text,'centerblock', 'center',textColor, wrapAt);
            Screen('Flip',w);
            fprintf('Waiting for keypress to present movie clip...\n');
            KbWait(-1,2);
%         else
%             text = 'Press any key to continue to the next clip';
%             Screen('FillRect',w,backgroundColor);
%             wrapAt = 50;
%             DrawFormattedText(w,text,'center','center',textColor,wrapAt);
%             Screen('Flip',w);
%             %WaitSecs(2) 
%             fprintf('Waiting for keypress to present movie clip...\n')
%             KbWait(-1);
        end
    

        % Include Movie Descriptions
        for matchStr = regexp('H1.mp4',moviename,'match');
            text = 'In this clip, you will see a man, trapped on a desert island, successfully making fire. \n\nPress any key to continue.'; 
            Screen('FillRect',w,backgroundColor);
            wrapAt = 50;
            DrawFormattedText(w,text,'centerblock','center',textColor,wrapAt);
            Screen('Flip',w);
%             WaitSecs(1); 
            fprintf('Waiting for keypress to start movie...\n')
            KbWait(-1,2);
        end 
        
        for  matchStr = regexp('H2.mp4',moviename,'match');
            text = 'In this clip, you will see a girl receiving an important phone message regarding a beauty pageant she entered. \n\nPress any key to continue.'; 
            Screen('FillRect',w,backgroundColor);
            wrapAt = 50;
            DrawFormattedText(w,text,'centerblock','center',textColor,wrapAt);
            Screen('Flip',w);
%             WaitSecs(1); 
            fprintf('Waiting for keypress to start movie...\n');
            KbWait(-1,2);
            
        end
        
        for  matchStr = regexp('F2.mp4',moviename,'match');
            text = 'In this clip, you will see a woman psychologist confronted by one of her former subjects in the bathroom. \n\nPress any key to continue.'; 
            Screen('FillRect',w,backgroundColor);
            wrapAt = 50;
            DrawFormattedText(w,text,'centerblock','center',textColor,wrapAt);
            Screen('Flip',w);
%             WaitSecs(1);
            fprintf('Waiting for keypress to start movie...\n');
            KbWait(-1,2);
        end
        
        for  matchStr = regexp('F1.mp4',moviename,'match');
            text = 'In this clip, you will see a man being punished for trying to escape from his captor. \n\nPress any key to continue.'; 
            Screen('FillRect',w,backgroundColor);
            wrapAt = 50;
            DrawFormattedText(w,text,'centerblock','center',textColor,wrapAt);
            Screen('Flip',w);
%             WaitSecs(1);
            fprintf('Waiting for keypress to start movie...\n');
            KbWait(-1,2);
        end
        
        for  matchStr = regexp('M2.mp4',moviename,'match');
            text = 'In this clip, you will see a Jewish-Italian man and his son sneak into the guard post in a concentration camp during the Holocaust. \n\nPress any key to continue.'; 
            Screen('FillRect',w,backgroundColor);
            wrapAt = 50;
            DrawFormattedText(w,text,'centerblock','center',textColor,wrapAt);
            Screen('Flip',w);
%             WaitSecs(1);
            fprintf('Waiting for keypress to start movie...\n');
            KbWait(-1,2);
            
        end
        
        for  matchStr = regexp('M1.mov',moviename,'match');
            text = 'In this clip, you will see a man receive a letter from a nun in Tanzania, who is writing on behalf of the illiterate, orphaned, Aftrican boy that the man has been sponsoring. \n\nPress any key to continue.'; 
            Screen('FillRect',w,backgroundColor);
            wrapAt = 50;
            DrawFormattedText(w,text,'centerblock','center',textColor,wrapAt);
            Screen('Flip',w);
%             WaitSecs(1); 
            fprintf('Waiting for keypress to start movie...\n');
            KbWait(-1,2);
            
        end 
        
        for  matchStr = regexp('S1.mp4',moviename,'match');
            text = 'In this clip, you will see a man and a woman discussing the end of their marriage. \n\nPress any key to continue.'; 
            Screen('FillRect',w,backgroundColor);
            wrapAt = 50;
            DrawFormattedText(w,text,'centerblock','center',textColor,wrapAt);
            Screen('Flip',w);
%             WaitSecs(1); 
            fprintf('Waiting for keypress to start movie...\n');
            KbWait(-1,2);
            
        end 
        
        for  matchStr = regexp('S2.mp4',moviename,'match');
            text = 'In this clip, you will see a boy, locked out of his mother''s home, begging her for money. \n\nPress any key to continue.'; 
            Screen('FillRect',w,backgroundColor);
            wrapAt = 50;
            DrawFormattedText(w,text,'centerblock','center',textColor,wrapAt);
            Screen('Flip',w);
%             WaitSecs(1); 
            fprintf('Waiting for keypress to start movie...\n');
            KbWait(-1,2);
        end
    

        %PLAY MOVIE
        Screen('PlayMovie', movie, 1, 0, soundvolume); 
        fprintf('playing...');
        t=Screen('Flip', w);
        
        movieStartTime = t-expStart; 

        %fprintf(logfile, '%d\t%s\t%s\t%3f\t',trialCounter, stimName, taskName, movieStartTime); 
        %toTime=toTime-fromTime+t;  %time to stop playing (infinite since we want the whole movie)
        toTime= GetSecs + 1;
       
        %loop through each frame of the movie and present it
        
        while t<toTime		
            tex= Screen('GetMovieImage', w, movie);
            if tex<=0 , break; end;
            Screen('DrawTexture', w, tex,sourcerect,destinrect);
            t=Screen('Flip', w);
            Screen('Close',tex); 
        end

        movieEndTime = t-expStart;

        Screen('PlayMovie', movie, 0); % stops movie
        Screen('CloseMovie', movie);  
        fprintf('done...');
       
        %Direct to Body Map 
        DrawFormattedText(w, 'For the next part, please direct your attention to the Macbook computer screen on your LEFT. \n\nPress any key to continue.','centerblock', 'center',textColor, wrapAt);
        wrapAt = 50;
        Screen('Flip',w);
        %WaitSecs(1)
        KbWait(-1,2);
        
        selftext = 'Now, you are going to color the regions whose activity you feel increasing or getting stronger in YOUR BODY when you watched the clip. \n\nOn the LEFT body, color the regions whose activity you feel increasing or getting stronger on YOUR BODY when you watched the clip. \n\nOn the RIGHT body, color the regions whose activity you feel decreasing or getting weaker on YOUR BODY when you watched the clip. \n\nOnce you have finished, select "Click here when done" on the MacBook.'; 
        charactertext = sprintf('Now, you are going to color the regions of the body where you believe %s in the film is feeling activity. \n\nOn the LEFT body, color the regions whose activity you feel increasing or getting stronger on the body %s portrayed in the film. \n\nOn the RIGHT body, color the regions whose activity you feel decreasing or getting weaker on body of %s portrayed in the film. \n\nOnce you have finished, select "Click here when done" on the MacBook.',character, character, character);
        
        %Readin and Scale images
        image = imageorder{i};
%         image = imagefileNames{1};
        imagepath = sprintf('%s/%s',imagedir, image);
        imageData = imread(imagepath);
        imageTexture = Screen('MakeTexture',w,imageData);
        [imageheight, imagewidth, colorchannel] = size(imageData);
        imagerect = [0 0 imagewidth imageheight]; 
        imagerect = imagerect./4; 
%         destinationrect = CenterRect(imagerect,rect);
        destinationrect = [0 0  imagerect(3) imagerect(4)];

        %randomize order of self vs. other ratings
        task = taskorder(i);
        trial_1 = totaltrial(i); 
        percent_1 = (trial_1/16)*100;
        trial_2 = trial_1 + 1; 
        percent_2 = (trial_2/16)*100;
        fname = moviename(1:end-4)
        if task == 1
            filename_1 = sprintf('%s_self',fname);
            filename_2 = sprintf('%s_other',fname);
        elseif task == 2
            filename_1 = sprintf('%s_other',fname);
            filename_2 = sprintf('%s_self',fname);
        end
        trialpage_1 = sprintf('http://cortex.usc.edu/embody_film/paintannotate.php?perc=%.2f&userID=%s&presentation=%d&filename=%s',percent_1,subjectCode,trial_1,filename_1);
        trialpage_2 = sprintf('http://cortex.usc.edu/embody_film/paintannotate.php?perc=%.2f&userID=%s&presentation=%d&filename=%s',percent_2,subjectCode,trial_2,filename_2);
        
        if task == 1
            taskfirst = 'self';
            fprintf('\nSelf-rating first\n'); 
            trialnum = sprintf('Trial %d.1',i);
            DrawFormattedText(w, selftext,'centerblock', 'center',textColor, wrapAt);
            DrawFormattedText(w,trialnum,'centerblock',150,red);
            startDraw1 = Screen('Flip',w);
            
            %launch webpage
            web(trialpage_1,'-browser')
            
            %write to presentation file
%             presname = sprintf('%s-%d',filename_1,trial_1);
%             fprintf(presfile,'%s\n',presname);
            
            
            while GetSecs - startDraw1 <= 300;
                [clicks,x1,y1,whichButton] = GetClicks();
                if x1 > 872 && x1 < 1088 && y1 > 658 && y1 < 702;
                    fprintf('%.2f\t%.2f\n',x1,y1);
                    break
                end
            end
            
%             if finishedintime == 0;
%                 fprintf('No response recorded, moving on...\n');
%                 DrawFormattedText(w, 'NO RECORDED RESPONSE\nMoving on\n','center', 'center',red, wrapAt);
%                 Screen('Flip',w);
%                 WaitSecs(2)
%             end
            
            trialnum = sprintf('Trial %d.2',i);
            DrawFormattedText(w,charactertext,'centerblock', 'center',textColor, wrapAt);
            DrawFormattedText(w,trialnum,'centerblock',150,red);
            Screen('DrawTexture',w,imageTexture,[],destinationrect);
            startDraw2 = Screen('Flip',w);
            
            %launch second webpage
            web(trialpage_2, '-browser')
            
            %write to presentation file
%             presname = sprintf('%s-%d',filename_2,trial_2);
%             fprintf(presfile,'%s\n',presname);
            
            while GetSecs - startDraw2 <= 300;
                [clicks,x2,y2,whichButton] = GetClicks();
                if x2 > 872 && x2 < 1088 && y2 > 658 && y2 < 702;
                    fprintf('%.2f\t%.2f\n',x2,y2);
                    break
                end
            end
            
%             if finishedintime == 0;
%                 fprintf('No response recorded, moving on...\n');
%                 DrawFormattedText(w, 'NO RECORDED RESPONSE\nMoving on\n','center', 'center',red, wrapAt);
%                 Screen('Flip',w);
%                 WaitSecs(2)
%             end
            
        elseif task == 2
            taskfirst = 'other';
            fprintf('\nOther-rating first\n');
            trialnum = sprintf('Trial %d.1',i);
            DrawFormattedText(w, charactertext,'centerblock', 'center',textColor, wrapAt);
            DrawFormattedText(w,trialnum,'centerblock',150,red);
            Screen('DrawTexture',w,imageTexture,[],destinationrect);
            startDraw1 = Screen('Flip',w);
            
            %launch webpage
            web(trialpage_1,'-browser')
            
%             write to presentation file
%             presname = sprintf('%s-%d',filename_1,trial_1);
%             fprintf(presfile,'%s\n',presname);
            
            while GetSecs - startDraw1 <= 300;
                [clicks,x1,y1,whichButton] = GetClicks();
                if x1 > 872 && x1 < 1088 && y1 > 658 && y1 < 702;
                    fprintf('%.2f\t%.2f\n',x1,y1);
                    break
                end
            end
            
%             if finishedintime == 0;
%                 fprintf('No response recorded, moving on...\n');
%                 DrawFormattedText(w, 'NO RECORDED RESPONSE\nMoving on\n','center', 'center',red, wrapAt);
%                 Screen('Flip',w);
%                 WaitSecs(2)
%             end

            trialnum = sprintf('Trial %d.2',i);
            DrawFormattedText(w,selftext,'centerblock', 'center',textColor, wrapAt);
            DrawFormattedText(w,trialnum,'centerblock',150,red);
            startDraw2 = Screen('Flip',w);
            
            %launch second webpage
            web(trialpage_2,'-browser')
            
            %write to presentation file
%             presname = sprintf('%s-%d',filename_2,trial_2);
%             fprintf(presfile,'%s\n',presname);
            
            while GetSecs - startDraw2 <= 300;
                [clicks,x2,y2,whichButton] = GetClicks();
                if x2 > 872 && x2 < 1088 && y2 > 658 && y2 < 702;
                    fprintf('%.2f\t%.2f\n',x2,y2);
                    break
                end
            end
        end
            
       
%         [clicks,x3,y3,whichButton] = GetClicks();
%         fprintf('%.2f\t%.2f\n',x3,y3);
%         [clicks,x4,y4,whichButton] = GetClicks();
%         fprintf('%.2f\t%.2f\n'),x4,y4;
%         [clicks,x5,y5,whichButton] = GetClicks();
%         fprintf('%.2f\t%.2f\n'),x5,y5;
%           872, 1088, 658, 702      
       
        DrawFormattedText(w,'Great job. \n\nNow, direct your attention back to THIS screen for a few more questions.\n\nPress any key to continue.' ,'centerblock', 'center',textColor, wrapAt);
        Screen('Flip',w);
        fprintf('Waiting for keypress to present questions...\n');
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
        selfques = 'What specific emotion did YOU feel when watching the clip';
        emoansw = '1 - Sad\n\n2 - Happy\n\n3 - Angry\n\n4 - Calm\n\n5 - Fear\n\n6 - I felt more than one of these emotions fairly strongly';  
        emoansw2 = '1 - Sad\n\n2 - Happy\n\n3 - Angry\n\n4 - Calm\n\n5 - Fear\n\n6 - He/she felt more than one of these emotions fairly strongly'; 
        Screen('FillRect', w,backgroundColor);
        wrapAt = 80; 
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
        otherques = sprintf('What specific emotion do you think %s in the film clip was feeling', character); 
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
        question = sprintf('How strongly did %s in the film clip feel this emotion', character);
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
        likeques = 'How much did you like watching this film clip?';
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
        famques = 'How familiar were you with the film clip you just saw';
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
        fprintf(logfile,'%d\t%s\t%s\t%3f\t%3f\t%s\t%s\t%s\t%s\t%s\t%s\n',i,moviename,taskfirst,movieStartTime,movieEndTime,self_emoresponse,self_intensresponse,other_emoresponse, other_intensresponse,likeresp,famresp);
        
        
        %Continue next clip
        DrawFormattedText(w,'Well done! \n\nNow, please press any key when you are ready for the next clip.' ,'center', 'center',textColor, wrapAt);
        Screen('Flip',w);
        fprintf('Waiting for keypress to start...\n');
        %WaitSecs(1)
        KbWait(-1,2); 
        %Screen('FillRect', w,backgroundColor);
    end 
    
    %Ending instructions
    text = 'You have completed this portion of the study.\n\n Please await further instructions.';
    Screen('FillRect',w,backgroundColor); 
    wrapAt = 50;
    DrawFormattedText(w, text,'centerblock', 'center',textColor, wrapAt);
    Screen('Flip',w);
    WaitSecs(10)
%     fprintf('Waiting for keypress to present movie clip...\n');
%     KbWait(-1);
    
    %close
    Screen('CloseAll');
    
end
