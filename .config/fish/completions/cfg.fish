complete --command=cfg --no-files

# subcommands {{{1

#     $ cfg apt
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=apt \
    --description='Advanced Package Tool'

#     $ cfg autostart
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=autostart \
    --description='autostart script'

#     $ cfg bash
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=bash \
    --description='GNU Bourne-Again SHell'

#     $ cfg bat
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=bat \
    --description='cat(1) clone with syntax highlighting and Git integration'

#     $ cfg cargo
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=cargo \
    --description="Rust's package manager"

#     $ cfg conky
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=conky \
    --description='system monitor for X'

#     $ cfg cmus
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=cmus \
    --description='C* Music Player'

#     $ cfg ctags
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=ctags \
    --description='Generate tag files for source code'

#     $ cfg feh
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=feh \
    --description='image viewer and cataloguer'

#     $ cfg fish
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=fish \
    --description='the friendly interactive shell'

#     $ cfg fzf
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=fzf \
    --description='fuzzy finder'

#     $ cfg gdb
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=gdb \
    --description='The GNU Debugger'

#     $ cfg git
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=git \
    --description='the stupid content tracker'

#     $ cfg htop
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=htop \
    --description='interactive process viewer'

#     $ cfg info
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=info \
    --description='read Info documents'

#     $ cfg intersubs
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=intersubs \
    --description='interactive subtitles for mpv'

#     $ cfg kernel
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=kernel \
    --description='kernel parameters'

#     $ cfg keyd
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=keyd \
    --description='keyboard layout'

#     $ cfg kitty
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=kitty \
    --description='terminal emulator'

#     $ cfg latexmk
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=latexmk \
    --description='generate LaTeX document'

#     $ cfg less
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=less \
    --description='pager'

#     $ cfg ls
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=ls \
    --description='list directory contents'

#     $ cfg mpv
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=mpv \
    --description='media player'

#     $ cfg navi
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=navi \
    --description='interactive shell snippet tool'

#     $ cfg newsboat
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=newsboat \
    --description='RSS/Atom feed reader'

#     $ cfg nnn
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=nnn \
    --description='terminal file manager'

#     $ cfg pam
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=pam \
    --description='Pluggable Authentication Modules for Linux'

#     $ cfg podman
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=podman \
    --description='Simple management tool for pods, containers and images'

#     $ cfg pudb
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=pudb \
    --description='console-based visual debugger for Python'

#     $ cfg pylint
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=pylint \
    --description='static code analyser for Python'

#     $ cfg radare2
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=radare2 \
    --description='Advanced command-line hexadecimal editor, disassembler and debugger'

#     $ cfg readline
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=readline \
    --description='line editor'

#     $ cfg redshift
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=redshift \
    --description='set color temperature of display according to time of day'

#     $ cfg s
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=s \
    --description='web search from terminal'

#     $ cfg shellcheck
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=shellcheck \
    --description='shell script analysis tool'

#     $ cfg ssh
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=ssh \
    --description='OpenSSH remote login client'

#     $ cfg systemd
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=systemd \
    --description='systemd system and service manager'

#     $ cfg tig
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=tig \
    --description='TUI for Git'

#     $ cfg tmux
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=tmux \
    --description='terminal multiplexer'

#     $ cfg trans
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=trans \
    --description='Command-line translator'

#     $ cfg urlscan
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=urlscan \
    --description='TUI browser for URLs'

#     $ cfg vim
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=vim \
    --description='text editor'

#     $ cfg w3m
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=w3m \
    --description='TUI web browser'

#     $ cfg weechat
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=weechat \
    --description='TUI IRC client'

#     $ cfg xfce-terminal
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=xfce-terminal \
    --description='terminal emulator for XFCE'

#     $ cfg xterm
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=xterm \
    --description='terminal emulator for X'

#     $ cfg yt-dlp
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=yt-dlp \
    --description='youtube-dl fork with additional features and patches'

#     $ cfg zathura
complete --command=cfg \
    --condition='__fish_use_subcommand' \
    --arguments=zathura \
    --description='document viewer'
