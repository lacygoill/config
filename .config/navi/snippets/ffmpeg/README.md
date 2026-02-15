# `-an`, `-sn`, `-vn`

Do not automatically select any audio/subtitle/video stream.
For full manual control over the streams selection, use `-map`.

# `-b`, `-b:v`, `-b:a`

Set video or audio bitrate.  Prefer `-b:v` over `-b`.

See:

    $ ffmpeg -hide_banner -help | grep bitrate
    -b bitrate          video bitrate (please use -b:v)
    -ab bitrate         audio bitrate (please use -b:a)

Also:

   > Options may be set by specifying **-option value** in the FFmpeg tools, or
   > by setting the value explicitly in the "AVCodecContext" options or
   > using the libavutil/opt.h API for programmatic use.
   >
   > The list of supported options follow:
   >
   > **b integer** (encoding,audio,video)
   >     Set bitrate in bits/s. Default value is 200K.
   >
   > **ab integer** (encoding,audio)
   >     Set audio bitrate (in bits/s). Default value is 128K.

Source: `man ffmpeg-codecs /^CODEC OPTIONS/;/^\s*b\>`

# `-y`

Overwrite output files without asking.

##
# `-codec[:stream_specifier] copy`

Copy streams as  they are (from input to output  file), instead of unnecessarily
transcoding them. It saves a lot of time, and avoid quality loss.

# `-map [-]input_file_ID[:stream_specifier][?]`, `-map [linklabel]`

Select which streams from which inputs will go into the output file.

`input_file_ID` is a 0-based index identifying the input file.

If `:stream_specifier` is omitted, all streams of the input file are selected.

---

`-map`  can be  used  several  times to  select  several  streams.  Their  order
matters: the first  `-map` specifies the source for output  stream 0, the second
`-map` specifies the source for output stream 1, ... For example:

    $ ffmpeg -i a.mov -i b.mov -codec copy -map 0:v -map 1:a:6 out.mov

This  selects all  video  streams  from input  file  `a.mov`  (specified by  the
identifier  `0:v`),  and the  audio  stream  with  index  6 from  input  `b.mov`
(specified  by the  identifier  `1:a:6`), and  copies them  to  the output  file
`out.mov`.

---

An optional leading `-` disables matching streams from already created mappings.
For example:

    all streams in first input     second audio stream
                      v----v       v---v
    $ ffmpeg -i INPUT -map 0 -map -0:a:1 OUTPUT
                                  ^
                                  negates the mapping

This maps all the streams except the second audio.

---

An optional  trailing `?` allows the  map to be  optional.  That is, if  the map
matches no streams,  it will be ignored  instead of failing.  Note  that it will
still fail if an invalid input file index  is used; such as if the map refers to
a non-existent input.  For example:

    $ ffmpeg -i INPUT -map 0:v -map 0:a? OUTPUT
                                       ^

This maps the video and audio streams from the first input.  But, thanks to `?`,
the audio mapping will not fail if the file does not contain any audio stream.

---

`-map [linklabel]` is  an alternative syntax  which maps outputs from  a complex
filter  graph  (see `-filter_complex`)  to  the  output file.  `linklabel`  must
correspond to a defined output link label in the graph.  For example:

    $ ffmpeg -i video.avi \
        -filter_complex 'extractplanes=y+u+v[y][u][v]' \
        -map '[y]' y.avi \
        -map '[u]' u.avi \
        -map '[v]' v.avi

This extracts the luma, u and v color channel components from `video.avi` into 3
grayscale output video  files.  Note that both in  `-filter_complex` and `-map`,
`[y]`,  `[u]` and  `[v]`  are arbitrary  labels.  You  could  replace them  with
anything you want (e.g. `[foo]`, `[bar]`, `[baz]`).

---

When `-map` is written *after* an  output file, it *resets* the selected streams
(instead of adding to the selection).  For example:

    $ ffmpeg -i video.mkv \
        -map 0:a:0 -codec:a libmp3lame -b:a 64K music-low.mp3 \
        -map 0:a:0 -codec:a libmp3lame -b:a 128K music-high.mp3

Here, we  extract the  audio stream  out of  a video  file (`video.mkv`)  into 2
output audio files (`music-{low,high}.mp3`), with different bitrates.  This also
illustrates that you can generate multiple output files with a single command.

# `-metadata[:s:stream_specifier]`

A bare `-metadata` sets a metadata key at the global/file/container level.

With a stream specifier, it sets a metadata key at a given stream level.
`:s` stands for "per-stream metadata".

