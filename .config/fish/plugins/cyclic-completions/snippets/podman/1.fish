ps --format='{{.Names}}\t{{.Command}}\t{{.Size}}\t{{.Status}}' --all --no-trunc --size
    # To understand `--size` output:
    #
    #                                     size of the changes made to the container
    #                                     v----v
    #     myapp       /usr/bin/run-httpd  32.4kB (virtual 440MB)  ...
    #     my_ubuntu   bash                767MB (virtual 72.8MB)  ...
    #                                                    ^----^
    #                                                    size of the image on which the container is based
    #                                                    (it's "virtual" because it can be shared between containers)
    #
    # ---
    #
    # `{{.Ports}}` might be useful if you run containerized web servers.
    # See `man podman-ps /OPTIONS/;/--format=format` for the  full list of valid
    # placeholders.
