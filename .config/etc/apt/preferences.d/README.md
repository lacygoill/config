# Files in this directory should have the `.no` or `.pref` extension.

   > Note that the files in the /etc/apt/preferences.d directory are parsed
   > in alphanumeric ascending order and need to obey the following naming
   > convention: **The files have either no or "pref" as filename extension**
   > and only contain alphanumeric, hyphen (-), underscore (_) and period
   > (.) characters.

Source: `man 5 apt_preferences`

In practice, the pinning seems to  work without these extensions.  But better be
safe than sorry, so let's respect this convention.

# How to put a comment in these files?

There is  no official syntax, but  some textual descriptions can  be provided by
putting one or more “Explanation” fields at the start of each entry:

    Explanation: The package xserver-xorg-video-intel provided
    Explanation: in experimental can be used safely
    Package: xserver-xorg-video-intel
    Pin: release a=experimental
    Pin-Priority: 500