The 0-based  index in the  stream specifier  identifies a given  *output* stream
(there might be several streams of the same type; e.g. multiple audio tracks for
several languages  in a  movie).  Note  that the index  applies to  the *output*
file, because metadata  is all about the latter.  This  is different than `-map`
for which the indexes apply to the *input* files.

See: `man ffmpeg /OPTIONS/;/Advanced options/;/-map_metadata/;/^\s*s\>`

---

Whether you can set a given key depends  on the muxer.  For example, you can set
an arbitrary key in an `.mkv`, `.webm`, or `.ogg` (!) (at the global level *and*
at the stream level).   But you can't in an `.avi` or `.mp4`.   And you can only
at the global level in an `.mp3` or `.flv`.

(!) Actually,  when I  try to  set global metadata  in an  `.ogg` file,  it sets
metadata  at  the  stream  level.   Maybe  `.ogg`  files  don't  contain  global
metadata...

# ?

    -map_metadata[:metadata_specifier] input_file_ID[:metadata_specifier]

Copy metadata information of next output file from given input file.

Note that the  left `metadata_specifier` is for the next  output file; the right
one is for the input file of given ID.

---

`metadata_specifier` specifies which metadata to copy.  It can be:

   - `g`: global metadata (i.e. metadata that applies to the whole file)

   - `s[:stream_specifier]`: As an *input* metadata specifier,  the *first*
     matching stream is copied from.  As an *output* metadata specifier, *all*
     matching streams are copied to.

If omitted, it defaults to `g` (i.e. global).

---

By default, global metadata is copied  from the first input file, and per-stream
metadata is copied  along with streams.  These default mappings  are disabled by
creating any mapping of the relevant type.  A negative file index can be used to
create a dummy mapping that just disables automatic copying.

For example,  to copy  metadata from  the first subtitle  stream of  `in.ogg` to
global metadata of `out.mp3`:

    $ ffmpeg -i in.ogg -map_metadata:g 0:s:0 out.mp3
                                    ^^

To do the reverse, i.e. copy global metadata to all audio streams:

    $ ffmpeg -i in.mkv -map_metadata:s:a 0:g out.mkv
                                          ^^

Note that `:g` could be omitted in both examples, but better be explicit.

---

For further  testing, let's  generate an audio  file, with  simple global/stream
metadata:

    $ cd /tmp/1000-user/test
    $ cp ~/Music/Logically.mp3 in.mp3
    $ ffmpeg -hide_banner -i ./in.mp3 \
        -map_metadata -1 \
        -metadata aaa=bbb \
        -metadata:s:a:0 encoder=ccc \
        -codec copy \
        -y out.mp3 2>/dev/null
    $ ffprobe -hide_banner ./out.mp3

Note that, for an MP3, at the global  level, we can set an arbitrary key (except
`encoder`).  And at  the stream level, it's  the opposite; we can  only set some
specific key(s) (e.g. `encoder`).

Edit: After performing some quick tests, it seems that:

   1. erasing global metadata with `-map_metadata` has no effect on stream-level
      metadata

   2. erasing stream-level metadata with `-map_metadata` erases *all* metadata
      (global + any stream)

   3. writing global metadata with `-metadata` has no effect on stream-level
      metadata

   4. writing stream-level metadata with `-metadata` has no effect on global
      metadata

`2.` is inconsistent...

You've   tested   "erasing"  and   "writing".    What   about  "copying"   (i.e.
`-map_metadata`, but without dummy `-1` input ID)?

