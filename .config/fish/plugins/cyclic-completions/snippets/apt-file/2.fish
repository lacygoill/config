search --regexp
    # Alternative:  `$ apt download <package> && dpkg --contents ./*.deb`
    #
    # TODO: Once  you  get  `apt-file(1)`  version  3.3  or  higher,  try  using
    # `--stream-results`.  It reduces the time until the first match is printed,
    # as well as the memory requirements.
