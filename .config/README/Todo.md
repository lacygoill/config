# Config files
## make sure we use underscores and hyphens consistently in their names

## make sure we have always set the executable bit only when necessary

    $ editor ~/.cfg-fileperms +'new | read # | silent vglobal /775$/ delete'
