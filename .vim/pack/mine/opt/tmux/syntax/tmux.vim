vim9script

if exists('b:current_syntax')
    finish
endif

# Make sure a hyphen is a keyword character.
syntax iskeyword -,@,48-57,_,192-255
syntax case match

syntax keyword tmuxHookCmds set-hook show-hooks

syntax keyword tmuxAction  any current none
syntax keyword tmuxBoolean off on

syntax keyword tmuxOptionValue
    \ bottom
    \ bottom-left
    \ bottom-right
    \ centre
    \ copy
    \ emacs
    \ left
    \ right
    \ top
    \ top-left
    \ top-right
    \ vi

syntax keyword tmuxLayoutOptionValue
    \ even-horizontal
    \ even-vertical
    \ main-horizontal
    \ main-vertical
    \ tiled

syntax keyword tmuxClientSessionCmds
    \ attach[-session]
    \ detach[-client]
    \ has[-session]
    \ kill-server
    \ kill-session
    \ list-clients lsc
    \ list-commands lscm
    \ list-sessions ls
    \ lock-client lockc
    \ lock-session locks
    \ new[-session]
    \ refresh[-client]
    \ rename[-session]
    \ show-messages showmsgs
    \ source[-file]
    \ start[-server]
    \ suspend-client suspendc
    \ switch-client switchc

syntax keyword tmuxWindowPaneCmds
    \ break-pane breakp
    \ capture-pane capturep
    \ choose-client
    \ choose-session
    \ choose-tree
    \ choose-window
    \ copy-mode
    \ display-panes displayp
    \ display-popup popup
    \ find-window findw
    \ join-pane joinp
    \ kill-pane killp
    \ kill-window killw
    \ last-pane lastp
    \ last[-window]
    \ link-window linkw
    \ list-panes lsp
    \ list-windows lsw
    \ move-pane movep
    \ move-window movew
    \ new-window neww
    \ next-layout nextl
    \ next[-window]
    \ pipe-pane pipep
    \ prev[ious-window]
    \ previous-layout prevl
    \ rename-window renamew
    \ resize-pane resizep
    \ respawn-pane respawnp
    \ respawn-window respawnw
    \ rotate-window rotatew
    \ select-layout selectl
    \ select-pane selectp
    \ select-window selectw
    \ split-window splitw
    \ swap-pane swapp
    \ swap-window swapw
    \ unlink-window unlinkw

syntax keyword tmuxBindingCmds lsk list-keys send[-keys] send-prefix

syntax keyword tmuxEnvironmentCmds setenv set-environment showenv show-environment

syntax keyword tmuxStatusLineCmds command-prompt confirm[-before] display[-message] display-menu menu

syntax keyword tmuxBufferCmds
    \ choose-buffer
    \ clear-history clearhist
    \ delete-buffer deleteb
    \ list-buffers lsb
    \ load-buffer loadb
    \ paste-buffer pasteb
    \ save-buffer saveb
    \ set-buffer setb
    \ show-buffer showb

syntax keyword tmuxMiscCmds clock-mode if[-shell] lock[-server] wait[-for]

syntax keyword tmuxOptsSet
    \ alternate-screen
    \ base-index
    \ bell-action
    \ buffer-limit
    \ default-command
    \ default-shell
    \ default-terminal
    \ destroy-unattached
    \ detach-on-destroy
    \ display-panes-active-colour
    \ display-panes-colour
    \ display-panes-time
    \ display-time
    \ escape-time
    \ exit-unattached
    \ extended-keys
    \ focus-events
    \ history-file
    \ history-limit
    \ lock-after-time
    \ lock-command
    \ lock-server
    \ message-limit
    \ mouse
    \ pane-border-format
    \ pane-border-status
    \ prefix
    \ prefix2
    \ renumber-windows
    \ repeat-time
    \ set-clipboard
    \ set-titles
    \ set-titles-string
    \ show[-options]
    \ status
    \ status-interval
    \ status-justify
    \ status-keys
    \ status-left
    \ status-left-length
    \ status-position
    \ status-right
    \ status-right-length
    \ status-style
    \ terminal-overrides
    \ update-environment
    \ visual-activity
    \ visual-bell
    \ visual-silence
    \ word-separators

