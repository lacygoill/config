vim9script

if 'dirvish' != get(b:, 'current_syntax', 'dirvish')
  finish
endif

# Define once (per buffer).
if !exists('b:current_syntax')
  execute 'syntax match DirvishPathHead =.*/\ze[^/]\+/\?$= conceal'
  execute 'syntax match DirvishPathTail =[^/]\+/$='
endif

# Define (again). Other windows (different arglists) need the old definitions.
# Do these last, else they may be overridden (see :h syn-priority).
for p: string in argv()
  execute 'syntax match DirvishArg ,'
    .. p->fnamemodify(':p')->escape('[,*.^$~\') .. '$, contains=DirvishPathHead'
endfor

b:current_syntax = 'dirvish'
