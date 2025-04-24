import sys
import shutil
import os

#folder with all the replays
replaysFolder = "." 
# Get the list of all files in a directory
files = os.listdir(replaysFolder)


#for each file
for file in files:
	os.rename(file, file.lower())


