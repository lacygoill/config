# `reenable` is a combination of `disable` and `enable`.

It's better to use `reenable` rather  than `enable` to enable a unit after
editing the `[Install]` section of its unit file.

A unit is  enabled through the creation of symlinks,  as configured in the
`[Install]` section of its unit file.  `enable` is only concerned with the
creation of  new symlinks; it doesn't  remove any stale symlink.   So, for
example, if you have this section in a unit file:

    [Install]
    WantedBy=multi-user.target
             ^--------^

And you edit it like so:

    [Install]
    WantedBy=graphical.target
             ^-------^

Then execute `$ systemctl enable <name>`, a new symlink would be created in:

    /etc/systemd/system/graphical.target.wants/

But the stale one in:

    /etc/systemd/system/multi-user.target.wants/

would *not* be removed.  `reenable` *would* remove it.
