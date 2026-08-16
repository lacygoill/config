vim9script

import autoload 'brackets/move.vim'

try
    import autoload 'submode.vim'
# E1053: Could not import "submode.vim"
catch /^Vim\%((\a\+)\)\=:E1053:/
endtry

# Interface {{{1
export def Setup() #{{{2
    # Warning: Leave this at the top.{{{
    #
    # `SetPopup()` sets `'termwinkey'`, whose correct value we need to inspect
    # later in this function.
    #}}}
    if win_gettype() == 'popup'
        SetPopup()
    endif

    nnoremap <buffer><nowait> I i<C-A>
    nnoremap <buffer><nowait> A i<C-E>

    nnoremap <buffer><expr><nowait> C "i\<C-E>\<C-U>" .. term_getline('', '.')->matchstr('٪ \zs.*\%.c')
    nnoremap <buffer><nowait> cc i<C-E><C-U>

    # Let us paste a register like we would in a regular buffer (e.g. `"ap`).{{{
    #
    # In Vim, the sequence to press is awkward:
    #
    #    ┌─────┬───────────────────────────────────────────┐
    #    │ key │                  meaning                  │
    #    ├─────┼───────────────────────────────────────────┤
    #    │ i   │ enter Terminal-Job mode                   │
    #    ├─────┼───────────────────────────────────────────┤
    #    │ C-e │ move to the end of the shell command-line │
    #    ├─────┼───────────────────────────────────────────┤
    #    │ C-w │ or whatever key is set in 'termwinkey'    │
    #    ├─────┼───────────────────────────────────────────┤
    #    │ "   │ specify a register name                   │
    #    ├─────┼───────────────────────────────────────────┤
    #    │ x   │ name of the register to paste             │
    #    └─────┴───────────────────────────────────────────┘
    #
    # And  paste bracket  control codes  are not  inserted around  the register.
    # As a result, Vim automatically executes  any text whenever it encounters a
    # newline.  We don't want that; we just want to insert some text.
    #}}}
    nnoremap <buffer><expr><nowait> p Put()

    nnoremap <buffer><nowait> D  <ScriptCmd>KillLine()<CR>
    nnoremap <buffer><nowait> dd i<C-E><C-U><C-\><C-N>

    xnoremap <buffer><nowait> c <Nop>
    xnoremap <buffer><nowait> d <Nop>
    xnoremap <buffer><nowait> p <Nop>
    xnoremap <buffer><nowait> x <Nop>

    InstallShellPromptMappings()

    # If `'termwinkey'` is not set, Vim falls back on `C-w`.  See `:help 'termwinkey'`.
    var termwinkey: string = &l:termwinkey ?? '<C-W>'
    # don't execute an inserted register when it contains a newline
    execute 'tnoremap <buffer><expr><nowait> ' .. termwinkey .. '" InsertRegister()'
    # we don't want a timeout when we press the termwinkey + `C-w` to focus the next window:
    # https://vi.stackexchange.com/a/24983/17449
    execute printf('tnoremap <buffer><nowait> %s<C-W> %s<C-W>', termwinkey, termwinkey)

    # Make `ZF` and `mq`  work on relative paths, by parsing  the CWD from the
    # previous shell prompt.
    &l:includeexpr = 'IncludeExpr()'
    xnoremap <buffer><nowait> mq <C-\><C-N><ScriptCmd>SelectionToQf()<CR>

    # Rationale:{{{
    #
    # Setting `'sidescrolloff'`  to a  non-zero value is  useless in  a terminal
    # buffer; long lines are automatically hard-wrapped.
    # Besides, it makes the window's view “dance” when pressing `l` and reaching
    # the end of a long line, which is jarring.
    #
    # ---
    #
    # We reset `'scrolloff'`  because it makes moving in a  terminal buffer more
    # consistent with tmux copy-mode.
    #}}}
    &l:scrolloff = 0 | &l:sidescrolloff = 0
    &l:wrap = false
enddef

