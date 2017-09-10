form Read all files of the given type from the given directory
   sentence Source_directory patient_data_wav
   sentence File_name_or_initial_substring test
   sentence File_extension .wav
endform
Create Strings as file list... list
'source_directory$'/'file_name_or_initial_substring$'*'file_extension$'
head_words = selected("Strings")
file_count = Get number of strings
for ifile to file_count
   select Strings list
   filename$ = Get string... ifile
   Read from file... 'source_directory$'/'filename$'
name$ = selected$("Sound",1)
To Intensity... 100 0 
select Intensity 'name$'
start = 0
end = 10
min_int = Get minimum... start
... end Parabolic
max_int = Get maximum... start
... end parabolic
mean_int = Get mean... start end
... energy
range_of_int = max_int-min_int
select Intensity 'name$'
Remove
select Sound 'name$'
 minimum_pitch = 70
 maximum_pitch = 500
 
 pitch_silence_threshold = 0.03
 pitch_voicing_threshold = 0.45
 pitch_octave_cost = 0.01
 pitch_octave_jump_cost = 0.35
 pitch_voiced_unvoiced_cost = 0.14
 
To Pitch (cc)... 0 minimum_pitch 15 no pitch_silence_threshold
pitch_voicing_threshold 
 ...0.01 0.35 0.14 maximum_pitch

plus Pitch 'name$'
 
To PointProcess
points = Get number of points
 
select Sound 'name$'
plus Pitch 'name$'
plus PointProcess 'name$'
 start = 0
 end = 10
 maximum_period_factor = 1.3
 maximum_amplitude_factor = 1.6
#Voice report... start end minimum_pitch maximum_pitch
maximum_period_factor maximum_amplitude_factor 0.03 0.45
report$ = Voice report... start end minimum_pitch maximum_pitch
maximum_period_factor maximum_amplitude_factor 0.03 0.45

medianPitch = extractNumber (report$, "Median pitch: ")
meanPitch = extractNumber (report$, "Mean pitch: ")
sdPitch =extractNumber (report$, "Standard deviation: ")
minPitch = extractNumber (report$, "Minimum pitch: ")
maxPitch = extractNumber (report$, "Maximum pitch: ")
pitch_range = maxPitch-minPitch

jitter_loc = extractNumber (report$, "Jitter (local): ") * 100
jitter_loc_abs = extractNumber (report$, "Jitter (local, absolute): ") *
1000000
jitter_rap = extractNumber (report$, "Jitter (rap): ") * 100
jitter_ppq5 = extractNumber (report$, "Jitter (ppq5): ") *100
shimmer_loc = extractNumber (report$, "Shimmer (local): ") *100
shimmer_loc_dB = extractNumber (report$, "Shimmer (local, dB): ")
shimmer_apq3 = extractNumber (report$, "Shimmer (apq3): ") * 100
shimmer_apq5 = extractNumber (report$, "Shimmer (apq5): ") * 100
shimmer_apq11 = extractNumber (report$, "Shimmer (apq11): ") * 100
mean_nhr = extractNumber (report$, "Mean noise-to-harmonics ratio: ")
 
fileappend "D:\praatoutput\info.txt" 
 ...'minPitch:3''tab$''maxPitch:3''tab$''pitch_range:3''tab$''medianPitch:3''tab$''meanPitch:3''tab$''sdPitch:3''tab$'
 ...'jitter_loc:3''tab$''jitter_loc_abs:3''tab$''jitter_rap:3''tab$''jitter_ppq5:3''tab$'
 ...'shimmer_loc:3''tab$''shimmer_loc_dB:3''tab$''shimmer_apq3:3''tab$''shimmer_apq5:3''tab$''shimmer_apq11:3'
 ...'tab$''mean_nhr:4''tab$''min_int:3''tab$''max_int:3''tab$''mean_int:3''tab$''range_of_int:3''newline$'

select Sound 'name$'
plus Pitch 'name$'
plus PointProcess 'name$'
Remove
select Strings list
endfor
Remove
 