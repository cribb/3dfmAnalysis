#!/bin/bash


# This script is a simple wrapper for ffmpeg that makes it easy to use it to convert videos
# into png image stacks. The script takes in the name of video files, with appropriate extensions, and
# creates a folder, with the same name as the video, with the image stack. You may use
# wild cards to select multiple videos at a time. 

# Created:  10/10/2013
# Author:   Robert Judith 

# Examples of usage:

# ex. 1: Convert an avi file to image stack
# vid2stack file_name.avi

# ex. 2: Convert two videos to image stack
# vid2stack file_name1.avi file_name2.mp4
# This will create two folders file_name1 and file_name2 with the image stacks.

# ex. 3: Convert all avi files in folder to stacks
# vid2stack *.avi

# Current known issues:
#   - Videos with over 100,000 frames will crash
#   - Input arguments without extensions will crash the script

# To-Do
#   - Add progress bar for each file
#   - Add flag for verbose output
#   - Check to see if ffmpeg is installed and exit gracefully if not
#   - Add input argument argument checking




# Make sure code stops if any commands have an error.
# Also ensures code wont overite
set -e 
counter=1

for i in "$@" # Iterates over input arguments
do
    echo "Converting file $counter of $#"
    folder="${i%.*}"
    mkdir $folder
    cd $folder
    ffmpeg -loglevel panic -i "../$i" -an -f image2 "Image_%06d.png"
    cd ..
    counter=$[$counter+1]
done
