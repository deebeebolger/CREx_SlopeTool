function GroupSlope=SaveSlopes(AllSetData,Time,Gnames,enumber,subnum,p1,p2)

%% Locate the troughs and peaks and calculate the slope coefficients for each electrode and condition at the subject level.
%Note that this function needs to run only once the interval of time has
%been selected. 

GAsubject=cell(subnum,length(Gnames));
TIndx=find(Time>=p1(1,1) & Time<=p2(1,1));
TimeIntval=Time(TIndx);

disp('****************************Saving All Slope Data ************************************');

for x=1:length(Gnames)
    
    Peakdata=cell(subnum,enumber);
    Troughdata=cell(subnum,enumber);
    Slopedata=cell(subnum,enumber);
    peaktimes=cell(subnum,enumber);
    troughtimes=cell(subnum,enumber);
    allslopedata=cell(subnum,enumber);
    
    for x1=1:subnum
        
        GAsubject{x1,x}=mean(AllSetData{1,x}(x1).data(1:enumber,TIndx,:),3);
        
        for eint=1:enumber
            
            [Peakdata{x1,eint},Troughdata{x1,eint},PeakIndx,TroughIndx,Polys,Slopedata{x1,eint},~,~,allslopedata{x1,eint},~]=CREx_getDataAnalyse([TimeIntval' GAsubject{x1,x}(eint,:)']);
            peaktimes{x1,eint}=TimeIntval(PeakIndx);
            troughtimes{x1,eint}=TimeIntval(TroughIndx);
            
        end
        
        
    end
     
    GroupSlope.(genvarname(Gnames{1,x})).peaks=Peakdata;
    GroupSlope.(genvarname(Gnames{1,x})).troughs=Troughdata;
    GroupSlope.(genvarname(Gnames{1,x})).peaktime=peaktimes;
    GroupSlope.(genvarname(Gnames{1,x})).troughtime=troughtimes;
    GroupSlope.(genvarname(Gnames{1,x})).polys=Polys;
    GroupSlope.(genvarname(Gnames{1,x})).slopes=Slopedata;
    GroupSlope.(genvarname(Gnames{1,x})).slopedata_all=allslopedata;
    
    
    %clear Peakdata Troughdata PeakIndx TroughIndx Polys Slopedata;
    
end
assignin('base','AllSlopeData',GroupSlope); 

end 