export def InstallShellPromptMappings()
# We might call this function from another plugin.
# For example, it's useful for `vim-tmux` when we capture a pane in a Vim buffer.
    map <buffer><nowait> ]c <Plug>(next-shell-prompt)
    map <buffer><nowait> [c <Plug>(prev-shell-prompt)
    noremap <buffer><expr> <Plug>(next-shell-prompt) move.Regex('shell-prompt')
    noremap <buffer><expr> <Plug>(prev-shell-prompt) move.Regex('shell-prompt', false)
    silent! execute submode.Enter('shell-prompts', 'nx', 'br', ']c', '<Plug>(next-shell-prompt)')
    silent! execute submode.Enter('shell-prompts', 'nx', 'br', '[c', '<Plug>(prev-shell-prompt)')
enddef
#}}}1
# Core {{{1
def KillLine() #{{{2
    var buf: number = bufnr('%')
    var vimpos: list<number> = getcurpos()
    var jobpos: list<any> = term_getcursor(buf)
    var offcol: number = jobpos[1] - vimpos[2]
    var offline: number = jobpos[0] - vimpos[1]
    normal! i
    var keys: string = repeat("\<Left>", offcol)
        .. repeat("\<Up>", offline)
        .. "\<C-K>"
    term_sendkeys(buf, keys)
    term_wait(buf, 50)
    feedkeys("\<C-\>\<C-N>", 'nx')
enddef

def IncludeExpr(): string #{{{2
    var cwd: string = GetCWD()
    # most of the code is leveraged from a similar function in our vimrc
    var line: string = getline('.')
    var pat: string = '${\f\+}' .. '\V' .. v:fname .. '\m'
        .. '\|${\V' .. v:fname .. '\m}\f\+'
        .. '\|\%.c${\f\+}\f\+'
    var before_cursor: string = '\%(\%<.c\|\%.c\)'
    var after_cursor: string = '\%>.c'
    pat = before_cursor .. '\%(' .. pat .. '\)' .. after_cursor

    if line =~ pat
        pat = line->matchstr(pat)
        var env: string = pat->matchstr('\w\+')
        return pat->substitute('${' .. env .. '}', getenv(env) ?? '', '')
    endif

    if line =~ before_cursor .. '=' .. after_cursor
        return v:fname->substitute('.*=', '', '')
    endif

    if line =~ '^\./'
        return v:fname->substitute('^\./', cwd .. '/', '')
    endif

    return cwd .. '/' .. v:fname
enddef

def InsertRegister(): string #{{{2
    var numeric: list<number> = range(10)
    var alpha: list<string> = range(char2nr('a'), char2nr('z'))
        ->map((_, v: number): string => nr2char(v))
    var other: list<string> = ['-', '*', '+', '/', '=']
    var reg: string = getcharstr()
    if (numeric + alpha + other)->index(reg) == -1
        return ''
    endif
    UseBracketedPaste(reg)
    var termwinkey: string = &l:termwinkey ?? '<C-W>'
    termwinkey = $'"\{termwinkey}"'->eval()
    return termwinkey .. '"' .. reg
enddef

def SelectionToQf() #{{{2
    var cwd: string = GetCWD()
    var lnum1: number = line("'<")
    var lnum2: number = line("'>")
    var lines: list<string> = getline(lnum1, lnum2)
        ->map((_, v: string) => cwd .. '/' .. v)
    setqflist([], ' ', {lines: lines, title: $':{lnum1},{lnum2} cgetbuffer'})
    cwindow
enddef

def Put(): string #{{{2
    var reg: string = v:register
    UseBracketedPaste(reg)
    var termwinkey: string = &l:termwinkey ?? '<C-W>'
    termwinkey = $'"\{termwinkey}"'->eval()
    return "i\<C-E>" .. termwinkey .. '"' .. reg
enddef

def SetPopup() #{{{2
    # Like for all  local options, the local value of  `'termwinkey'` has been
    # reset to  its default value (empty  string), which makes Vim  use `C-w`.
    # Set the option again, so that we  get the same experience as in terminal
    # buffers in non-popup windows.
    set termwinkey<

    # suppress error: “Vim(wincmd):E994: Not allowed in a popup window”
    nnoremap <buffer><nowait> <C-H> <Nop>
    nnoremap <buffer><nowait> <C-J> <Nop>
    nnoremap <buffer><nowait> <C-K> <Nop>
    nnoremap <buffer><nowait> <C-L> <Nop>
enddef
#}}}1
# Utilities {{{1
def GetCWD(): string #{{{2
    var cwd: string = (search('^٪', 'bnW') - 1)
        ->getline()
        # We include a no-break space right after the shell's CWD in our shell's prompt.{{{
        #
        # This is necessary because the  prompt might contain extra info, like
        # a git branch name.
        #}}}
        ->matchstr('.\{-}\ze\%xa0')
    return cwd
enddef

def UseBracketedPaste(reg: string) #{{{2
    # don't execute anything, even if the register contains newlines
    var reginfo: dict<any> = getreginfo(reg)
    var save: dict<any> = deepcopy(reginfo)
    if get(reginfo, 'regcontents', [])->len() > 1
        var before: string = &t_PS
        var after: string = &t_PE
        reginfo.regcontents[0] = before .. reginfo.regcontents[0]
        reginfo.regcontents[-1] ..= after
        # Don't use the `'l'` or `'V'` type.  It would cause the automatic execution of the pasted command.
        reginfo.regtype = 'c'
        setreg(reg, reginfo)
        timer_start(0, (_) => setreg(reg, save))
    endif
enddef
