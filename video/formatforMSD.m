function formatforMSD(filename)

VSTData=csvread(filename,1,0);
formattedData=[VSTData(:,2),VSTData(:,1),VSTData(:,3),VSTData(:,4)];
formattedData=sortrows(formattedData);
root=strsplit(filename,'.');
newname=char(strcat(root(1),'_MSDFormat.csv'));
csvwrite(newname,formattedData)