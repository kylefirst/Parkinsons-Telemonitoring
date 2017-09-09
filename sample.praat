#########################################################################
# Use an octothorpe (pound sign) to leave comments.                     #
# When you run the Praat script, anything in a comments won't run.      #
# Praat has weird rules about using dollar signs and periods            #
# to name variables.                                                    #
#########################################################################

## Preparations
# Set the folder where the Praat files are, where you want the output to
# go, and the types of files you will be analyzing.
basepath$ = "patient_data_wav"
outDirectory$ = "praat_out"
outFile$ = "please"
filetype$ = ".wav"
# Initialize array of directory names
num_Dirs = 0
depth = 0

# Call the openDir procedure starting with the base folder.
call openDir 'basepath$'

#########################################################################
#########################################################################
## Procedure: openDir                                                  ##
## Arguments: Send a path to open.                                     ##
## Description: Every folder in .dir$ is opened is opened recursively  ##
## and every file of type "filetype$" will be analyzed with Praat.     ##
## Note that because                                                   ##
#########################################################################
#########################################################################

procedure openDir .dir$

# .listName$ is the name of each Strings, purely cosmetic
.listName$ = "dirList"
.dir_'depth'$ = .dir$

#########################################################################
# All code placed after this point will be run on every subdirectory    #
# within the tree (.dir$).                                              #
#########################################################################

# Call the listDir procedure to get a list of the folders in .dir$
call listDir '.dir$'

# Create Strings of every subdirectory in .dir$
Create Strings as directory list... '.listName$' '.dir$'
.numDirs_'depth' = Get number of strings

# This loops for every subdirectory and is skipped if none exist.
# All of the code on lines between "for" and "endfor" are run. 
for .dir_'depth' to .numDirs_'depth'
.nextDir$ = Get string... .dir_'depth'

# Sometimes Windows will list "." and ".." as directories. 
# This tells Praat to exclude them from analysis.
if .nextDir$ <> "." and .nextDir$ <> ".."
depth += 1

# This calls the openDir procedure. A procedure that calls itself is 
# known as a 'recursive procedure call'
call openDir '.dir$'/'.nextDir$'
depth -= 1
endif

# Reset .dir$, because recursive call has overwritten it
.dir$ = .dir_'depth'$
select Strings '.listName$'
endfor
Remove
endproc


#########################################################################
#########################################################################
## Procedure: listDir                                                  ##
## Arguments: Send a path to open.                                     ##
## Description: Every folder in .dir$ is listed and the output is      ##
## set up. Praat then exports all of the desired output for ever file. ##
#########################################################################
#########################################################################

