# Write temporary files into `$TMPDIR` (instead of `/tmp`).

In the python scripts, you might need:

    from os import getenv
    ...
    f'{getenv("TMPDIR")}/...'

Or maybe:

    from os import environ
    ...
    f'{environ["TMPDIR"]}/...'

Not sure about the equivalent in a lua script.
