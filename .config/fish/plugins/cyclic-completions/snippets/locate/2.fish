--ignore-case --basename '\NAME'
    # Find file(s) whose name is exactly `NAME`.
    #
    # `--basename`  forces  the pattern  to  be  matched against  the  filename,
    # instead of the  whole path.  And in the pattern,  the backslash suppresses
    # the implicit `*` globbing characters which surround a pattern:
    #
    #    > If any PATTERN contains no globbing characters, locate  behaves  as  if
    #    > the pattern were `*`PATTERN`*`.
    #
    # Source: `man mlocate`
    #
    # So, to disable  this behavior, all you need is  a globbing character which
    # doesn't change the pattern.  A backslash seems to fit the bill.
    #
    # For more info, see `man mlocate /EXAMPLES`.
