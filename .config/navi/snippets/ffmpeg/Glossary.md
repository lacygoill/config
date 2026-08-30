# c
## channel

In an audio stream,  a channel refers to a specific component  of the sound that
is played through a specific speaker.

---

For example, a  stereo audio stream has  two channels: the left  channel and the
right  channel.  The  left channel  contains  sound information  that is  played
through the  left speaker,  while the right  channel contains  sound information
that is played through the right speaker.

OTOH, a 5.1 surround sound audio stream  has six channels: the left, center, and
right channels, as well as left and right surround channels, and a low frequency
effects (LFE) channel.  Each  of them is meant to be played  back by a different
speaker  in a  surround setup  (the LFE  channel is  typically played  through a
subwoofer).

---

By separating the sound information into  different channels, it allows for more
precise  control over  how the  sound is  played back,  and can  provide a  more
immersive listening experience.

Note that  channels are interleaved.   For example, if  you have a  stereo audio
stream, a  sample from the left  channel will be  followed by a sample  from the
right channel, and this pattern repeats throughout the file.

## channel layout

Specific arrangement of audio channels within an audio stream.

It defines the number and position of each channel, and helps to ensure that the
sound is played back correctly in a given playback environment.
The position  of a channel is  the location of  the speaker in a  surround sound
setup where the audio from that channel is intended to be played.

For example, a  stereo channel layout would typically have  two channels: a left
channel and a right channel.  The left  channel would be played through the left
speaker, and the right channel would be played through the right speaker.

OTOH, a 5.1 channel layout would have six channels: a center channel, a left and
right front  channel, a  left and  right surround  channel, and  a low-frequency
effects (LFE) channel.   The center channel would typically be  played through a
center speaker,  the front left and  right channels would be  played through the
left and  right speakers, the surround  left and right channels  would be played
through  the  left and  right  surround  speakers,  and  the LFE  channel  would
typically be played through a subwoofer.

Channel layouts are important because they allow audio engineers to create sound
mixes with specific speaker configurations in mind, and ensure that the sound is
played back as intended in a given playback environment.

---

For a list of standard layouts, see: `man ffmpeg-utils /SYNTAX/;/Channel Layout`.
For example, a 7.1 layout can be expressed as `FL+FR+FC+LFE+BL+BR+SL+SR`:

   - The front left and right speakers (FL & FR) provide sound effects and music.

   - The front center speaker (FC) provides dialogue and on-screen action.

   - Subwoofer (LFE): The subwoofer handles **L**ow-**F**requency **E**ffects,
     producing deep bass and vibrations.

   - The back left and right speakers (BL & BR) are placed behind the listener
     and add more depth to the surround sound experience.

   - The left and right surround speakers (SL & SR) add depth to the audio,
     typically placed to the side of the listener.

##
## codec

