vim9script noclear

if stridx(&runtimepath, '/vim9asm,') == -1
    finish
endif

g:vim9asm = {
    autofocus: true,
    autohint: true,
}
