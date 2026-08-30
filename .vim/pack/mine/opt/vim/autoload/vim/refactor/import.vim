vim9script

# Purpose: Make an `import autoload` faster.{{{
#
# Issue: This command might be slow:
#
#     import autoload 'path/to/script.vim'
#
# Indeed, Vim  has to look  for `path/to/script.vim` under every  `autoload/` of
# the runtimepath.  The more entries Vim needs to try before finding the script,
# the more time-consuming the command is.
#
# This is an issue in a script under `plugin/` because it has an impact on Vim's
# startup time.
#
# Solution: Refactor the command using a path relative to the current script:
#
#                         this will not be exactly the same path as before:
#                         the previous path was relative to autoload/,
#                         while this one is relative to the current script
#                         v----------------v
#     import autoload '../path/to/script.vim'
#                      ^^
#                      this could be a single dot,
#                      if "script.vim" is under the directory of the current script
#}}}
export def Main(type = ''): string
    if type == ''
        &operatorfunc = Main
        return 'g@l'
    endif

    var curscript: string = expand('%:p')
    var autodir: string
    if curscript == $MYVIMRC
        autodir = $HOME .. '/.vim/autoload/'
    else
        var dirs: any =<< trim END
            after
            autoload
            colors
            compiler
            ftplugin
            indent
            plugin
            syntax
        END
        dirs = dirs->join('\|')
        autodir = curscript
            ->matchstr(printf('.\{-}\ze/\%%(%s\)', dirs)) .. '/autoload/'
    endif
    var curline: string = getline('.')

    if curline !~ '^\s*import\s\+autoload'
        echo 'no autoload import on this line'
        return ''
    endif

    var quote: string = '[''"]'
    var curpath: string = curline
        ->matchstr(printf('.*\zs\(%s\).*\1', quote))
        ->trim(quote)
    var script_to_autoload: string = printf('%s%s', autodir, curpath)

    if !script_to_autoload->filereadable()
        echo printf('"%s" is not readable', script_to_autoload)
        return ''
    endif

    # whether the script to autoload is below the directory of the current script
    var below_curdir: bool = true
    # deepest directory  containing both  the current script  and the  script to
    # autoload
    var common_head: string = curscript->fnamemodify(':h')
    def UpdatePat(): string
        return '^\V' .. common_head->escape('\') .. '/'
    enddef
    var common_head_pat: string = UpdatePat()
    var relpath_to_common_head: string
    while script_to_autoload !~ common_head_pat
            && common_head != '/'
        relpath_to_common_head ..= '../'
        common_head = common_head->fnamemodify(':h')
        common_head_pat = UpdatePat()
        below_curdir = false
    endwhile

    #     ../../path/to/script.vim
    #          ^-----------------^
    var path_tail: string = script_to_autoload
        ->substitute(common_head_pat, '', '')
    var new_path: string
    if below_curdir
        new_path = './' .. path_tail
    else
        new_path = relpath_to_common_head .. path_tail
    endif
    curline
        ->substitute('^\s*import\s\+autoload\s\+\([''"]\)\zs.*\ze\1', new_path, '')
        ->setline('.')
    return ''
enddef
