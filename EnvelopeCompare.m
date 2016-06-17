% Date: 15-06-2016                          Programmed by: D. Bolger
% Scritp to calculate and visualise distance metrics from models of
% selected GA ERP signal for a single electrode, extracted by polynomial regression, with models of the
% same interval for each individual subject.
% It uses the dynamic time warping (DTW) and cosine distances to evualate the
% difference between the GA ERP and the signals for each subject for the
% same temporal interval.
% The DTW values are plotted as a bar plot against the cosine distances.
% Selecting a single bar will open a figure presenting a scatter plot of
% the GA ERP and single-subject ERP with a slope fitted (by least-squares)
% and a plot of the two ERPs as a function of time.
%************************************************************************************
numsub=30;
condnum=2;
d1=zeros(numsub,1);
D=zeros(numsub,1);
elec=48;
tempdata=curvefitteddata{condnum,elec};
b1=zeros(numsub,1);
s1=zeros(numsub,1);
f2=figure; set(f2,'Color',[1 1 1])
condnames={'Cond1' 'Cond2'};

for counter=1:numsub
    
    subnum=counter;
    
    compdata=GAcurvedata{subnum,condnum}(elec,:);
    
    DIn=cat(1,tempdata',compdata);
    D(counter)=pdist(DIn,'spearman');
    
    [d1(counter),~]=dtw(tempdata',compdata);
    
    s1(counter)=stem(1:numsub,D,'r-');
    hold on
    b1(counter)=bar(1:numsub,d1);
    title(horzcat('Electrode: ',EEG.chanlocs(elec).labels,':  Condition ',condnames{1,condnum}));
    set(gca,'XGrid','on','YGrid','on','Box','off','XTick',[1:30]);
    ylabel('DTW - Dis-similarity'); xlabel('Subject Number');
    
    if counter==1
        legend([b1(counter) s1(counter)],'DWT','Spearman Correlation','Location','NorthEast');
    end
    
end


set(b1,'Userdata',{tempdata,GAcurvedata,elec},'ButtonDownFcn',@clickbarcallback);








