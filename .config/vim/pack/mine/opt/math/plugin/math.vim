vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/math.vim'

# Documentation {{{1

# A calculator can interpret math operators like `+`, `-`, `*`, `/`, but not our
# plugin.  This is *not* a calculator, like the `bc(1)` shell command.
#
# The plugin merely installs an operator/command  to *analyse* a set of numbers,
# separated by spaces  or newlines.  It automatically adds  operators to compute
# different metrics.  So, there should be no  math operator in the text that the
# plugin analyses, *only* numbers.

# Command {{{1

command -bar -range AnalyseNumbers {
    math.Op()
    execute printf('normal! %dGg@%dG', <line1>, <line2>)
}

# Mappings {{{1

nnoremap <expr><unique> -m  math.Op()
nnoremap <expr><unique> -mm math.Op() .. '_'
xnoremap <expr><unique> -m  math.Op()
