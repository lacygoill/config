# What are the valid scopes of systemd commands (`systemctl(1)`, `journalctl(1)`, `systemd-analyze(1)`, ...)?

   - `--system` (implied by defaul) talks to the service manager of the system

   - `--user` talks to the service manager of the calling user

   - `--runtime` limits  the effect of the  command to this boot  of the system
     (by changing files in `/run/` instead of `/etc/`)
