vim9script

# Interface {{{1
export def HighlightLanguages() #{{{2
    # What's the purpose of this `for` loop?{{{
    #
    # Iterate over the  languages mentioned in `b:markdown_highlight`,  and for each
    # of them, include the corresponding syntax plugin.
    #}}}
    var delims: list<string> = get(b:, 'markdown_highlight', [])
    if delims->empty()
        return
    endif

    # Don't let the function re-call itself.
    # Can happen if there is a ```markdown fenced codeblock.
    var stack: string = expand('<stack>')
    var funcname: string = stack->matchstr('.*function \zs[^ \[]*')
    if stack->count(funcname) > 1
        return
    endif

    var iskeyword_save: string = execute('syntax iskeyword')
        ->matchstr('syntax iskeyword \zs.*')
    var sync_settings: list<string>
    var done_include: dict<bool>
    for delim: string in delims
        # If by accident, we manually  assign a value to `b:markdown_highlight`, and
        # we write duplicate values, we want to include the corresponding syntax
        # plugin only once.
        if done_include->has_key(delim)
            continue
        endif
        # We can't blindly rely on the delim:{{{
        #
        #     # ✔
        #     ```python
        #     # here, we indeed want the python syntax plugin
        #
        #     # ✘
        #     ```js
        #     # there's no js syntax plugin
        #     # we want the javascript syntax plugin
        #}}}
        var filetype: string = GetFiletype(delim)
        if filetype->empty()
            continue
        endif

        # What's the effect of `:syntax include`?{{{
        #
        # If you execute:
        #
        #     syntax include @markdownHighlight_python syntax/python.vim
        #
        # 1. Vim will define all groups from  all python syntax plugins, but for
        # each of them, it will add the argument `contained`.
        #
        # 2. Vim  will  define  the  cluster  `@markdownHighlight_python`  which
        # contains all the syntax groups defined in python syntax plugins.
        #
        # Note that if `b:current_syntax` is set, Vim won't define the contained
        # python syntax groups; the cluster will be defined but contain nothing.
        #}}}
        # `silent!` is necessary to suppress a possible E403 error.{{{
        #
        # To reproduce, write this text in `/tmp/md.md`:
        #
        #     ```rexx
        #     text
        #     ```
        #     ```vim
        #     text
        #     ```
        #
        # Then, open the `/tmp/md.md` file:
        #
        #     Error detected while processing BufRead Autocommands for "*.md"
        #         ..FileType Autocommands for "*"
        #         ..Syntax Autocommands for "*"
        #         ..function <SNR>22_SynSet[25]
        #         ..script ~/.vim/pack/mine/opt/markdown/syntax/markdown.vim[835]
        #         ..function markdown#HighlightLanguages[82]
        #         ..script /usr/local/share/vim/vim82/syntax/vim.vim:
        #     line  838:
        #     E403: syntax sync: line continuations pattern specified twice
        #
        # The issue  is that  the markdown  file contains  2 fenced  code blocks
        # causing Vim to include 2 syntax  plugins, each of which runs this kind
        # of command:
        #
        #     syntax sync linecount {pattern}
        #}}}
        # Warning: do *not* use a different prefix than `markdownHighlight_` in the cluster name{{{
        #
        # That's the  prefix used by the  default markdown plugin; as  a result,
        # that's the one assumed by other default syntax plugins.
        #
        # If you  change the  prefix, an  embedded fenced  codeblock may  not be
        # correctly highlighted.
        #}}}
        # I have some wrong highlighting in a code block.  An item matches where it should not!{{{
        #
        # The  plugin  author  might  have forgotten  to  use  `contained`  when
        # installing a rule.
        #
        # If an item  is missing `contained`, *all* the rules  in the group will
        # match  at the  toplevel of  a  fenced code  block.  Even  if they  are
        # defined with `contained`.
        # That's because `:help syn-include` includes  any group for which there
        # is at  least one  item matching  at the top  level, inside  the ad-hoc
        # specified cluster.   The one that you  use later to define  the region
        # highlighting a code block.
        #}}}
        execute $'silent! syntax include @markdownHighlight_{filetype}'
            .. $' syntax/{filetype}.vim'
        # Why?{{{
        #
        # The previous  `:syntax include` has  caused `b:current_syntax`  to set
        # the value stored in `filetype`.
        # If  more than  one language  is embedded,  the next  time that  we run
        # `:syntax include`, the resulting cluster will contain nothing.
        #}}}
        unlet! b:current_syntax

        # Note that the name of the region is identical to the name of the cluster:{{{
        #
        #     $'markdownHighlight_{filetype}'
        #
        # But there's no conflict.
        # Probably because a cluster name is always prefixed by `@`.
        #}}}
        # Don't allow whitespace before the backticks.{{{
        #
        # For example, you might want to put a diff for some documentation file,
        # which itself embeds a  triple backtick.  Allowing whitespace increases
        # the risk for our syntax plugin to conflate an indented triple backtick
        # with the end of the fenced code block.
        #}}}
        execute $'syntax region markdownHighlight_{filetype}'
            .. ' matchgroup=markdownCodeDelimiter'
            .. $' start=/^\z(````*\)\s*{delim}\S\@!.*$/'
            .. ' end=/^\z1\ze\s*$/'
            .. ' keepend'
            .. ' concealends'
            .. $' contains=@markdownHighlight_{filetype}'
        done_include[delim] = true

        # To make sure there is no collapsed highlighting after a fenced code block.{{{
        #
        # See also:
        #
        #    - `:help 44.10`
        #    - `:help syn-sync-groupthere`
        #}}}
        # For some reason, we need `display`:{{{
        #
        # Otherwise, in a markdown file, there might be collapsed highlighting
        # after a bash heredoc.  I can reproduce with just these rules:
        #
        #     syntax region xFoo start=/garbage_start/ end=/garbage_end/
        #     syntax sync match bashFencedCodeBlockSync grouphere xFoo /^```bash$/
        #     syntax sync match bashFencedCodeBlockSync groupthere NONE /^```$/
        #}}}
        # TODO: Does `display` break something else?
        sync_settings += [
            # tell Vim that a triple backtick + delim starts a fenced code block
            $'syntax sync match {filetype}FencedCodeBlockSync grouphere markdownHighlight_{filetype} /^```{delim}\s*$/ display',
            # tell Vim that a triple backtick alone on a line ends a fenced code block{{{
            #
            # It doesn't seem necessary ATM, but it doesn't hurt.
            #}}}
            $'syntax sync match {filetype}FencedCodeBlockSync groupthere NONE /^```\s*$/'
        ]
    endfor

    # Make sure settings from irrelevant syntax plugins don't interfere.
    # This is especially necessary when including  the C syntax plugin, to avoid
    # collapsed highlighting after a fenced code block.
    syntax sync clear
    # But that's not always enough.{{{
    #
    # Disable the `grouphere` setting, then run this:
    #
    #     vim9script
    #     var lines = ['```vim', '```', '```vim']
    #         + ['x']->repeat(100)
    #         + ['```']
    #         + ['y', 'y', 'y']
    #     lines->writefile('/tmp/md.md')
    #     exit
    #
    #     $ vim +'normal! G' /tmp/md.md
    #
    # Notice that the `y` lines are wrongly highlighted with `markdownFencedCodeBlock`.
    #}}}
    for setting: string in sync_settings
        execute setting
    endfor
    # restore original sync settings (set in the filetype plugin)
    execute b:sync_setting

    if iskeyword_save != 'not set'
        execute $'syntax sync {iskeyword_save}'
    endif
