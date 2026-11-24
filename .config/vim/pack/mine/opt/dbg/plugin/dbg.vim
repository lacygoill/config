vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/dbg.vim'
import autoload '../autoload/dbg/autoSynstack.vim'
import autoload '../autoload/dbg/capture.vim'
import autoload '../autoload/dbg/cmdline.vim'
import autoload '../autoload/dbg/localPlugin.vim'
import autoload '../autoload/dbg/log.vim'
import autoload '../autoload/dbg/mappings.vim'
import autoload '../autoload/dbg/output.vim'
import autoload '../autoload/dbg/prof.vim'
import autoload '../autoload/dbg/scriptnames.vim'
import autoload '../autoload/dbg/synnames.vim'
import autoload '../autoload/dbg/termcap.vim'
import autoload '../autoload/dbg/timer.vim'
import autoload '../autoload/dbg/verbose.vim'

# TODO: Implement a command which would tell us which rule governs the indentation of a given line.
#
# https://vi.stackexchange.com/a/25338/17449
# https://vi.stackexchange.com/a/25204/17449


# Log Channel Activity {{{1

const LOG_CHANNEL_ACTIVITY: bool = true
export const LOGFILE_CHAN: string = $'{$TMPDIR}/vim/channel_activity.log'

augroup LogChannelActivity
    # we need to delay until `VimEnter` so that `v:servername` has been set
    autocmd VimEnter * LogChannelActivity()
augroup END

def LogChannelActivity()
    if LOG_CHANNEL_ACTIVITY
    # only log the activity of our main Vim instance
    && v:servername != ''
        ch_logfile(LOGFILE_CHAN, 'w')
        def ReduceLogfile()
            # For now, we're only interested in the keys we've typed (interactively).
            var keep_only_raw_keys: string = 'raw key input'
            var keep_only_last_lines: string = 'execute '':1,'' .. (line(''$'') - 1000) .. '' delete _'''
            var cmd: string = printf(
                # Do *not* use `sed(1)`.{{{
                #
                #     sed -i '/pattern/!d' "$LOGFILE_CHAN"
                #         ^^
                #         ✘
                #
                # It would temporarily  delete the logfile which  would stop Vim
                # from logging channel activity.
                #}}}
                'vim -es -Nu NONE -U NONE -i NONE'
                    .. ' -c "vglobal/%s/delete _"'
                    .. ' -c "%s"'
                    .. ' -c "update | quitall!" %s',
                keep_only_raw_keys,
                keep_only_last_lines,
                LOGFILE_CHAN
            )
            # Is it OK for `cmd` to be a string?{{{
            #
            # Yes,  but  only   if  the  commands  in  `-c   "..."`  are  inside
            # double-quoted   strings;  not   single-quoted  ones.    Outside  a
            # double-quoted string, Vim splits on any whitespace it can find.
            # From `:help job_start()`:
            #
            #    > {command} can be a String.  This works best on MS-Windows.  On
            #    > Unix it is split up in white-separated parts to be passed to
            #    > execvp().  **Arguments in double quotes can contain white space.**
            #
            # The splitting must not break the meaning of a Vim token.
            # For Vim, `:echo localtime()` is one command which can't be split.
            # You can't write this:
            #
            #     :echo
            #     :localtime()
            #
            # So, you would not start Vim like this:
            #
            #     ✘
            #     $ vim -Nu NONE -c echo localtime()
            #
            # But like this:
            #
            #     ✔
            #     $ vim -Nu NONE -c 'echo localtime()'
            #
            # ---
            #
            # Test:
            #
            #     :call delete('/tmp/file')
            #     :let cmd = 'vim -es -Nu NONE -U NONE -i NONE +"call writefile([''test''], ''/tmp/file'') | quitall!"'
            #     :call job_start(cmd)
            #     :echo readfile('/tmp/file')
            #     ['test']
            #}}}
            # Alternatively, you could start a shell which would do the splitting for you:{{{
            #
            #               v--------------------------v
            #     job_start([&shell, &shellcmdflag, cmd], {
            #     ...
            #
            # Notice that we pass a list, not a string.
            # With a  list, Vim does not  split anything, and simply  passes the
            # items unchanged to `execvp()`.
            #}}}
            job_start(cmd, {
                err_io: 'null',
                in_io: 'null',
            })
        enddef
        # The logged channel activity is very verbose.
        # Reduce it on a regular interval.
        timer_start(1'000'000, (_) => ReduceLogfile(), {repeat: -1})
    endif
enddef

# Autocmds {{{1

augroup MyDebug
    autocmd!
    autocmd BufNewFile /tmp/*/timer_info timer.Populate()
    autocmd BufReadPost ftp://ftp.vim.org/pub/vim/patches/*/README dbg.VimPatchesPrettify()
augroup END

# Commands {{{1

# Wrapper around `:profile` to make profiling more intuitive.
command -bar -bang -nargs=? -complete=customlist,prof.Completion Prof prof.Wrapper(<q-bang>, <q-args>)

# Purpose:{{{
# Wrapper around commands such as `:breakadd file */ftplugin/bash.vim`.
# Provides a usage message, and smart completion.
#
# Useful to debug a filetype/indent/syntax plugin.
#}}}
command -bar -nargs=* -complete=custom,localPlugin.Complete DebugLocalPlugin {
    localPlugin.Main(<q-args>)
}

