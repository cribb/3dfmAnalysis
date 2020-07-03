function A = filter_min_intensity(data, min_intensity)
    A = load_video_tracking(data, [], 'pixels', 1, 'absolute', 'no', 'matrix');
    video_tracking_constants;
    ids_to_remove=[];
    
    
    col1=(A(:,ID));
    col2=(A(:,CENTINTS));
    tempMat=horzcat(col1,col2);
    idlist=unique(tempMat(:,1));
    for i =1:length(idlist)
            tracker_data=find(tempMat(:,1)==idlist(i));
             intens_data=tempMat(tracker_data,:);
            avg_intensity=mean(intens_data);
         if (avg_intensity<min_intensity)
             ids_to_remove(end+1) = idlist(i);
         end
    end
    if isempty(ids_to_remove)
        fprintf('Nothing to remove');
        return;
    end
    
    midx = zeros(size(A,1),1);
    for k = 1:length(ids_to_remove)
        idx = ( A(:,ID) == ids_to_remove(k) );
        midx = or(midx, idx);
    end
    
     A(midx,:) = [];
     B=horzcat(A(:,FRAME),A(:,ID),A(:,X),A(:,Y),A(:,Z),A(:,WELL),A(:,CENTINTS),A(:,ROLL),A(:,PITCH),A(:,YAW),A(:,WELL),A(:,WELL),A(:,WELL),A(:,AREA),A(:,SENS));
     [pathstr,name,ext] = fileparts(data);
     cd(pathstr);
     filename=strcat(name,'_filtered.csv');
     csvwrite(filename,B);
return;