enddef

export def FixFormatting() #{{{2
    var view: dict<number> = winsaveview()
    &l:foldenable = false

    # If a link contains a closing parenthesis, it breaks the highlighting.{{{
    #
    # The latter (and the conceal) stops too early.
    #
    # Besides, on some markdown pages like this one:
    # https://github.com/junegunn/fzf/wiki/Examples
    #
    # Some links are invisible.
    #
    #     ![](https://github.com/piotryordanov/fzf-mpd/raw/master/demo.gif)
    #       ^
    #       ✘
    #
    # This is because there's no description of the link.
    #
    # We can fix all of these issues by converting inline links to reference links.
    #}}}
    # Let's  make sure  that  `:LinkInline2Ref` does  not  change the  current
    # window (might happen if it opens the location window).
    var winid: number = win_getid()
    execute 'LinkInline2Ref'
    win_gotoid(winid)

    # trim trailing whitespace
    silent keepjumps keeppatterns :% substitute/\s\+$//e

    # I  think triple  backticks can  sometimes cause  collapsed highlighting.
    # Maybe because  the ending line  of a  fenced codeblock can  be conflated
    # with the starting one, since they're identical.  Let's remove them after
    # indenting the lines inside the codeblock.
    var in_fenced_codeblock: bool  # ```
    var in_fenced_codeblock_filetype: bool  # ```bash, ...
    for [lnum: number, line: string] in getline(1, '$')->items()
        # ```bash
        if line =~ '^[`~]\{3,}[^`~[:blank:]]\+$'
            in_fenced_codeblock = false
            in_fenced_codeblock_filetype = true

        # ```
        elseif line =~ '^[`~]\{3,}$'
            # a ``` line which starts a codeblock
            if !in_fenced_codeblock && !in_fenced_codeblock_filetype
                in_fenced_codeblock = true
                # mark the line for future deletion
                execute $"silent keepjumps keeppatterns :{lnum + 1} substitute/^/\<C-A>/e"

            # a ``` line which ends a codeblock
            else
                if in_fenced_codeblock
                    # mark the line for future deletion
                    execute $"silent keepjumps keeppatterns :{lnum + 1} substitute/^/\<C-A>/e"
                endif
                in_fenced_codeblock = false
                in_fenced_codeblock_filetype = false
            endif
        endif

        # Indent the lines inside a ``` codeblock.
        if in_fenced_codeblock
                && line != ''
                && line !~ '^[`~]\{3,}$'
            execute $'silent keepjumps keeppatterns :{lnum + 1} substitute/^/    /e'
        # A codeblock  might contain some  comments beginning with  `#`; those
        # will be wrongly interpreted as headers.   Fix this by adding a space
        # in front  of them.   Do *not*  try to inspect  the syntax;  it's too
        # unreliable and tricky to get it right in all circumstances.
        elseif in_fenced_codeblock_filetype && line =~ '^#'
            execute $'silent keepjumps keeppatterns :{lnum + 1} substitute/^/ /e'
        endif
    endfor

    # delete empty lines before first fold (if any)
    if getline(1) =~ '^\s*$'
        silent :1;/^#\+\s\+[^ #]/- delete _
    endif
    # triple backtick lines are no longer necessary (we've indented their contents){{{
    #
    # `silent!` with  a bang because there  might be no match.   ATM, there is
    # none for the tmux wiki.
    #}}}
    silent! global/^\s*\%x01/keepjumps delete _

    # Warning: Leave this block at the end.   It assumes that no line is going
    # to be deleted later.
    #
    # Between the last line of a fold and the title of the next one, make sure
    # there is always at least one empty line.
    silent :% substitute/\S\n\zs\ze#\+$/\r/e
    # If a  codeblock follows a line  starting with a bullet  point, make sure
    # it's separated by a rule.
    silent :% substitute/^ \{,3}-\s.*\n\zs\ze\n    \S/\r---\r/e
    silent :% substitute/^ \{,3}\*.*\*\@1<!\n\zs\ze\n    \S/\r---\r/e

    &l:foldenable = true
    winrestview(view)
