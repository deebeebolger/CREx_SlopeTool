function [pks,minima,locs_pks,locs_mins]= CREx_peakfinder(XIn)
% Date: 26-05-2016    Programmed by: D. Bolger
% Use of first order differences to locate peaks.
%******************************************************
diffX=diff(XIn);
d=sign(diffX);    %find the 10D of y-values returning 1 if element > 0 and -1 if <0
idx=find(d==0);  %find possible pleateaus.
Lend=length(d);

if isempty(idx)==0
    %Back propogate 1OD for plateaus
    for i=length(idx):-1:1
        
        if d(min(idx(i)+1,Lend))>=0
            d(idx(i))=1;
        else
            d(idx(i))=-1;
        end
        
    end
    
    locs_pk=find(diff(d)==-2)+1; % these are the peaks
    locs_mins=find(diff(d)==2)+1;
else
    
    locs_pks=find(diff(d)==-2)+1;
    locs_mins=find(diff(d)==2)+1;
end

pks=XIn(locs_pks);
minima=XIn(locs_mins);
end