TODO: More tests.

    #!/bin/bash -

    readonly DIR="$TMPDIR"/test
    cd "$DIR" || exit

    readonly -A TESTS=(
      [erase global metadata]='-map_metadata:g -1'
      [erase stream-level metadata]='-map_metadata:s:a -1'
      [copy global metadata]='-map_metadata:g 0:g'
      [copy stream-level metadata]='-map_metadata:s:a 0:s:a'
      [write global metadata]='-metadata eee=fff'
      [write stream-level metadata]='-metadata:s:a:0 encoder=ggg'
    )

    # no AVI files, because it seems we can't set any metadata for those
    readonly -a INPUT_FILES=(
      # FLV
      '/media/lgc/HDD-INT-2T/Videos/Udacity/Crypto/Unit_1/Unit_1/05-Do_Not_Implement_Your_Own_Crypto_Solution.flv'
      # MKV
      '/media/lgc/HDD-INT-2T/hdd-500G-backup/SERIES/Mr Robot/Mr Robot S01E10/Sample/sample-mr.robot.s01e10.720p.hdtv.x264-killers.mkv'
      # MP3
      "$HOME"/Music/Logically.mp3
      # MP4
      '/media/lgc/HDD-INT-2T/hdd-500G-backup/TECH/Wireshark/07. Wrapping Up/07_03-Conclusion.mp4'
      # OGG
      '/media/lgc/HDD-INT-2T/hdd-500G-backup/Music/KEYGENMUSiC MusicPack/AiR/AiR - Italian Grand kg.ogg'
      # WEBM
      '/media/lgc/HDD-INT-2T/hdd-500G-backup/TECH/LOGIC/Thought Experiments/14 - Thought Experiments in Artificial Intelligence.webm'
    )

    for input in "${INPUT_FILES[@]}"; do
      ext="${input##*.}"
      cp "$input" in."$ext"
      ffmpeg -hide_banner -i ./in."$ext" \
        -metadata aaa=bbb \
        -metadata:s:a:0 encoder=ccc \
        -metadata:s:a:0 handler_name=ddd \
        -codec copy \
        -y out."$ext" 2>/dev/null
      mv out."$ext" in."$ext"

      for some_test in "${!TESTS[@]}"; do
        # shellcheck disable=SC2086
        ffmpeg -hide_banner -i ./in."$ext" \
          ${TESTS[$some_test]} \
          -codec copy \
          -y out."$ext" 2>/dev/null

        ffprobe -hide_banner ./in."$ext" >./before 2>&1
        ffprobe -hide_banner ./out."$ext" >./after 2>&1
        if ! vimdiff +"echowindow ${some_test@Q} | wincmd l" ./{before,after}; then
          break 2
        fi
      done
    done

---

About `-metadata`:

   > This option overrides metadata set with "-map_metadata". It is also
   > possible to delete metadata by using an empty value.

Document that.  Also, what's the idiomatic way to delete metadata?
With `-map_metadata` and a dummy `-1` input ID?
Or with `-metadata` and an empty value?

---

Mux a file with multiple video and audio streams.
Write metadata at the global level, and at every stream-level.
Erase  given stream-level  metadata (with  `-map_metadata:s:... -1`), and  check
whether all metadata is erased.  If it is, write the code to reproduce the issue
in a pitfall fold.

    $ find /usr/share/sounds -name '*.wav' -type f -print \
        | head --lines=2 \
        | xargs --delimiter='\n' --replace='{}' cp '{}' .

    $ find /usr/share -name '*.png' -type f -print \
        | head --lines=2 \
        | xargs --delimiter='\n' --replace='{}' cp '{}' .

# `stream_specifier`

Look for "stream specifier" in the glossary.

##
# `-ss <position>`

Specify  timestamp  of playback  location  from  which  processing needs  to  be
performed.

Writing `-ss` *before*  `-i`, instead of after, makes a  command faster.  That's
because, after `-i`, `ffmpeg(1)` has to  needlessly decode all the data from the
beginning up to the given position, and then discards it:

   > When used as an output option (before an output url), decodes but
   > discards input until the timestamps reach position.

Source: `man ffmpeg /OPTIONS/;/Main options/;/-ss`

In contrast,  *before* `-i`, `-ss`  lets `ffmpeg(1)`  quickly jump to  the given
position without having to decode anything.

# `-t <duration>`

When used as an input option (before `-i`), limit the duration of data read from
the input file.

When used as  an output option (after  `-i`), stop writing the  output after its
duration reaches duration.

# `-to <position>`

Stop writing the output or reading the input at given position.

`-to` and `-t` are mutually exclusive, and `-t` has priority.

---

Warning: Do *not*  write `-to` after  `-i`, and `-ss`  before `-i`.  If  you do,
`-to` behaves like  `-t` (probably because the start of  the original input gets
lost; it's discarded  up to the specified position; so  the position after `-to`
is relative to that new start).  Either omit `-ss`, or write it on the same side
as `-to` relative to `-i` (i.e. both before or both after).

# `<position>`, `<duration>`

A time position/duration can be expressed as:

    [<HH>:]<MM>:<SS>[.<m>]

`HH`/`MM`/`SS` is  the number  of hours/minutes/seconds (with  a maximum  of two
digits for the minutes and seconds). `m` is the decimal value for `SS`.

Or as:

    <S>[.<m>]

`S` is the  number of seconds (any  number of digits); `m`  the optional decimal
part.

Examples:

    ┌──────────┬─────────────────────────────────────┐
    │ 55       │ 55 seconds                          │
    ├──────────┼─────────────────────────────────────┤
    │ 12:03:45 │ 12 hours, 03 minutes and 45 seconds │
    ├──────────┼─────────────────────────────────────┤
    │ 23.189   │ 23.189 seconds                      │
    └──────────┴─────────────────────────────────────┘

For more info: `man ffmpeg-utils /SYNTAX/;/Time duration`.
