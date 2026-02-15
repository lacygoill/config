--extract --file=ARCHIVE.tar --verbose
    # To read the output from another command, replace `ARCHIVE.tar` with `-`.
    #
    # ---
    #
    # Do not add anything at the end:
    #
    #     $ tar --extract --file=ARCHIVE.tar --verbose dir/
    #                                                  ^--^
    #                                                   ✘
    #
    # `dir/` would  be wrongly  parsed as  a member  of the  archive (as  if you
    # wanted it  to be extracted  alone).  If you  want `tar(1)` to  extract the
    # archive in a different directory than the CWD, use `--directory=dir`.
