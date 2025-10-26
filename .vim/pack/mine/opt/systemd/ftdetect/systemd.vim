vim9script

# `.conf`  files in  `/etc/systemd/`  are currently  not  detected with  the
# `systemd` filetype (but with `conf` instead).  We want them to be.
autocmd! BufNewFile,BufRead /etc/systemd/*.conf setfiletype systemd
