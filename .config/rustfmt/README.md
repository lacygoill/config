# What is rustfmt?

A tool for formatting Rust code according to style guidelines.

# Where did you find the code for the current config?

    $ rustfmt --print-config default

# Where can I find documentation about the meaning of each option?

    $ rustfmt --help=config

For more details, see: <https://rust-lang.github.io/rustfmt/?version=master>

# Why are some of the options commented out?

Some of them are only available in nightly channel.

If you uncomment them, rustfmt will complain:

    Warning: can't set `...`, unstable features are only available in nightly channel.

Unless you're on the nightly channel.
We are not; for the moment, we want to be on the stable channel.

# How to perform a trial run without actually changing any file?

    $ rustfmt --check /path/to/file.rs ...
              ^-----^

If the file is already correctly formatted, rustfmt exits with 0.
Otherwise, it exits with 1, and prints a diff containing the changes which would
have been performed without `--check`.

## I don't want a diff.  I just want the list of files which require some formatting!

    $ rustfmt --check -l /path/to/file.rs ...
                      ^^

`-l` is the short form of `--files-with-diff`.

##
# The options are not applied!

Make rustfmt more verbose:

    $ rustfmt -v /path/to/file.rs
              ^^

This will show you which config files are read:

                              v------------------------------------v
    Using rustfmt config file /home/lgc/.config/rustfmt/rustfmt.toml for /tmp/rs.rs

Make sure your file is present in there.
If other files are listed too, check whether they override any of your settings.


    Format Rust code
    usage: /home/lgc/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/rustfmt [options] <file>...

    Options:
            --emit [files|stdout]
                            What data to emit and how
            --backup        Backup any modified files.
            --config-path [Path for the configuration file]
                            Recursively searches the given path for the
                            rustfmt.toml config file. If not found reverts to the
                            input file path
            --edition [2015|2018]
                            Rust edition to use
            --color [always|never|auto]
                            Use colored output (if supported)
            --config [key1=val1,key2=val2...]
                            Set options from command line. These settings take
                            priority over .rustfmt.toml
        -v, --verbose       Print verbose output
        -q, --quiet         Print less output
        -V, --version       Show version information
        -h, --help [=TOPIC] Show this message or help about a specific topic:
                            `config` or `file-lines`
