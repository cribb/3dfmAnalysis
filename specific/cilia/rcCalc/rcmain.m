
%rcmain takes a tiff file as it's input minus the extension as well as
%a filename for the saved file. If the file doesn't exist it makes it with
%the units as headers for the colums. If the file does exist then it just
%appends the data to the exisitng file. If no filename for the saved name 
%is specified it just outputs the data as a vector in matlab.

function rcdata = rcmain(rcfile,rcoutput)
    
    %adds extension to files
    rcfile = strcat(rcfile, '.tif');
     
    I = imread(rcfile);
    imshow(I);
    
    %Runs set scale wich outputs units and pixal to unit ratio 
    [units, p_ratio] = setscale();    

    waitfor(msgbox(sprintf('Click three points along arc and enter to take radius of curvature and length.  \n If you want the lenght of a line, click two points then enter.')));

    %Set up counters
    CollectData = 1;
    i = 1;

    %
    while CollectData == 1
        
        points = ginput(4);
        lpoints = size(points);
        lpoints = lpoints(:,1);

        %Ends while loop if no points are chosesn
        if isempty(points) == 1;

            CollectData = 0;

        %Gives error if wrong number of points are chosen
        
       
        %if three points calc arclength and r curve
        elseif lpoints == 3
            
            %takes results of rccalc calibrates to the pixal ratio
            [radius arclength] = rccalc(points);
            rcdata(i,1) = radius*p_ratio;
            rcdata(i,2) = arclength*p_ratio;
            i = i + 1;
            
        %if only two points calculates length and put radious as zero
        elseif lpoints ==2
            
            rcdata(i,1) = 0;
            rcdata(i,2) = sqrt((points(1,1)-points(2,1))^2+(points(1,2)-points(2,2))^2)*p_ratio;
            i = i+1;
            
        else
             
            waitfor(msgbox('You must click two or three points'));

        end

    end

    %If filename is specified save file
    if isempty(rcoutput) == 0;
    
        rcoutput = strcat(rcoutput, '.csv');

        %check to see if file already exists if so appends data to file
        if exist(rcoutput,'file') == 2
            dlmwrite(rcoutput, rcdata,'-append');

        %otherwise write a new file with headers
        else

            headers = {['Radius ' units] ['Length ' units]};
            fid = fopen(rcoutput,'w');
                % Write headers
                for i=1:length(headers)
                    fprintf(fid,'%s,',headers{i});
                end
            fprintf(fid,'\n');
            fclose(fid);

            %write data
            dlmwrite(rcoutput, rcdata,'-append');
        end 
    else
        dps('done');
    end
    
  
