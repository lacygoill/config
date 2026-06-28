--ignore-leading-blanks --stable --version-sort
    # `--stable`: useful for lines scoring the same; guarantees that the order of the next field is preserved
    #
    # ---
    #
    # `--version-sort`: less unexpected results (and sort like Vim's `:sort`)
    #
    #     $ printf '%s\n' ':a' ':d' 'a:c' 'a:b' | sort
    #     :a
    #     a:b
    #     a:c
    #     :d
    #
    # Here, I would  expect the `:a`/`:d` lines to be  grouped; not separated by
    # the `a:b`/`a:c`  lines.  Without  `--version-sort`, `sort(1)`  ignores the
    # colon.
