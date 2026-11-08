vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/logevents.vim'

#                               ┌ We could simply use `-complete=events` instead.
#                               │ But it wouldn't filter out dangerous events (SourceCmd, ...).
#                               │
command -nargs=* -bar -complete=custom,logevents.Complete LogEvents logevents.Main([<f-args>])
