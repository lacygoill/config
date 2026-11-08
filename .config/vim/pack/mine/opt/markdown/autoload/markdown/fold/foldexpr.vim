vim9script

silent! import autoload 'fold/lazy.vim'

# Old but can still be useful {{{1
#     def HasSurroundingFencemarks(lnum: number): bool {{{2
#         var pos: list<number> = [line('.'), col('.')]
#         cursor(lnum, 1)
#
#         var start_fence: string = '\%^```\|^\n\zs```'
#         var end_fence: string = '```\n^$'
#         var fence_position: list<number> = searchpairpos(start_fence, '', end_fence, 'W')
#
#         cursor(pos)
#         return fence_position != [0, 0]
#     enddef
#
#     def HasSyntaxGroup(lnum: number): bool {{{2
#         return synstack(lnum, 1)
#             ->indexof((_, id: number): bool => id->synIDattr('name') =~ '\cmarkdown\%(Code\|Highlight\)') >= 0
#     enddef
#
#     def LineIsFenced(lnum: number): bool {{{2
#         if get(b:, 'current_syntax', '') == 'markdown'
#             # It's cheap to check if the current line has 'markdownCode' syntax group
#             return HasSyntaxGroup(lnum)
#         else
#             # Using `searchpairpos()` is expensive, so only do it if syntax highlighting is not enabled
#             return HasSurroundingFencemarks(lnum)
#         endif
#     enddef
# }}}1

export def Toggle() #{{{1
    if &l:foldexpr =~ 'Stacked()'
        &l:foldexpr = 'Nested()'
    else
        &l:foldexpr = 'Stacked()'
    endif
    # Why?{{{
    #
    # We set `'foldmethod'`  to `manual` by default, because `expr`  can be much
    # more expensive.  As a consequence, if we change the value of `'foldexpr'`,
    # Vim won't  re-compute the  folds; we  want it  to; that's  why we  need to
    # execute `lazy.Compute()`.
    #}}}
    lazy.Compute(false)
enddef
#}}}1
export def HeadingDepth(lnum: number): number #{{{1
    var thisline: string = getline(lnum)
    # `thisline =~ '\S'` would  be more  correct, but  makes the  expression a
    # little slower (by about 10%).
    if thisline != ''
            && thisline !~ '^```'
        var nextline: string = getline(lnum + 1)
        if nextline =~ '^=\+\s*$'
            return 1
        # Why `\{2,}` and not just `\+`?{{{
        #
        # Indeed, according to the markdown spec would parse, a single hyphen at
        # the  start of  a line  is enough  to start  a heading.   However, it's
        # *very* annoying for Vim to parse a  single hyphen as a heading when we
        # put a diff in a markdown file.
        #}}}
        elseif nextline =~ '^-\{2,}\s*$'
            return 2
        endif
    endif
    # Temporarily commented because it makes us gain 0.5 seconds when loading Vim notes:{{{
    #
    #     if level > 0 && LineIsFenced(lnum)
    #         # Ignore # or === if they appear within fenced code blocks
    #         return 0
    #     endif
    #
    # If you want to uncomment it, you first need to:
    #
    #    - at the start of the function, after the `thisline` assignment, write:
    #
    #         var level: number = matchend(thisline, '^#\{1,6}')
    #
    #    - in the previous block, replace `return {1|2}` with `level = {1|2}`
    #    - at the end of the function, replace the current `return matchend(...)` with `return level`
    #}}}
    return matchend(thisline, '^#\{1,6}')
enddef

export def Nested(): string #{{{1
    var depth: number = HeadingDepth(v:lnum)
    return depth > 0 ? '>' .. depth : '='
enddef

export def Stacked(): string #{{{1
    # Why would it be useful to return `1` instead of `'='`?{{{
    #
    # Run this shell command:
    #
    #     setlocal foldmethod=expr foldexpr=FoldExpr() debug=throw
    #     def g:FoldExpr(): string
    #         return HeadingDepth(v:lnum) > 0 ? '>1' : '='
    #         #                                         ^
    #     enddef
    #     def HeadingDepth(lnum: number): number
    #         var level: number = getline(lnum)->matchend('^#\{1,6}')
    #         if level == -1
    #             if getline(lnum + 1) =~ '^=\+\s*$'
    #                 level = 1
    #             endif
    #         endif
    #         return level
    #     enddef
    #     inoremap <expr> <C-K> repeat('<Del>', 300)
    #     :% delete
    #     'text'->setline(1)
    #     normal! yy300pG300Ax
    #
    # Vim starts up after about 2 seconds.
    # Next, press `I C-k`; Vim removes 300 characters after about 2 seconds.
    #
    # Now, replace  `'='` with `1` and  re-run the same command:  this time, Vim
    # starts up immediately; similarly, it removes 300 characters immediately.
    #}}}
    #   Why is it possible here, but not in `Nested()`?{{{
    #
    # Because this function is meant for files with only level-1 folds.
    # OTOH, we can't  in `Nested()`, because the latter is  meant for files with
    # up to level-6 folds.
    #}}}
    #   Why don't you return `1` then?{{{
    #
    # If you write some lines before the first heading line, they will be folded.
    # I don't want such lines to be folded.
    # A line should be folded only if it's somewhere below a heading line.
    #
    # See also our comments in:
    #
    #     ~/.vim/pack/mine/opt/git/after/ftplugin/git.vim
    #
    # One of them illustrates how `'='` is preferable to `1`.
    # Folding too much can have unexpected results.
    #}}}
    #     But doesn't it make the performance worse?{{{
    #
    # No, because – in big enough files  – as soon as Vim creates the folds,
    # we reset `'foldmethod'` to `manual` which is less costly.
    #}}}
    return HeadingDepth(v:lnum) > 0 ? '>1' : '='
enddef
