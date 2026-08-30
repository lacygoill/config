vim9script

# Init {{{1

var slive: bool

var easy_align_delimiters_default: dict<dict<any>> = {
  ' ': {
    pattern: ' ',
    left_margin: 0,
    right_margin: 0,
    stick_to_left: 0
  },
  '=': {
    pattern: '===\|<=>\|\(&&\|||\|<<\|>>\)=\|=\~[#?]\?\|=>\|[:+/*!%^=><&|.?-]\?=[#?]\?',
    left_margin: 1,
    right_margin: 1,
    stick_to_left: 0
  },
  ':': {
    pattern: ':',
    left_margin: 0,
    right_margin: 1,
    stick_to_left: 1
  },
  ',': {
    pattern: ',',
    left_margin: 0,
    right_margin: 1,
    stick_to_left: 1
  },
  '|': {
    pattern: '|',
    left_margin: 1,
    right_margin: 1,
    stick_to_left: 0
  },
  '.': {
    pattern: '\.',
    left_margin: 0,
    right_margin: 0,
    stick_to_left: 0
  },
  '#': {
    pattern: '#\+',
    delimiter_align: 'l',
    ignore_groups: ['!Comment']
  },
  '"': {
    pattern: '"\+',
    delimiter_align: 'l',
    ignore_groups: ['!Comment']
  },
  '&': {
    pattern: '\\\@<!&\|\\\\',
    left_margin: 1,
    right_margin: 1,
    stick_to_left: 0
  },
  '{': {
    pattern: '(\@<!{',
    left_margin: 1,
    right_margin: 1,
    stick_to_left: 0
  },
  '}': {
    pattern: '}',
    left_margin: 1,
    right_margin: 0,
    stick_to_left: 0
  }
}

var mode_labels: dict<string> = {
  l: '',
  r: '[R]',
  c: '[C]'
}

var known_options: dict<list<number>> = {
  margin_left: [0, 1],
  margin_right: [0, 1],
  stick_to_left: [0],
  left_margin: [0, 1],
  right_margin: [0, 1],
  indentation: [1],
  ignore_groups: [3],
  ignore_unmatched: [0],
  delimiter_align: [1],
  mode_sequence: [1],
  ignores: [3],
  filter: [1],
  align: [1]
}

var option_values: dict<list<any>> = {
  indentation: ['shallow', 'deep', 'none', 'keep', -1],
  delimiter_align: ['left', 'center', 'right', -1],
  ignore_unmatched: [0, 1, -1],
  ignore_groups: [[], ['String'], ['Comment'], ['String', 'Comment'], -1]
}

var shorthand: dict<string> = {
  margin_left: 'lm',
  margin_right: 'rm',
  stick_to_left: 'stl',
  left_margin: 'lm',
  right_margin: 'rm',
  indentation: 'idt',
  ignore_groups: 'ig',
  ignore_unmatched: 'iu',
  delimiter_align: 'da',
  mode_sequence: 'a',
  ignores: 'ig',
  filter: 'f',
  align: 'a'
}

var shorthand_regex: string =
  '\s*\%('
    .. '\(lm\?[0-9]\+\)\|\(rm\?[0-9]\+\)\|\(iu[01]\)\|\(\%(s\%(tl\)\?[01]\)\|[<>]\)\|'
    .. '\(da\?[clr]\)\|\(\%(ms\?\|a\)[lrc*]\+\)\|\(i\%(dt\)\?[kdsn]\)\|\([gv]/.*/\)\|\(ig\[.*\]\)'
    .. '\)\+\s*$'

# Functions {{{1
# Interface {{{2
export def Align( #{{{3
  bang: bool,
  live: bool,
  visualmode: string,
  expr: string,
  line1: number,
  line2: number
)

  try
    AlignImpl(bang, live, visualmode, line1, line2, expr)
  catch /^\%(Vim:Interrupt\|exit\)$/
    if empty(visualmode)
      echon "\r"
      echon "\r"
    else
      normal! gv
    endif
  endtry
enddef
#}}}2
# Core {{{2
def Ceil2(v: number): number #{{{3
  return v % 2 == 0 ? v : v + 1
enddef

def Floor2(v: number): number #{{{3
  return v % 2 == 0 ? v : v - 1
enddef

def HighlightedAs( #{{{3
  line: number,
  col: number,
  groups: list<string>
): bool

  if empty(groups)
    return false
  endif
  var hl: string = synIDattr(synID(line, col, false), 'name')
  for grp: string in groups
    if grp[0] == '!'
      if hl !~ grp[1 : -1]
        return 1
      endif
    elseif hl =~ grp
      return true
    endif
  endfor
  return false
enddef

def IgnoredSyntax(): list<string> #{{{3
  if has('syntax_items')
    # Backward-compatibility
    return get(g:, 'easy_align_ignore_groups',
            get(g:, 'easy_align_ignores',
              (get(g:, 'easy_align_ignore_comment', 1) == 0) ?
                ['String'] : ['String', 'Comment']))
  endif
  return []
enddef

