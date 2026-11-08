/dev/tty
    # Useful to get instantaneous feedback in a pipeline where a command takes a long time.
    #
    # For example:
    #
    #       should take enough time to illustrate the benefit of tee(1)
    #       v-------------v
    #     $ find /home /usr 2>/dev/null | tee /dev/tty | wc -l
    #                                     ^----------^
    #
    # ---
    #
    # `$ CMD | tee FILE` is another common idiom.
    #
    # If `CMD` was originally meant to  write its output into `FILE` (either via
    # a custom command-line option or a  redirection), but is slow, `tee(1)` can
    # be useful.   It will  write `CMD`'s  output into `FILE`,  but also  to the
    # terminal, since  its own STDOUT is  connected to the latter  (and `tee(1)`
    # always writes to its STDOUT, in addition to optional files).
