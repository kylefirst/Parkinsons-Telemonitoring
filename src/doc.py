"""

@mainpage Intro
<div>
<a name="topOfPage"></a>
This is a collection of open source Python scripts that I found useful for analyzing data from human and mammalian vocalizations, and for generating aesthetically pleasing graphs and videos, to be used in publications and presentations/lectures.
</div>

<div>
To date, these packages are available (there's more, but the respective code is still in development):
- general utility scripts (@ref generalUtility)
- digital signal processing (DSP) functionality (@ref dspUtil and @ref myWave)
- interacting and utilizing <a href="http://www.praat.org">Praat</a> (@ref praatUtil and @ref praatTextGrid)
- functionality for creating graphs (@ref matplotlibUtil)
</div>

<div>
You can download the library <a href="ChristiansPythonLibrary.zip">here</a>. There's two straightforward ways to install the modules: either store them in the same path as the script that you're running, or add the module's path to the system path (before importing the modules) from within the Python script that you're executing, such as:
@code
modulePath = '/Users/ch/data/programming/python/lib/' # change as appropriate
import sys
sys.path.append(modulePath)
# now you're good to import the modules
import generalUtility
import dspUtil
import matplotlibUtil
...
@endcode
</div>

<div>
Here are a few tutorial-style examples (with Python code):
- <a href="#wavDemo">Loading a wave file and saving a normalized time-inverted version of the sound</a>
- <a href="#praatTextGrid">Reading and writing Praat TextGrids</a> (for interactively annotating recordings)
- <a href="#praatUtilDemo">Delegating analysis tasks to Praat from within Python</a>
- <a href="#formantDemo">Creating a F1/F2 plot</a> (Praat interaction, simple graph example)
- <a href="#graphDemo">Graph demo</a>
- <a href="#videoDemo">Generating a video from a series of matplotlib graphs</a>
</div>

<div>
Enjoy! - If you have any questions, please contact <a href="http://www.christian-herbst.org">me</a>.
</div>

<div>
@warning Finally, a DISCLAIMER: this library was developed 
on a Mac, and it was never thoroughly tested a Windows platform. There might be 
problems with the backslashes used in Windows path indicators. From what I've
seen you should not run into problems if you avoid backslashes, but rather use
forward slashes.
</div>

</div>

<div>&nbsp;</div>
<div>&nbsp;</div>


<!-- ###################################################################### -->

<div>
<a name="wavDemo"></a>
<h2>Loading a wave file and saving a normalized version of the sound</h2>

<div>
<a href="waveDemo.py">Download source code</a> | <a href="WilhelmScream.wav">WAV input file</a>
@include waveDemo.py
</div>
<div style="text-align:right;"><a href="#topOfPage"><span style="font-size:10px;">top of page</span></a></div>
</div>

<!-- ###################################################################### -->
 
<div>
<a name="praatTextGrid"></a>
<h2>Reading and writing Praat TextGrids (for interactively annotating recordings)</h2>
<div>
<a href="http://www.praat.org">Praat</a> is an incredibly powerful free software application for analyzing human (and mammalian) vocalizations. If offers a wealth of analysis options, as well as scripting support. However, when performing more complex analysis tasks (particularly when a larger number of files is involved, or when performing an analysis that is not provided by Praat, such as calculating the EGG contact quotient), algorithmic interaction between Praat and Python might be desirable.
</div>
<div>
In order to call Praat from your Python code, Praat's directory must be known to your computer. For this, you need to add the directory where Praat is stored to your computer's system path variable. See these tutorials for doing this on a <a href="http://www.cyberciti.biz/faq/appleosx-bash-unix-change-set-path-environment-variable/">Mac</a> or on <a href="http://stackoverflow.com/questions/3701646/how-to-add-to-the-pythonpath-in-windows-7">Windows</a>.
</div>
<div>
One possibility is to utilize Praat as a graphical user interface to annotate files containing acoustic recordings using Praat TextGrids, and then continue processing the annotated segments with Python. Here, such an approach is presented, consisting of three steps:
</div>
<div>
<b>(1)</b> Locate all WAV files in a directory and automatically create Praat TextGrids containing one IntervalTier with Python (saves you a lot of clicking when you need to analyze hundreds of files): 
</div>
<div><a href="praatTextGridDemo1.py">Download source code (part 1)</a>
@include praatTextGridDemo1.py
</div>
<div>
<b>(2)</b> Annotate all WAV files within Praat (select both the WAV file and the TextGrid, once loaded in Praat, and open them by clicking "View & Edit"): add intervals to the IntervalTier as needed, and provide a meaningful label (in this example, any interval lavel will suffice). 
</div>
<div>
<b>(3)</b> Finally, the annotation data can be utilized for further analysis. In this example, we'll simply generate a CSV file containing the file name, start and end time and the label of all annotations of all WAV files in the directory. The generated CSV could then be used for further analysis, e.g. in <a href="http://www.openoffice.org">OpenOffice</a>.  
</div>
<div>
<a href="praatTextGridDemo2.py">Download source code (part 2)</a>
@include praatTextGridDemo2.py
</div>
<div style="text-align:right;"><a href="#topOfPage"><span style="font-size:10px;">top of page</span></a></div>
</div>

<!-- ###################################################################### -->

<div>
<a name="praatUtilDemo"></a>
<h2>Delegating analysis tasks to Praat from within Python</h2>

<div>
In this little example, we'll calculate a sound file's time-varying intensity by calling Praat's <a href="http://www.fon.hum.uva.nl/praat/manual/Sound__To_Intensity___.html">To Intensity...</a> function within Python and create a simple graph with the result. Since Praat's intensity data is not calibrated, we'll convert the analysis data to relative dB.
</div>

<div>
In order for this example to work, Praat needs to be installed properly, and the Praat executable needs to be available in the <a href="http://en.wikipedia.org/wiki/Command-line_interface">command line.</a>
</div>

<div>
<a href="praatUtilDemo.py">Download source code</a> | <a href="WilhelmScream.wav">WAV input file</a>
@include praatUtilityDemo.py
</div>

<div>
Running this script will produce this graph:
</div>

<div>
<img src="WilhelmScream_intensity.png">
</div>

<div style="text-align:right;"><a href="#topOfPage"><span style="font-size:10px;">top of page</span></a></div>
</div>

<!-- ###################################################################### -->

<div>
<a name="formantDemo"></a>
<h2>Creating a F1/F2 plot (Praat interaction, simple graph example)</h2>

<div>
In this more complex example three concepts are being demonstrated: running a Praat script from within Python, loading and parsing a Praat Formant structure, and generating a simple graph. [<i>Note that you could just as well call this module's @ref calculateFormants() function instead of generating a Praat script, but then we'd miss the chance to explain the @ref runPraatScript() method in this tutorial.</i>]
</div>

<div>
<a href="praatFormantsDemo.py">Download source code</a> | <a href="AEIOU_vocalFry.wav">the analyzed WAV file</a> | <a href="AEIOU_vocalFry.TextGrid">TextGrid annotation</a>
@include praatFormantsDemo.py
</div>

<div>
Executing this code will produce the following graph:
</div>

<div>
<img src = "formantDemo.png">
</div>

</div>
<div style="text-align:right;"><a href="#topOfPage"><span style="font-size:10px;">top of page</span></a></div>
</div>

<!-- ###################################################################### -->

<div>
<a name="graphDemo"></a>
<h2>Graph demo</h2>

<div>
<a href="http://matplotlib.org/">Matplotlib</a> is a superb module for creating aesthetically pleasing graphs. When combinaed with <a href="http://www.numpy.org/">numpy</a> and any other data analysis framework (I mostly use <a href="www.praat.org">Praat</a> from within Python via the @ref praatUtil module, one can create fully or semi-automated algorithmic solutions for analyzing huge amounts of data - an approach that, once mastered, vastly increases productivity!
</div>

<div>
There is no limit to the praises I sing for the matplotlib framework, it has enormously simplified my life as a publishing scientist. Matplotlib is easy to use at large, particularly when executing simpler tasks. There are, however, a few situations where matplotlib's functionality is obscure and not well documented (mostly if one wants to tweak details in a graph's appearance). To overcome this minor shortcoming, a number of utility functions are collected in the module @ref matplotlibUtil.
</div>

<div>
A few of these utility functions (and one class for handling the layout of graphs: @ref CGraph) are illustrated in the code below:
</div>

<div>
<a href="matplotlibUtilDemo.py">Download source code</a>

@include matplotlibUtilDemo.py
</div>

<div>
Running this script will produce this graph:
</div>

<div>
<img src="matplotlibUtilDemo.png">
</div>
<div style="text-align:right;"><a href="#topOfPage"><span style="font-size:10px;">top of page</span></a></div>
</div>

<!-- ###################################################################### -->

<div>
<a name="videoDemo"></a>
<h2>Generating a video from a series of matplotlib graphs</h2>

<div>
<a href="http://ffmpeg.org/">FFMPEG</a> is an excellent open source tool to process and manage video data. Here, we utilize FFMPEG's functionality to turn a series of graphs (created with matplotlib) into an AVI movie. In order for this to work, you need to have FFMPEG installed and an available on your <a href="http://en.wikipedia.org/wiki/Command-line_interface">command line</a>.
</div>

<div>
<a href="videoDemo.py">Download source code</a> | <a href="WilhelmScream.wav">WAV input file</a>
@include videoDemo.py
</div>

<div>
Running this script will produce this <a href="WilhelmScream.avi">video</a>.
</div>


<div style="text-align:right;"><a href="#topOfPage"><span style="font-size:10px;">top of page</span></a></div>
</div>

<!-- ###################################################################### -->

<!-- paragraph template
<div>
<a name="videoDemo"></a>
<h2>Generating a video from a series of matplotlib graphs</h2>
<div>
<div style="text-align:right;"><a href="#topOfPage"><span style="font-size:10px;">top of page</span></a></div>
</div>
-->

<!-- ###################################################################### -->

"""

# this is a dummy page for documentation purposes only
