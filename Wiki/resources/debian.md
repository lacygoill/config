The Universal Operating System

# DpkgBot on #debian

    $ xdg-open 'https://wiki.debian.org/IRC/DpkgBot' \
        && xdg-open 'https://ircbots.debian.net/factoids/'

# APT configuration

    $ man 5 apt.conf  # See also: /usr/share/doc/apt/examples/configure-index

# aptitude reference manual

    # require the `aptitude-doc-en` package
    $ xdg-open /usr/share/doc/aptitude/html/en/index.html

# aptitude user manual

    $ editor +'Man 7 glob' \
        +'Man 7 apt-patterns' \
        +'bufdo argadd %' \
        +argdedupe \
        +close \
        /usr/share/doc/aptitude/README

# ISOs

    $ xdg-open 'https://cdimage.debian.org/debian-cd/current-live/amd64/bt-hybrid/' \
        && xdg-open 'https://www.debian.org/releases/stable/debian-installer/'

If you want to *try* the system, download a **live install** image.
If you want to *install* it, download the **netinst CD** image.

---

For old distributions (e.g. oldstable): <https://cdimage.debian.org/cdimage/archive/>

# packaging

<https://wiki.debian.org/Packaging>

See  also  the  chapter  15  “Creating  a  Debian  Package”  in  The  Debian
Administrator's Handbook.
