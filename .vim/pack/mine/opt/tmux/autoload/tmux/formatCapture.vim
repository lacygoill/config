vim9script

import autoload 'fold/adhoc.vim' as fold
import autoload 'terminal.vim'

const SFILE: string = expand('<sfile>:p')

# Interface {{{1
export def Main() #{{{2
    # Purpose:{{{
    #
    # This function is called by a tmux key binding.
    #
    # It makes tmux copy the contents of the pane, from the start of the history
    # down to the end of the visible pane, in a tmux buffer.
    # Then, it makes Vim read this tmux buffer.
    #
    # If you create a new tmux window and run `$ ls ~`, the tmux buffer contains
    # a lot of empty lines at the bottom; we don't want them.
    #
    # Besides, the tmux buffer contains a lot of trailing whitespace, because we
    # need to pass `-J` to `capture-pane`; we don't want them either.
    #
    # This function  tries to remove  all trailing whitespace, and  all trailing
    # empty lines at the end of the Vim buffer.
    #
    # ---
    #
    # Also, it tries to ease the process of copying text in Vim, then pasting it
    # in the shell; see the one-shot autocmd at the end.
    #}}}

    # we don't want folding to interfere in the next editions
    &l:foldenable = false

    silent! TrimWhitespace
    cursor('$', 1)
    search('^\S', 'bW')
    silent! keepjumps keeppatterns :.,$ global/^\s*$/delete _

    var xdcc_send: string = '\/\cmsg\C\s\+.\{-}XDCC\s\+SEND\s\+#\=\d\+'
    var podcast_url: string = '^Podcast Download URL:'
    # Format the buffer if it contains commands to downloads files via xdcc.{{{
    #
    # Remove noise.
    # Conceal xdcc commands.
    # Highlight filenames.
    # Install mappings to copy the xdcc command in the clipboard.
    #}}}
    # Why `search('│') == 0`?{{{
    #
    # The code will work  best after we have pressed our  WeeChat key binding to
    # get a bare display (`M-r` atm), where “noise” has been removed.
    # Indeed, with  noise, some xdcc commands  can't be copied in  one pass, but
    # only in two.
    # So,  if we're  not  in  a bare  window,  I don't  want  to  get the  false
    # impression that the buffer can be interacted with reliably.
    #}}}
    if search(xdcc_send) > 0 && search('│') == 0
        FormatXdccBuffer(xdcc_send)
    elseif search(podcast_url) > 0
        DownloadPodcast(podcast_url)
    elseif search('^٪') > 0
        FormatShellBuffer()
    endif

    &l:foldenable = true
    normal! zv

    # The buffer might be wrongly highlighted as a conf file.{{{
    #
    # That happens  if one of the  first lines start  with `#`, and we  save the
    # buffer in a file in `/tmp`.
    #
    # We don't  have this issue  with a  pseudo-file in `/proc/`,  because we've
    # configured Vim to ignore the filetype detection of such files:
    #
    #     g:ft_ignore_pat = '\.\%(Z\|gz\|bz2\|zip\|tgz\|log\)$\|^/proc/'
    #                                                           ^-----^
    #}}}
    &l:filetype = ''
enddef
#}}}1
# Core {{{1
def FormatXdccBuffer(xdcc_send: string) #{{{2
    # remove noise
    execute 'silent! keepjumps keeppatterns vglobal/' .. xdcc_send .. '/delete _'

    # `-- BotReign`: server buffer (`!s movie`)
    # `<BotReign>`: private buffer (`.s movie`)
    on_Abjects = search('^-- BotReign \|^<BotReign> ', 'cn') > 0

    for [lnum: number, line: string] in getline(1, '$')->items()
        var size: string = line
            ->matchstr('\d\+\%(\.\d\+\)\=[kmgt]')
        var filename: string
        if on_Abjects
            filename = line
                ->matchstr('.*\%(\d\+\.\d\+[kmgt]\)\@! \zs\%([^ |()]\+\.\)\{2}[^ |()]\+\ze \@=')
        else
            filename = line
                ->matchstr(')\s*\zs.*\ze\s*(Command')
        endif
        var cmd: string = line
            ->matchstr(xdcc_send)
        printf('%s : %s ; %s', size, filename, cmd)->setline(lnum + 1)
    endfor

    if executable('sed') && executable('column')
        # sort the packages from the smallest to the biggest
        silent :% !sort --field-separator='@' --key=1bh,1
        # align the fields
        silent :% !column -s $':' -t
    endif

    # highlight filenames
    var pat_file: string = ' \zs\S\+\ze ;'
    matchadd('Underlined', pat_file, 0)

    # conceal commands
    matchadd('Conceal', ' ; ' .. xdcc_send, 0)
    &l:conceallevel = 3
    &l:concealcursor = 'nc'

    # make filenames interactive
    nnoremap <buffer><nowait> <CR> <ScriptCmd>CopyCmdToGetFileViaXDCC()<CR>
    nmap <buffer><nowait> ZZ <CR>

    # let us jump from one filename to another by pressing `n` or `N`
    setreg('/', [pat_file], 'c')
