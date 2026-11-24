vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/unix.vim'
import autoload '../autoload/unix/cloc.vim'
import autoload '../autoload/unix/share.vim'
import autoload '../autoload/unix/sudo.vim'
import autoload '../autoload/unix/trash.vim'

const SKELETONS_DIR: string = expand('<sfile>:h:h') .. '/skeletons'

# TODO: You shouldn't call  `system()`; you should `:echo` it, so  that we see
# the exact error message in case of an issue (useful for example with `:Cp`).

# Autocmds {{{1

augroup MyUnix
    autocmd!
    autocmd BufNewFile * {
        # don't clobber text when we read a file with a trailing colon (matching a line)
        if expand('<afile>') !~ ':\d\+$'
            MaybeReadSkeleton()
        endif
    }
    # `BufFilePost` is necessary for `:saveas` (used by `:Rename`):{{{
    #
    #     $ vim /tmp/file_old
    #     :call setline(1, '#!/bin/bash -')
    #     :write
    #     :saveas /tmp/file_new
    #     :echo expand('%:p')->getfperm()
    #     rwxrw-r--
    #       ^
    #}}}
    autocmd BufNewFile,BufFilePost * {
        autocmd BufWritePost <buffer> ++once MaybeMakeExecutable()
    }
augroup END

# Commands {{{1

command -bar -nargs=1 Chmod unix.Chmod(<q-args>)

# Do not give the `-complete=[file|dir]` attribute to any command.{{{
#
# It makes  Vim automatically expand special  characters such as `%`,  which can
# give unexpected results, and possibly destroy valuable data.
#
# MRE:
#
#     edit /tmp/file
#     command -complete=file -nargs=1 Cmd Func(<args>)
#     def Func(arg: any)
#         echo arg
#     enddef
#     Cmd 'A%B'
#     A/tmp/fileB˜
#
# ---
#
# In the past, we used it for these commands:
#
#     Cloc
#     Cp
#     Clocate
#     Mkdir (only one to which we gave `-complete=dir`)
#     Mv
#     SudoEdit
#}}}
# TODO: Actually, we need to give `-complete=file` to `:Mv`, otherwise `:Rename` doesn't work as expected.{{{
#
# Without, `%:h` is not expanded.
# Is there another way to expand `%:h`?
# If not, should we give back `-complete=file` to all relevant commands?
# Edit: Could we use `expandcmd()` to manually expand `%:h`?
#
# ---
#
# If you use `-complete=file_in_path` instead, `%:h` is still not expanded.
# Why?
# Idk, but the issue may depend on the CWD...
#}}}
# TODO: Should we give it to harmless commands (i.e. commands which don't rename/(re)move/copy files)?
# Edit: I gave it back to `:SudoEdit`; I think it should be harmless there (plus it's really useful).
command -range=% -nargs=? Cloc cloc.Main(<line1>, <line2>, <q-args>)
# Don't give `-bar` to commands whose argument might contain `"` or `|`.
# A path might contain one of them, so here, we don't specify `-bar`.

command -bang -nargs=1 Cp unix.Cp(<q-args>, <bang>0)

command -bang -nargs=? Mkdir unix.Mkdir(<q-args>, <bang>0)

# `:Mv` lets us move the current file to any location.
# `:Rename` lets us rename the current file inside the current directory.
command -bang -nargs=1 -complete=file Mv unix.Move(<q-args>, <bang>0)
command -bang -nargs=1 -complete=custom,unix.RenameComplete Rename unix.Rename(<q-args>, <bang>0)

# Usage: Select some text,  and execute `:'<,'>Share` to  upload the selection
# on `termbin.com`, or just execute `:Share` to upload the whole current file.
# Alternative websites:
#
#    - http://ix.io/
#    - https://0x0.st/
#    - https://paste.debian.net
command -bar -range=% Share share.Main(<line1>, <line2>)

command -bang -nargs=? -complete=file SudoEdit sudo.Edit(<q-args>, <bang>0)
command -bar SudoWrite expand('%:p')->sudo.Setup() | write!

# TODO: Are `:SudoWrite` and `:W` doing the same thing?
# Should we eliminate one of them?

# What's the effect of a bang?{{{
#
# `:Tp` deletes the current file and UNLOADS its buffer.
# Also, before  that, it loads  the alternate file if  there's one, so  that the
# current window is not (always) closed.
#
# `:Tp!` deletes the current file and RELOADS the buffer.
# As a result, we can restart the creation of a new file with the same name.
#}}}
command -bar -bang Tp trash.Put(<bang>0)
command -bar       Tl trash.List()
#                  └ Warning:{{{
#
#                   It could conflict with the default `:tl[ast]` command.
#                   In practice, I don't think it will, because we'll use `]T` instead.
#}}}

command -bar Trr trash.Restore()

command -bar Wall unix.Wall()

