vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import 'lg/mapping.vim'

import autoload '../autoload/cmdline.vim'
import autoload '../autoload/cmdline/cL.vim'
import autoload '../autoload/cmdline/cycle/filter.vim' as _filter
import autoload '../autoload/cmdline/cycle/generic.vim'
import autoload '../autoload/cmdline/transform.vim'

# Abbreviations {{{1
# Unused_code:{{{
#
#         def StrictAbbr(args: string, search_cmdline = false)
#             var lhs: string
#             var rhs: string
#             [lhs, rhs] = matchlist(a:args, '^\s*\(\S\+\)\s\+\(.*\)')[1 : 2]
#             if search_cmdline
#                 execute printf("cnoreabbrev <expr> %s getcmdtype() =~ '[/?]' ? '%s' : '%s'", lhs, rhs, lhs)
#             else
#                 execute printf("cnoreabbrev <expr> %s getcmdtype() =~ '[:>]' ? '%s' : '%s'", lhs, rhs, lhs)
#             endif
#         enddef
#
#         command -nargs=+ Cab StrictAbbr(<q-args>)
#         command -nargs=+ Sab StrictAbbr(<q-args>, true)
#}}}

# fix some typos
cnoreabbrev <expr>  \` getcmdtype() =~ '[/?]' ? '\t' : '\`'

cnoreabbrev <expr> dig getcmdtype() =~ '[:>]' && getcmdpos() == 4 ? 'verbose Digraphs!' : 'dig'
cnoreabbrev <expr> ecoh getcmdtype() =~ '[:>]' && getcmdpos() == 5 ? 'echo' : 'ecoh'
cnoreabbrev <expr> et getcmdtype() =~ '[:>]' && getcmdpos() == 3 ? 'e /tmp/t.vim' : 'et'
cnoreabbrev <expr> hg getcmdtype() =~ '[:>]' && getcmdpos() == 3 ? 'helpgrep' : 'hg'
cnoreabbrev <expr> sl getcmdtype() =~ '[:>]' && getcmdpos() == 3 ? 'ls' : 'sl'
cnoreabbrev <expr> soù getcmdtype() =~ '[:>]' && getcmdpos() == 4 ? 'source %' : 'soù'

cnoreabbrev <expr> ucs getcmdtype() =~ '[:>]' && getcmdpos() == 4 ? 'UnicodeSearch' : 'ucs'
cnoreabbrev <expr> V cmdline.Vim9Abbrev()

# Commands {{{1

# `:filter` doesn't support all commands.   We install a wrapper command which
# emulates `:filter` for the commands which are not supported.
command -bang -nargs=+ -complete=custom,_filter.Completion Filter _filter.Main(<q-args>, <bang>0)

# Autocmds {{{1
# Do *not* automatically capitalize a custom command name written in lowercase.{{{
#
#     ✘
#     cmdline.AutoCapitalize()
#
# An abbreviation matching a builtin Ex command  is a bad idea.  If you type a
# mapping which is  *recursive*, and the latter tries to  execute a builtin Ex
# command, an abbreviation might unexpectedly replace the command name:
#
#     nmap <F3> :echomsg 'no issue'<CR>
#     cnoreabbrev echomsg invalid
#     feedkeys("\<F3>")
#     # Expected: 'no issue'
#     # Actual: E492: Not an editor command: invalid 'no issue'
#
# IOW, this kind of abbreviation makes  Vim less predictable.  You might think
# that  this is  a non-issue:  a good  mapping should  be recursive  only when
# necessary.  True.  But you don't have control over *all* the mappings you're
# using (third-party plugins, $VIMRUNTIME ftplugins, ...).
#
# Besides, abbreviations should be used sparingly; like with anything which is
# automated, it  can lead  to unexpected results.   Adding a  new abbreviation
# whenever we get a new custom Ex command is too much.
#}}}

augroup MyCmdlineChain
    autocmd!
    # Automatically execute  command B when A  has just been executed  (chain of
    # commands).  Inspiration:
    # https://gist.github.com/romainl/047aca21e338df7ccf771f96858edb86
    autocmd CmdlineLeave : cmdline.Chain()

    # TODO: The  following  autocmds  are not  handled  by  `cmdline.Chain()`,
    # because they don't execute simple Ex  commands.  Still, it's a bit weird
    # to have  an autocmd handling  simple commands (+  2 less simple),  and a
    # bunch of other related autocmds handling more complex commands.
    #
    # Try to find a way to consolidate all cases in `cmdline.Chain()`.
    # Refactor it, so that when it handles complex commands, the code is readable.
    # No long: `if ... | then ... | elseif ... | ... | elseif ... | ...`.

    # sometimes, we type `:help functionz)` instead of `:help function()`
    autocmd CmdlineLeave : {
        if getcmdline() =~ '\C^h\%[elp]\s\+\S\+z)\s*$'
            cmdline.FixTypo('z')
        endif
    }

    # When  we copy  a  line of  vimscript  and paste  it  on the  command-line,
    # sometimes the newline gets copied and  translated into a literal CR, which
    # gives an error; remove it.
    autocmd CmdlineLeave : {
        if getcmdline() =~ '\r$'
            cmdline.FixTypo('cr')
        endif
    }
augroup END

# Mappings {{{1

# extend `:help c^l` to `:vimgrep` and `:substitute`
cnoremap <expr> <C-L> cL.Main()

# Prevent the function from returning anything if we are not in the pattern field of `:vim`.
# The following mapping transforms the command-line in 2 ways, depending on where we press it:{{{
#
#    - on the search command-line, it translates the pattern so that:
#
#        - it's searched outside comments
#
#        - all alphabetical characters are replaced by their corresponding
#        equivalence class
#
#    - on the Ex command-line, if the latter contains a substitution command,
#      inside the pattern, it captures the words written in snake case or
#      camel case inside parentheses, so that we can refer to them easily
#      with backref in the replacement.
#}}}
cnoremap <expr><unique> <C-S> transform.Main()

# Cycle through a set of arbitrary commands.
cnoremap <unique> <C-G> <C-\>e <SID>generic.Move()<CR>
execute mapping.Meta('cnoremap <unique> <M-G> <C-\>e <SID>generic.Move(v:false)<CR>')

xnoremap <unique> <C-G>s :s///g<Left><Left><Left>

nnoremap <unique> <C-G>z :<C-U>g//z.4 <Bar> echo repeat('=', &columns)<C-B><Right><Right>

# populate the arglist with:
#
#    - all the files in a directory
#    - all the files in the output of a shell command
execute generic.Set('a',
    'sp <Bar> args `=glob(''⌖./**/*'', 0, 1)->filter({_, v -> filereadable(v)})`',
    'sp <Bar> silent args `=systemlist(''⌖'')`')

#                    definition
#                    v
execute generic.Set('d',
    'Verb nno ⌖',
    'Verb com ⌖',
    'Verb au ⌖',
    'Verb au * <buffer=⌖>',
    'Verb fu ⌖',
    'Verb fu {''<lambda>⌖''}')

execute generic.Set('ee',
    'tabe $MYVIMRC⌖',
    'e $MYVIMRC⌖',
    'sp $MYVIMRC⌖',
    'vs $MYVIMRC⌖')

execute generic.Set('em',
    'tabe /tmp/vimrc⌖',
    'tabe /tmp/vim.vim⌖')

# search a file in:{{{
#
#    - the working directory
#    - ~/.vim
#    - the directory of the current buffer
#}}}
execute generic.Set('ef',
    'fin ~/.vim/**/*⌖',
    'fin *⌖',
    'fin %:h/**/*⌖')
# Why `fin *⌖`, and not `fin **/*⌖`?{{{
#
# 1. It's useless to add `**` because we already included it inside 'path'.
#    And `:find` searches in all paths of 'path'.
#    So, it will use `**` as a prefix.
#
# 2. If we used `fin **/*⌖`, the path of the matches would be relative to
#    the working directory.
#    It's too verbose.  We just need their name.
#
#     Btw, you may wonder what happens when we type `:fin *bar` and press Tab or
#    C-d,  while  there  are two  files  with  the  same  name `foobar`  in  two
#    directories in the working directory.
#
#     The answer is  simple: for each match, Vim prepends  the previous path
#    component to  remove the ambiguity.  If it's  not enough, it goes  on adding
#    path components until it's not needed anymore.
#}}}
execute generic.Set('es',
    'sf ~/.vim/**/*⌖',
    'sf *⌖',
    'sf %:h/**/*⌖')
execute generic.Set('ev',
    'vert sf ~/.vim/**/*⌖',
    'vert sf *⌖',
    'vert sf %:h/**/*⌖')
execute generic.Set('et',
    'tabf ~/.vim/**/*⌖',
    'tabf *⌖',
    'tabf %:h/**/*⌖')

execute generic.Set('f', 'Verb Filter /\c⌖/ ')

execute generic.Set('p', 'new <Bar> :0 put =execute(''⌖'')')

# When should I prefer this over `:WebPageRead`?{{{
#
# When you need to download code, or when you want to save the text in a file.
#
# Indeed, the buffer  created by `:WebPageRead` is not associated  to a file, so
# you can't save it.
# I you want to save it, you need to yank the text and paste it in another buffer.
#
# Besides, the text is formatted to not go beyond 100 characters per line, which
# could break some long line of code.
#}}}
# `-s`: don't show progress meter, nor error messages
execute generic.Set('r', 'execute ''read !curl -s '' .. shellescape(''⌖'', v:true)')

execute generic.Set('s',
    '%s/⌖//g',
    # If you think you can merge the two substitutions, try your solution against these texts:{{{
    #
    #     example, ‘du --exclude='*.o'’ excludes files whose names end in
    #
    #     A block size  specification preceded by ‘'’ causes output  sizes to be displayed
    #}}}
    '%s/`\(.\{-}\)''/`\1`/gce <Bar> %s/‘\(.\{-}\)’/`\1`/gce',
    # Suppose you have this text:{{{
    #
    #     pat1
    #     text
    #     pat2
    #     text
    #     pat3
    #     text
    #
    #     foo
    #     bar
    #     baz
    #
    # And you want to move `foo`, `bar` and `baz` after `pat1`, `pat2` and `pat3`.
    #
    #    1. yank the `foo`, `bar`, `baz` block
    #
    #    2. visually select the `pat1`, `pat2`, `pat3` block,
    #       then leave to get back to normal mode
    #
    #    3. invoke the substitution command, write `pat\d` at the start of the
    #       pattern field, and validate
    #}}}
    'let list = split(@", "\n") <Bar> *s/⌖\zs/\=list->remove(0)/'
)

# Compare files in the first two windows, and output lines unique to the first
# one.  To get the lines unique to the second one, replace `-23` with `-13`.
execute generic.Set('u', 'bo new <Bar> exe $''.!comm -2⌖3 <(sort #{winbufnr(1)}) <(sort #{winbufnr(2)})''')

# Why don't you add `<Bar> cwindow` in your mappings?{{{
#
# `:VimGrep` is a custom command, which  isn't defined with `-bar`.  So, if it
# sees  `| cwindow`,  it will  wrongly  interpret  it  as  being part  of  its
# argument.  We don't  define `:VimGrep` with `-bar` because we  might need to
# look for a pattern which contains a bar.
#}}}
execute generic.Set('v',
    # files in current directory with same extension as current file
    'VimGrep /⌖/gj ./**/*.<C-R>=expand("%:e")<CR>',
    # our ebooks
    'VimGrep /⌖/gj ~/.cache/convert2text/*',
    # Vim files
    'VimGrep /⌖/gj $VIMRUNTIME/**/*.vim',
    # arglist
    'VimGrep /⌖/gj ##',
    # To look for files (and not a pattern).
    # Example, all `.conf` files under `/etc`.
    'VimGrep /\%^/gj /etc/**/*.conf',
)
