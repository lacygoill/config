vim9script noclear

if exists('loaded') || stridx(&runtimepath, '/exchange,') == -1
    finish
endif
var loaded = true

# We want linewise exchanges to be re-indented with `==`.
# For more info: `:help g:exchange_indent`.

g:exchange_indent = '=='
