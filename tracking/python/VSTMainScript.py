import os
import AutoVSTLai
import sys

directory = sys.argv[1]
os.chdir(directory)
AutoVSTLai.main()

