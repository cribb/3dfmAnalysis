function formattedData=formatForCSVCompare(filename)
  [pa,name,ext]=fileparts(filename);
  if(strcmp(ext,'.xlsx'))
    XLdata=xlsread(filename,3);
  else
    XLdata=csvread(filename);
  end
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
    