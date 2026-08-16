vim9script

import autoload './util.vim'

# NOTES:
#   problem:  cchar cannot be more than 1 character.
#   strategy: make fg/bg the same color, then conceal the other char.
#
#   problem:  [before 7.4.792] keyword highlight takes priority over conceal.
#   strategy: syntax clear | [do the conceal] | &syntax = opts_save.syntax

g:sneak#target_labels = get(g:, 'sneak#target_labels', ";sftunq/SFGHLTUNRMQZ?0")

var matchmap: dict<list<number>>
var match_ids: list<number>
var orig_conceal_matches: list<dict<any>>

def Placematch(c: string, pos: list<number>)
  matchmap[c] = pos
  var pat: string = '\%' .. pos[0] .. 'l\%' .. pos[1] .. 'c.'
  var id: number = matchadd('Conceal', pat, 999, -1, {conceal: c})
  add(match_ids, id)
enddef

def SaveConcealMatches()
  for m: dict<any> in getmatches()
    if m.group == 'Conceal'
      add(orig_conceal_matches, m)
      silent! matchdelete(m.id)
    endif
  endfor
enddef

def RestoreConcealMatches()
  for m: dict<any> in orig_conceal_matches
    var d: dict<number>
    if has_key(m, 'conceal') | d.conceal = m.conceal | endif
    if has_key(m, 'window') | d.window = m.window | endif
    silent! matchadd(m.group, m.pattern, m.priority, m.id, d)
  endfor
  orig_conceal_matches = []
enddef

export def To(s: dict<any>, v: bool): string
  var seq: string
  while true
    var choice: string = DoLabel(s, v, s._reverse)
    seq ..= choice
    if choice =~ "^\<S-Tab>\\|\<BS>$"
      s.init(s._input, s._repeatmotion, true)
    elseif choice == "\<Tab>"
      s.init(s._input, s._repeatmotion, false)
    else
      return seq
    endif
  endwhile
  return ''
enddef

