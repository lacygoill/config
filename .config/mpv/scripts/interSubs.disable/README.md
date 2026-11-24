# Where are the interSubs scripts?

   - `scripts/interSubs.lua`
   - `scripts/interSubs.disable/interSubs.py`
   - `scripts/interSubs.disable/interSubs_config.py`

##
# How to
## change the appearance of the subtitles?

In `interSubs_config.py`, set `style_subs` to the desired value.
For example:

    style_subs = '''
            /* looks of subtitles */
            QFrame {
                    background: transparent;
                    color: white;

                    font-family: "Trebuchet MS";
                    font-weight: bold;
                    font-size: 53px;
            }
    '''

## change the Web service used to pronounce words?

In `interSubs_config.py`, set `listen_via` to one of these values:

   - `gtts`
   - `pons`
   - `forvo`

## display the subtitles even when the mpv window is not in full screen mode?

In `interSubs_config.py`, set `hide_when_not_fullscreen_B` to `False`.

##
## get the audio pronunciation of a word?

In `interSubs_config.py`, bind the `f_listen` function to some key.

For example, to bind it to a right click:

    mouse_buttons = [
            ['RightButton',              'NoModifier',           'f_listen'],
            ...

## translate a whole sentence?

In `interSubs_config.py`, bind the `f_translation_full_sentence` function to some key.

The  feature  leverages some  Web  service  (either  Google Translate  or  DeepL
Translate), which is set by `translation_function_name_full_sentence`.

If your AS is blacklisted by DeepL, try Google.
##
# I get a bunch of "SyntaxWarning: invalid escape sequence" error messages!

Edit    `~/.config/mpv/scripts/interSubs.disable/interSubs.py`     and    prefix
problematic regexes with `r`.  Example:

    p = re.sub(r'<div style="float:right;color:#999">\d*</div>', '', p)
               ^
