# Which rules should I follow with regard to the position of options?

Their position  relative to `-i ...`  is crucial since  they are applied  to the
next specified file.

To avoid issues follow these rules:

   - Global options (e.g. verbosity level) should be specified first.

   - Do not mix input and output files – first specify all input files, then all
     output files.

   - Do not mix options that apply to different files.   Options apply *only* to
     the next input or output file, and  are reset between files.  Note that you
     can  have  the  same  option  on the  command-line  multiple  times.   Each
     occurrence is then applied to the next input or output file.  For example:

         # force frame rate of input file to 1 fps and frame rate of output file to 24 fps
         $ ffmpeg -r 1 -i input.m2v -r 24 output.avi
                  ^--^              ^---^

# What's the consequence of a highly compressed/high-quality media file?

It's more demanding to decode for the CPU when being played back.
