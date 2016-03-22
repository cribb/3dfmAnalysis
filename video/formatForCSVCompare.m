function formattedData=formatForCSVCompare(filename)
  XLdata=xlsread(filename,3);
  sz=size(XLdata);
  formattedData=zeros(sz(1),16);
  formattedData(:,1)=XLdata(:,2);
  formattedData(:,2)=XLdata(:,1);
  formattedData(:,3)=XLdata(:,3);
  formattedData(:,4)=XLdata(:,4);
  formattedData=sortrows(formattedData);
  
  root=strsplit(filename,'.');
  newname=char(strcat(root(1),'_compareFormat.csv'));
  csvwrite(newname,formattedData)
    