def Echon_(tokens: list<list<string>>) #{{{3
  # http://vim.wikia.com/wiki/How_to_print_full_screen_width_messages
  var xy: list<bool> = [&ruler, &showcmd]
  try
    set noruler noshowcmd

    var winlen: number = winwidth(winnr()) - 2
    var len: number = copy(tokens)
      ->map((_, v: list<string>): string => v[1])
      ->join('')
      ->len()
    var ellipsis: string = len > winlen ? '..' : ''

    echon "\r"
    var yet: number
    for [hl: string, msg: string] in tokens
      if empty(msg)
        continue
      endif
      execute 'echohl ' .. hl
      yet += len(msg)
      if yet > winlen - len(ellipsis)
        echon msg[ 0 : (winlen - len(ellipsis) - yet - 1) ] .. ellipsis
        break
      else
        echon msg
      endif
    endfor
  finally
    echohl None
    [&ruler, &showcmd] = xy
  endtry
enddef

def Echon( #{{{3
  l: string,
  n: string,
  r: number,
  d: string,
  o: dict<any>,
  warn: string
): string

  var tokens: list<list<string>> = [
    ['Function', slive ? ':LiveEasyAlign' : ':EasyAlign'],
    ['ModeMsg', get(mode_labels, l, l)],
    ['None', ' ']
  ]

  if r == -1
    tokens->add(['Comment', '('])
  endif
  tokens->add([n =~ '*' ? 'Repeat' : 'Number', n])
  extend(tokens, r == 1 ?
  [['Delimiter', '/'], ['String', d], ['Delimiter', '/']] :
  [['Identifier', d == ' ' ? '\ ' : (d == '\' ? '\\' : d)]])

  if r == -1
    extend(tokens, [['Normal', '_'], ['Comment', ')']])
  endif
  tokens->add(['Statement', empty(o) ? '' : ' ' .. string(o)])
  if !empty(warn)
    tokens->add(['WarningMsg', ' (' .. warn .. ')'])
  endif

  Echon_(tokens)
  return tokens
    ->mapnew((_, v: list<string>): string => v[1])
    ->join('')
enddef

def Exit(msg: string) #{{{3
  Echon_([['ErrorMsg', msg]])
  throw 'exit'
enddef

def Ltrim(str: string): string #{{{3
  return substitute(str, '^\s\+', '', '')
enddef

def Rtrim(str: string): string #{{{3
  return substitute(str, '\s\+$', '', '')
enddef

def Trim(str: string): string #{{{3
  return substitute(str, '^\s*\(.\{-}\)\s*$', '\1', '')
enddef

def FuzzyLu(arg_key: string): string #{{{3
  if has_key(known_options, arg_key)
    return arg_key
  endif
  var key: string = tolower(arg_key)

  # stl -> ^s.*_t.*_l.*
  var regexp1: string = '^' .. key[0] .. '.*' .. key[1 : -1]->substitute('\(.\)', '_\1.*', 'g')
  var matches: list<string> = keys(known_options)->filter((_, v: string): bool => v =~ regexp1)
  if len(matches) == 1
    return matches[0]
  endif

  # stl -> ^s.*t.*l.*
  var regexp2: string = '^' .. substitute(key, '-', '_', 'g')
    ->substitute('\(.\)', '\1.*', 'g')
  matches = keys(known_options)
    ->filter((_, v: string): bool => v =~ regexp2)

  if empty(matches)
    Exit("Unknown option key: " .. arg_key)
  elseif len(matches) == 1
    return matches[0]
  else
    # Avoid ambiguity introduced by deprecated margin_left and margin_right
    if sort(matches) == ['margin_left', 'margin_right', 'mode_sequence']
      return 'mode_sequence'
    endif
    if sort(matches) == ['ignore_groups', 'ignores']
      return 'ignore_groups'
    endif
    Exit('Ambiguous option key: ' .. arg_key .. ' (' .. matches->join(', ') .. ')')
  endif
  return ''
enddef

def Shift(modes: list<any>, cycle: bool): any #{{{3
  var item: any = modes->remove(0)
  if cycle || empty(modes)
    modes->add(item)
  endif
  return item
enddef

def NormalizeOptions(opts: dict<any>): dict<any> #{{{3
  var ret: dict<any>
  for k: string in keys(opts)
    var v: any = opts[k]
    var kk = FuzzyLu(k)
    # Backward-compatibility
    if kk == 'margin_left'   | kk = 'left_margin'  | endif
    if kk == 'margin_right'  | kk = 'right_margin' | endif
    if kk == 'mode_sequence' | kk = 'align'        | endif
    ret[kk] = v
  endfor
  return ValidateOptions(ret)
enddef

def CompactOptions(opts: dict<any>): dict<any> #{{{3
  var ret: dict<any>
  for k: string in keys(opts)
    ret[shorthand[k]] = opts[k]
  endfor
  return ret
enddef

def ValidateOptions(opts: dict<any>): dict<any> #{{{3
  for k: string in keys(opts)
    var v: any = opts[k]
    if known_options[k]->index(type(v)) == -1
      Exit('Invalid type for option: ' .. k)
    endif
  endfor
  return opts
enddef

def SplitLine( #{{{3
  line: number,
  nth: number,
  modes: list<string>,
  cycle: bool,
  fc: number,
  lc: number,
  arg_pattern: string,
  stick_to_left: number,
  ignore_unmatched: number,
  ignore_groups: list<string>
): list<list<string>>

  var mode: string = ''

  var string: string = lc != 0 ?
      getline(line)->strpart(fc - 1, lc - fc + 1) :
      getline(line)->strpart(fc - 1)
  var idx: number = 0
  var nomagic: bool = arg_pattern->match('\\v') > arg_pattern->match('\C\\[mMV]')
  var pattern: string = '^.\{-}\s*\zs\(' .. arg_pattern .. (nomagic ? ')' : '\)')
  var tokens: list<string>
  var delims: list<string>

  # Phase 1: split
  var ignorable: bool
  var token: string
  var phantom: bool
  var pmode: string
  while true
    var matchidx: number = string->match(pattern, idx)
    # No match
    if matchidx < 0
      break
    endif
    var matchend: number = string->matchend(pattern, idx)
    var spaces: string = string->matchstr(
      '\s' .. (stick_to_left ? '*' : '\{-}'),
      matchend + (matchidx == matchend ? 1 : 0)
    )

    var match: string
    var part: string
    var delim: string
    # Match, but empty
    if len(spaces) + matchend - idx == 0
      var char: string = string->strpart(idx, 1)
      if empty(char)
        break
      endif
      [match, part, delim] = [char, char, '']
    # Match
    else
      match = string->strpart(idx, matchend - idx + len(spaces))
      part = string->strpart(idx, matchidx - idx)
      delim = string->strpart(matchidx, matchend - matchidx)
    endif

    ignorable = HighlightedAs(line, idx + len(part) + fc, ignore_groups)
    if ignorable
      token ..= match
    else
      [pmode, mode] = [mode, Shift(modes, cycle)]
      tokens->add(token .. match)
      delims->add(delim)
      token = ''
    endif

    idx += len(match)

    # If the string is non-empty and ends with the delimiter,
    # append an empty token to the list
    if idx == len(string)
      phantom = true
      break
    endif
  endwhile

  var leftover: string = token .. strpart(string, idx)
  if !empty(leftover)
    ignorable = HighlightedAs(line, len(string) + fc - 1, ignore_groups)
    tokens->add(leftover)
    delims->add('')
  elseif phantom
    tokens->add('')
    delims->add('')
  endif
  [pmode, mode] = [mode, Shift(modes, cycle)]

  # Preserve indentation - merge first two tokens
  if len(tokens) > 1 && tokens[0]->Rtrim()->empty()
    tokens[1] = tokens[0] .. tokens[1]
    tokens->remove(0)
    delims->remove(0)
    mode = pmode
  endif

  # Skip comment line
  if ignorable && len(tokens) == 1 && ignore_unmatched != 0
    tokens = []
    delims = []
  # Append an empty item to enable right/center alignment of the last token
  # - if the last token is not ignorable or ignorable but not the only token
  elseif ignore_unmatched != 1          &&
          (mode ==? 'r' || mode ==? 'c')  &&
          (!ignorable || len(tokens) > 1) &&
          nth >= 0 # includes -0
    tokens->add('')
    delims->add('')
  endif

  return [tokens, delims]
enddef

def DoAlign( #{{{3
  todo: dict<string>,
  modes: list<string>,
  all_tokens: dict<list<string>>,
  all_delims: dict<list<string>>,
  fl: number,
  ll: number,
  fc: number,
  lc: number,
  anth: number,
  recur: number,
  d: dict<any>
): list<any>

  var mode: string = modes[0]
  var lines: dict<list<any>>
  var min_indent: number = -1
  var max: dict<number> = {
    pivot_len2: 0,
    token_len: 0,
    just_len: 0,
    delim_len: 0,
    indent: 0,
    tokens: 0,
    strip_len: 0
  }
  var f: number
  var fx: string
  [f, fx] = ParseFilter(d.filter)

  # Phase 1
  for line: number in range(fl, ll)
    var snip: string = lc > 0 ? getline(line)[fc - 1 : lc - 1] : getline(line)
    if f == 1 && snip !~ fx
      continue
    elseif f == -1 && snip =~ fx
      continue
    endif

    var tokens: list<string>
    var delims: list<string>
    if !has_key(all_tokens, line)
      # Split line into the tokens by the delimiters
      [tokens, delims] = SplitLine(
           line, anth, copy(modes), recur == 2,
           fc, lc, d.pattern,
           d.stick_to_left, d.ignore_unmatched, d.ignore_groups)

      # Remember tokens for subsequent recursive calls
      all_tokens[line] = tokens
      all_delims[line] = delims
    else
      tokens = all_tokens[line]
      delims = all_delims[line]
    endif

    # Skip empty lines
    if empty(tokens)
      continue
    endif

    # Calculate the maximum number of tokens for a line within the range
    max.tokens = [max.tokens, len(tokens)]->max()

    var nth: number
    if anth > 0 # Positive N-th
      if len(tokens) < anth
        continue
      endif
      nth = anth - 1 # make it 0-based
    else # -0 or Negative N-th
      if anth == 0 && mode !=? 'l'
        nth = len(tokens) - 1
      else
        nth = len(tokens) + anth
      endif
      if empty(delims[len(delims) - 1])
        --nth
      endif

      if nth < 0 || nth == len(tokens)
        continue
      endif
    endif

    var prefix: string = nth > 0 ? join(tokens[0 : nth - 1], '') : ''
    var delim: string = delims[nth]
    var token: string = tokens[nth]->Rtrim()
    token = token->strpart(0, len(token) - Rtrim(delim)->len())->Rtrim()
    if empty(delim) && (tokens->len() <= nth + 1) && d.ignore_unmatched != 0
      continue
    endif

    var indent: number = matchstr(tokens[0], '^\s*')->strdisplaywidth()
    if min_indent < 0 || indent < min_indent
      min_indent = indent
    endif
    if mode ==? 'c'
      token ..= substitute(matchstr(token, '^\s*'), '\t', repeat(' ', &tabstop), 'g')
    endif
    var pw: number = prefix->strdisplaywidth()
    var tw: number = token->strdisplaywidth()
    max.indent = [max.indent, indent]->max()
    max.token_len = [max.token_len, tw]->max()
    max.just_len = [max.just_len,  pw + tw]->max()
    max.delim_len = [max.delim_len, strdisplaywidth(delim)]->max()

    if mode ==? 'c'
      var pivot_len2: number = pw * 2 + tw
      if max.pivot_len2 < pivot_len2
        max.pivot_len2 = pivot_len2
      endif
      max.strip_len = [max.strip_len, token->Trim()->strdisplaywidth()]->max()
    endif
    lines[line] = [nth, prefix, token, delim]
  endfor

  # Phase 1.5: indentation handling (only on nth == 1)
  if anth == 1
    var idt: string = d.indentation
    var indent: number
    if idt ==? 'd'
      indent = max.indent
    elseif idt ==? 's'
      indent = min_indent
    elseif idt ==? 'n'
      indent = 0
    elseif idt !=? 'k'
      Exit('Invalid indentation: ' .. idt)
    endif

    if idt !=? 'k'
      max.just_len = 0
      max.token_len = 0
      max.pivot_len2 = 0

      for [line: string, elems: list<any>] in items(lines)
        var prefix: string
        var token: string
        [_, prefix, token, _] = elems

        var tindent: string = token->matchstr('^\s*')
        while true
          var len: number = strdisplaywidth(tindent)
          if len < indent
            tindent ..= repeat(' ', indent - len)
            break
          elseif len > indent
            tindent = tindent[0 : -2]
          else
            break
          endif
        endwhile

        token = tindent .. Ltrim(token)
        if mode ==? 'c'
          token = token->substitute('\s*$', repeat(' ', indent), '')
        endif
        var pw: number = strdisplaywidth(prefix)
        var tw: number = strdisplaywidth(token)
        max.token_len = max([max.token_len, tw])
        max.just_len  = max([max.just_len,  pw + tw])
        if mode ==? 'c'
          var pivot_len2: number = pw * 2 + tw
          if max.pivot_len2 < pivot_len2
            max.pivot_len2 = pivot_len2
          endif
        endif

        lines[line][2] = token
      endfor
    endif
  endif

  # Phase 2
  for [line: string, elems: list<any>] in lines->items()
    var tokens: list<string> = all_tokens[line]
    var delims: list<string> = all_delims[line]
    var nth: number
    var prefix: string
    var token: string
    var delim: string
    [nth, prefix, token, delim] = elems

    # Remove the leading whitespaces of the next token
    if tokens->len() > nth + 1
      tokens[nth + 1] = tokens[nth + 1]->Ltrim()
    endif

    # Pad the token with spaces
    var pw: number = prefix->strdisplaywidth()
    var tw: number = token->strdisplaywidth()
    var rpad: string
    if mode ==? 'l'
      var pad: string = repeat(' ', max.just_len - pw - tw)
      if d.stick_to_left
        rpad = pad
      else
        token = token .. pad
      endif
    elseif mode ==? 'r'
      var pad: string = repeat(' ', max.just_len - pw - tw)
      var indent: string = token->matchstr('^\s*')
      token = indent .. pad .. token->Ltrim()
    elseif mode ==? 'c'
      var p1: number = max.pivot_len2 - (pw * 2 + tw)
      var p2: number = max.token_len - tw
      var pf1: number = Floor2(p1)
      if pf1 < p1 | p2 = Ceil2(p2)
      else        | p2 = Floor2(p2)
      endif
      var strip: number = Ceil2(max.token_len - max.strip_len) / 2
      var indent: string = token->matchstr('^\s*')
      token = indent .. repeat(' ', pf1 / 2) .. token->Ltrim() .. repeat(' ', p2 / 2)
      token = token->substitute(repeat(' ', strip) .. '$', '', '')

      if d.stick_to_left
        if Rtrim(token)->empty()
          var center: number = len(token) / 2
          [token, rpad] = [token->strpart(0, center), token->strpart(center)]
        else
          [token, rpad] = [token->Rtrim(), token->matchstr('\s*$')]
        endif
      endif
    endif
    tokens[nth] = token

    # Pad the delimiter
    var dpadl: number = max.delim_len - delim->strdisplaywidth()
    var da: string = d.delimiter_align
    var dl: string
    var dr: string
    if da ==? 'l'
      [dl, dr] = ['', repeat(' ', dpadl)]
    elseif da ==? 'c'
      dl = repeat(' ', dpadl / 2)
      dr = repeat(' ', dpadl - dpadl / 2)
    elseif da ==? 'r'
      [dl, dr] = [repeat(' ', dpadl), '']
    else
      Exit('Invalid delimiter_align: ' .. da)
    endif

    # Before and after the range (for blockwise visual mode)
    var cline: string = getline(line->str2nr())
    var before: string = cline->strpart(0, fc - 1)
    var after: string = lc != 0 ? cline->strpart(lc) : ''

    # Determine the left and right margin around the delimiter
    var rest: string = tokens[nth + 1 : -1]->join('')
    var nomore: bool = empty(rest .. after)
    var ml: string = (empty(prefix .. token) || empty(delim) && nomore) ? '' : d.ml
    var mr: string = nomore ? '' : d.mr

    # Adjust indentation of the lines starting with a delimiter
    var lpad: string
    if nth == 0
      var ipad: string = repeat(' ', min_indent - strdisplaywidth(token .. ml))
      if mode ==? 'l'
        token = ipad .. token
      else
        lpad = ipad
      endif
    endif

    # Align the token
    var aligned: string = [lpad, token, ml, dl, delim, dr, mr, rpad]->join('')
    tokens[nth] = aligned

    # Update the line
    todo[line] = before .. tokens->join('') .. after
  endfor

  if anth < max.tokens && (recur != 0 || len(modes) > 1)
    Shift(modes, recur == 2)
    return [todo, modes, all_tokens, all_delims,
            fl, ll, fc, lc, anth + 1, recur, d]
  endif
  return [todo]
enddef

def Input( #{{{3
  str: string,
  default: string,
  vis: bool
): string

  if vis
    normal! gv
    redraw
    execute "normal! \<esc>"
  else
    # EasyAlign command can be called without visual selection
    redraw
  endif
  return input(str, default)
enddef

def Atoi(str: string): any #{{{3
  return (str =~ '^[0-9]\+$') ? str2nr(str) : str
enddef

def ShiftOpts(opts: dict<any>, key: string, vals: list<any>) #{{{3
  var val: any = Shift(vals, true)
  if type(val) == 0 && val == -1
    opts->remove(key)
  else
    opts[key] = val
  endif
enddef

def Interactive( #{{{3
  range: list<number>,
  modes: list<string>,
  an: string,
  ad: string,
  aopts: dict<any>,
  rules: dict<dict<any>>,
  vis: bool,
  bvis: bool
): list<any>

  var mode: any = Shift(modes, true)
  var n: string = an
  var d: string = ad
  var ch: string
  var opts: dict<any> = CompactOptions(aopts)
  var vals: dict<list<any>> = deepcopy(option_values)
  var regx: number
  var warn: string
  var should_undo: bool
  var output: dict<any>
  var char: string

  while true
    # Live preview
    var rdrw: bool
    if should_undo
      silent! undo
      should_undo = false
      rdrw = true
    endif
    if slive && !empty(d)
      output = Process(range, mode, n, d, NormalizeOptions(opts), regx, rules, bvis)
      &undolevels = &undolevels # Close undo block
      UpdateLines(output.todo)
      should_undo = !empty(output.todo)
      rdrw = true
    endif
    if rdrw
      if vis
        normal! gv
      endif
      redraw
      if vis | execute "normal! \<Esc>" | endif
    endif
    Echon(mode, n, -1, regx ? '/' .. d .. '/' : d, opts, warn)

    var check: bool
    warn = ''

    try
      char = getcharstr()
    catch /^Vim:Interrupt$/
      char = "\<Esc>"
    endtry
    if char == "\<C-C>" || char == "\<Esc>"
      if should_undo
        silent! undo
      endif
      throw 'exit'
    elseif char == "\<BS>"
      if !empty(d)
        d = ''
        regx = 0
      elseif len(n) > 0
        n = strpart(n, 0, len(n) - 1)
      endif
    elseif char == "\<CR>"
      mode = Shift(modes, true)
      if opts->has_key('a')
        opts.a = mode .. strpart(opts.a, 1)
      endif
    elseif char == '-'
      if empty(n)      | n = '-'
      elseif n == '-'  | n = ''
      else             | check = true
      endif
    elseif char == '*'
      if empty(n)      | n = '*'
      elseif n == '*'  | n = '**'
      elseif n == '**' | n = ''
      else             | check = true
      endif
    elseif empty(d) && ((char == '0' && len(n) > 0) || char =~ '[1-9]')
      if n[0] == '*'   | check = true
      else             | n = n .. char
      endif
    elseif char == "\<C-D>"
      ShiftOpts(opts, 'da', vals['delimiter_align'])
    elseif char == "\<C-I>"
      ShiftOpts(opts, 'idt', vals['indentation'])
    elseif char == "\<C-L>"
      var lm: string = Input('Left margin: ', get(opts, 'lm', ''), vis)
      if empty(lm)
        warn = 'Set to default. Input 0 to remove it'
        silent! opts->remove('lm')
      else
        opts['lm'] = Atoi(lm)
      endif
    elseif char == "\<C-R>"
      var rm: string = Input('Right margin: ', get(opts, 'rm', ''), vis)
      if empty(rm)
        warn = 'Set to default. Input 0 to remove it'
        silent! opts->remove('rm')
      else
        opts['rm'] = Atoi(rm)
      endif
    elseif char == "\<C-U>"
      ShiftOpts(opts, 'iu', vals['ignore_unmatched'])
    elseif char == "\<C-G>"
      ShiftOpts(opts, 'ig', vals['ignore_groups'])
    elseif char == "\<C-P>"
      if slive
        if !empty(d)
          char = d
          break
        else
          slive = false
        endif
      else
        slive = true
      endif
    elseif char == "\<Left>"
      opts['stl'] = 1
      opts['lm']  = 0
    elseif char == "\<Right>"
      opts['stl'] = 0
      opts['lm']  = 1
    elseif char == "\<Down>"
      opts['lm']  = 0
      opts['rm']  = 0
    elseif char == "\<Up>"
      silent! opts->remove('stl')
      silent! opts->remove('lm')
      silent! opts->remove('rm')
    elseif char == "\<C-A>" || char == "\<C-O>"
      var bmodes: string = Input('Alignment ([lrc...][[*]*]): ', get(opts, 'a', mode), vis)
        ->tolower()
      if bmodes->match('^[lrc]\+\*\{0,2}$') != -1
        opts['a'] = bmodes
        mode = bmodes[0]
        while mode != Shift(modes, true)
        endwhile
      else
        silent! opts->remove('a')
      endif
    elseif char == "\<C-_>" || char == "\<C-X>"
      if slive && regx && !empty(d)
        break
      endif

      var prompt: string = 'Regular expression: '
      char = Input(prompt, '', vis)
      if !empty(char) && ValidRegexp(char)
        regx = 1
        d = char
        if !slive | break | endif
      else
        warn = 'Invalid regular expression: ' .. char
      endif
    elseif char == "\<C-F>"
      var f: string = Input('Filter (g/../ or v/../): ', get(opts, 'f', ''), vis)
      var m: list<string> = f->matchlist('^[gv]/\(.\{-}\)/\?$')
      if empty(f)
        silent! opts->remove('f')
      elseif !empty(m) && m[1]->ValidRegexp()
        opts['f'] = f
      else
        warn = 'Invalid filter expression'
      endif
    elseif char =~ '[[:print:]]'
      check = true
    else
      warn = 'Invalid character'
    endif

    if check
      if empty(d)
        if rules->has_key(char)
          d = char
          if !slive
            if vis
              execute "normal! gv\<Esc>"
            endif
            break
          endif
        else
          warn = 'Unknown delimiter key: ' .. char
        endif
      else
        if regx
          warn = 'Press <CTRL-X> to finish'
        else
          if d == char
            break
          else
            warn = 'Press ''' .. d .. ''' again to finish'
          endif
        endif
      endif
    endif
  endwhile
  if slive
    var copts: dict<any> = call(Summarize, output.summarize)
    slive = false
    g:easy_align_last_command = Echon('', n, regx, d, copts, '')
    slive = true
  endif
  return [mode, n, char, opts, regx]
enddef

def ValidRegexp(regexp: string): bool #{{{3
  try
    matchlist('', regexp)
  catch
    return false
  endtry
  return true
enddef

def TestRegexp(arg_regexp: string): string #{{{3
  var regexp: string = empty(arg_regexp) ? @/ : arg_regexp
  if !ValidRegexp(regexp)
    Exit('Invalid regular expression: ' .. regexp)
  endif
  return regexp
enddef

def ParseShorthandOpts(arg_expr: string): dict<any> #{{{3
  var opts: dict<any>
  var expr: string = arg_expr->substitute('\s', '', 'g')
  var regex: string = '^' .. shorthand_regex

  if empty(expr)
    return opts
  endif
  if expr !~ regex
    Exit('Invalid expression: ' .. arg_expr)
  else
    var match: list<string> = expr->matchlist(regex)
    var keys: list<string> =<< trim END
      lm
      rm
      l
      r
      stl
      s
      <
      >
      iu
      da
      d
      ms
      m
      ig
      i
      g
      v
      a
    END
    for m: string in match[ 1 : -1 ]
        ->filter((_, v: string): bool => !empty(v))
      for ikey: string in keys
        var key: string = ikey
        if tolower(m)->stridx(key) == 0
          var rest: string = m->strpart(len(key))
          if key == 'i'
            key = 'idt'
          endif
          if key == 'g' || key == 'v'
            rest = key .. rest
            key = 'f'
          endif

          if key == 'idt' || ['d', 'f', 'm', 'a']->index(key[0]) >= 0
            opts[key] = rest
          elseif key == 'ig'
            try
              var arr: any = eval(rest)
              if type(arr) == 3
                opts[key] = arr
              else
                throw 'Not an array'
              endif
            catch
              Exit('Invalid ignore_groups: ' .. arg_expr)
            endtry
          elseif key =~ '[<>]'
            opts['stl'] = key == '<' ? 1 : 0
          else
            opts[key] = str2nr(rest)
          endif
          break
        endif
      endfor
    endfor
  endif
  return NormalizeOptions(opts)
enddef

def ParseArgs(aargs: string): list<any> #{{{3
  if empty(aargs)
    return ['', '', {}, 0]
  endif
  var cand: string
  var args: any = aargs
  var opts: dict<any>

  # Poor man's option parser
  var idx: number
  while true
    var midx: number = args->match('\s*{.*}\s*$', idx)
    if midx == -1
      break
    endif

    cand = args->strpart(midx)
    try
      var l: string = 'l'
      var r: string = 'r'
      var c: string = 'c'
      var k: string = 'k'
      var s: string = 's'
      var d: string = 'd'
      var n: string = 'n'

      var L: string = 'l'
      var R: string = 'r'
      var C: string = 'c'
      var K: string = 'k'
      var S: string = 's'
      var D: string = 'd'
      var N: string = 'n'

      var o: any = LegacyEval(cand)
      if type(o) == 4
        opts = o
        if args[midx - 1 : midx] == '\ '
          ++midx
        endif
        args = args->strpart(0, midx)
        break
      endif
    catch
      # Ignore
    endtry
    idx = midx + 1
  endwhile

  # Invalid option dictionary
  if substitute(cand, '\s', '', 'g')->len() > 2 && empty(opts)
    Exit('Invalid option: ' .. cand)
  else
    opts = NormalizeOptions(opts)
  endif

  # Shorthand option notation
  var sopts: string = args->matchstr(shorthand_regex)
  if !empty(sopts)
    args = strpart(args, 0, len(args) - len(sopts))
    opts = extend(ParseShorthandOpts(sopts), opts)
  endif

  # Has /Regexp/?
  var matches: list<string> = args->matchlist('^\(.\{-}\)\s*/\(.*\)/\s*$')

  # Found regexp
  if !empty(matches)
    return [matches[1], TestRegexp(matches[2]), opts, 1]
  endif
  var tokens: list<string> = args
    ->matchlist('^\([1-9][0-9]*\|-[0-9]*\|\*\*\?\)\?\s*\(.\{-}\)\?$')
  # Try swapping n and ch
  var ch: string
  var n: any
  [n, ch] = tokens[2]->empty() ? tokens[1 : 2]->reverse() : tokens[1 : 2]

  # Resolving command-line ambiguity
  # '\ ' => ' '
  # '\'  => ' '
  if ch =~ '^\\\s*$'
    ch = ' '
  # '\\' => '\'
  elseif ch =~ '^\\\\\s*$'
    ch = '\'
  endif

  return [n, ch, opts, 0]
enddef

function LegacyEval(cand) abort
  " `cand` could be a dictionary where there is no white space after a colon delimiter
  return eval(a:cand)
endfunction

def ParseFilter(f: string): list<any> #{{{3
  var m: list<string> = f->matchlist('^\([gv]\)/\(.\{-}\)/\?$')
  if empty(m)
    return [0, '']
  endif
  return [m[1] == 'g' ? 1 : -1, m[2]]
enddef

def InteractiveModes(bang: bool): list<string> #{{{3
  return get(g:,
      (bang ? 'easy_align_bang_interactive_modes' : 'easy_align_interactive_modes'),
      (bang ? ['r', 'l', 'c'] : ['l', 'r', 'c']))
enddef

def AlternatingModes(mode: string): string #{{{3
  return mode ==? 'r' ? 'rl' : 'lr'
enddef

def UpdateLines(todo: dict<string>) #{{{3
  for [lnum: string, content: string] in items(todo)
    Rtrim(content)->setline(lnum->str2nr())
  endfor
enddef

def ParseNth(n: string): list<number> #{{{3
  var nth: number
  var recur: number
  if n == '*'      | [nth, recur] = [1, 1]
  elseif n == '**' | [nth, recur] = [1, 2]
  elseif n == '-'  | nth = -1
  elseif empty(n)  | nth = 1
  elseif n == '0' || ( n != '-0' && n != string(str2nr(n)) )
    Exit('Invalid N-th parameter: ' .. n)
  else
    nth = n->str2nr()
  endif
  return [nth, recur]
enddef

def BuildDict( #{{{3
  delimiters: dict<dict<any>>,
  ch: string,
  regexp: number,
  opts: dict<any>
): dict<any>

  var dict: dict<any>
  if regexp != 0
    dict = {pattern: ch}
  else
    if !has_key(delimiters, ch)
      Exit('Unknown delimiter key: ' .. ch)
    endif
    dict = copy(delimiters[ch])
  endif
  dict->extend(opts)

  var ml: any = get(dict, 'left_margin', ' ')
  var mr: any = get(dict, 'right_margin', ' ')
  if type(ml) == 0 | ml = repeat(' ', ml) | endif
  if type(mr) == 0 | mr = repeat(' ', mr) | endif
  extend(dict, {ml: ml, mr: mr})

  dict.pattern = get(dict, 'pattern', ch)
  dict.delimiter_align = get(dict, 'delimiter_align', get(g:, 'easy_align_delimiter_align', 'r'))[0]
  dict.indentation = get(dict, 'indentation', get(g:, 'easy_align_indentation', 'k'))[0]
  dict.stick_to_left = get(dict, 'stick_to_left', 0)
  dict.ignore_unmatched = get(dict, 'ignore_unmatched', get(g:, 'easy_align_ignore_unmatched', 2))
  dict.ignore_groups = get(dict, 'ignore_groups', get(dict, 'ignores', IgnoredSyntax()))
  dict.filter = get(dict, 'filter', '')

  return dict
enddef

def BuildModeSequence(aexpr: string, arecur: number): list<any> #{{{3
  var expr: string = aexpr
  var recur: number = arecur
  var suffix: string = aexpr->matchstr('\*\+$')
  if suffix == '*'
    expr = expr[0 : -2]
    recur = 1
  elseif suffix == '**'
    expr = expr[0 : -3]
    recur = 2
  endif
  return [tolower(expr), recur]
enddef

def Process( #{{{3
  range: list<number>,
  mode: string,
  n: string,
  ch: string,
  opts: dict<any>,
  regexp: number,
  rules: dict<dict<any>>,
  bvis: bool
): dict<any>

  var nth: number
  var recur: number
  [nth, recur] = ParseNth((empty(n) && exists('g:easy_align_nth')) ? g:easy_align_nth : n)
  var dict: dict<any> = BuildDict(rules, ch, regexp, opts)
  var mode_sequence: string
  [mode_sequence, recur] = BuildModeSequence(
      get(dict, 'align', recur == 2 ? AlternatingModes(mode) : mode),
      recur)

  var ve: string = &virtualedit
  set ve=all
  var args: list<any> = [
    {}, split(mode_sequence, '\zs'),
    {}, {}, range[0], range[1],
    bvis             ? [virtcol("'<"), virtcol("'>")]->min() : 1,
    (!recur && bvis) ? [virtcol("'<"), virtcol("'>")]->max() : 0,
    nth, recur, dict ]
  &ve = ve
  while len(args) > 1
    args = call(DoAlign, args)
  endwhile

  # todo: lines to update
  # summarize: arguments to Summarize()
  return {todo: args[0], summarize: [opts, recur, mode_sequence]}
enddef

def Summarize( #{{{3
  opts: dict<any>,
  recur: number,
  mode_sequence: string
): dict<any>

  var copts: dict<any> = CompactOptions(opts)
  var nbmode: string = InteractiveModes(0)[0]
  if !has_key(copts, 'a') && (
     (recur == 2 && AlternatingModes(nbmode) != mode_sequence) ||
     (recur != 2 && (mode_sequence[0] != nbmode || len(mode_sequence) > 1))
  )
    copts->extend({a: mode_sequence})
  endif
  return copts
enddef

def AlignImpl( #{{{3
  bang: bool,
  live: bool,
  visualmode: string,
  first_line: number,
  last_line: number,
  expr: string
)

  # Heuristically determine if the user was in visual mode
  var vis: bool
  var bvis: bool
  if visualmode == 'command'
    vis  = first_line == line("'<") && last_line == line("'>")
    bvis = vis && visualmode() == "\<C-V>"
  elseif empty(visualmode)
    vis = false
    bvis = false
  else
    vis = true
    bvis = visualmode == "\<C-V>"
  endif
  var range: list<number> = [first_line, last_line]
  var modes: list<string> = InteractiveModes(bang)
  var mode: string  = modes[0]
  slive = live

  var rules: dict<dict<any>> = easy_align_delimiters_default
  if exists('g:easy_align_delimiters')
    rules = extend(copy(rules), g:easy_align_delimiters)
  endif

  var n: string
  var ch: string
  var opts: dict<any>
  var regexp: number
  [n, ch, opts, regexp] = ParseArgs(expr)

  var bypass_fold: bool = get(g:, 'easy_align_bypass_fold', 0)
  var ofm: string = &l:foldmethod
  try
    if bypass_fold
      &l:foldmethod = 'manual'
    endif

    if empty(n) && empty(ch) || slive
      [mode, n, ch, opts, regexp] = Interactive(range, copy(modes), n, ch, opts, rules, vis, bvis)
    endif

    if !slive
      var output: dict<any> = Process(range, mode, n, ch, NormalizeOptions(opts), regexp, rules, bvis)
      UpdateLines(output.todo)
      var copts: dict<any> = call(Summarize, output.summarize)
      g:easy_align_last_command = Echon('', n, regexp, ch, copts, '')
    endif
  finally
    if bypass_fold
      &l:foldmethod = ofm
    endif
  endtry
enddef
