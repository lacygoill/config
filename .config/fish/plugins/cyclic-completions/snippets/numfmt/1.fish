--field=- --to=iec
    # Format number into human-readable form.
    #
    # `--field=-`: replace numbers in all input fields.
    # `--to=iec`: auto-scale  output numbers  to `K` (thousand),  `M` (million),
    # ... units.
    #
    # ---
    #
    # `numfmt(1)` can read from STDIN, and supports these other options:
    #
    #    - `--header=N`: ignore first N lines.
    #      Useful if the input does not contain any number on the first N lines.
    #
    #    - `--field=N-M`: the numbers are on the N-th field, up to the M-th one.
    #      Useful if they're not at the start of the lines.
    #
    #    - `--delimiter=,`: the numbers are separated by commas.
    #      Useful if they're not separated by whitespace.
