vim9script

if exists('b:current_syntax')
    finish
endif

syntax match timerInfoNoise /^\%(#\+\|---\)$\|^#\s\zeid/ conceal
syntax match timerInfoInteresting
    \ /\%(^\%(remaining\|#\sid\)\)\@9<=\s\+.*\|^paused\s\+\zs1$\|^\s\{4}.*/
    \ contains=timerInfoCallback
# We match after  `:return` because it's the latter we  must search if there's
# an issue with the callback. `:return`  is never written in the original code
# from which the timer is started.
syntax match timerInfoCallback /^\s\{4}1\s\+return\s\zs.*/

highlight default link timerInfoInteresting Identifier
highlight default link timerInfoCallback WarningMsg

b:current_syntax = 'timer_info'
