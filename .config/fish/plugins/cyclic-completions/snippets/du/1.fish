--human-readable --all . | sort --key=1bh,1
    # Don't replace the `h` flag with `--human-numeric-sort`; the latter would be ignored:
    #
    #     $ sort --debug --key=1b,1 --human-numeric-sort
    #     sort: option '-h' is ignored
