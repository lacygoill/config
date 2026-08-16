vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/man.vim'

var warning: list<string>
# Vim was invoked as a man pager
if v:argv->index('+Man!') >= 0
    # `:Man foo` works, but the page is taken from the wrong section!{{{
    #
    #     $ man info
    #     :Man 5 info
    #     # Expected: The man page for info(5) is open (i.e. the one in section 5)
    #     # Actual: The man page for info(1) is open (i.e. the one in section 1)
    #
    # It's a bug in man-db which was fixed in man-db version 2.10.0:
    #
    #    > man no longer inadvertently modifies the MANSECT environment variable
    #
    # This has been a recurrent issue for almost 4 years.
    # I'm fed up with it.
    # Don't try to add yet another complex workaround.
    # Just wait for a system update.
    # For Ubuntu, that will be the 22.04 LTS which provides man-db with version 2.10.2.
    #}}}
    # *simple* workaround
    setenv('MANSECT', '1:n:l:8:3:2:3posix:3pm:3perl:3am:5:4:9:6:7')
    #                  ^----------------------------------------^
    #                      default value given at `man man /DEFAULTS/;/3posix`

    # there is an AppArmor profile
    if filereadable('/etc/apparmor.d/usr.bin.man')
            # it's not disabled
            && !filereadable('/etc/apparmor.d/disable/usr.bin.man')
            # it's not in complain mode
            && readfile('/etc/apparmor.d/usr.bin.man')->match('\<complain\>\C') == -1
    warning =<< trim END
        Found an AppArmor profile for the man command set in enforce mode.
        It might prevent Vim from working as expected when invoked as a man pager.
        Consider disabling the profile:
        $ sudo aa-disable /etc/apparmor.d/usr.bin.man
    END
        autocmd VimEnter * ++once for line: string in warning | echomsg line | endfor
    endif
endif

augroup man
    autocmd!
    autocmd BufReadCmd man://* {
        expand('<amatch>')
            ->substitute('^man://', '', '')
            ->man.ShellCmd()
    }

    #     $ less ~/.bashrc
    #     # press H to display less(1) help
    #     # press E to pipe the buffer to Vim
    autocmd StdinReadPost * {
        # Vim was not invoked as a man pager.
        # Warning: Don't use `$MAN_PN == ''`.{{{
        #
        # It would wrongly fail when we  use the default man pager, `less(1)`,
        # and pipe its buffer to Vim.  For example:
        #
        #     $ bash
        #     $ unset MANPAGER
        #     $ man man
        #     # press: E
        #}}}
        if v:argv->index('+Man!') == -1
                # But the buffer still contains some backspaced text.
                # See also: `$VIMRUNTIME/syntax/ctrlh.vim`
                && search('\(.\)\b\1\|_\b.', 'cn') > 0

            # install some `man*` HGs and property types (e.g. `manBold`)
            &syntax = 'man'

            man.HighlightOnCursormoved()
        endif
    }
augroup END

# `-range=-1` will let us detect wheter `:Man` was given a count.
# If we don't give a count, `<count>` will be replaced with `-1`.
command -bang -bar -range=-1 -complete=customlist,man.CmdComplete -nargs=* Man {
    if <bang>0
        man.InitPager()
    else
        man.ExCmd(<count>, <q-mods>, <f-args>)
    endif
}
cnoreabbrev <expr> man getcmdtype() =~ '[:>]' && getcmdpos() == 4 ? 'Man' : 'man'
