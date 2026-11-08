vim9script

const DIR: string = $'{$TMPDIR}/vim'

const KITTY_DOC: string = $'{$HOME}/.local/kitty.app/share/doc'

# Interface {{{1
export def Open(in_term = false) #{{{2
    var url: string
    if mode() =~ "^[vV\<C-V>]$"
        var reg_save: list<dict<any>> = [getreginfo('0'), getreginfo('1')]
        try
            execute "normal! \<Esc>gvy"
            url = @"
        finally
            setreg('0', reg_save[0])
            setreg('"', reg_save[1])
        endtry
    else
        var line: string = getline('.')
        if line =~ 'Reference: page \d\+ (paper) / \d\+ (ebook)$'
        # in an epub opened by Calibre, we might need to refer to half a page (e.g. `53.5`)
        || line =~ 'Reference: page \d\+\%(\.\d\+\)\=$'
            var bookname: string = expand('%:p')
                ->matchstr('\C/code/\zs[^/]\+')
            if bookname != ''
                var pagenr: string = line->matchstr('\d\+\ze (ebook)$\|\d\+\%(\.\d\+\)\=$')
                # We could replace `frec` with `locate(1)`, but it would be:{{{
                #
                #    - a little slower
                #    - less reliable (needs to run `$ sudo updatedb` which takes time)
                #}}}
                if executable('frec')
                    silent var file: string = systemlist($'frec -l')
                        ->filter((_, v: string): bool => v =~ bookname && v =~ 'pdf\|epub')
                        ->get(0, '')
                    if !file->filereadable()
                        echo $'`frec -l` failed to find any relevant PDF/EPUB'
                        return
                    endif
                    var ext: string = file->fnamemodify(':e')
                    var cmd: string = $'{EbookViewer(ext)}{pagenr} {file}'
                    # We need to  clear the `stoponexit` job  option, because if
                    # we quit  or restart Vim,  we don't  want the viewer  to be
                    # closed.
                    job_start(cmd, {stoponexit: ''})
                    return
                endif
            endif
        endif
        url = GetUrl()
    endif

    if url->empty()
        return
    endif

    # [some book](~/Ebooks/Later/Algo To Live By.pdf#page=123)
    if url !~ '^\%(https\=\|file\|ftps\=\|www\)://'
        var pagenr: number = url->matchstr('#page=\zs\d\+$')->str2nr()
        # Don't use `expand()`!{{{
        #
        # We don't want  something like `#anchor` to be replaced  by the path to
        # the alternate file.
        #
        # We could also do sth like:
        #
        #     url = fnameescape(url)->expand()
        #
        # Not sure whether it's totally equivalent though...
        #}}}
        url = url
            ->substitute('^\~', $HOME, '')
            ->substitute('#page=\d\+$', '', '')
        if !url->filereadable()
            return
        endif
        var ext: string = url->fnamemodify(':e')
        var ebook_viewer: string = EbookViewer(ext)
        var cmd: string = ebook_viewer
        if pagenr > 0
            cmd ..= pagenr
        endif
        cmd ..= $' {url}'
        job_start(cmd, {stoponexit: ''})
        return
    endif

    if url =~ '\.onion/\=$'
        # TODO: Get the path to the `.desktop` file programmatically.
        # TODO: It doesn't work if the Tor Browser is already running:{{{
        #
        #    > Tor Browser is already running, but is not responding.
        #    > To use Tor Browser, you must first close the existing Tor Browser process,
        #    > restart your device, or use a different profile.
        #
        # ---
        #
        # Note that the `.desktop` file executes this:
        #
        #     ...
        #     Exec=sh -c '...' dummy %k
        #     ...
        #
        # ---
        #
        # In XFCE, `xdg-open(1)` executes `exo-open(1)`.
        #
        # ---
        #
        # As a last resort, `xdg-open(1)` executes the `Exec` line of the `.desktop` file.
        # It finds the name of the latter by extracting the protocol from the url:
        #
        #     protocol = url->matchstr('^[[:alnum:]+\.-]*:.*')
        #
        # Then, it executes  `xdg-mime(1)` to get the  default application which
        # handles this type of data:
        #
        #     x-scheme-handler/<protocol>
        #
        # Example:
        #
        #     $ xdg-mime query default x-scheme-handler/https
        #     firefox.desktop
        #}}}
        silent system($'cd ~/.local/bin/tor-browser_en-US/ && ./start-tor-browser.desktop {url->shellescape()}')
        return
    endif

    if in_term
        if $TMUX == ''
            echomsg 'Only works while in a tmux session'
            return
        endif
        # Could we pass the shell command to `$ tmux split-window` directly?{{{
        #
        # Yes but the pane would be closed immediately.
        # Because by default, tmux closes  a window/pane whose shell command
        # has completed:
        #
        #    > When the shell command completes, the window closes.
        #    > See the remain-on-exit option to change this behaviour.
        #
        # For more info, see `man tmux`, and search:
        #
        #     new-window
        #     split-window
        #     respawn-pane
        #     set-remain-on-exit
        #}}}
        silent system($'tmux split-window -c {DIR->shellescape()}')
        # maximize the pane
        silent system('tmux resize-pane -Z')
        # start `w3m`
        silent system($'tmux send-keys web \ {url->shellescape()} Enter')
        #                                   │{{{
        #                                   └ without the backslash,
        #
        # Tmux would  think it's a  space to  separate the arguments  of the
        # `send-keys` command; therefore, it would remove it and type:
        #
        #     weburl
        #
        # instead of:
        #
        #     web url
        #
        # The backslash is there to tell it's a semantic space.
        #}}}
        return
    endif

    job_start($'xdg-open {url}', {stoponexit: ''})
