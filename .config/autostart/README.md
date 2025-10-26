# What is the purpose of this directory?

It  contains  `.desktop`  files  that  determine  which  processes  are  started
automatically   when   you   log   in.    It's  not   alone;   there   is   also
`/etc/xdg/autostart/`.

# What is the purpose of a `.desktop` file which only contains `[Desktop Entry]` and `Hidden=true`?

Suppose there is a file with the same name in `/etc/xdg/autostart/`.  It will be
started automatically  whenever we log  in.  To prevent  this, you can  create a
file with the same name here, whose contents is simply:

    [Desktop Entry]
    Hidden=true

# How is a process autostarted exactly?

   1. the systemd process starts the login/display manager (e.g. `lightdm` or `sddm`)

   2. the latter starts a helper process (e.g. `lightdm` again, or
      `sddm-helper`); probably  to isolate the user sessions (which provides
      several benefits: better security, stability, resource management, ...)

   3. the helper starts a session process (e.g. `xfce4-session` or `lxqt-session`)

   4. the session process autostarts some processes according to the `.desktop`
      files in `/etc/xdg/autostart` and `~/.config/autostart/`

As an example, here is the tree of processes for the autostarted geoclue process
on Xubuntu and Lubuntu:

    # Xubuntu
    $ pstree --long --show-parents --show-pids $(pgrep --full geoclue)
    systemd(1)───lightdm(748)───lightdm(1213169)───xfce4-session(1213683)───agent(1213879)─┬─{agent}(1213882)
                                                                                           └─{agent}(1213895)


    # Lubuntu
    $ pstree --long --show-parents --show-pids $(pgrep --full geoclue)
    systemd(1)---sddm(811)---sddm-helper(974)---lxqt-session(986)---agent(1099)-+-{agent}(1106)
                                                                                `-{agent}(1111)
