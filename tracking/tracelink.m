function tracelink(conversion,MSD_cutoff)
root=pwd;
files=dir('*.xlsx');
saved=mkdir('Linked Files');
for i=1:length(files)
    data=xlsread(files(i).name,'Sheet3');
    particles=unique(data(:,1));
    num_particles=length(particles);
    
   
    for j=1:num_particles
        frames=(data(data(:,1)==particles(j),:));
        [m,~]=size(frames);
        entries{j}=frames(1,:);
        exits{j}=frames(m,:);

    end
    
    for j=1:num_particles
        current_exit=exits{j};
       [~,num]=size(entries);
        for k=1:num
            
            if(~isempty(entries{k})&&entries{k}(:,2)>current_exit(:,2)&& entries{k}(:,2)-current_exit(:,2)<6)
                distance=conversion*conversion*((entries{k}(:,3)-current_exit(:,3))^2 + (entries{k}(:,4)-current_exit(:,4))^2);
                if distance<MSD_cutoff
                    particle_to_link=entries{k}(:,1);
                    current_particle=current_exit(:,1);
                    test=data(data(:,1)==current_particle,:);
                    test(:,1)=particle_to_link;
                    data(data(:,1)==current_particle,:)=test;
                    entries{j}=[];
                    break;
                end    
            end
        end
        
    end
    
    
    final_data=sortrows(data);
    newName=['Linked_' files(i).name]
    cd('Linked Files');
    xlswrite(newName,final_data,'Sheet3');
    cd(root);
end