Edited May 1st, 2019

This folder contains music and film stimuli presented in Sachs et al. (2018) as well as matlab scripts to run the experiment, written by Jonas Kaplan and Matthew Sachs 

REQUIREMENTS
#############

Matlab 2013 or higher and updated versions of Psychtoolbox are required to run all matlab scripts 

INSTRUCTIONs
#############

To run the study with the film stimuli, use embody_film.m. To run the study with the musical stimuli, use embody_music.m
An additional script (embody_music_middle.m) can be used if the embody_music.m script fails or quits before the completion of the study. This script finds where the last one stopped and runs the next, non-completed trial. 


Inputs for this script are the subject ID as a string variable EX: embody_film(‘sub-01’)

The script automatically pseudorandomizes the order of the presented stimuli and creates a unique matlab variable for each participants with this randomized trial order (located in trialorder_film and trialorder_music). 

The script first launches a webpage (located in webserver_scripts/embody_film or embody_music) that registers the participant and creates a folder on the web server where the embody tool is being launched. Data from each trial is located here. 


The script then presents all instructions and stimuli on the screen through Psychtoolbox. After the stimuli is presented, the script launches a webpage through the browser with the two empty bodies for drawing for each trial. After drawings, the participants are presented with a series of questions (on the screen where stimuli were presented through Psychtoolbox) about the stimuli. Responses are recorded as a text file in the logfile folder in this directory. 



 
