function ClickonData(hdl,~)


disp('************interactive mode***********')
D=get(hdl,'UserDat');
axh=D{1,1};  %get the current axes data
fh=D{1,2};
groupnoms=D{1,3};
Enums=D{1,4};
time=D{1,5};
meanData=D{1,6};
chanls=D{1,7};
allsets=D{1,8};
sujnumber=D{1,9};


point1=get(axh,'CurrentPoint');
rect_pos=rbbox;
point2=get(axh,'CurrentPoint');
assignin('base','point1',point1);      %assign these values to the current workspace
assignin('base','point2',point2);



allLines=findall(axh,'Type','line');  %returns handles of all lines
dataInRect=cell(length(allLines),1);

for n=1:length(allLines)
    dataInRect{n,1}=getDataInRect(point1(1,1:2),point2(1,1:2),allLines(n));  %call of function to extract data from data selected
end

%CREx_SlopePlot(dataInRect);

%% Plot the data in the selected region for each Condition and each electrode

f1=zeros(length(groupnoms),1);                             %should be same length as dataInRect cell array i.e. number of lines
indT=find(time>=point1(1,1) & time<=point2(1,1)); %define the time interval corresponding to the region selected. Note the point1 and point2 variables calculated in the function ClickonData.
Time_int=time(indT);
dataIntval=cell(length(groupnoms),Enums);
peaks=cell(length(groupnoms),Enums);
troughs=cell(length(groupnoms),Enums);
slopes=cell(length(groupnoms),Enums);
plh=zeros(length(groupnoms),Enums);
curvedata=cell(length(groupnoms),Enums);
splot_rows=8;

SlopeData=SaveSlopes(allsets,time,groupnoms,Enums,sujnumber,point1,point2);%Call of function here to save the slope data of individual subjects

for condcnt=1:length(groupnoms)
    
    f1(condcnt,1)=figure; set(f1(condcnt,1),'Color',[1 1 1],'Name',groupnoms{1,condcnt});
    
    for ecnt=1:Enums
        
        plh(condcnt,ecnt)=subplot(splot_rows,ceil(Enums/splot_rows),ecnt);
        dataIntval{condcnt,ecnt}=meanData{1,condcnt}(ecnt,indT);
        plot(Time_int,dataIntval{condcnt,ecnt});
        set(gca,'XGrid','on','YGrid','on','Box','off','YDir','reverse');
        title(chanls{1,ecnt});
        
        [peaks{condcnt,ecnt},troughs{condcnt,ecnt},pindx,tindx,polys,slopes{condcnt,ecnt},Xdata,Ydata,~,curvedata{condcnt,ecnt}]=CREx_getDataAnalyse([Time_int' dataIntval{condcnt,ecnt}']); %call of function to locate the peaks and troughs and calculate the slope coefficient
        
        hold on
        plot(Time_int(pindx),peaks{condcnt,ecnt},'or')
        hold on
        plot(Time_int(tindx),troughs{condcnt,ecnt},'ok')
        hold on
        
        set(plh(condcnt,ecnt),'HitTest','on','SelectionHighlight','on','UserData',{Time_int,dataIntval{condcnt,ecnt},pindx,tindx,peaks{condcnt,ecnt},troughs{condcnt,ecnt},polys,slopes{condcnt,ecnt},Xdata,chanls{1,ecnt},time,meanData{1,condcnt}(ecnt,:),...
            groupnoms{1,condcnt},SlopeData,ecnt,Ydata,curvedata{condcnt,ecnt}},'NextPlot','new');
        set(plh(condcnt,ecnt),'ButtonDownFcn',@plotsingle)
        
    end
    
    
end %end of condcnt loop


end

%****************************************************************Sub-Functions*******************************************************************************************

%% CALL OF BUTTONDOWNFCN FUNCTION
function plotsingle(hdl,~)

D=get(hdl,'UserDat');
tind=D{1,1};      %time of selection
dataIn=D{1,2};   %data over selected interval for current electrode
pind=D{1,3};      %indices of the peaks
trind=D{1,4};       %indices of the troughs
peaks=D{1,5};    %amplitudes of all the peaks
troffs=D{1,6};     %amplitudes of all the troughs or minima
polyn=D{1,7};
slpe=D{1,8};
xdata=D{1,9};
chnl=D{1,10};      %title of the current channel
Time=D{1,11};
AllData=D{1,12};
condnom=D{1,13};
slopedata=D{1,14};
Eind=D{1,15};
ydata=D{1,16};
curves=D{1,17};

f1=figure; set(f1,'Color',[1 1 1],'Position',[100 100 1500 895])
subplot(2,2,1)
plot(tind,dataIn)
set(gca,'XGrid','on','YGrid','on','Box','off')
title(strcat(condnom,'-',chnl,' selected interval')); xlabel('time(ms)'); ylabel('amplitude(\muV)');
hold on
plot(tind(pind),peaks,'or');
hold on
plot(tind(trind),troffs,'ok');
hold on

lineplot=zeros(length(polyn),1);   %predefine matrix to hold line plot handles

for cnt=1:length(polyn)
    %slpe(cnt)=slpe(cnt)*-1;
    lineplot(cnt)=plot(xdata{cnt,1},polyn{cnt,1},'r','LineWidth',2);
    hold on
    set(gca,'YDir','reverse');
    set(lineplot(cnt),'HitTest','on','SelectionHighlight','on','UserData',{slpe(cnt),xdata{cnt,1}},'ButtonDownFcn',@showslope);
    set(lineplot(cnt),'LineWidth',0.5);
   
end

s1=subplot(2,2,2);
plot(1:length(curves),curves,'k-o');
set(s1,'XGrid','on','YGrid','on','Box','off'); set(s1,'YDir','reverse');
title('Reproduction of envelope (12th order polynomial)');
ylabel('coefficients');
xlabel('coefficient number');

subplot(2,2,[3,4]);
plot(Time,AllData);
set(gca,'XGrid','on','YGrid','on','Box','off','YDir','reverse');
title(strcat(condnom,'-',chnl,' whole epoch')); xlabel('time(ms)'); ylabel('amplitude(\muV)');
hold on
p2=plot(tind,dataIn,'r');
set(p2,'LineWidth',3);

end

%% GET DATA IN THE SELECTED RECTANGLE

function dataout=getDataInRect(p1,p2,hlines)


if (p1(1)<p2(1))
    lowX=p1(1); highX=p2(1);
else
    lowX=p2(1); highX=p1(1);
end

if (p1(2)<p2(2))
    lowY=p1(2); highY=p2(2);
else
    lowY=p2(2); highY=p1(2);
end

xdata=get(hlines,'XData');
ydata=get(hlines,'YData');

xind=find(xdata>=lowX & xdata<=highX);
yind=find(ydata>=lowY & ydata<=highY);

dataout=[xdata(xind); ydata(xind)]';
end

%% CALL OF BUTTONDOWNFCN FUNCTION
function showslope(hdl,~)

D=get(hdl,'UserDat');
slope=D{1,1};
Xdata=D{1,2};

set(hdl,'LineWidth',4)

if sign(slope)==1
    peaktime=Xdata(end);
    trofftime=Xdata(1);
elseif sign(slope)==-1
    trofftime=Xdata(end);
    peaktime=Xdata(1);
end

annotation('textbox',[0.15 0.8 0.1 0.1], 'String', {['Slope=' num2str(slope)],['Peak= ' num2str(peaktime)],['Minima=' num2str(trofftime)]},...
    'FontSize',11,'Fontname','Arial','BackgroundColor',[0.95 0.95 0.95]);
    
end

