% 
close all; clear all;

Cond_names={'NOL' 'NOL'};     %Can only have a single element
Group_names={'MotsCC' 'MotsIC'}; % Can only accept two elements
sujnum=30;                       %very important to specify the correct number of subjects.
elecnum=64;                     %number of electrodes over which to base GFP calculation.
channel='Cz';                     %electrode used for visualising the full epoch and selecting temporal interval

% Initialise variables
dircond=cell(1,length(Group_names));
filescond=cell(1,length(Group_names));
fileIndex=cell(1,length(Group_names));
currbase='F:\BLRI\EEG\Projets_en_cours\Projet_MotInter\ExpEEG_Phase1\Data_Biosemi\P1AUD_Results\'; %the base directory

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;  %open an eeglab session and load in all the necessary files

for condcnt=1:length(Group_names)
    
    dircond{1,condcnt}=strcat(currbase,Group_names{1,condcnt},'\',Cond_names{1,condcnt},'\');
    filescond{1,condcnt}=dir(dircond{1,condcnt});
    currfiles=filescond{1,condcnt};
    fileIndex{1,condcnt}=find(~[currfiles.isdir]);
    fInd=fileIndex{1,condcnt};
    x=strfind({currfiles.name},'.set');
    emptycell=[cellfun(@isempty,x)==0]; fIndx=find(emptycell);
    fload={currfiles(fIndx).name};
    
    if length(fload)~=sujnum
        uiwait(msgbox('The number of datasets in the current folder differs from the defined number of subjects','Inconsistency','error','modal'));   %abort execution if the number of subjects defined is not the same as the number of datafiles in current folder.
        break
    end
    
    EEG=pop_loadset('filename',fload,'filepath',dircond{1,condcnt})
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'study',0);
    EEG=eeg_checkset(EEG); eeglab redraw;
    
end

Time=ALLEEG(1).times;
ChanInfo=ALLEEG(1).chanlocs;

%% CALCULATE THE GRAND AVERAGE FOR EACH CONDITION

AllSets=cell(1,length(Group_names));
MeanSets=cell(1,length(Group_names));

for counter=1:length(Group_names)
    
    curstart=((sujnum*counter)-sujnum)+1;
    AllSets{1,counter}=ALLEEG(curstart:sujnum*counter);
    [MeanSets{1,counter},~,~,~,~]=pop_comperp(ALLEEG,1, [curstart:sujnum*counter]);  %calculates the means over all subjects for the current Condition and Group
    
end

%% CALL OF FUNCTIONS TO CALCULATE AND VISUALISE THE SLOPE COEFFICIENT DATA

p1=zeros(length(Group_names),1);
col={'b' 'g' 'k'}; %define colours
chanind=find(strcmpi(channel,{ChanInfo.labels}));   %find the indice of the channel/s defined

f1=figure; set(f1,'Color',[1 1 1],'Position',[100 100 1049 895])
for counter1=1:length(Group_names)
    
    p1(counter1)=plot(Time,MeanSets{1,counter1}(chanind,:),col{1,counter1});
    hold on
    set(gca,'XGrid','on','YGrid','on','Box','off','YDir','reverse')
    set(gca,'UserData',{gca,f1,Group_names,elecnum,Time,MeanSets,{ChanInfo.labels},AllSets,sujnum},'ButtonDownFcn',@ClickonData);    %call of function
    
    
end
title(strcat('Grand Average of Conditions , ',Cond_names{1,1},'  : ',Group_names{1,1},'&',Group_names{1,2},' Electrode ',channel ));
xlabel('Time (ms)');
legend(Group_names{1,1},Group_names{1,2},'Location','NorthEast');

clear counter counter1;