procedure listDir .dir$
	
	#####################################################################
	# This code will create the CSV output file.                        #
	# My data had 33 files for each session.                            #
	#####################################################################
	
	# Get the session number
	indexdir = rindex(.dir$, "/")
	lengthdir = length(.dir$)
	diffdir = lengthdir - indexdir
	session$ = right$(.dir$, diffdir)
	
	print Starting work on session 'session$':'newline$'
	
	# Add the headers to the file	
	Create Strings as file list... fileList '.dir$'/*'filetype$'
	.numFiles = Get number of strings
	if .numFiles > 0
	print '.numFiles' files in 'session$''newline$'
	for i to 32
		i$ = "'i'"
		fileappend 'outDirectory$''outFile$'.csv "Session", "Filename.'i$'", "duration.'i$'", "pitch.med.'i$'","pitch.mean.'i$'","pitch.SD.'i$'","pitch.max.'i$'","pitch.min.'i$'","jitter.local.'i$'","jitter.local.abs.'i$'","jitter.rap.'i$'","jitter.ppq5.'i$'","jitter.ddp.'i$'","shimmer.local.'i$'","shimmer.local.dB.'i$'","shimmer.apq3.'i$'","shimmer.apq5.'i$'","shimmer.apqii.'i$'","shimmer.dda.'i$'","voicing.fractunvoicedframes.'i$'","voicing.numbreaks.'i$'","voicing.degbreaks.'i$'","intensity.dB.mean.'i$'","intensity.dB.min.'i$'","intensity.dB.max.'i$'",
	endfor
	fileappend 'outDirectory$''outFile$'.csv 'newline$',  	
	for i to 32
		i$ = "'i'"
		prefix$ = "a" + session$ + "-" + i$
		fName$ = prefix$ + filetype$
		tgName$ = prefix$ + ".TextGrid"
		print for i looking at 'fName$' and 'tgName$' 
		
		# Read from file... '.dir$'/'fName$'
		if fileReadable("'.dir$'/'fName$'")
			nowarn Open long sound file... '.dir$'/'fName$'
			lsName$ = selected$ ("LongSound")

			# Create textgrid files
			if fileReadable ("'.dir$'/'tgName$'")
				print TextGrid file already exists.
			else
				print  TextGrid file is being created. 
				select LongSound 'lsName$'
				To TextGrid... "'tgName$'"
				Write to text file... '.dir$'/'tgName$'
				if fileReadable ("'.dir$'/'tgName$'")
					print and the file is readable 'newline$'
				else print and the file is not readable 'newline$'
				endif
			endif

			# Get the duration, open the file in the editor, 
			# set settings, and extract the rest of the information 
			# about the files (pitch, intensity/dB, etc.)
			select LongSound 'lsName$'
			duration = Get total duration
			
			if 'duration'>0
				Rename... soundObj
				Read from file... '.dir$'/'tgName$'
				Rename... tgObj
				select TextGrid tgObj
				plus LongSound soundObj
				
				Edit
				editor TextGrid tgObj
					Editor info
					Show analyses... yes yes yes yes yes 600
					Zoom... 0 duration
					Select... 0 duration
					Pitch settings... 75 500 Hertz cross-correlation automatic
					voiceReport$ = Voice report
					pitch.med = extractNumber(voiceReport$, "Median pitch: ")	
					pitch.mean = extractNumber(voiceReport$, "Mean pitch: ")
					pitch.SD = extractNumber(voiceReport$, "Standard deviation: ")
					pitch.max = extractNumber(voiceReport$, "Maximum pitch: ")						
					pitch.min = extractNumber(voiceReport$, "Minimum pitch: ")
					jitter.local = extractNumber(voiceReport$, "Jitter (local): ")
					jitter.local.abs = extractNumber(voiceReport$, "Jitter (local, absolute): ")
					jitter.rap = extractNumber(voiceReport$, "Jitter (rap): ")
					jitter.ppq5 = extractNumber(voiceReport$, "Jitter (ppq5): ")
					jitter.ddp = extractNumber(voiceReport$, "Jitter (ddp): ")
					shimmer.local = extractNumber(voiceReport$, "Shimmer (local): ")
					shimmer.local.dB = extractNumber(voiceReport$, "Shimmer (local, dB): ")
					shimmer.apq3 = extractNumber(voiceReport$, "Shimmer (apq3): ")
					shimmer.apq5 = extractNumber(voiceReport$, "Shimmer (apq5): ")
					shimmer.apq11 = extractNumber(voiceReport$, "Shimmer (apq11): ")
					shimmer.dda = extractNumber(voiceReport$, "Shimmer (dda): ")
					voicing.fractunvoicedframes = extractNumber(voiceReport$, "Fraction of locally unvoiced frames: ")
					voicing.numbreaks = extractNumber(voiceReport$, "Number of voice breaks: ")
					voicing.degbreaks = extractNumber(voiceReport$, "Degree of voice breaks: ")
					intensity.dB.mean = Get intensity
					intensity.dB.min = Get minimum intensity
					intensity.dB.max = Get maximum intensity
					Close
				endeditor		
				
				# Export the values to the output file
				fileappend 'outDirectory$''outFile$'.csv 'session$', 'prefix$', 'duration', 'pitch.med', 'pitch.mean', 'pitch.SD', 'pitch.max', 'pitch.min', 'jitter.local', 'jitter.local.abs', 'jitter.rap', 'jitter.ppq5', 'jitter.ddp', 'shimmer.local', 'shimmer.local.dB', 'shimmer.apq3', 'shimmer.apq5', 'shimmer.apq11', 'shimmer.dda', 'voicing.fractunvoicedframes', 'voicing.numbreaks', 'voicing.degbreaks', 'intensity.dB.mean', 'intensity.dB.min', 'intensity.dB.max',		
			endif
			Remove
		else
			fileappend 'outDirectory$''outFile$'.csv 'session$', 'prefix$', , , , , , , , , , , , , , , , , , , , , , , ,
		endif	
		select Strings fileList
		endfor
		print 'fName$' complete.'newline$'
		fileappend 'outDirectory$''outFile$'.csv 'newline$'
	endif
	select Strings fileList
	Remove
endproc
