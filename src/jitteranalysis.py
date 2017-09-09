import myWave
import dspUtil
import numpy
import copy
import generalUtility
import os

for fname in os.listdir("../patient_data_wav"):

	# load the input file
	# data is a list of numpy arrays, one for each channel
	numChannels, numFrames, fs, data = myWave.readWaveFile("../patient_data_wav/" + fname)

	# normalize the left channel, leave the right channel untouched
	data[0] = dspUtil.normalize(data[0])

	# just for kicks, reverse (i.e., time-invert) all channels
	# ^ wait wtf..."just for kicks"
	for chIdx in range(numChannels):
		n = len(data[chIdx])
		dataTmp = copy.deepcopy(data[chIdx])
		for i in range(n):
			data[chIdx][i] = dataTmp[n - (i + 1)]

    # save the normalized file (both channels)
	# this is the explicit code version, to make clear what we're doing. since we've
	# treated the data in place, we could simple write: 
	# myWave.writeWaveFile(data, outputFileName, fs) and not declare dataOut
	dataOut = [data[0], data[1]] 
	fileNameOnly = generalUtility.getFileNameOnly("../patient_data_wav/" + fname)
	outputFileName = fileNameOnly + "_processed.wav"
	myWave.writeWaveFile(dataOut, outputFileName, fs)

# calculate features from here: http://homepage.univie.ac.at/christian.herbst/python/namespacedsp_util.html


