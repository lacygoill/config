vim9script

syntax keyword aptconfUnattendedUpgrade Allowed-Origins Update-Days contained

# `man apt.conf /SYNTAX/;/#clear`
syntax match aptconfClearCommand /^#clear\s\+.*/ containedin=aptconfComment
highlight default link aptconfClearCommand PreProc
