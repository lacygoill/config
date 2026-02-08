vim9script

import autoload './util.vim'

def New(): dict<func>
  var s: dict<func>

  s.init = function(Init, [s])
  s.initpattern = function(Initpattern, [s])
  s.dosearch = function(Dosearch, [s])
  s.get_onscreen_searchpattern = function(GetOnscreenSearchpattern, [s])
  s.get_stopline = function(GetStopline, [s])
  s.hasmatches = function(Hasmatches, [s])

  return s
enddef

def Init(
  self: dict<any>,
  input: string,
  repeatmotion: number,
  reverse: bool
)

  self._input = input
  self._repeatmotion = repeatmotion
  self._reverse = reverse
  # search pattern modifiers (case-sensitivity, magic)
  self.prefix = GetCs(input, g:sneak#opt.use_ic_scs) .. '\V'
  # the escaped user input to search for
  self.search = substitute(escape(input, '"\'), '\a', '\\[[=\0=]]', 'g')
  # example: highlight string 'ab' after line 42, column 5
  #          matchadd('foo', 'ab\%>42l\%5c', 1)
  self.match_pattern = ''
  # do not wrap                     search backward
  self._search_options = 'W' .. (reverse ? 'b' : '')
  self.search_options_no_s = self._search_options
  # save the jump on the initial invocation, _not_ repeats or consecutive invocations.
  if !repeatmotion && !g:SneakIsSneaking()
    self._search_options ..= 's'
  endif
enddef

def Initpattern(self: dict<any>)
  self._searchpattern = (self.prefix) .. (self.match_pattern) .. '\zs' .. (self.search)
enddef

def Dosearch(
  self: dict<any>,
  ...extra_search_options: list<string>
): list<number>

  return searchpos(self._searchpattern,
    self._search_options .. (extra_search_options->empty() ? '' : extra_search_options[0]),
    0
  )
enddef

def GetOnscreenSearchpattern(_, w: dict<number>): string
  if &wrap
    return ''
  endif
  var wincol_lhs: number = w.leftcol # this is actually just to the _left_ of the first onscreen column.
  var wincol_rhs: number = 2 + (winwidth(0) - util.Wincol1()) + wincol_lhs
  # restrict search to window
  return '\%>' .. (wincol_lhs) .. 'v' .. '\%<' .. (wincol_rhs + 1) .. 'v'
enddef

def GetStopline(self: dict<any>): number
  return self._reverse ? line('w0') : line('w$')
enddef

# returns 1 if there are n _on-screen_ matches in the search direction.
def Hasmatches(self: dict<any>, n: number): bool
  var w: dict<number> = winsaveview()
  var searchpattern: string = (self._searchpattern) .. (self.get_onscreen_searchpattern(w))
  var visiblematches: number
  while true
    var matchpos: list<number> = searchpos(searchpattern, self.search_options_no_s, self.get_stopline())
    if 0 == matchpos[0] # no more matches
      break
    elseif 0 != util.SkipFold(matchpos[0], self._reverse)
      continue
    endif
    ++visiblematches
    if visiblematches == n
      break
    endif
  endwhile
  winrestview(w)
  return visiblematches >= n
enddef

# gets the case sensitivity modifier for the search
def GetCs(input: string, use_ic_scs: bool): string
  if !use_ic_scs
  || !&ignorecase
  || (&smartcase && util.HasUpper(input))
    return '\C'
  endif
  return '\c'
enddef

# search object singleton
g:sneak#search#instance = New()
