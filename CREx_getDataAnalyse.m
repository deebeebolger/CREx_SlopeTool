function [peaks,minpeak,plocs,mlocs,p,slopes,Xdata,Ydata,slopesdata_all,curves]= CREx_getDataAnalyse(dataIn)
% Date: 27-5-2016                               Programmed by: D. Bolger
% Function to obtain the peaks and minima in the selected temporal region of the
% signal, by calling the function "CREx_peakfinder()' and to calculate the
% slope for each trough to peak difference, peakdiff, that exceeds a predefined
% amplitude (in mV). The default mV difference is 5mV. 
% Function called by CREx_ERPSlopeAmp_calc script.
% Input variables :
%                       - dataIn : n X 2 matrix with time data on first column and n data points on second column. [Time Data];
%                       - peakdiff: trough to peak difference limit
%
% Output variables:
%        - peaks: t
%        - minpeaks: temporal location of all minima.
%        - plocs: temporal location of all maxima
%        - mlocs: temporal locations of all minima.
%        - p: line fitted to the trough to peak curve
%        - slopes: the slopes values 
%        - Xdata: the x-axis data used in calculation of polynomial fitting
% Use as:  [peaks,troughs,pindx,tindx,polys,slopes,Xdata]=CREx_getDataAnalyse([Time_int' dataIntval']);
% ********************************************************************************************
                                                                   
[peaks,minpeak,plocs,mlocs]=CREx_peakfinder(dataIn(:,2));    %call of function to locate the peaks in the currently selected temporal region. 
peakdiff=0.01;                                          % set the peak to trough difference limit (mV)
pktimes=dataIn(plocs,1);                          %find the peak times
ttimes=dataIn(mlocs,1);                            %find the minima times
[allpktimes,indx]=sort(cat(1,pktimes,ttimes));
allpeaks=cat(1,peaks,minpeak);                %concatenate the peaks and troughs and sort in ascending order
allpeaks=allpeaks(indx);
allLocs=cat(1,plocs,mlocs); allLocs=allLocs(indx);
AllPeakData=[allpeaks,allpktimes,allLocs];
diffpeaks=abs(diff(allpeaks));
i=find(diffpeaks>=peakdiff);                   %find trough to peak differences that exceed 5mV to calculate slopes
slopes=zeros(length(i),1);
p=cell(length(i),1);
Xdata=cell(length(i),1);
Ydata=cell(length(i),1);
slopesdata_all=zeros(length(i),3);

%Calculate the slope for each trough to peak difference that exceeds 5mV
for icounter=1:length(i)
    
    Ydata{icounter,1}=dataIn(AllPeakData(i(icounter),3):AllPeakData(i(icounter)+1,3),2);                      % y-axis data to use in the polyfit
    Xdata{icounter,1}=dataIn(AllPeakData(i(icounter),3):AllPeakData(i(icounter)+1,3),1);      % x-axis data to use in the polyfit
    ply=polyfit(Xdata{icounter,1},Ydata{icounter,1},1);                                                                     %the first coefficient is the slope
    p{icounter,1}=polyval(ply,Xdata{icounter,1});
    slopes(icounter)=ply(1); slopes(icounter)=slopes(icounter)*-1;
    slopesdata_all(icounter,:)=[AllPeakData(i(icounter),2) AllPeakData(i(icounter)+1,2) slopes(icounter)];
     
end
     
    %fitting curve to the envelope of the selected time interval
    xdat=dataIn(:,1)-dataIn(1,1);
    ydat=(dataIn(:,2)-min(dataIn(:,2)))./(max(dataIn(:,2))-min(dataIn(:,2))); %scaling the data between 0 and 1
    [plycurve,~,mu]=polyfit(xdat,ydat,3);
    curves=polyval(plycurve,ydat,[],mu);
    

end





