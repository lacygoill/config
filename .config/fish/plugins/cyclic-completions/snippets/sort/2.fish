^W xargs --delimiter='\n' stat --format='%z %n' -- | sort
    # Sort paths by time of last status change (`%z`).
    #
    # ---
    #
    # Warning: Do *not* use the time of last data modification (`%y`).
    #
    # If a file is  moved, its data is not considered to  be modified.  But it's
    # useful to sort a moved file at the  end (e.g. it's easier to find a config
    # file which  we need to  `$ config add` back after  it has been  moved, via
    # `$ config untracked`).
    #
    # ---
    #
    # Warning: If  connected to  `$ ls  -l`, remove  `-l`.  Or  better yet,  use
    # `--sort=time --time=ctime`.
    #
    # ---
    #
    # Warning: If a  path can contain  a newline, try to  pass an option  to the
    # command so that  it produces NULL-separated output.  And  pass `--null` to
    # `xargs(1)`, as well as `--zero-terminated` to `sort(1)`.
