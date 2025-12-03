vim9script

# This compiler is not meant to run any program, nor to parse any output.  But
# we might  need it for  our custom lints  under `~/Wiki/linter/` to  be used.
# For example, when we press `|c` to lint a file, `RunCompiler()` bails out if
# no compiler is set, and unfortunately, there is no linter for fish.  So, our
# fish lints would be ignored if we didn't set a compiler.
#
# We could make an exception for fish  in the guard, but the code assumes that
# a compiler was set at various points  later.  It seems more elegant to set a
# dummy compiler.

g:current_compiler = 'none'

#                       ignore any message
#                       v-----v
CompilerSet errorformat=%-G%.%#
CompilerSet makeprg=:
#                   ^
#                   no-op shell builtin
