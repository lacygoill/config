vim9script noclear

if exists('loaded') || stridx(&runtimepath, '/dirvish,') == -1
    finish
endif
var loaded = true

const g:dirvish_mode = ':call fex#FormatEntries()'
