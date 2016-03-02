from numpy import uint8, uint16
def roisin_thresh(adj):
    
    import PIL,os,numpy 
    from PIL import Image
    import matplotlib.pyplot as plt
    adj_threshold=[]
    directory=os.getcwd()
    #find all tif stacks
    for root, dirs, files in os.walk(directory):
        for folders in dirs:
            
            os.chdir(os.path.join(directory,folders))
            im=plt.imread('frame_0000.tif')
            os.chdir(directory) 
                        
            if im.max()>256:
               bit=16
            else:
               bit=8
                       
            
             
            if bit==16:
                              
                pixelCount,bins,_=numpy.histogram(im,bins=5000)
            else:
                
                pixelCount,bins,_= numpy.histogram(im,bins=256)
                
    
            max_peak=numpy.max(pixelCount)
            peak_coord=pixelCount.argmax()
            
            topPoint=[peak_coord, max_peak]
            ind_nonZero=numpy.nonzero(pixelCount)[-1]
            
            last_zeroBin=ind_nonZero[-1]
            bottomPoint=[last_zeroBin,pixelCount[last_zeroBin]]
            
            best_idx=-1
            max_dist=-1
            for x0 in range(peak_coord, last_zeroBin):
                 y0=pixelCount[x0]
                 a=[topPoint[0]-bottomPoint[0],topPoint[1]-bottomPoint[1]]
                 b=[x0-bottomPoint[0],y0-bottomPoint[1]]
                 cross_ab = a[0]*b[1]-b[0]*a[1]
                 d=numpy.linalg.norm(cross_ab)/numpy.linalg.norm(a)
                 if d>max_dist:
                     best_idx=x0
                     max_dist=d
            if bit==8:
                ints_cut=best_idx
                level=ints_cut/256
                
            else:
                ints_cut=best_idx*13.1
                level=ints_cut/65537
            maxPixel=numpy.max(im)
            minPixel=numpy.min(im)    
            threshold=(ints_cut)/((maxPixel-minPixel)+minPixel)
            
            if bit ==16:
                flat_length=maxPixel/13.1-best_idx;
                new_idx=best_idx+flat_length*adj
                adj_threshold=(new_idx*13.1)/((maxPixel-minPixel)+minPixel)
            else:
                flat_length=maxPixel-best_idx;
                new_idx=best_idx+flat_length*adj
                adj_threshold[len(adj_threshold)]=(new_idx)/((maxPixel-minPixel)+minPixel)
            
            
            
        return adj_threshold
              
    
    
    
    
    
    
    
    
    
    
    
    
 
    