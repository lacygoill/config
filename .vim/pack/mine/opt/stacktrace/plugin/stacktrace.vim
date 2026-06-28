vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/stacktrace.vim'

# Usage:
#
#     :WTF 5
#
# Populate qfl with the  last error, as well as the previous  errors, as long as
# they are less than 5 lines away from each other in the message log.

command -bar -nargs=? WTF stacktrace.Main(<q-args> != '' ? <q-args> : 5)

nnoremap <unique> !w <ScriptCmd>stacktrace.Main(v:count != 0 ? v:count : 5)<CR>
nnoremap <unique> !W <ScriptCmd>stacktrace.Main(1'000)<CR>
