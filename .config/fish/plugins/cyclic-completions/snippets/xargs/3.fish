--open-tty
    # Reopen STDIN as `/dev/tty` in the child process before executing the command.
    #
    # This lets the command be associated to the terminal while `xargs(1)` reads
    # from a  different stream, e.g.  from a pipe.  This  is useful if  you want
    # `xargs(1)` to run an interactive application:
    #
    #     $ grep --files-with-matches --null PATTERN * \
    #         | xargs --null --open-tty vi
    #                        ^--------^ ^^
    #                                   interactive application
    #
    # An alternative would be:
    #
    #     $ grep --files-with-matches --null PATTERN * \
    #         | xargs --null sh -c 'vi "$@" </dev/tty' vi
    #                                       ^-------^  ^^
    #                                                  to prevent sh(1) from consuming first input file to set $0