def DoLabel(
  s: dict<any>,
  v: bool,
  reverse: bool
): string

  var w: dict<number> = winsaveview()
  Before()
  var search_pattern: string = (s.prefix) .. (s.search) .. (s.get_onscreen_searchpattern(w))

  var i: number
  # position of the next match (if any) after we have run out of target labels.
  var overflow: list<number> = [0, 0]
  while true
    # searchpos() is faster than 'norm! /'
    var p: list<number> = searchpos(search_pattern, s.search_options_no_s, s.get_stopline())
    var skippedfold: number = util.SkipFold(p[0], reverse) # Note: 'set foldopen-=search' does not affect search().

    if 0 == p[0] || -1 == skippedfold
      break
    elseif 1 == skippedfold
      continue
    endif

    if i < maxmarks
      var c: string = strcharpart(g:sneak#target_labels, i, 1)
      Placematch(c, p)
    else # we have exhausted the target labels; grab the first non-labeled match.
      overflow = p
      break
    endif

    ++i
  endwhile

  winrestview(w)
  redraw
  var choice: string = util.GetChar()
  After()

  var mappedto: string = maparg(choice, v ? 'x' : 'n')
  var mappedtoNext: bool = (g:sneak#opt.absolute_dir && reverse)
        ? mappedto =~ '<Plug>Sneak\(_,\|Previous\)'
        : mappedto =~ '<Plug>Sneak\(_;\|Next\)'

  if choice =~ "\\v^\<Tab>|\<S-Tab>|\<BS>$"  # Decorate next N matches.
    if (!reverse && choice == "\<Tab>") || (reverse && choice =~ "^\<S-Tab>\\|\<BS>$")
      cursor(overflow[0], overflow[1])
    endif  # ...else we just switched directions, do not overflow.
  elseif (g:sneak#opt.label_esc != '' && choice == g:sneak#opt.label_esc)
      || -1 != ["\<Esc>", "\<C-c>"]->index(choice)
    return "\<Esc>" # exit label-mode.
  elseif !mappedtoNext && !matchmap->has_key(choice) # press *any* invalid key to escape.
    return "\<Esc>"  # Exit label-mode.
  elseif !mappedtoNext && !matchmap->has_key(choice)  # Fallthrough: press *any* invalid key to escape.
    util.Removehl()
    feedkeys(choice)  # Exit label-mode, fall through to Vim.
  else # valid target was selected
    var p: list<number> = mappedtoNext
      ? matchmap[strcharpart(g:sneak#target_labels, 0, 1)]
      : matchmap[choice]
    cursor(p[0], p[1])
  endif

  return choice
enddef

def After()
  autocmd! sneak_label_cleanup
  try
    matchdelete(sneak_cursor_hl)
  catch
  endtry
  for id: number in match_ids
    matchdelete(id)
  endfor
  match_ids = []
  # remove temporary highlight links
  execute 'highlight! link Conceal ' .. orig_hl_conceal
  RestoreConcealMatches()
  execute 'highlight! link Sneak ' .. orig_hl_sneak

  [&l:concealcursor, &l:conceallevel] = [opts_save.cocu, opts_save.cole]
enddef

var opts_save: dict<any> = {
  cocu: '',
  cole: 0,
  fdm: '',
  spell: false,
  spelllang: '',
  synmaxcol: 0,
  syntax: ''
}
var orig_hl_sneak: string
var orig_hl_conceal: string
var sneak_cursor_hl: number
def Before()
  matchmap = {}
  for name: string in opts_save->keys()
    opts_save[name] = eval('&l:' .. name)
  endfor

  setlocal concealcursor=ncv conceallevel=2

  # Highlight the cursor location (because cursor is hidden during getchar()).
  sneak_cursor_hl = matchadd("SneakScope", '\%#', 11, -1)

  orig_hl_conceal = util.LinksTo('Conceal')
  SaveConcealMatches()
  orig_hl_sneak = util.LinksTo('Sneak')
  # set temporary link to our custom 'conceal' highlight
  highlight! link Conceal SneakLabel
  # set temporary link to hide the sneak search targets
  highlight! link Sneak SneakLabelMask

  augroup sneak_label_cleanup
    autocmd!
    autocmd CursorMoved * After()
  augroup END
enddef

# returns `true` if `key` is invisible or special.
def IsSpecialKey(key: string): bool
  return -1 != ["\<Esc>", "\<C-c>", "\<Space>", "\<CR>", "\<Tab>"]->index(key)
    || maparg(key, 'n') =~ '<Plug>Sneak\(_;\|_,\|Next\|Previous\)'
    || (g:sneak#opt.s_next && maparg(key, 'n') =~ '<Plug>Sneak\(_s\|Forward\)')
enddef

# We must do this because:
#  - Don't know which keys the user assigned to Sneak_;/Sneak_,
#  - Must reserve special keys like <Esc> and <Tab>
def SanitizeTargetLabels()
  var nrbytes: number = g:sneak#target_labels->len()
  var i: number
  while i < nrbytes
    # Intentionally using byte-index for use with substitute().
    var k: string = g:sneak#target_labels->strpart(i, 1)
    if IsSpecialKey(k) # remove the char
      g:sneak#target_labels = g:sneak#target_labels
        ->substitute('\%' .. (i + 1) .. 'c.', '', '')
      # Move ; (or s if 'clever-s' is enabled) to the front.
      if !g:sneak#opt.absolute_dir
            && ((!g:sneak#opt.s_next && maparg(k, 'n') =~ '<Plug>Sneak\(_;\|Next\)')
                || (maparg(k, 'n') =~ '<Plug>Sneak\(_s\|Forward\)'))
        g:sneak#target_labels = k .. g:sneak#target_labels
      else
        --nrbytes
        continue
      endif
    endif
    ++i
  endwhile
enddef

SanitizeTargetLabels()
var maxmarks: number = strwidth(g:sneak#target_labels)
