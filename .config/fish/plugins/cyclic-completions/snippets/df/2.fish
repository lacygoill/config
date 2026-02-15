^W dfc -p /dev
    # Only filesystem whose name starts with `/dev`.
    # Alternatively, to filter out the filesystems named `udev` and `tmpfs`:
    #
    #     $ dfc -p -udev,tmpfs
    #              ^
    #              negate all subsequent filesystems'
