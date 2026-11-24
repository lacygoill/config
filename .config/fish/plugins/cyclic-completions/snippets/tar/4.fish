--null --create --file=ARCHIVE.tar --files-from=- --verbose
    # Archive files/directories whose paths are given by another command.
    #
    # For example, `$ find . -mindepth 1 ... -printf '%P\0'`.
    #                       ^---------^
    #                       to prevent `tar(1)` from archiving the whole directory because of `.`
    #
    # ---
    #
    # Warning: Make sure the previous command does not output absolute file names.
    #
    # ---
    #
    # Warning: Make sure `--null` comes before `--files-from`.