enddef

export def UndoFtplugin() #{{{2
    set autoindent<
    set commentstring<
    set concealcursor<
    set conceallevel<
    set comments<
    set errorformat<
    set foldexpr<
    set foldmethod<
    set foldtext<
    set formatprg<
    set keywordprg<
    set makeprg<
    set spelllang<
    set textwidth<
    set wrap<
    unlet! b:cr_command
         \ b:exchange_indent
         \ b:markdown_highlight
         \ b:mc_chain
         \ b:sandwich_recipes
         \ b:sync_setting
    silent! autocmd! InstantMarkdown * <buffer>
    silent! autocmd! MarkdownWindowSettings * <buffer>

    nunmap <buffer> <bar>p

    nunmap <buffer> cof
    nunmap <buffer> [of
    nunmap <buffer> ]of
    nunmap <buffer> gd
    xunmap <buffer> gd
    nunmap <buffer> gl

    nunmap <buffer> +[#
    nunmap <buffer> +]#

    nunmap <buffer> +h

    nunmap <buffer> =rb
    nunmap <buffer> =r-
    nunmap <buffer> =r--
    xunmap <buffer> =r-

    xunmap <buffer> H
    xunmap <buffer> L

    delcommand CheckPunctuation
    delcommand CommitHash2Link
    delcommand FixFormatting
    delcommand FoldSortBySize
    delcommand LinkInline2Ref
