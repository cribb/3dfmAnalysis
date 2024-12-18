function [SNR, signal, background, noise]=calc_video_SNR(filepath,filenum,beadsize,filetype,thresh)

double errorthresh;
cd(filepath);

switch filetype 
    case '.tif'
     files=dir('*.tif');
    case '.pgm'
      files=dir('*.pgm');
end 

if nargin <5 || isempty(thresh)
    thresh=.3;
end
threshold=thresh;
if isempty(files)
    error('No files in list. Wrong filename?');
end

if (beadsize==1000 || beadsize==2000)
    errorthresh=.001;
else
     errorthresh=.01;
end    
filename = files(filenum).name;
    
info=imfinfo(filename);
num_images=numel(info);
    
    if (num_images==1)
        for fid=1:length(files)
            filename=files(fid).name;
            im=imread(filename);
            picinfo = imfinfo(filename);
            bit = picinfo.BitDepth;
                
                if bit ~=8 && bit~=16
                       error('image neither 16-bit or 8-bit depth');
                end
            frame(:,:,fid) = im;
        end
   
         im=mean(frame,3);
         im = im/fid;
         
         background = imopen(im,strel('disk',100));
         
        for i=1:fid
            
              frame(:,:,i)=double(frame(:,:,i))-background;
             [avgSNR(i), mean_max_sig(i), image_background(i), image_noise(i)] = tracking_single_image_SNR(frame(:,:,i), errorthresh,'n',threshold,bit);
             
    
        end
   tracking_single_image_SNR(frame(:,:,1),errorthresh,'y',threshold,bit);     
   SNR=mean(avgSNR)
   signal=mean(mean_max_sig)
   background=mean(image_background)
   noise=mean(image_noise)
  err=std(avgSNR)/sqrt(length(avgSNR))
  snfig = figure; 
 plot(1:length(avgSNR), avgSNR);
% h= errorbar(1:length(avgSNR),avgSNR);
  %// a color spec here would affect both data and error bars
%hc = get(h, 'Children');
%set(hc(1),'color','b') %// data
%set(hc(2),'color','g') %// error bars
  xlabel('Frame #');
   ylabel('Signal-to-Noise Ratio');
   title([filename]);
   pretty_plot;
  
        
        
    else
        for k=1:num_images
            im=imread(filename,k);
            picinfo = imfinfo(filename);
            bit = picinfo.BitDepth;

             switch bit
                case 16
                    q = double(im);
                    q = q/2^16*2^8;
                    im = uint8(q);
                case 8
            % No change required
                otherwise
                     error('image neither 16-bit or 8-bit depth');
         end
   
            frame(:,:,k)=im;
   
   
   
        end

          im=mean(frame,3);
          im = im/num_images;
          background = imopen(im,strel('disk',100));
        for i=1:num_images
             frame(:,:,i)=double(frame(:,:,i))-background;
             [avgSNR(i), mean_max_sig(i), image_background(i), image_noise(i)] = tracking_single_image_SNR(frame(:,:,i), errorthresh,'n',threshold,bit);
                 
        end
tracking_single_image(frame(:,:,1),errorthresh,'y',threshold, bit);
  SNR=mean(avgSNR)
   signal=mean(mean_max_sig)
   background=mean(image_background)
   noise=mean(image_noise)
   err=stddev(avgSNR)/sqrt(length(avgSNR))
   snfig = figure; 
   plot(1:length(snr), snr);
   %errorbar(1:length(snr),snr,total_error);
   xlabel('Frame #');
   ylabel('Signal-to-Noise Ratio');
   title([filename]);
   pretty_plot; 
       
    end
    return;
    
    
    
  
  