# What's the purpose of `:W`?{{{
#
# It lets us write a file for which we don't have write access to.
# This happens when we  try to edit a root file in a  Vim session started from a
# regular user.
#}}}
# What to do if I have the message `W11` or `W12`?{{{
#
# The full message looks something like this:
#
#    > W12: Warning: File "/etc/apt/sources.list" has changed and the buffer was changed in Vim as well
#    > See ":help W12" for more info.
#    > [O]K, (L)oad File:
#
# If you press `O`, the buffer will be written.
# If you press `L`, the file will be reloaded.
#
# In this particular case, whatever you answer shouldn't matter.
# The file and the buffer contain the same text.
#
# If  you've set  `'autoread'`,  there  should be  no  message,  and Vim  should
# automatically write the buffer.
#}}}
# Why `&l:modified = false`?{{{
#
# I don't remember what issue it solved, but I keep it because I've noticed that
# it bypasses the W12 warning.
#}}}

#                       ┌ write the buffer on the standard input of a shell command (`:help w_c`)
#                       │ and execute the latter
#                       │
#                       │       ┌ raise the rights of the `tee(1)` process so that it can write in
#                       │       │ a file owned by any user
#                       ├─────┐ │
command -bar W execute 'write !sudo tee >/dev/null ' .. expand('%:p')->shellescape(true) | &l:modified = false
#                                       ├────────┘              │
#                                       │                       └ but write in the current file
#                                       │
#                                       └ don't write in the terminal

# Mappings {{{1

nnoremap <unique> g<C-L> <ScriptCmd>Cloc<CR>
xnoremap <unique> g<C-L> <C-\><C-N><ScriptCmd>:* Cloc<CR>
nnoremap <unique> gl <ScriptCmd>cloc.CountLinesInFunc()<CR>

# Functions {{{1
def MaybeMakeExecutable() #{{{2
    var shebang: string = getline(1)
        ->matchstr('^#!\S\+')

    if shebang->empty()
        return
    endif

    var new_mode: string = expand('<afile>:p')
        ->getfperm()
        ->substitute('..\zs.', 'x', '')
    if new_mode == ''
        return
    endif
    execute $'Chmod {new_mode}'
enddef

def MaybeReadSkeleton() #{{{2
    if directories == []
        directories = ($'{SKELETONS_DIR}/by-directory')
            ->readdir(true, {sort: 'none'})
            ->map((_, path: string) => path->fnamemodify(':r'))
    endif

    var fullpath: string = expand('<afile>:p')
    var dir: string = fullpath->fnamemodify(':h:t')
    var parent_dir: string = fullpath->fnamemodify(':h:h:t')
    var fname: string = fullpath->fnamemodify(':t')
    var extension: string = fullpath->fnamemodify(':e')

    # `:keepalt` prevents a skeleton file from becoming the alternate file for
    # the current window.

    var i: number = directories->index(dir)
    var j: number = directories->index(parent_dir)
    if i >= 0
        Read($'{SKELETONS_DIR}/by-directory/{directories[i]}.skel')

    # Handle case where  the relevant directory is one more  level above.  For
    # example, if we  create `~/Wiki/linter/bash/123.md`, we want  to read the
    # `linter`  skeleton,  but the  `linter/`  directory  is not  right  above
    # `123.md`.
    elseif j >= 0
        Read($'{SKELETONS_DIR}/by-directory/{directories[j]}.skel')

    elseif filereadable($'{SKELETONS_DIR}/by-name/{fname}.skel')
        Read($'{SKELETONS_DIR}/by-name/{fname}.skel')

    elseif filereadable($'{SKELETONS_DIR}/by-extension/{extension}.skel')
        Read($'{SKELETONS_DIR}/by-extension/{extension}.skel')

    elseif filereadable($'{SKELETONS_DIR}/by-filetype/{&filetype}.skel')
        Read($'{SKELETONS_DIR}/by-filetype/{&filetype}.skel')
    endif

    # Expand expressions inside `❴❵` to support dynamic skeletons.
    # For now, we don't support:{{{
    #
    #    - nesting
    #    - multiple expressions per line
    #    - a multiline expression inside a single `❴❵`
    #}}}
    for [lnum: number, line: string] in getline(1, '$')->items()
        if line =~ '❴.*❵'
            var cml: string = expand('<abuf>')
                ->str2nr()
                ->getbufvar('&l:commentstring')
                ->split('%s')
                ->get(0, '')
                ->trim()

            var expanded: string = line
                # support dynamic comment leader
                ->substitute('❴cml❵', cml, '')
                # support arbitrary dynamic expression
                ->substitute('❴\(.*\)❵', (m) => m[1]->Eval(), '')

            if expanded =~ '\n'
                execute $'keepjumps :{lnum + 1} delete _'
                append(lnum, expanded->split('\n', true))
            else
                setline(lnum + 1, expanded)
            endif
        endif
    endfor
enddef
var directories: list<string>

def Read(fname: string)
    # The `:read` alternative is more complex:
    #
    #     execute $'keepalt :0 read {fnameescape(fname)}'
    #     deletebufline('%', '$')
    fname->readfile()->setline(1)
enddef

def Eval(expr: string): string
    var result: any = expr
        ->trim()
        ->eval()

    if result->typename() == 'list<string>'
        return result
            ->join("\n")
    elseif result->typename() == 'string'
        return result
    endif
    return expr
enddef
