vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/easy_align.vim'
import autoload 'repeat.vim'

# Declarations {{{1

var last_visual: list<any>

# Mappings {{{1

# Start interactive EasyAlign for a motion/text object (e.g. `gaip`)
nmap ga <Plug>(EasyAlign)

# Start interactive EasyAlign in visual mode (e.g. `vipga`)
xmap ga <Plug>(EasyAlign)

nnoremap <Plug>(EasyAlign) <ScriptCmd>&operatorfunc = EasyAlignOp<CR>g@
nnoremap <Plug>(LiveEasyAlign) <ScriptCmd>&operatorfunc = LiveEasyAlignOp<CR>g@
nnoremap <Plug>(EasyAlignRepeat) <ScriptCmd>EasyAlignRepeat()<CR>

# TODO: Try to use `<ScriptCmd>` here.
# TODO: Try to elimintate the `vim-repeat` dependency.
xnoremap <silent> <Plug>(EasyAlign) :<C-U>call <SID>EasyAlignOp(visualmode(), 1)<CR>
xnoremap <silent> <Plug>(LiveEasyAlign) :<C-U>call <SID>LiveEasyAlignOp(visualmode(), 1)<CR>
xnoremap <silent> <Plug>(EasyAlignRepeat) :<C-U>call <SID>RepeatInVisual()<CR>

# Ex Commands {{{1

command -nargs=* -range -bang EasyAlign easy_align.Align(<bang>0, 0, 'command', <q-args>, <line1>, <line2>)
command -nargs=* -range -bang LiveEasyAlign easy_align.Align(<bang>0, 1, 'command', <q-args>, <line1>, <line2>)

# Functions {{{1
def RememberVisual(mode: string) #{{{2
  last_visual = [
    mode,
    (line("'>") - line("'<"))->abs(),
    (col("'>") - col("'<"))->abs()
  ]
enddef

def RepeatVisual() #{{{2
  var mode: string
  var ldiff: number
  var cdiff: number
  [mode, ldiff, cdiff] = last_visual
  var cmd: string = 'normal! ' .. mode
  if ldiff > 0
    cmd ..= ldiff .. 'j'
  endif

  var ve_save: string = &l:virtualedit
  try
    if mode == "\<C-V>"
      if cdiff > 0
        cmd ..= cdiff .. 'l'
      endif
      setlocal virtualedit+=block
    endif
    execute cmd .. ":\<C-r>=get(g:, 'easy_align_last_command', '')\<CR>\<CR>"
    SetRepeat()
  finally
    if ve_save != &l:virtualedit
      &l:virtualedit = ve_save
    endif
  endtry
enddef

def RepeatInVisual() #{{{2
  if exists('g:easy_align_last_command')
    visualmode()->RememberVisual()
    RepeatVisual()
  endif
enddef

def SetRepeat() #{{{2
  silent! repeat.Set("\<Plug>(EasyAlignRepeat)")
enddef

def GenericEasyAlignOp(type: string, arg_vmode: bool, live: bool) #{{{2
  if !&modifiable
    if arg_vmode
      normal! gv
    endif
    return
  endif
  var sel_save: string = &selection
  &selection = "inclusive"

  var range: string
  var l1: number
  var l2: number
  var vmode: string
  if arg_vmode
    vmode = type
    range = ":'<,'>"
    [l1, l2] = [line("'<"), line("'>")]
    RememberVisual(vmode)
  else
    vmode = ''
    range = ":'[,']"
    [l1, l2] = [line("'["), line("']")]
    last_visual = []
  endif

  try
    if get(g:, 'easy_align_need_repeat', false)
      execute range .. g:easy_align_last_command
    else
      easy_align.Align(0, live, vmode, '', l1, l2)
    endif
    SetRepeat()
  finally
    &selection = sel_save
  endtry
enddef

def EasyAlignOp(type: string, vmode = false) #{{{2
  GenericEasyAlignOp(type, vmode, false)
enddef

def LiveEasyAlignOp(type: string, vmode = false) #{{{2
  GenericEasyAlignOp(type, vmode, true)
enddef

def EasyAlignRepeat() #{{{2
  if !last_visual->empty()
    RepeatVisual()
  else
    try
      g:easy_align_need_repeat = true
      normal! .
    finally
      unlet! g:easy_align_need_repeat
    endtry
  endif
enddef
