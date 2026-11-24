# Generic
## From which location can I set an option?

By increasing priority order:

   - the command-line (--option)
   - `/usr/local/etc/mpv.conf` (system-wide)
   - `~/.config/mpv/mpv.conf` (per-user)

##
## How to list all options and their default values?

    $ mpv --list-options

##
## How to change the value of an option while a video is playing?

Install a key binding:

    <key> set <option>
    │         │
    │         └ the name of the option whose value you want to change
    │
    └ your key

## How to change the value of a property? (3)

Use one of these 3 commands:

   - add
   - cycle
   - set

##
## How to start `mpv` without any config (including resume playback file)?

Use `--no-config`:

    $ mpv --no-config /path/to/media

Files explicitly requested by command line options, like `--include`.

## How to start `mpv` with a different configuration directory?

Use `--config-dir`:

    $ mpv --config-dir=/path/to/config/dir /path/to/media

`~/.config/mpv/` is ignored, and overrides through environment variables
(`MPV_HOME`) are also ignored.

Note that the `--no-config` option takes precedence over `--config-dir`.

##
## How to get the value of a property? (2)

Use the  `show-text` command, or  the property expansion mechanism  described in
`man mpv /COMMAND INTERFACE/;/Property Expansion`

##
## How to make `mpv` parse an extra configuration file after all the default ones?

Use `--include`:

    $ mpv --include=/path/to/extra/file /path/to/media

##
# Video
## How to list the compiled-in video output drivers?

    $ mpv --vo=help

## Which one should I choose?

None.

`mpv` automatically selects `--vo=gpu`.

The other drivers are for compatibility or special purposes.

If `gpu` does not work, `mpv` will  fallback to other drivers (in the same order
as listed by `mpv --vo=help`).

##
# Profiles
## How to list all available profiles?

    $ mpv --profile=help

## Where should I write per-profile settings?

At the bottom of the configuration file.

If you  write default  settings after  a profile, they'll  be restricted  to the
latter.

IOW, you can't write default settings  after a profile (unless you start writing
your settings under the profile `[default]`):

    # default settings
    ...

    [a-profile]
    # profile-local settings
    ...

    [default]
    # default settings
    ...

## How to give a description to the profile 'my-profile'?

    [my-profile]
    profile-desc="this is a description"

## Where will I see this description?

    $ mpv --profile= Tab

    $ mpv --profile=help Enter

## How to end a profile?

Start another  one or use  the profile name  'default' to continue  with default
options.

## How to include the settings of the profile 'utility' in the profile 'main'?

    [main]
    ...
    profile=utility
    ...

## How to print the options set by a profile?

    $ mpv --show-profile=<profile_name>
