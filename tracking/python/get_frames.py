def get_frames():
    import os,shutil,PIL
    from PIL import Image
     
    directory=os.getcwd()
    #find all tif stacks
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.tif'):                #find only tif files
               rtname=os.path.basename(file) 
               rtname=rtname.split('.')
              
               newfilepath=os.path.join(directory,rtname[0])  #naming and creation of new folder for individual videos
               os.makedirs(newfilepath);
               shutil.move(file,newfilepath);
               os.chdir(newfilepath);
               im=Image.open(file)      
               imcount=im.n_frames
               for i in range(0,imcount): ##individual frames saved
                im.save('frame_%04i.tif'%(i,))
            os.chdir(directory)
    print('done with frames')
                   
#     
