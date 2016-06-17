
function clickbarcallback(hdl,~)

DataIn=get(hdl,'UserDat');
tempdat=DataIn{1,1};
compdat=DataIn{1,2};
E=DataIn{1,3};

cP=get(gca,'CurrentPoint'); 
xdata=round(cP(1,1));

f1=figure; set(f1,'Color',[1 1 1]);
s1=subplot(1,2,1);
scatter(s1,tempdat,compdat{xdata,1}(E,:))
set(gca,'XGrid','on','YGrid','on','Box','off');
hl=lsline; set(hl,'Color','r')
title(strcat('Subject: ',num2str(xdata)));
ylabel('coefficients (single subject ERP)'); xlabel('coefficients (GA ERP)');

subplot(1,2,2);
[ax1,h1,h2]=plotyy(1:length(tempdat),tempdat,1:length(tempdat),compdat{xdata,1}(E,:));
set(ax1,'XGrid','on','YGrid','on','Box','off','YDir','reverse');
legend([h1 h2],'GA ERP - cubic spline interpolation',strcat('GA subject',num2str(xdata),'- cubic spline interpolation'),'Location','NorthEast');
title(horzcat('Comparison of GA ERP and ERP of Subject ', num2str(xdata)));
xlabel('Data Points'); ylabel('Piecewise Polynomial Coefficient');

end