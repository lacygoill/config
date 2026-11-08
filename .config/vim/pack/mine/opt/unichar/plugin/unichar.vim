vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/unichar/complete.vim'
import autoload '../autoload/unichar/toggle.vim'

# Mappings {{{1

inoremap <unique> <C-G><C-U> <ScriptCmd>complete.Fuzzy()<CR>

# Commands {{{1

# This command looks  for special sequences such as `\u1234`  inside the range
# of lines it  received.  If it finds  one, it tries to  translate all similar
# ones into  the literal characters  they stand for.   If it doesn't  find any
# `\u1234`, it  tries to do the  reverse; translate all characters  whose code
# point is above 255 (anything which is  not in the extended ascii table) into
# special characters + code points.

command -bar -range=% UnicharToggle toggle.Main(<line1>, <line2>)