enddef

export def Hyphens2hashes(type = ''): string #{{{2
    if type == ''
        &operatorfunc = Hyphens2hashes
        return 'g@'
    endif

    var range: string = ":'[,']"
    var hashes: string = search('^#', 'bnW')->getline()->matchstr('^#*')
    if empty(hashes)
        return ''
    endif
    execute $'silent {range} substitute/^---/{hashes} ?/e'
    return ''
enddef

export def ConvertToHelpLink(type = ''): string #{{{2
    if type == ''
        &operatorfunc = ConvertToHelpLink
        return 'g@l'
    endif

    var line: string = getline('.')
    var pat: string = '\C\%(\%<.c\|\%.c\)'
        .. '\%(\[`\)\='
        .. '\%(:h\%[elp]\s\+\)\='
        .. '\S\+\%>.c'
    if search(pat, 'bcW', line('.')) == 0
        return ''
    endif

    if synstack('.', col('.'))
            ->indexof((_, id: number): bool => id->synIDattr('name') =~ '\clink') >= 0
        # If we're on a link, undo it:{{{
        #
        #     [`:help :autocmd`](https://vimhelp.org/autocmd.txt.html#%3Aautocmd)
        #     →
        #     :help :autocmd
        #}}}
        pat = '\C\%.c'
            .. '\%(\[`\)\='
            .. '\(\%(:h\%[elp]\s\+\)\=\S\+\)'
            .. '`\](.\{-})\+'
        line
            ->substitute(pat, '\1', '')
            ->setline('.')
        return ''
    endif

    var help_cmd: string = line->matchstr(pat)

    var tags_save: string = &l:tags
    var tagname: string = help_cmd
        ->substitute(':h\%[elp]\s\+', '', '')
        ->escape('\')
    if tagname == '' | return '' | endif
    &l:tags = $'{$VIMRUNTIME}/doc/tags'
    var taglist: list<dict<any>> = taglist($'^{tagname}$')
    if taglist->empty()
        var msgs: list<string> =<< trim eval END
            taglist() cannot find anything for ^{tagname}$
            Did you forget a slash?

                # written in buffer (not executed)
                :help \%c
                      ^
                      ✘

                :help /\%c
                      ^
                      ✔

            Trying again without ^ anchor
        END
        for msg: string in msgs
            echowindow msg
        endfor
        taglist = taglist($'{tagname}$')
    endif
    &l:tags = tags_save
    if taglist->empty() || taglist[0]->empty()
        return ''
    endif
    var fname: string = taglist[0].filename->fnamemodify(':t:r')
    tagname = taglist[0].name

    # Need to  escape backslashes to  preserve them, because they're  special in
    # the pattern  *and* replacement fields  of a substitution.  This  is useful
    # for a tag like `:help \%c`.
    help_cmd = help_cmd->escape('\')
    var rep: string = printf('[`%s`](https://vimhelp.org/%s.txt.html#%s)',
        help_cmd,
        fname,
        tagname->Encoded())
    line
        ->substitute($'\%.c\V{help_cmd}', rep, '')
        ->setline('.')
    return ''
enddef
# }}}1
# Utilities {{{1
def GetFiletype(afiletype: string): string #{{{2
    if getcompletion(afiletype, 'syntax')->index(afiletype) >= 0
        return afiletype
    endif
    var filetype: string = execute('autocmd filetypedetect')
        ->split('\n')
        ->filter((_, v: string): bool => v =~ $'\C\*\.{afiletype}\>')
        ->get(0, '')
        ->matchstr('\Csetf\%[iletype]\s*\zs\S*')
    if getcompletion(filetype, 'syntax')->index(filetype) >= 0
        return filetype
    endif
    return ''
enddef

def Encoded(name: string): string #{{{2
# For the link to work in the browser, some characters need to be replaced with a hex code prefixed with `%`:{{{
#
#     % → %25
#     ' → %27
#     ( → %28
#     ) → %29
#     / → %2F
#     : → %3A
#     \ → %5C
#     ...
#}}}
    var Rep: func: string = () => '%' .. submatch(0)
        ->char2nr()
        ->printf('%x')
        ->toupper()
    return name->substitute('[^-_a-zA-Z0-9]', Rep, 'g')
enddef
