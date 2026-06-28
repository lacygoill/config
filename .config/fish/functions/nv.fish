function nv #{{{1
    set -f server 'VIM'

    # if no server is running, just start one
    # Why do you look for a server whose name is VIM?{{{
    #
    # By default, when you execute:
    #
    #     $ vim --remote file
    #
    # ... without `--servername`, Vim tries to open `file` in a Vim server whose
    # name is VIM.  So,  we use this name for our default  server.  This way, we
    # won't have to specify the name of the server later.
    # }}}
    # Why `--line-regexp`?{{{
    #
    # To be  able to restart Vim  (`SPC R`) even if another  instance is running
    # with the GUI.  The latter becomes a server whose name is `VIM123`.
    # We want to ignore `VIM123`; we're only interested in a server whose entire
    # name is exactly `VIM`.
    #}}}
    if ! vim --serverlist | grep --quiet --line-regexp "$server"
        # What's this `VIMSERVER` variable?{{{
        #
        # We  inspect  it  in  `vim-session`  to  determine  whether  we  should
        # automatically restore the last Vim session.
        #}}}
        VIMSERVER=yes vim --servername $server $argv
        return
    end

    # If no argument was given, just start a new Vim session.
    if test "$(count $argv)" -eq 0
        vim
        return
    end

    # From now on, we can assume a server is running.

    # Save the tmux pane id of the Vim server now.  *Before* the other `--remote-*`.{{{
    #
    # Otherwise, there would  be a noticeable delay between the  moment the server
    # has executed/evaluated our command, and the moment it's focused.
    #}}}
    if test -n "$TMUX"
        set -f pane_id $(vim --remote-expr "\$TMUX_PANE")
    end

    if string match --regex --quiet -- '^-[bdoOpq]$' $argv[1]
        set -f flag $argv[1]
        # If later  we need  to send  the arguments  to the  server, we  want to
        # ignore an optional flag.
        set --erase argv[1]
    end

    # Warning: `--remote` must always come last!{{{
    #
    # In particular, this is wrong:
    #
    #     vim --remote $argv --servername $server
    #                        ^----------^ ^-----^
    #                             ✘          ✘
    #
    # Because everything after `--remote` is interpreted as a filename.
    # From `:help --remote`:
    #
    #                              vvv
    #     --remote [+{cmd}] {file} ...
    #
    #    > The rest of the command line is taken as the
    #    > file list.  Thus any non-file arguments must
    #    > come before this.
    #}}}

    switch $flag
        # edit binary files
        case -b
          # send the filenames to the server
          vim --servername $server --remote $argv
          # For each buffer in the arglist:{{{
          #
          #    - set `'binary'`
          #
          #      Among other things, il will prevent  Vim from doing any kind of
          #      conversion, which could damage the files.
          #
          #    - set `'buftype'` and `'swapfile'` to get a scratch buffer
          #
          #      This should make sure we don't save the buffer accidently.
          #
          #    - set the filetype to `xxd` (to have syntax highlighting)
          #}}}
          vim --servername $server \
              --remote-send "<Cmd>argdo setlocal \
                binary \
                buftype=nofile \
                filetype=xxd \
                noswapfile
                <CR>"
          # filter the contents of the binary buffer through `xxd(1)`
          vim --servername $server --remote-send '<Cmd>argdo :%! xxd<CR><CR>'

        # compare files
        case -d
            # open a new tabpage
            vim --servername $server --remote-send '<Cmd>tabnew<CR>'
            # send the files to the server
            vim --servername $server --remote $argv
            # display the buffers of the arglist in a dedicated vertical split
            vim --servername $server --remote-send '<Cmd>argdo vsplit<CR><Cmd>q<CR>'
            # execute `:diffthis` in each window
            vim --servername $server --remote-send '<Cmd>windo diffthis<CR>'

        # open each file in a dedicated horizontal split
        case -o
            vim --servername $server --remote-send '<Cmd>split<CR>'
            vim --servername $server --remote $argv
            # Why `<Cmd>q<CR>`?{{{
            #
            # To  close the  last window,  because  the last  file is  displayed
            # twice, in 2 windows.
            #}}}
            vim --servername $server --remote-send '<Cmd>argdo split<CR><Cmd>quit<CR><CR>'

        # open each file in a dedicated vertical split
        case -O
            vim --servername $server --remote-send '<Cmd>vsplit<CR>'
            vim --servername $server --remote $argv
            vim --servername $server --remote-send '<Cmd>argdo vsplit<CR><Cmd>quit<CR><CR>'

        # open each file in a dedicated tab page
        case -p
            vim --servername $server --remote-send '<Cmd>tabnew<CR>'
            vim --servername $server --remote $argv
            vim --servername $server --remote-send '<Cmd>argdo tabedit<CR><Cmd>quit<CR>'

        # populate the quickfix list with the output of a shell command
        case -q
            # Why don't you just send the shell command to Vim, and make it execute via `:cexpr system()`?{{{
            #
            # It makes the code needlessly more complex:
            #
            #    - it causes Vim to start yet another shell (via `system()`)
            #
            #    - `system()`'s shell shell is run in Vim's cwd, instead of
            #      your original shell's cwd; if they're different, you may get
            #      unexpected results
            #}}}
            set -f tmp_file $(mktemp)
            # let's write  the shell command  at the  start of the  errorfile so
            # that we can set the title of the quickfix window
            echo $argv >$tmp_file
            # now, let's run the shell command to get the necessary contents for
            # the errorfile
            eval $argv >>$tmp_file
            vim --servername $server --remote-expr "qf#Nv('$tmp_file')"

        # no flag; just send files to the server
        case '*'
            vim --servername $server --remote $argv
      end

      # focus the Vim server
      if test -n "$TMUX"
          tmux switch-client -Z -t $pane_id
          # need to redraw if the tmux pane is zoomed
          vim --remote-send '<C-L>'
      end
end

function _SIGUSR1_handler --on-signal SIGUSR1 #{{{1
# Don't make the function start `nv` directly.{{{
#
#     nv
#     ^^
#     ✘
#
# Rationale: Way too difficult otherwise.
#
# If you try to  start `nv` directly, `SPC  R` will work once out  of two.
#}}}
# Don't run `fish --command=nv`.{{{
#
# This would add  an intermediate fish process between your  Vim process and the
# original fish process, every time you restart your Vim instance.
#
# Besides, after restarting Vim, if you suspend  it, you won't be able to get it
# back anymore; `fg` won't work.
#}}}
# Don't use `xdotool(1)` with `--clearmodifiers`.{{{
#
#     for key in n v KP_Enter
#         xdotool key --clearmodifiers $key
#     end
#
# Regularly, the keyboard would behave as  if the physical capslock key had been
# pressed (when  that happens, pressing  a Shift  modifier fixes the  issue).  I
# think that's because of `--clearmodifiers`.
#}}}

    commandline --replace 'nv'
    xdotool key KP_Enter
end