syntax match tmuxUserOptsSet /@[[:alnum:]_-]\+/ display

syntax keyword tmuxOptsSetw
    \ aggressive-resize
    \ allow-rename
    \ automatic-rename
    \ clock-mode-colour
    \ clock-mode-style
    \ main-pane-height
    \ main-pane-width
    \ mode-keys
    \ monitor-activity
    \ monitor-silence
    \ other-pane-height
    \ other-pane-width
    \ pane-active-border-style
    \ pane-base-index
    \ pane-border-lines
    \ pane-border-style
    \ pane-border-indicators
    \ remain-on-exit
    \ synchronize-panes
    \ utf8
    \ window-active-style
    \ window-status-activity-style
    \ window-status-bell-style
    \ window-status-current-format
    \ window-status-format
    \ window-status-separator
    \ window-style
    \ wrap-search

# keywords for vi/emacs edit, choice and copy modes
syntax keyword tmuxModeCmds
    \ append-selection
    \ append-selection-and-cancel
    \ back-to-indentation
    \ begin-selection
    \ bottom-line
    \ cancel
    \ clear-selection
    \ copy-end-of-line
    \ copy-line
    \ copy-pipe
    \ copy-pipe-and-cancel
    \ copy-pipe-no-clear
    \ pipe
    \ pipe-and-cancel
    \ pipe-no-clear
    \ copy-selection
    \ copy-selection-and-cancel
    \ copy-selection-no-clear
    \ cursor-down
    \ cursor-down-and-cancel
    \ cursor-left
    \ cursor-right
    \ cursor-up
    \ end-of-line
    \ goto-line
    \ halfpage-down
    \ halfpage-down-and-cancel
    \ halfpage-up
    \ history-bottom
    \ history-top
    \ jump-again
    \ jump-backward
    \ jump-forward
    \ jump-reverse
    \ jump-to-backward
    \ jump-to-forward
    \ jump-to-mark
    \ middle-line
    \ next-matching-bracket
    \ next-paragraph
    \ next-space
    \ next-space-end
    \ next-word
    \ next-word-end
    \ other-end
    \ page-down
    \ page-down-and-cancel
    \ page-up
    \ previous-matching-bracket
    \ previous-paragraph
    \ previous-space
    \ previous-word
    \ rectangle-toggle
    \ refresh-from-pane
    \ scroll-down
    \ scroll-down-and-cancel
    \ scroll-up
    \ search-again
    \ search-backward
    \ search-backward-incremental
    \ search-backward-text
    \ search-forward
    \ search-forward-incremental
    \ search-forward-text
    \ search-reverse
    \ select-line
    \ select-word
    \ set-mark
    \ start-of-line
    \ stop-selection
    \ top-line

# These keys can be used for the 'bind' command
syntax keyword tmuxKeySymbol
    \ BSpace
    \ BTab
    \ DC
    \ Down
    \ End
    \ Enter
    \ Escape
    \ F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12
    \ Home
    \ IC
    \ Left
    \ NPage
    \ PPage
    \ PageDown
    \ PageUp
    \ PgDn
    \ PgUp
    \ Right
    \ Space
    \ Tab
    \ Up

syntax match tmuxMiscCmds /run\%(-shell\)\=/ display
syntax match tmuxBindingCmds /\%(un\)\=bind\%(-key\)\=/ display
syntax match tmuxOptsSet /set\%(-option\)\=/ display
syntax match tmuxOptsSetw /\%(setw\|set-window-option\)/ display