command -bar DebugMappingsFunctionKeys mappings.UsingFunctionKeys()

# `:DebugTermcap` dumps the termcap db of the current Vim instance
# `:DebugTermcap!` prettifies the termcap db written in the current file
command -bar -bang DebugTermcap termcap.Main(<bang>0)

# Sometimes, after a  refactoring, we forget to remove some  functions which are
# no longer necessary.  This command should list them in the location window.
# Warning: It might  give false  positives, because a  function may  appear only
# once in a plugin, but still be called from another plugin.
command -bar DebugUnusedFunctions dbg.UnusedFunctions()

command -bar Scriptnames scriptnames.Main()

# Do *not* use `-bar` here!{{{
#
# It  would discard  anything  after a  `"`, which  could  wrongly truncate  the
# command we want to debug.  Example:
#
#     :Time execute "normal \<F3>"
#                   ^
#                   we don't want to stop here!
#
# From `:help :command-bar`:
#
#    > -bar        The command can be followed by a "|" and another command.
#    >             A "|" inside the command argument is not allowed then.
#    >             **Also checks for a " to start a comment.**
#}}}
# Since Vim's patch 8.1.1241, a range seems to be, by default, interpreted as a line address.{{{
#
# But here, we don't use the range as a line address, but as an arbitrary count.
# And it's possible that we give a count which is bigger than the number of lines in the current buffer.
# If that happens, `E16` will be given:
#
#     :command -range=1 Cmd echo ''
#     :new
#     :3 Cmd
#     E16: Invalid range˜
#
# Here's the patch 8.1.1241:
# https://github.com/vim/vim/commit/b731689e85b4153af7edc8f0a6b9f99d36d8b011
#
# ---
#
# Solution: use the additional attribute `-addr=other`:
#
#                       v---------v
#     :command -range=1 -addr=other Cmd echo ''
#     :new
#     :3 Cmd
#
# I think it specifies that the type of  the range is not known (i.e. not a line
# address, not a buffer number, not a window number, ...).
#}}}
command -range=1 -addr=other -nargs=+ -complete=command Time dbg.Time(<q-args>, <count>)
# Do *not* give the `-bar` attribute to `:Verbose`.
command -range=1 -addr=other -nargs=1 -complete=command Verbose {
    log.Output({level: <count>, excmd: <q-args>})
}

command -bar -nargs=1 -complete=option Vo verbose.Option(<q-args>)
cnoreabbrev <expr> vo getcmdtype() =~ '[:>]' && getcmdpos() == 3 ? 'Vo' : 'vo'

# Mappings {{{1
# C-x C-v   evaluate variable under cursor while on command-line{{{2

cnoremap <unique> <C-X><C-V> <C-\>e <SID>cmdline.EvalVarUnderCursor()<CR>

# dg C-l    clean log {{{2

nnoremap <unique> dg<C-L> <ScriptCmd>dbg.CleanLog()<CR>

# g!        last page in the output of last command {{{2

# Why?{{{
#
# `g!` is easier to type.
# `g<` could be used with `g>` to perform a pair of opposite actions.
#}}}
nnoremap <unique> g! g<

# !c        capture variable {{{2

# This mapping is useful to create a copy of a variable local to a function or a
# script into the global namespace, for debugging purpose.

# `!c` captures the latest value of a variable.
# `!C` captures all the values of a variable during its lifetime.
nnoremap <expr><unique> !c capture.Main(false)
nnoremap <expr><unique> !C capture.Main(true)

# !d        echo g:d_* {{{2

nnoremap <unique> !d <ScriptCmd>capture.Dump()<CR>

# !e        show help about last error {{{2

# Description:
# You execute some function/command which gives one or several errors.
# Press `!e` to open the help topic explaining the last one.
# Repeat to cycle through all the help topics related to the rest of the errors.

# An intermediate `<Plug>`  mapping is necessary to make  the mapping repeatable
# via our submode API.
nmap <unique> !e <Plug>(help-last-errors)
nnoremap <Plug>(help-last-errors) <ScriptCmd>execute dbg.HelpAboutLastErrors()<CR>

# !K        show last pressed keys {{{2

nnoremap <unique> !K <ScriptCmd>dbg.LastPressedKeys()<CR>

# !m        show messages {{{2

nnoremap <unique> !m <ScriptCmd>dbg.Messages()<CR>

# !M        clean messages {{{2

nnoremap <unique> !M <ScriptCmd>messages clear <Bar> echo 'messages cleared'<CR>

# !o        paste Output of last Ex command  {{{2

nmap <expr><unique> !o output.LastExCommand()

# !O        log Vim options {{{2

nnoremap <unique> !O <ScriptCmd>dbg.LogOptions()<CR>

# !s        show syntax groups under cursor {{{2

# Usage:
# all these commands apply to the character under the cursor
#
#     !s     show the names of all syntax groups
#     1!s    show the definition of the innermost syntax group
#     3!s    show the definition of the 3rd syntax group

nnoremap <unique> !s <ScriptCmd>synnames.Main(v:count)<CR>

# !S        autoprint stack items under the cursor {{{2

nnoremap <unique> !S <ScriptCmd>autoSynstack.Main()<CR>

# !T        measure time to do task {{{2

nnoremap <unique> !T <ScriptCmd>timer.Measure()<CR>

# !t        show info about running timers {{{2

nnoremap <unique> !t <ScriptCmd>timer.InfoOpen()<CR>
