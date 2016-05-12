function formatforMSD()

root=pwd;
subdirs=dir();
mkdir('Reformatted_Data_Files');
newFolder=strcat(pwd,'\Reformatted_Data_Files');
for i=3:length(subdirs)
    cd(subdirs(i).name);
    filename=dir('*.csv');
    VSTData=csvread(filename.name,1,0);
        formattedData=[VSTData(:,2),VSTData(:,1),VSTData(:,3),VSTData(:,4)];
        formattedData=sortrows(formattedData);
        
        tiflist=dir('*.tif');
        for k=1:length(tiflist)
            if(isempty(strfind(tiflist(k).name,'frame')))
                [path,name,ext]=fileparts(tiflist(k).name);
                newname=name;
                break;
            end
        end
        newname=strcat(newname,' (final).xlsx');
        xlswrite(newname,formattedData,'Sheet3');
        cd(newFolder);
        xlswrite(newname,formattedData,'Sheet3');
        cd(root);
end 
    