# Why the `skip` argument?{{{
#
# Because of this undocumented syntax:
#
#                         v
#     # some tmux comment \
#     this second line is still considered commented by tmux!!!
#
# This  is because  tmux joins  continuation  lines, *then*  checks whether  the
# resulting line is commented:
# https://github.com/tmux/tmux/issues/75#issuecomment-130452290
#
# I don't want to wrongly think that a  line of code is sourced, while in effect
# it is *not*.
#}}}
# Why the `keepend` argument?{{{
#
# To  prevent  a  commented  codeblock  from continuing  on  the  next  line  of
# uncommented code:
#
#     #     x
#     set -s default-terminal tmux-256color
#
# In this example, without `keepend`, the `set` line would be wrongly commented.
#}}}
#   Does it cause an issue?{{{
#
# Yes.
#
# Because of it, a commented list item stops after the first line:
#
#     + the start of this list item is correctly highlighted
#       but the next line is not (it's highlighted as a commented code block)
#
# It's  an  acceptable issue:  don't  use  a list  in  a  tmux comment,  or  use
# single-line items only.
#
# ---
#
# If you think you can fix this issue, test your solution against this text:
#
#     #    - list item
#     #      continuation of list item
#
#     #     codeblock
#     command
#
#     # comment \
#     continuation of comment
#}}}
#   Why other similar syntax groups like `shComment` don't need `keepend`?{{{
#
# `shComment` is a match, so no issue.
# But `tmuxComment` *must* be a region, because we need `skip`.
#}}}
syntax region tmuxComment start=/#/ skip=/\\\@1<!\\$/ end=/$/ contains=tmuxTodo,tmuxURL,@Spell keepend

syntax keyword tmuxTodo FIXME NOTE TODO XXX todo contained

syntax match tmuxKey               /\(C-\|M-\|\^\)\+\S\+/  display
syntax match tmuxKey               /\%(^\s*\%(un\)\=bind\%(-key\)\=\s\+\%(\%(-T\s\+\%(copy-mode-vi\|copy-mode\|root\)\|-r\)\s\+\)\=\)\@<=\S\+/ display
syntax match tmuxNumber            /\<[+-]\=\d\+/          display
syntax match tmuxSelWindowOption   /:[!+-]\=/              display
syntax match tmuxOptions           /\s-\a\+/               display
syntax match tmuxVariable          /\w\+=/                 display
syntax match tmuxVariableExpansion /\${\=\w\+}\=/          display
syntax match tmuxAdditionalCommand /\\;/ display

syntax match tmuxKeyTable /\s\%(-T\)\=\(copy-mode-vi\|copy-mode\|root\)/ display

syntax match tmuxColor /\(bright\)\=\(black\|red\|green\|yellow\|blue\|magenta\|cyan\|white\)/ display
syntax match tmuxColor /default/        display
syntax match tmuxColor /colour\d\{1,3}/ display
syntax match tmuxColor /#\x\{6}/        display

# Why `-\@1<!`?{{{
#
# Because of the `search-reverse` command.
#
#     send -X search-reverse
#                    ^-----^
#                    we don't want that to be highlighted by `tmuxStyle`
#}}}
syntax match tmuxStyle /\(no\)\=\(bright\|bold\|dim\|underscore\|blink\|-\@1<!reverse\|hidden\|italics\)/ display

syntax match tmuxPromptInpol /%\d\|%%%\=/ contained

