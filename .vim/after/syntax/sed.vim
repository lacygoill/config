vim9script

# Most of these rules are copied from `$VIMRUNTIME/syntax/sed.vim`

# highlight typos in comments
syntax clear sedComment
syntax match sedComment /#.*$/ contains=@Spell,sedTodo
#                                       ^----^

# support GNU `T` command
syntax region sedBranch matchgroup=sedFunction start=/T/ matchgroup=sedSemicolon end=/;\|$/ contains=sedWhitespace

# support GNU `z` command
syntax match sedFunction /z\s*\%($\|;\)/ contains=sedSemicolon,sedWhitespace
