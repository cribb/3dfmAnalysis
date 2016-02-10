def autotrack(startframe): #start must be a string that indicates the name of the first frame of each video (all videos should have the same first frame name) including the file extension
	#print 'Testing autotrack'
	import os, shutil
	rootdir = os.getcwd()
	start,filetype = os.path.splitext(startframe)
	
	autofindframename = 'autofind_frame'+filetype
	startframename = start+filetype
	print(startframename)
	findlist = []
	files = []
	for dirpath, dirnames, filenames in os.walk(rootdir):
		for filename in [f for f in filenames if f.endswith(start+filetype)]:
			findlist.append(os.path.join(dirpath,filename))
		for filename in [c for c in filenames if c.endswith('.cfg')]:
			[root,ext] = os.path.splitext(filename)
			if ext == '.cfg':
				files.append(os.path.join(dirpath,filename))
	print('Found all start frames:')
	print('\n' .join(findlist))
	print('Found these config files:')
	print('\n' .join(files))

	widgets_tcl = 'C:\Program Files\CISMM/video_spot_tracker_v08.01_extra_output/russ_widgets.tcl'
	vst_tcl = 'C:\Program Files\CISMM/video_spot_tracker_v08.01_extra_output/video_spot_tracker.tcl'
	new_widgets = os.path.join(rootdir,'russ_widgets.tcl')
	new_vsttcl = os.path.join(rootdir,'video_spot_tracker.tcl')
	shutil.copy(widgets_tcl,rootdir)
	shutil.copy(vst_tcl,rootdir)
	print('Moved tcl files.')

	for i in findlist:
		thisvideodir = os.path.dirname(i)
		source = os.path.join(thisvideodir,startframename)
		dest = os.path.join(thisvideodir,autofindframename)
		shutil.copy(source,dest)
		
		#These will be inputs to Run_VST
		abs_autoframename = os.path.join(rootdir,thisvideodir,autofindframename) #where to find auto find frame for Run_VST?
		abs_autoframename = '"'+abs_autoframename+'"'
		abs_startframename = os.path.join(rootdir,thisvideodir,startframename) #where to find start frame for Run VST?
		abs_startframename = '"'+abs_startframename+'"'
		logpath = os.path.join(rootdir,thisvideodir) #where and name for saving the tracking data
		current_directoryname = os.path.split(thisvideodir)[1]
		logname = logpath+'\\'+current_directoryname

		for cfg in files:
			Run_VST(logname,abs_startframename,abs_autoframename,cfg)

	os.remove(new_widgets)
	os.remove(new_vsttcl)
	print('Removed tcl files.')
	os.chdir(rootdir)
	print('Done tracking with all states.')


def Run_VST(logname,startframename,autofindframe,cfg): #will take inputs autofindframe,startframe,logname
	import os, shutil, re, subprocess

	wd = os.getcwd()
	extension = '.vrpn'
	#vst_path = '"C:\\Program Files\\CISMM\\video_spot_tracker_v08.01_extra_output\\video_spot_tracker_nogui.exe"'
	vst_path = '"C:\\Program Files\\CISMM\\video_spot_tracker_v08.01_extra_output\\video_spot_tracker.exe"'
	#state = 'C:\\Users\\phoebelee\\Desktop\\testconfig.cfg'
	#print state

	cfgname = os.path.split(cfg)[1]
	temptraj = '"'+logname + '_tmp"'
	trajoutfile = '"'+logname+'_'+cfgname+'"'

	#needs to go through several config files at a time

	cfgfile = open(cfg)
	parameters = cfgfile.readlines()
	cfgfile.close()
	#print parameters
	for p in parameters:
		if p.startswith('set radius'):
			radius_line = p
	r = re.findall('\d+',radius_line)
	r = int(r[0])
	print('Tracker Radius = ' + str(r))

	#autofind_vst = vst_path+' -nogui -enable_internal_values -lost_all_colliding_trackers -load_state "'+cfg+'" -tracker 0 0 '+str(r)+' -outfile '+temptraj+' '+autofindframe
	#track =        vst_path+' -nogui -enable_internal_values -lost_all_colliding_trackers -load_state "'+cfg+'" -maintain_fluorescent_beads 0 -log_video 300 -tracker 0 0 '+str(r)+' -continue_from '+temptraj+'.csv -outfile '+trajoutfile+' '+startframename

	autofind_vst = vst_path+'  -enable_internal_values  -load_state "'+cfg+'" -tracker 0 0 '+str(r)+' -outfile '+temptraj+' '+autofindframe
	track =        vst_path+'  -enable_internal_values  -load_state "'+cfg+'" -tracker 0 0 '+str(r)+' -continue_from '+temptraj+'.csv -outfile '+trajoutfile+' '+startframename

	subprocess.call(autofind_vst)

		
	subprocess.call(track)

	os.remove(logname+'_tmp.csv')
	os.remove(logname+'_tmp.vrpn')
	print('Removed temp files.')
	#remove temporary autofind files (temptraj)

	print('Done.')