# Matching `man 3 strftime` formats
syntax match tmuxDateInpol /%[0_^#-]\=[A-DF-IMR-Z+]/     contained
syntax match tmuxDateInpol /%[0_^#-]\=[a-eghj-npr-z]/    contained
syntax match tmuxDateInpol /%[0_^#-]\=E[cCxXyY]/         contained
syntax match tmuxDateInpol /%[0_^#-]\=O[BdeHImMSuUVwWy]/ contained

# Format aliases
syntax match tmuxFmtAlias /#[HhDPTSFIW#]/ contained

# Format interpolation
syntax region tmuxFmtInpol
    \ matchgroup=tmuxFmtInpolDelimiter
    \ start=/#{/ end=/}/
    \ contained
    \ contains=
    \     tmuxFmtConditional,
    \     tmuxFmtInpol,
    \     tmuxFmtLimit,
    \     tmuxFmtVariable
syntax match  tmuxFmtVariable    /[[:alnum:]_-]\+/ contained display
syntax match  tmuxFmtConditional /[?,]/            contained display
syntax match  tmuxFmtLimit       /=.\{-}:/         contained display contains=tmuxNumber

# Attribute interpolation
syntax region tmuxAttrInpol matchgroup=tmuxAttrInpolDelimiter start=/#\[/ skip=/#\[.\{-}]/ end=/]/ contained keepend contains=tmuxColor,tmuxAttrBgFg,tmuxAttrEquals,tmuxAttrSeparator,tmuxStyle
syntax match  tmuxAttrBgFg      /[fb]g/ contained display
syntax match  tmuxAttrEquals    /=/     contained display
syntax match  tmuxAttrSeparator /,/     contained display

# Shell command interpolation
syntax region tmuxShellInpol matchgroup=tmuxShellInpolDelimiter start=/#(/ skip=/#(.\{-})/ end=/)/ contained keepend

syntax region tmuxString matchgroup=tmuxStringDelimiter start=/"/ skip=/\\./ end=/"/ contains=tmuxFmtInpol,tmuxFmtAlias,tmuxAttrInpol,tmuxShellInpol,tmuxPromptInpol,tmuxDateInpol,@Spell display keepend
syntax region tmuxString matchgroup=tmuxStringDelimiter start=/'/ end=/'/            contains=tmuxFmtInpol,tmuxFmtAlias,tmuxAttrInpol,tmuxShellInpol,tmuxPromptInpol,tmuxDateInpol,@Spell display keepend

highlight default link tmuxHookCmds            Statement

highlight default link tmuxAction              Boolean
highlight default link tmuxBoolean             Boolean
highlight default link tmuxOptionValue         Constant
highlight default link tmuxLayoutOptionValue   Constant

highlight default link tmuxClientSessionCmds   Statement
highlight default link tmuxWindowPaneCmds      Statement
highlight default link tmuxBindingCmds         Statement
highlight default link tmuxEnvironmentCmds     Statement
highlight default link tmuxStatusLineCmds      Statement
highlight default link tmuxBufferCmds          Statement
highlight default link tmuxMiscCmds            Statement

highlight default link tmuxComment             Comment
highlight default link tmuxKey                 Special
highlight default link tmuxKeySymbol           Special
highlight default link tmuxNumber              Number
highlight default link tmuxSelWindowOption     Number
highlight default link tmuxOptions             Operator
highlight default link tmuxOptsSet             Statement
highlight default link tmuxUserOptsSet         Identifier
highlight default link tmuxOptsSetw            PreProc
highlight default link tmuxKeyTable            PreProc
highlight default link tmuxModeCmds            Statement
highlight default link tmuxString              String
highlight default link tmuxStringDelimiter     Delimiter
highlight default link tmuxColor               Constant
highlight default link tmuxStyle               Constant

highlight default link tmuxPromptInpol         Special
highlight default link tmuxDateInpol           Special
highlight default link tmuxFmtAlias            Special
highlight default link tmuxFmtVariable         Constant
highlight default link tmuxFmtConditional      Conditional
highlight default link tmuxFmtLimit            Operator
highlight default link tmuxAttrBgFg            Constant
highlight default link tmuxAttrEquals          Operator
highlight default link tmuxAttrSeparator       Operator
highlight default link tmuxShellInpol          String
highlight default link tmuxFmtInpolDelimiter   Delimiter
highlight default link tmuxAttrInpolDelimiter  Delimiter
highlight default link tmuxShellInpolDelimiter Delimiter

highlight default link tmuxTodo                Todo
highlight default link tmuxVariable            Constant
highlight default link tmuxVariableExpansion   Constant
highlight default link tmuxAdditionalCommand   Special

b:current_syntax = 'tmux'
