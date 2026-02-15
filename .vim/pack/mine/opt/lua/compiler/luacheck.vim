vim9script

g:current_compiler = 'luacheck'

CompilerSet errorformat=%f:%l:%c-%k:%\\s%#%m

# Flags copied from:
# https://github.com/mfussenegger/nvim-lint/blob/master/lua/lint/linters/luacheck.lua
# `--formatter=plain`:{{{
#
# Use `plain` module to format output.
# This gives a simple warning-per-line formatting which is easy to parse.
#}}}
# `--codes`:{{{
#
# Show warning code in front of each message (e.g. `(E011)`).
#}}}
# `--ranges`:{{{
#
# Show ranges of columns related to warnings.
#
#     /tmp/lua.lua:4:9-14: (E011) expected 'then' near 'return'
#                     ^^^
#
# We match this with `%k`.
#}}}
CompilerSet makeprg=luacheck\ --formatter=plain\ --codes\ --ranges\ %:p:S
