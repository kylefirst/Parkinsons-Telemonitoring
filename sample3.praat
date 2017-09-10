# Tae-Jin Yoon
# University of Illinois at Urbana-Champaign
# version 0.4
# DATE = 2/04/2005

# Measuring Spectral Information, Jitter, Shimmer and HNR, mean Autocorrelation
# To run, type make

# temporary working script: c:\praat\script\temp\temp\vqtest4withJitterShimmerHNR

# Read files in a directory
#############################

clearinfo

directory$ = "patient_data_wav"
Create Strings as file list... list 'directory$'/*.TextGrid
numberOfFiles = Get number of strings

for ifile to numberOfFiles
    select Strings list
    fileName$ = Get string... ifile
    Read from file... 'directory$'/'fileName$'
    fileName$ = fileName$ - ".TextGrid"
    outputName$ = "'directory$'/'fileName$'.VQ"
    voiceReportName$ = "'directory$'/'fileName$'"
    wavFile$ = fileName$ + ".wav"
    Read from file... 'directory$'/'wavFile$'


    # Intensity Normalization (85dB)
    ###################################

    select Sound 'fileName$'
    To Intensity... 100 0
    Formula... self+(85-self)
    Down to IntensityTier
    select IntensityTier 'fileName$'
    plus Sound 'fileName$'
    Multiply

    # Cleaning
    select Intensity 'fileName$'
    Remove
    select IntensityTier 'fileName$'
    Remove
    select Sound 'fileName$'
    Remove
    select Sound 'fileName$'_int
    Rename... 'fileName$'

    # Formants (burg)
    #########################
    select Sound 'fileName$'
    To Formant (burg)... 0.01 5 5000 0.25 50
    Rename... 'fileName$'_beforetracking
    Track... 3 500 1485 2475 3850 4950 1 1 1
    Rename... 'fileName$'_aftertracking


    # LPC (autocorrelation)
    #########################
    select Sound 'fileName$'
    To LPC (autocorrelation)... 16 0.025 0.005 50

    # Inverse Filtering
    ####################

    select Sound 'fileName$'
    plus LPC 'fileName$'
    Filter (inverse)

    Rename... 'fileName$'_Source

   # Preprocessing for minimum and maximum Pitch Range
   ####################################################
   select Sound 'fileName$'
   To Pitch... 0 60 500
   median = Get quantile... 0 0 0.5 Hertz

   # more than +/- 3 semitone for min and max pitch
   #######################################
   minPitch = median*exp(-10*ln(2)/7)
   maxPitch = median*exp(10*ln(2)/7)
   select Pitch 'fileName$'
   Remove



    # Autocorrelation Pitch Analysis (with inverse filtered)
    #########################################################

    # minimum_pitch = 40
    timeStep = 0.25/minPitch
    select Sound 'fileName$'_Source
    To Pitch (ac)... timeStep minPitch 15 0 0.05 0.005 0.0025 0.02 0.0 maxPitch
#   To Pitch (ac)... timeStep minPitch 15 0.01 0.01 0.0 0.01 0.0 0.0 maxPitch

    # Create Point Process
    select Sound 'fileName$'_Source
    plus Pitch 'fileName$'_Source
    To PointProcess (cc)

    # find and count unvoiced intervals
    To TextGrid (vuv)... 0.02 0.01
    number_of_U_intervals = Count labels... 1 u
    number_of_intervals = Get number of intervals... 1
    label_of_interval_1$ = Get label of interval... 1 1
    label_of_interval_last$ = Get label of interval... 1 number_of_intervals

    interval_1_start = Get starting point... 1 1
    interval_last_end = Get end point... 1 number_of_intervals
    duration = Get total duration

    if label_of_interval_1$ = "U"
        if interval_1_start = 0
            number_of_U_intervals = number_of_U_intervals - 1
        endif
    endif

    if label_of_interval_last$ = "U"
        if interval_last_end = duration
            number_of_U_intervals = number_of_U_intervals - 1
        endif
    endif


    # extract jitter measurements
    ##############################
    select PointProcess 'fileName$'_Source

    # Variable initialization
    ############################
    shortest_period = 0.0001
    longest_period = 0.02
    nperiods = Get number of periods... 0 0 shortest_period longest_period 1.3
    mean_period = Get mean period... 0 0 shortest_period longest_period 1.3
    sd_period = Get stdev period... 0 0 shortest_period longest_period 1.3
    mean_period = mean_period * 1000
    sd_period = sd_period*1000

    # extract shimmer measurement
    ##############################
    select Sound 'fileName$'_Source
    plus PointProcess 'fileName$'_Source
    shimmer_loc = Get shimmer (local)... 0 0 shortest_period longest_period 1.3 1.6

    # extract harmonicity to noise ratio and write it to info window
    ##################################################################
    select Sound 'fileName$'
    To Harmonicity (cc)... timeStep minPitch 0.1 1
    hnr = Get mean... 0 0

    # voice report (info window)
    ##############################
    select Sound 'fileName$'
    plus Pitch 'fileName$'_Source
    plus PointProcess 'fileName$'_Source

;    voiceReport$ = Voice report... 0.0 0.0 60.0 600.0 1.3 1.6 0.03 0.45

;    meanPeriod = extractNumber(voiceReport$, "Mean period: ")
;    stdevPeriod = extractNumber(voiceReport$, "Standard deviation of period: ")
;    unvoicedFrames = extractNumber(voiceReport$, "Fraction of locally unvoiced frames: ")
;    degOfVoiceBreaks = extractNumber(voiceReport$, "Degree of voice breaks: ")
;    jitterLocal = extractNumber(voiceReport$, "Jitter (local): ")
;    shimmerLocal = extractNumber(voiceReport$, "Shimmer (local): ")
;    meanAutoCorrelation = extractNumber(voiceReport$, "Mean autocorrelation: ")
;    meanNHR = extractNumber(voiceReport$, "Mean noise-to-harmonics ratio: ")
;    meanHNR = extractNumber(voiceReport$, "Mean harmonics-to-noise ratio: ")




    # Initialization for H1-H2 computing
    ##########################################
    select Pitch 'fileName$'_Source
    t_start = Get time from frame number... 1
    t = t_start
    ;t = 0
    number_of_frames = Get number of frames

    # Variable Initialization
    ############################

    n = 0
    sum_h1 = 0
    sqsum_h1 = 0
    sum_h2 = 0
    sqsum_h2 = 0
    sum_h1minush2 = 0
    sqsum_h1minush2 = 0
    sum_a1 = 0
    sqsum_a1 = 0
    sum_a2 = 0
    sqsum_a2 = 0
    sum_a3 = 0
    sqsum_a3 = 0
    sum_h1minusa1 = 0
    sqsum_h1minusa1 = 0
    sum_h1minusa2 = 0
    sqsum_h1minusa2 = 0
    sum_h1minusa3 = 0
    sqsum_h1minusa3 = 0
    sum_a1minusa3 = 0
    sqsum_a1minusa3 = 0
    sum_dB = 0
    sqsum_dB = 0
    sum_f0 = 0
    sqsum_f0 = 0


    number_of_periods_in_analysis_window = 3.5
    frequency_window = 60
    effective_duration = Get time from frame number... number_of_frames

    shortest_period = 0.0001
    longest_period = 0.02

    # 3.9300625 seconds


    # computing H1, H2, A1, A2, A3 for individual frames
    ######################################################

    while t <= effective_duration

    # Inverse Filtered Pitch (for dB of harmonics)
    ################################################

        select Pitch 'fileName$'_Source
        f0 = Get value at time... t Hertz Linear

        select Formant 'fileName$'_aftertracking
        f1 = Get value at time... 1 t Hertz Linear
        f2 = Get value at time... 2 t Hertz Linear
        f3 = Get value at time... 3 t Hertz Linear

;       if f1 = undefined
;      print "HELLO"
;       endif

        select Pitch 'fileName$'_Source

    # computing analysis window for autocorrelation
    ################################################

        n = n+1
        t0 = 1/f0

        start = t - t0*number_of_periods_in_analysis_window/2
        end = t + t0*number_of_periods_in_analysis_window/2

    # Inverse Filtered Sound (for h1, h2)
    ######################################

        select Sound 'fileName$'_Source
        Extract part... start end Hanning 1 yes

        To Spectrum (fft)
        To Ltas (1-to-1)

        lower_limit_h1 = f0 - frequency_window/2
        # 200 +/- 1.75
        upper_limit_h1 = f0 + frequency_window/2
        lower_limit_h2 = (2*f0) - frequency_window/2
        upper_limit_h2 = (2*f0) + frequency_window/2

        h1 = Get maximum... lower_limit_h1 upper_limit_h1 None
        h2 = Get maximum... lower_limit_h2 upper_limit_h2 None
        h1hz = Get frequency of maximum... lower_limit_h1 upper_limit_h1 None
        h2hz = Get frequency of maximum... lower_limit_h2 upper_limit_h2 None

        h1minush2 = h1 - h2
        h1hzminush2hz = h1hz - h2hz

    # original, non-inverse filtered sound (for dB of formants)
    ########################################################

       select Sound 'fileName$'
       Extract part... start end Hanning 1 yes
       To Spectrum (fft)
       To Ltas (1-to-1)

       lower_limit_a1 = f1 - frequency_window/2
       upper_limit_a1 = f1 + frequency_window/2

       a1 = Get maximum... lower_limit_a1 upper_limit_a1 None
       a1hz = Get frequency of maximum... lower_limit_a1 upper_limit_a1 None

       lower_limit_a2 = f2 - frequency_window/2
       upper_limit_a2 = f2 + frequency_window/2

       a2 = Get maximum... lower_limit_a2 upper_limit_a2 None
       a2hz = Get frequency of maximum... lower_limit_a2 upper_limit_a2 None

       lower_limit_a3 = f3 - frequency_window/2
       upper_limit_a3 = f3 + frequency_window/2

       a3 = Get maximum... lower_limit_a3 upper_limit_a3 None
       a3hz = Get frequency of maximum... lower_limit_a3 upper_limit_a3 None

       h1minusa1 = h1 - a1
       h1minusa2 = h1 - a2
       h1minusa3 = h1 - a3
       a1minusa3 = a1 - a3

       h1hzminusa1hz = h1hz - a1hz
       h1hzminusa2hz = h1hz - a2hz
       h1hzminusa3hz = h1hz - a3hz
       a1hzminusa3hz = a1hz - a3hz


       # Slope analysis
       select Ltas 'fileName$'_Source_part
       Compute trend line... 600 4000
       select Ltas 'fileName$'_Source_part_trend
       slope = Get slope... 0.0 1000.0 1000.0 4000.0 energy

       # extract voice report
       ##########################
       select Sound 'fileName$'_Source
       plus Pitch 'fileName$'_Source
       plus PointProcess 'fileName$'_Source

      startT = t
      endT = t + 0.05

       voiceReport$ = Voice report... startT endT 50 500 1.3 1.6 0.03 0.45

       meanPeriod = extractNumber(voiceReport$, "Mean period: ")
       stdevPeriod = extractNumber(voiceReport$, "Standard deviation of period: ")
       unvoicedFrames = extractNumber(voiceReport$, "Fraction of locally unvoiced frames: ")
       degOfVoiceBreaks = extractNumber(voiceReport$, "Degree of voice breaks: ")
       jitterLocal = extractNumber(voiceReport$, "Jitter (local): ")
       shimmerLocal = extractNumber(voiceReport$, "Shimmer (local): ")
       meanAutoCorrelation = extractNumber(voiceReport$, "Mean autocorrelation: ")
       meanNHR = extractNumber(voiceReport$, "Mean noise-to-harmonics ratio: ")
       meanHNR = extractNumber(voiceReport$, "Mean harmonics-to-noise ratio: ")


       # We need to save the voiceReport in terms of frame
       # ############### HERE ##########################

       # extract Intensity
       select Sound 'fileName$'
       To Intensity... 100 0
       select Intensity 'fileName$'
       dB = Get mean... start end dB

       # array for dynamic programming

       t'n' = t
       f0'n' = f0
       h1'n' = h1
       h1hz'n' = h1hz
       h2'n' = h2
       h2hz'n' = h2hz
       h1minush2'n' = h1minush2
       h1hzminush2hz'n' = h1hzminush2hz
       a1'n' = a1
       a1hz'n' = a1hz
       a2'n' = a2
       a2hz'n' = a2hz
       a3'n' = a3
       a3hz'n' = a3hz
       h1minusa1'n' = h1minusa1
       h1hzminusa1hz'n' = h1hzminush2hz
       h1minusa2'n' = h1minusa2
       h1hzminusa2hz'n' = h1hzminusa2hz
       h1minusa3'n' = h1minusa3
       h1hzminusa3hz'n' = h1hzminusa3hz
       a1minusa3'n' = a1minusa3
       a1hzminusa3hz'n' = a1hzminusa3hz

       slope'n' = slope

       dB'n' = dB
       f0'n' = f0

       meanPeriod'n'= meanPeriod
       stdevPeriod'n' = stdevPeriod
       unvoicedFrames'n' = unvoicedFrames
       degOfVoiceBreaks'n' = degOfVoiceBreaks
       jitterLocal'n' = jitterLocal
       shimmerLocal'n' = shimmerLocal
       meanAutoCorrelation'n' = meanAutoCorrelation
       meanNHR'n' = meanNHR
       meanHNR'n' = meanHNR

       # Sum and Square Sum

       sum_h1 = sum_h1 + h1
       sqsum_h1 = sqsum_h1 + h1*h1
       sum_h2 = sum_h2 + h2
       sqsum_h2 = sqsum_h2 + h2*h2
       sum_h1minush2 = sum_h1minush2 + h1minush2
       sqsum_h1minush2 = sqsum_h1minush2 + h1minush2*h1minush2

       sum_a1 = sum_a1 + a1
       sqsum_a1 = sqsum_a1 + a1*a1
       sum_a2 = sum_a2 + a2
       sqsum_a2 = sqsum_a2 + a2*a2
       sum_a3 = sum_a3 + a3
       sqsum_a3 = sqsum_a3 + a3*a3
       sum_h1minusa1 = sum_h1minusa1 + h1minusa1
       sqsum_h1miusa1 = sqsum_h1minusa1 + h1minusa1*h1minusa1
       sum_h1minusa2 = sum_h1minusa2 + h1minusa2
       sqsum_h1minusa2 = sqsum_h1minusa2 + h1minusa2*h1minusa2
       sum_h1minusa3 = sum_h1minusa3 + h1minusa3
       sqsum_h1minusa3 = sqsum_h1minusa3 + h1minusa3*h1minusa3
       sum_a1minusa3 = sum_a1minusa3 + a1minusa3
       sqsum_a1minusa3 = sqsum_a1minusa3 + a1minusa3*a1minusa3

       sum_dB = sum_dB + dB
       sqsum_dB = sqsum_dB + dB*dB
       sum_f0 = sum_f0 * f0
       sqsum_f0 = sqsum_f0 + f0*f0

       # Time Step of 50ms
       #####################
       t = t + 0.05

       # Cleaning
       ###################

       select Sound 'fileName$'_part
       Remove
       select Spectrum 'fileName$'_part
       Remove
       select Ltas 'fileName$'_part
       Remove
       select Sound 'fileName$'_Source_part
       Remove
       select Spectrum 'fileName$'_Source_part
       Remove
       select Ltas 'fileName$'_Source_part
       Remove
       select Ltas 'fileName$'_Source_part_trend
       Remove

    endwhile

    mean_h1 = sum_h1/n
    mean_h2 = sum_h2/n
    mean_a1 = sum_a1/n
    mean_a2 = sum_a2/n
    mean_a3 = sum_a3/n
    mean_h1minush2 = sum_h1minush2/n
    mean_h1minusa1 = sum_h1minusa1/n
    mean_h1minusa2 = sum_h1minusa2/n
    mean_h1minusa3 = sum_h1minusa3/n
    mean_a1minusa3 = sum_a1minusa3/n

    mean_dB = sum_dB/n
    mean_f0 = sum_f0/n

    sd_h1 = sqrt((n*sqsum_h1 - sum_h1*sum_h1)/(n*(n-1)))
    sd_h2 = sqrt((n*sqsum_h2 - sum_h2*sum_h2)/(n*(n-1)))
    sd_a1 = sqrt((n*sqsum_a1 - sum_a1*sum_a1)/(n*(n-1)))
    sd_a2 = sqrt((n*sqsum_a2 - sum_a2*sum_a2)/(n*(n-1)))
    sd_a3 = sqrt((n*sqsum_a3 - sum_a3*sum_a3)/(n*(n-1)))
    sd_h1minush2 = sqrt((n*sqsum_h1minush2 - sum_h1minush2*sum_h1minush2)/(n*(n-1)))
    sd_h1minusa1 = sqrt((n*sqsum_h1minusa1 - sum_h1minusa1*sum_h1minusa1)/(n*(n-1)))
    sd_h1minusa2 = sqrt((n*sqsum_h1minusa2 - sum_h1minusa2*sum_h1minusa2)/(n*(n-1)))
    sd_h1minusa3 = sqrt((n*sqsum_h1minusa3 - sum_h1minusa3*sum_h1minusa3)/(n*(n-1)))
    sd_a1minusa3 = sqrt((n*sqsum_a1minusa3 - sum_a1minusa3*sum_a1minusa3)/(n*(n-1)))
    sd_dB = sqrt((n*sqsum_dB - sum_dB*sum_dB)/(n*(n-1)))
    sd_f0 = sqrt((n*sqsum_f0 - sum_f0*sum_f0)/(n*(n-1)))


stop = n


printline # 'tab$' Extracted Feature Information
printline # 1: Phone
printline # 2: timeIndex (Increment every 50 msec)
printline # 3: F0
printline # 4: Intensity
printline # 5: mean H1 - H2
printline # 6: mean H1 - A1
printline # 7: mean H1 - A2
printline # 8: mean H1 - A3
printline # 9:  H1
printline # 10: H2
printline # 11: A1
printline # 12: A2
printline # 13: A3
printline # 14: H1-H2
printline # 15: Spectral Slope
printline # 16 H1 - A1
printline # 17: H1 - A2
printline # 18: H1 - A3
printline # 19: F1
printline # 20: F2
printline # 21: F3
printline # 'tab$' Summary of Voice Report based on Frames
printline # 22: mean period
printline # 23: Sted Dev of Period
printline # 24: Unvoiced Frames
printline # 25: Degree of Voice Breaks
printline # 26: Local Jitter
printline # 27: Local Shimmer
printline # 28: Mean Autocorrelation
printline # 29: Mean Noise to Harmonic Ration
printline # 30: Mean Harmonic to Noise Ration


    # Extract features from each phone interval
    ############################################

select TextGrid 'fileName$'
nT1 = Get number of intervals... 3
    for p to nT1

        pStart = Get starting point... 3 p
        pEnd = Get end point... 3 p
        pLabel$ = Get label of interval... 3 p
        duration = pEnd - pStart

        for n from 1 to stop
            t = t'n'

            f0 = f0'n'
            dB = dB'n'
            h1 = h1'n'
            h2 = h2'n'
            a1 = a1'n'
            a2 = a2'n'
            a3 = a3'n'
            a1hz = a1hz'n'
            a2hz = a2hz'n'
            a3hz = a3hz'n'

            h1minush2 = h1minush2'n'
            h1minusa1 = h1minusa1'n'
            h1minusa2 = h1minusa2'n'
            h1minusa3 = h1minusa3'n'
            a1minusa3 = a1minusa3'n'
            slope = slope'n'

            meanPeriod = meanPeriod'n'
            stdevPeriod = stdevPeriod'n'
            unvoicedFrames = unvoicedFrames'n'
            degOfVoiceBreaks = degOfVoiceBreaks'n'
            jitterLocal = jitterLocal'n'
            shimmerLocal = shimmerLocal'n'
            meanAutoCorrelation = meanAutoCorrelation'n'
            meanNHR = meanNHR'n'
            meanHNR = meanHNR'n'

            if t'n' >= pStart and t'n' <= pEnd

        # Output cleaning

                if f0 = undefined

                    f0 = 0

                    h1 = 0
                    h2 = 0
                    slope = 0
                    h1minush2 = 0
                    h1minusa1 = 0
                    h1minusa2 = 0
                    h1minusa3 = 0
                    a1minusa3 = 0
            a1 = 0
                    a2 = 0
                    a3 = 0
                    a1hz = 0
                    a2hz = 0
                    a3hz = 0

                 endif


        if meanPeriod = undefined
                    meanPeriod = 0
        endif
        if stdevPeriod = undefined
            stdevPeriod = 0
        endif
        if unvoicedFrames = undefined
            unvoicedFrames = 0
        endif
        if degOfVoiceBreaks = undefined
            degOfVoiceBreaks = 0
        endif
        if jitterLocal = undefined
            jitterLocal = 0
        endif
        if shimmerLocal = undefined
            shimmerLocal = 0
        endif
        if meanAutoCorrelation = undefined
            meanAutoCorrelation = 0
        endif
        if meanNHR = undefined
            meanNHR = 0
        endif
        if meanHNR = undefined
            meanHNR = 0
        endif

        # TO DO 1: Put the normalized Value in term of Z-Score
        # NormVal = (Val - meanVal)/StdevVal
        # TO DO 2: Will it be better to get a 1-st order differential Values?
                #          It will be useful for F0 and Intensity, but how about f1 through a3

        # something wrong with mean F0 value
        # printline 'mean_f0' 'tab$' 'mean_dB'
        printline 'pLabel$' 'tab$' 't:3' 'tab$' 'f0:2' 'tab$' 'dB:2' 'tab$'
            ... 'mean_h1minush2:2' 'tab$' 'mean_h1minusa1:2' 'tab$'
            ... 'mean_h1minusa2:2' 'tab$' 'mean_h1minusa3:2' 'tab$'
            ... 'mean_a1minusa3:1' 'tab$' 'h1:1' 'tab$' 'h2:1' 'tab$' 'a1:1' 'tab$'
            ... 'a2:1' 'tab$' 'a3:1' 'tab$' 'h1minush2:1' 'tab$' 'slope:2' 'tab$'
            ... 'h1minusa1:1' 'tab$' 'h1minusa2:1' 'tab$' 'h1minusa3:1' 'tab$'
            .... 'a1hz:1' 'tab$' 'a2hz:1' 'tab$' 'a3hz:1' 'tab$'
            ... 'meanPeriod' 'tab$' 'stdevPeriod' 'tab$' 'unvoicedFrames' 'tab$'
            ... 'degOfVoiceBreaks' 'tab$' 'jitterLocal' 'tab$''shimmerLocal' 'tab$'
            ... 'meanAutoCorrelation' 'tab$' 'meanNHR' 'tab$' 'meanHNR'
;	printline 'pLabel$' 'tab$' 'f0:2' 'tab$' 'h1minush2:1' 'tab$' 'meanAutoCorrelation:2'

            endif
        endfor
    endfor
endfor
