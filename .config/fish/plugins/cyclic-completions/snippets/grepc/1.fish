--count
    # This *might* be an anti-pattern:
    #
    #     $ grep pat file | wc -l
    #
    # Instead, you *might* want to run:
    #
    #     $ grep --count pat file
    #
    # For more info, see the README.