Software or hardware implementation of a coding format specification.
It en**co**des/**dec**odes  data in a  given coding format  from/to uncompressed
video/audio file.

See: <https://en.wikipedia.org/wiki/Video_coding_format#Distinction_between_format_and_codec>

##
## coding format

Layout plan  for data  produced or  consumed by  a codec.   It's described  in a
specification.

See: <https://en.wikipedia.org/wiki/Video_coding_format#Distinction_between_format_and_codec>

### Audio
#### AAC

More efficient and better sound quality than MP3.

#### AC3

Commonly used in surround sound systems, DVD, and Blu-ray.

#### MP3

Most common audio format.
Convenient for storing music on portable players or tablets.
Works on almost all playback devices.
Supported by all major browsers.
Inefficient compared to AAC, Opus, or Ogg Vorbis.

#### WAV

Lossless format (no loss of original data).
High sound quality.
Large file sizes.

#### Opus

Open-source and royalty-free alternative to MP3 and AAC.

Compared  to Vorbis,  it's  more recent  and superior  in  terms of  compression
efficiency, sound quality,  and flexibility (because it's applicable  to a wider
range of audio qualities and rates while having low latency).

#### Vorbis

Open-source and royalty-free alternative to MP3 and AAC.
Better sound quality than MP3 due to higher efficiency.
Ogg container not universally supported.

###
### Video
#### H.264

Provides a good balance between compression and quality, and is widely supported.

#### H.265

Provides a better compression than H.264 at the cost of higher CPU usage.

#### VP8

Open-source and royalty-free alternative to H.264.

#### VP9

Open-source and royalty-free alternative to H.265.

###
### Subtitle
#### SRT (aka SubRip Text)

Pros:

   - compatible with most media players and platforms
   - simpler to create/edit than SSA

Con: Less powerful than SSA.

Overall: Good choice for basic subtitle needs.

#### SSA (aka SubStation Alpha) or ASS (aka Advanced SubStation alpha)

Pro: supports  more advanced formatting options  than SRT, such as  font styles,
colors, and animations.

Cons:

   - less  widely  supported than  SRT;  might  require additional  software  or
     plugins to be displayed correctly

   - more complex to create/edit

Overall: Good choice for advanced formatting.

##
## container

    +------------------------------------------------------------------------------------------------+
    |                                  Container                                                     |
    |                                                                                                |
    | +----------------------------------------------------------------------------+                 |
    | |                                Streams                                     |                 |
    | |                                                                            |                 |
    | |  +------------------------------+  +-------------------------------+       |                 |
    | |  |Video stream                  |  |Audio stream                   |       |                 |
    | |  +---------------------+        |  +---------------------+         |       |                 |
    | |  |Video stream metadata|        |  |Audio stream metadata|         |       |                 |
    | |  +---------------------+--------+  +---------------------+---------+       |                 |
    | |                                                                            | Global metadata |
    | |  +------------------------------+  +------------------------------------+  |                 |
    | |  |Subtitle stream               |  |File attachment stream              |  |                 |
    | |  +------------------------+     |  +-------------------------------+    |  |                 |
    | |  |Subtitle stream metadata|     |  |File attachment stream metadata|    |  |                 |
    | |  +------------------------+-----+  +-------------------------------+----+  |                 |
    | +----------------------------------------------------------------------------+                 |
    +------------------------------------------------------------------------------------------------+

Notice  that  a   container  can  contain  2  types  of   metadata:  global  and
stream-specific.

A file attachment stream can contain custom fonts to display subtitles.

---

You can find the default codecs  used by `ffmpeg(1)` for a given container/muxer
with:

    $ ffmpeg -hide_banner -help muxer=<muxer> | grep codec

### MP4

Pros: Widely supported by various players and devices, easy to stream.

Cons: Limited coding format support compared to MKV.

Default codecs:

   - video: H.264
   - audio: AAC

### MKV

Pros: Supports a wide range of coding formats, flexible and extensible, better
error recovery.

Cons: Not  as widely  supported  as  MP4, may  require  additional software  for
playback on some devices.

Default codecs:

   - video: H.264
   - audio: Vorbis

### WebM

Pros: Designed for web use, open standard, good compression, and quality.

Cons: Limited coding format support, not as widely supported as MP4.

Default codecs:

   - video: VP9
   - audio: Opus

##
# i
## ID3 tags

ID3 tags can  be read with `ffprobe(1)`, and set  with `ffmpeg(1)`'s `-metadata`
and keys such as:

   - `title`
   - `album`
   - `artist`
   - `genre`
   - `date`
   - `comment`
   ...

The ID3 tag specification can be found here:

   - <https://id3.org/id3v2.3.0>
   - <https://id3.org/id3v2.4.0>

But note that there is no uniform implementation among media players.

##
# m
## muxer/demuxer

A demuxer is responsible for  extracting (demultiplexing) the individual streams
(audio, video,  subtitles, etc.) from  a media  container format.  It  reads the
input media file and separates the contained streams, allowing FFmpeg to process
them separately, for decoding, filtering, or encoding.

A muxer  is responsible for  combining (multiplexing) the separate  streams back
into a single media container format after they have been processed.

---

Here is  an ASCII  diagram showing how  the muxer/demuxer,  encoder/decoder, and
filters work together to produce the desired output:

    +----------+                     +-----------+
    |Input file|                     |Output file|
    +----------+                     +-----------+
        |                                     ^
        v                                     |
    +-------+    +-------+    +-------+    +-----+
    |Demuxer|--->|Decoder|--->|Encoder|--->|Muxer|
    +-------+    +-------+    +-------+    +-----+
                      \           ^
                       \          |
                        \     +-------+
                         +--->|Filters|
                              +-------+

Filters are optional, hence why there are 2 paths out of the `Decoder` box.

##
# s
## sample

In the context  of an audio stream,  a sample refers to a  single measurement of
the amplitude of the audio signal at a specific point in time.

---

Audio signals are continuous waveforms, meaning that they fluctuate in amplitude
(loudness)  and frequency  (pitch) over  time.  In  order to  store or  transmit
digital  audio, it  is  necessary to  break the  continuous  waveform down  into
discrete samples that can be stored as a sequence of numbers.

Each audio  sample represents the  amplitude of the  audio signal at  a specific
point in time, and  is typically represented as a 16-bit  or 24-bit integer (for
CD-quality audio) or a 32-bit floating point number (for high-resolution audio).
The more samples per second that are taken, the more accurately the audio signal
can be reproduced.

For example, CD-quality  audio has a sample  rate of 44.1 kHz,  which means that
44,100 samples  are taken per  second.  Each sample  is represented as  a 16-bit
integer, which means  that the amplitude of the audio  signal can be represented
by any one of 65,536 possible values.

When an  audio stream  is played  back, the  samples are  converted back  into a
continuous waveform  by a digital-to-analog  converter (DAC), which  produces an
analog signal that can be amplified and played through speakers or headphones.

## stream

Audio, video,  subtitles, data, or  a file  attachment inside a  container.  The
allowed number and/or types of streams can be limited by the container format.

## stream specifier

Some `ffmpeg(1)` options are applied  per-stream, e.g. bitrate or codec.  Stream
specifiers are used to precisely specify  which stream(s) a given option belongs
to.

A  stream specifier  is  a string  generally  appended to  the  option name  and
separated  from it  by a  colon.   Among other  possible  forms, it  can be  the
combination of a stream type and a  0-based stream index.  Both the type and the
index are optional.  A few examples:

    # select `ac3` codec for second audio stream
    -codec:a:1 ac3
           ^^^
           stream specifier matching second audio stream

    # select all audio streams
    -b:a 128k
       ^

An empty  stream specifier matches  all streams.  For example,  `-codec copy` or
`-codec: copy` would copy all the streams without re-encoding.

A stream specifier can also be the  combination of an optional stream type and a
metadata tag name (optionally followed by a value).  For example:

                                 stream specifier
                                 v--------------v
        $ ffmpeg -i INPUT -map 0:a:m:language:eng OUTPUT
                                  ^^ ^------^ ^^^
                                  |     |     value
                                  |    tag
                                  man ffmpeg /OPTIONS/;/Stream specifiers/;/m:key

This picks the English audio stream.

---

Even though the  stream type is optional,  it's a good habit to  always write it
explicitly (unless you  also omit the stream  index, to select all  streams of a
given input  file); it will  make your  `ffmpeg(1)` command more  reliable.  For
example, assuming  you have  a video  file containing one  video stream  and two
audio language streams:

   - prefer `0:v:0` over `0:0` for the video stream
   - prefer `0:a:0` and `0:a:1` over `0:1` and `0:2` for the audio streams

## stream type

One of:

   - `v` for all video streams
   - `V` for video streams which are not attached pictures, video thumbnails or cover arts
   - `a` for audio
   - `s` for subtitle
   - `d` for data
   - `t` for attachments

##
# t
## transcoding

The transcoding process  in `ffmpeg(1)` for each output can  be described by the
following diagram:

     _______              ______________
    |       |            |              |
    | input |  demuxer   | encoded data |   decoder
    | file  | ---------> | packets      | -----+
    |_______|            |______________|      |
                                               v
                                           _________
                                          |         |
                                          | decoded |
                                          | frames  |
                                          |_________|
     ________             ______________       |
    |        |           |              |      |
    | output | <-------- | encoded data | <----+
    | file   |   muxer   | packets      |   encoder
    |________|           |______________|

`ffmpeg(1)` calls  the libavformat library  (containing demuxers) to  read input
files and get packets containing encoded data from them.

Encoded  packets are  then passed  to  the decoder  which produces  uncompressed
frames (raw  video/PCM audio/...)  that can be  processed further  by filtering.
After filtering,  the frames are passed  to the encoder, which  encodes them and
outputs encoded  packets.  Finally those are  passed to the muxer,  which writes
the encoded packets to the output file.