enddef
# }}}1
# Core {{{1
def GetUrl(): string #{{{2
    var inside_brackets: string
    var link_colstart: number
    var brackets_colstart: number
    var brackets_colend: number
    var pos: list<number> = getcurpos()
    # [link](url)  (or [link][id])
    var pat: string = '!\=\[.\{-}\]' .. '\%((.\{-1,})\|\[.\{-1,}\]\)'
    normal! 0
    var flags: string = 'cW'
    var line: string = getline('.')
    var curlnum: number = line('.')
    var g: number = 0
    while search(pat, flags, curlnum) > 0 && g < 100 | ++g
        # [link](inside_brackets)
        # ^
        link_colstart = col('.')

        normal! %ll
        # [link](inside_brackets)
        #        ^
        brackets_colstart = col('.')

        normal! h%h
        # [link](inside_brackets)
        #                      ^
        brackets_colend = col('.')

        if link_colstart <= pos[2] && pos[2] <= brackets_colend
            var idx1: number = charidx(line, brackets_colstart - 1)
            var idx2: number = charidx(line, brackets_colend - 1)
            inside_brackets = line[idx1 : idx2]
            break
        endif
        flags = 'W'
    endwhile
    setpos('.', pos)

    if inside_brackets != ''
        return GetUrlMarkdownStyle(line, inside_brackets, brackets_colstart)
    endif
    return GetUrlRegular()
enddef

