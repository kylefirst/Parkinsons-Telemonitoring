import myWave
import dspUtil
import numpy
import copy
import generalUtility

fname = "../patient_data/test_set_subject_1.wav"
numChannels, numFrames, fs, data = myWave.readWaveFile(fname)
data[0] = dspUtil.normalize(data[0])

# calculate features from here: http://homepage.univie.ac.at/christian.herbst/python/namespacedsp_util.html
# for example,

dspUtil.calculateJitterPercent(data[0])
dspUtil.calculateJitterRatio(data[0])