enddef
var on_Abjects: bool

def DownloadPodcast(header: string) #{{{2
    # delete lines before URL
    var before_url: number = search(header)
    execute $'silent! keepjumps :1,{before_url - 1} delete _'

    # Delete lines after URL.{{{
    #
    # The  latter  should  end  with `(type: audio/mpeg)`,  but  there  is  no
    # guarantee that `(type: audio/mpeg)` is written on a single line.
    #}}}
    execute $'silent! keepjumps :/(/+1,$ delete _'

    # the URL is written after some  header text, and split on multiple lines;
    # remove the header, and join the URL back into a single line
    execute $'silent keepjumps keeppatterns :1 substitute/{header}//e'
    :% join!
    # delete `(type: audio/mpeg)` at the end (it  might be that only some part
    # is still present; e.g. `(type:`)
    silent keepjumps keeppatterns substitute/(.*//e

    silent system($'tmux split-window -c /tmp; tmux send-keys download\ audio\ {getline(1)->shellescape()}')
    quitall!
enddef

def FormatShellBuffer() #{{{2
    terminal.InstallShellPromptMappings()

    # We might need to run `set filetype=`, which can break our mappings.
    b:undo_ftplugin = ''

    # remove empty first line, and empty last prompt
    silent! keepjumps :/^\%1l$/ delete _
    execute 'silent! keepjumps :/^\%' .. line('$') .. 'l٪$/ delete _'

    # Why the priority 0?{{{
    #
    # To allow  a search to highlight  text even if it's  already highlighted by
    # this match.
    #}}}
    highlight Cwd ctermfg=blue
    matchadd('Cwd', '.*\ze\n٪', 0)

    # Why don't you use `matchadd()` for the last line of the buffer?{{{
    #
    # If we delete the last line of the  buffer, we don't want the new last line
    # to  be highlighted  as  if it  was printing  the  shell's current  working
    # directory.  IOW, we need the highlighting  to be attached to the *initial*
    # last line of the buffer; not whatever last line is at any given time.
    #}}}
    prop_type_add('LastLine', {
        highlight: 'Cwd',
        bufnr: bufnr('%'),
        combine: false,
    })
    prop_add(line('$'), 1, {
        type: 'LastLine',
        length: col([line('$'), '$']),
        bufnr: bufnr('%'),
    })

    highlight ExitCode ctermfg=red
    matchadd('ExitCode', '\[\d\+\]\ze\%(\n٪\|\%$\)', 0)

    highlight ShellCmd ctermfg=green
    matchadd('ShellCmd', '^٪.\+', 0)

    fold.Main()
enddef

def CopyCmdToGetFileViaXDCC() #{{{2
    var line: string = getline('.')
    var msg: string = line->matchstr('/msg\s\+\zs.\{-}xdcc\s\+send\s\+#\=\d\+')

    var cmd: string
    if on_Abjects
        # `/getpack` is actually a custom WeeChat alias.{{{
        #
        # We  don't join  `#moviegods` by  default, because  it adds  too much
        # network  traffic.  And  a  `/msg ... xdcc send ...` command  doesn't
        # work if  you haven't joined  this channel.  IOW,  we need to  run at
        # least 2 commands:
        #
        #     /join #moviegods
        #     /msg ... xdcc send ...
        #
        # But, in the end, we will only be able to write one in the clipboard.
        # To fix this  issue, we need to build a  command-line which would run
        # several commands.
        #
        # An alias lets you use the `;` token which has the same meaning as in
        # a shell.  With it, you can do:
        #
        #     cmd1 ; cmd2
        #}}}
        cmd = $'/getpack #moviegods {msg}'
    else
        cmd = $'/getpack #ELITEWAREZ {msg}'
    endif

    setreg('+', [cmd], 'c')
    timer_start(0, (_) => execute('quitall!'))
enddef
#}}}1