def GetUrlMarkdownStyle( #{{{2
    line: string,
    inside_brackets: string,
    brackets_colstart: number
): string

    # [link](inside_brackets){{{
    #
    #     This is [an example](http://example.com/ "Title") inline link.
    #}}}
    if strpart(line, brackets_colstart - 2)[0] == '('
        return inside_brackets
            ->substitute('\s*".\{-}"\s*$', '', '')

    # [link][id]{{{
    #
    #     Visit [Daring Fireball][id] for more information.
    #     [id]: https://daringfireball.net/projects/markdown/syntax#link
    #}}}
    else
        var cml: string = &filetype == 'markdown'
            ?     ''
            :     '\V' .. &commentstring->matchstr('\S*\ze\s*%s')->escape('\') .. '\m'
        var noise: string = '\s\+\(["'']\).\{-}\1\s*$'
            .. '\|\s\+(.\{-})\s*$'

        return getline('.', '$')
            ->filter((_, v: string): bool =>
                v =~ $'^\s*{cml}\s*\c\V[{inside_brackets}]:')
            ->get(0, '')
            ->matchstr('\[.\{-}\]:\s*\zs.*')
            # Remove possible noise:{{{
            #
            #     [id]: http://example.com/  "Optional Title Here"
            #                              ^---------------------^
            #     [id]: http://example.com/  'Optional Title Here'
            #                              ^---------------------^
            #     [id]: http://example.com/  (Optional Title Here)
            #                              ^---------------------^
            #     [id]: <http://example.com/>  "Optional Title Here"
            #           ^                   ^
            #}}}
            ->substitute(noise, '', '')
            ->trim('<>')
    endif
enddef

def GetUrlRegular(): string #{{{2
    # Do *not* use `<cfile>`.{{{
    #
    # Sometimes, it wouldn't handle some urls correctly.
    #
    #     https://www.youtube.com/watch?v=InAaCKqUmjE&t=90s
    #                                  ├────────────┘├────┘
    #                                  │             └ when the cursor is somewhere here,
    #                                  │               expand('<cfile>') is t=90s
    #                                  │
    #                                  └ when the cursor is somewhere here,
    #                                    expand('<cfile>') is v=InAaCKqUmjE
    #}}}
    var url: string = expand('<cWORD>')->trim('.', 2)
    var scheme: string = '\%(https\=\|ftps\=\|www\)://'
    if url !~ scheme
        # Support a github issue/PR ID in a fish man page.
        # Useful for `man fish-releasenotes`.
        if url =~ '#\d\+'
        && (expand('%:p') =~ '^man://fish-'
        # also in a fish script
        || &filetype == 'fish')
            return 'https://github.com/fish-shell/fish-shell/issues/'
                .. url->matchstr('#\zs\d\+')
        endif
        return GetUrlLocalFile(url)
    endif

    # Which characters make a URL invalid?
    # https://stackoverflow.com/a/13500078

    # Handle link broken on multiple lines.{{{
    #
    # For an example:
    #
    #    > https://www.gnu.org/software/gawk/man‐
    #    > ual/html_node/String-Functions.html#String-
    #    > Functions
    #
    # Source: `man gawk /PATTERNS AND ACTIONS/;/String Functions/;/match(s`
    #
    # Note that the two trailing hyphens are not the same unicode character:
    #
    #     '‐' U+2010 Dec:8208 HYPHEN
    #     '-' U+002D Dec:45 HYPHEN-MINUS
    #}}}
    var hyphens: string = '-‐'
    if url =~ $'[{hyphens}]$'
        # check if URL is working
        silent system($'curl --head --fail --silent {url}')
        # if it's not
        if v:shell_error != 0
            url = url->trim(hyphens)
            var lnum: number = line('.') + 1
            # grab subsequent lines ending with a hyphen
            while getline(lnum) =~ $'[{hyphens}]$'
                url ..= getline(lnum)
                    ->substitute('^\s\+', '', '')
                    ->trim(hyphens)
                ++lnum
            endwhile
            # grab last part of the URL
            url ..= getline(lnum)->matchstr('\S\+')
        endif
    endif

    # remove everything before the first `http`, `ftp` or `www`
    url = url->substitute('.\{-}\ze' .. scheme, '', '')

    # Remove everything after some closing brace or punctuation.
    # But some wikipedia links contain parentheses:{{{
    # https://en.wikipedia.org/wiki/Daemon_(computing)
    #
    # In those cases,  we need to make an exception,  and not remove the
    # text after the closing parenthesis.
    #}}}
    var chars: string = url =~ '('
        ? '[]⟩>}`,;]'
        : '[]⟩>}`,;)]'
    # Also, `:` is tricky because it's used after the protocol name.
    # Tip: If you need to write a  URL which contains one of these characters,
    # use URL encoding.  For example, instead of writing ",", write "%2c".

    return url
        ->substitute('.\{-}\zs' .. chars .. '.*', '', '')
        # remove everything after the last quote
        ->substitute('["''].*', '', '')
enddef

def GetUrlLocalFile(url: string): string #{{{2
# Support the case of a local file.{{{
#
# For example, it's convenient to be able to write this in a kitty config file:
#
#     remote-control.html#kitty-resize-window
#
# And then make `gx` open something like:
#
#     file:///home/lgc/.local/kitty.app/share/doc/kitty/html/remote-control.html#kitty-resize-window
#}}}
    if url !~ '\.html'
        return ''
    endif

    var anchor: string = url->matchstr('.*\zs#.*')
    var fname: string = url->substitute(anchor, '', '')
    var doc_dir: string = expand('%:p') =~ $'^{$HOME}/.config/kitty/'
        ? KITTY_DOC
        # For the moment, we only look under `/usr/local`.
        # Looking under `/usr` takes more time, because it has many more files.
        : '/usr/local/share/doc'
    var fpath: string = fname
        ->findfile($'{doc_dir}/**3')
        ->fnamemodify(':p')
    if !fpath->empty()
        return $'file://{fpath}{anchor}'
    endif

    return ''
enddef

def EbookViewer(ext: string): string #{{{2
    if ext == 'epub'
        # The  position is  a location  or  position you  can get  by using  the
        # `Go to->Location` action in the viewer controls.
        #
        # Alternately, you can use the form  `toc:something` and it will open at
        # the location  of the first Table  of Contents entry that  contains the
        # string "something".
        #
        # The  form  `toc-href:something` will  match  the  href (internal  link
        # destination) of  toc nodes.  The  matching is  exact.  If you  want to
        # match a substring, use the form `toc-href-contains:something`.
        #
        # The form `ref:something` will use Reference mode references.
        return 'ebook-viewer --open-at='
    endif

    if executable('zathura')
        return 'zathura --page='
    endif
    if executable('atril')
        return 'atril --page-label='
    endif
    return 'xdg-open'
enddef
