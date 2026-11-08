vim9script

import 'lg.vim'

var manual: dict<any>

def DictInit(d: dict<any>) #{{{1
    d.colors = d.ReadColors(d, g:quickhl_manual_colors)
    d.history = g:quickhl_manual_colors->len()->range()
    d.InitHighlight(d)
enddef

def DictReadColors(d: dict<any>, list: list<string>): list<dict<any>> #{{{1
    return list
        ->mapnew((i: number, v: string): dict<any> => ({
            name: 'QuickhlManual' .. i,
            val: v,
            pat: '',
            escaped: false,
        }))
enddef

def DictSearch(d: dict<any>, flag: string) #{{{1
  var pat: string
  for color: dict<any> in d.colors
    if color.pat != ''
      pat ..= '\|' .. color.pat
    endif
  endfor
  # eliminate first '\|'
  search(pat->strpart(2), flag)
enddef

def DictInitHighlight(d: dict<any>) #{{{1
    d.colors
      ->mapnew((_, v: dict<any>) => {
        execute 'highlight ' .. v.name .. ' ' .. v.val
      })
enddef

def DictSet(d: dict<any>) #{{{1
    var view: dict<number> = winsaveview()

    for color: dict<any> in d.colors
        # avoid `E35` when @/ is empty
        # TODO: is it the right fix?{{{
        #
        # What about this instead?:
        #
        #     for color in deepcopy(d.colors)->filter((_, v) => v.pat != '')
        #}}}
        if color.pat == ''
            continue
        endif
        Highlight(color.pat, color.name)
    endfor
    winrestview(view)

    augroup QuickhlPersistAfterReload
        autocmd! * <buffer>
        autocmd BufReadPost <buffer> manual.Refresh(manual)
    augroup END
enddef

def DictClear(d: dict<any>) #{{{1
    var buf: number = bufnr('%')
    var prop_types: list<string> = prop_type_list({bufnr: buf})
        ->filter((_, type: string): bool => type =~ '^QuickhlManual')
    if !prop_types->empty()
        # TODO: This clears all highlights.
        # How about clearing only the highlight under the cursor? (`M-*`, `x_M-`)
        prop_remove({types: prop_types, all: true}, 1, line('$'))
    endif
enddef

def DictReset(d: dict<any>) #{{{1
    d.Init(d)
    manual.Refresh(manual)
enddef

def DictRefresh(d: dict<any>) #{{{1
    d.Clear(d)
    if d.locked || (exists('w:quickhl_manual_lock') && w:quickhl_manual_lock)
        return
    endif
    d.Set(d)
enddef

def DictShowColors(d: dict<any>) #{{{1
    for h: dict<any> in d.colors
        execute 'highlight ' .. h.name
    endfor
enddef

def DictAdd(d: dict<any>, argpat: string, escaped: bool) #{{{1
    var pat: string = escaped ? argpat : Escape(argpat)
    if manual.IndexOf(manual, pat) >= 0
        return
    endif
    var i: number = d.NextIndex(d)
    d.colors[i]['pat'] = pat
    d.history->add(i)
enddef

def DictNextIndex(d: dict<any>): number #{{{1
    # var index = d.IndexOf(d, '')
    # return ( index != -1 ? index : d.history->remove(0) )
    return d.history->remove(0)
enddef

def DictIndexOf(d: dict<any>, pat: string): number #{{{1
    for color: dict<any> in d.colors
        if color.pat == pat
            return d.colors->index(color)
        endif
    endfor
    return -1
enddef

def DictDel(d: dict<any>, argpat: string, escaped: bool) #{{{1
    var pat = escaped ? argpat : Escape(argpat)

    var index: number = d.IndexOf(d, pat)
    if index == -1
        return
    endif
    d.DelByIndex(d, index)
enddef

def DictDelByIndex(d: dict<any>, idx: number) #{{{1
    if idx >= len(d.colors)
        return
    endif
    d.colors[idx]['pat'] = ''
    d.history->remove(d.history->index(idx))
    d.history->insert(idx, 0)
enddef

def DictList(d: dict<any>) #{{{1
    for idx: number in d.colors->len()->range()
        var color: dict<string> = d.colors[idx]
        execute 'echohl ' .. color.name
        echo printf('%2d: ', idx) .. color.pat
        echohl None
    endfor
enddef
# }}}1

# Interface {{{1
export def Word(mode: string) #{{{2
    if !manual.enabled
        Enable()
    endif
    # TODO: Should we handle the pattern as a list to preserve possible NULs?
    # If so, remove `->join("\n")` every time we've invoked `lg.GetSelectionText()` in this plugin.
    var pat: string =
        mode == 'n' ? expand('<cword>') :
        mode == 'v' ? lg.GetSelectionText()->join("\n") :
        ''
    if pat == ''
        return
    endif
    AddOrDel(pat, false)
enddef

export def WholeWord() #{{{2
    if !manual.enabled
        Enable()
    endif
    var pat: string = expand('<cword>')
    AddOrDel('\<' .. Escape(pat) .. '\>', true)
enddef

export def ClearThis(mode: string) #{{{2
    if !manual.enabled
        Enable()
    endif
    var pat: string =
        mode == 'n' ? expand('<cword>') :
        mode == 'v' ? lg.GetSelectionText()->join("\n") :
        ''
    if pat == ''
        return
    endif
    var pat_et: string = Escape(pat)
    var pat_ew: string = '\<' .. Escape(pat) .. '\>'
    if manual.IndexOf(manual, pat_et) != -1
        manual.Del(manual, pat_et, true)
    elseif manual.IndexOf(manual, pat_ew) != -1
        manual.Del(manual, pat_ew, true)
    endif
    manual.Refresh(manual)
enddef

export def Next(flags = '') #{{{2
    manual.Search(manual, flags)
enddef

export def Prev(flags = '') #{{{2
    manual.Search(manual, 'b' .. flags)
enddef

export def Reset() #{{{2
    manual.Reset(manual)
enddef

export def List() #{{{2
    manual.List(manual)
enddef

export def LockWindow() #{{{2
    w:quickhl_manual_lock = true
    manual.Clear(manual)
enddef

export def UnlockWindow() #{{{2
    w:quickhl_manual_lock = false
    manual.Refresh(manual)
enddef

export def LockWindowToggle() #{{{2
    if !exists('w:quickhl_manual_lock')
        w:quickhl_manual_lock = false
    endif
    w:quickhl_manual_lock = !w:quickhl_manual_lock
    manual.Refresh(manual)
enddef

export def Lock() #{{{2
    manual.locked = true
    manual.Refresh(manual)
enddef

export def Unlock() #{{{2
    manual.locked = false
    manual.Refresh(manual)
enddef

export def LockToggle() #{{{2
    manual.locked = !manual.locked
    echo manual.locked ? '[quickhl] Locked' : '[quickhl] Unlocked'
    manual.Refresh(manual)
enddef

export def Add(pat: string, escaped: bool) #{{{2
    if !manual.enabled
        Enable()
    endif
    manual.Add(manual, pat, escaped)
    manual.Refresh(manual)
enddef

export def Del(pat: string, escaped: bool) #{{{2
    if empty(pat)
        manual.List(manual)
        var index: string = input('index to delete: ')
        if empty(index)
            return
        endif
        manual.DelByIndex(manual, index)
    else
        manual.Del(manual, pat, escaped)
    endif
    manual.Refresh(manual)
enddef

export def Colors() #{{{2
    manual.ShowColors(manual)
enddef

export def Enable() #{{{2
    manual.Init(manual)
    manual.enabled = true

    augroup QuickhlManual
        autocmd!
        # TODO: Why `VimEnter`?
        autocmd VimEnter * manual.Refresh(manual)
        autocmd ColorScheme * InitHighlight()
    augroup END
    InitHighlight()
    manual.Refresh(manual)
enddef

export def Disable() #{{{2
    manual.enabled = false
    augroup QuickhlManual
      autocmd!
    augroup END
    autocmd! QuickhlManual
    Reset()
enddef

export def Op(type = ''): string #{{{2
  if type == ''
    &operatorfunc = function(lg.Opfunc, [{funcname: Op}])
    return 'g@'
  endif
  # If we operate on a line, don't highlight the first character of the next line.
  @" = @"->substitute('\n$', '', '')
  AddOrDel(@", false)
  return ''
enddef

export def ShowHelp() #{{{2
    # TODO: Include help about Ex commands, and show help in a scratch buffer.
    # Take inspiration from `cheatkeys` files for the scratch buffer.
    var help: list<string> =<< trim END
        M-m *     highlight word under cursor        N
        M-m g*    highlight unbounded word           N
        M-m       highlight motion or text-object    N
        M-m c     clear highlighting under cursor    N
        M-m C     clear all highlighting             N
        co M-m    toggle global lock                 N

        M-m       highlight selection                X
        m M-m     clear highlighting on selection    X
    END
    echo help->join("\n")
enddef
#}}}1
# Core {{{1
def AddOrDel(pat: string, escaped: bool) #{{{2
    if !manual.enabled
        Enable()
    endif

    if manual.IndexOf(manual, escaped ? pat : Escape(pat)) == -1
        manual.Add(manual, pat, escaped)
    else
        manual.Del(manual, pat, escaped)
    endif
    manual.Refresh(manual)
enddef

def InitHighlight() #{{{2
    manual.InitHighlight(manual)
enddef

def Highlight(pat: string, name: string) #{{{2
    silent! prop_type_add(name, {
        highlight: name,
        bufnr: bufnr('%'),
        combine: false,
    })
    cursor(1, 1)
    var flags: string = 'cW'
    var lnum: number
    var col: number
    var end_lnum: number
    var end_col: number
    while search(pat, flags) > 0
        [lnum, col] = getcurpos()[1 : 2]
        [end_lnum, end_col] = searchpos(pat .. '\zs', 'cn')
        flags = 'W'
        prop_add(lnum, col, {
          end_lnum: end_lnum,
          end_col: end_col,
          type: name,
        })
    endwhile
enddef
#}}}1
# Util {{{1
def Escape(pat: string): string #{{{2
    return '\V' .. escape(pat, '\')->substitute("\n", '\\n', 'g')
enddef
#}}}1

manual = {
    name: 'QuickhlManual\d',
    enabled: false,
    locked: false,
    Init: DictInit,
    ReadColors: DictReadColors,
    InitHighlight: DictInitHighlight,
    Set: DictSet,
    Clear: DictClear,
    Reset: DictReset,
    Refresh: DictRefresh,
    ShowColors: DictShowColors,
    Add: DictAdd,
    NextIndex: DictNextIndex,
    IndexOf: DictIndexOf,
    Del: DictDel,
    DelByIndex: DictDelByIndex,
    List: DictList,
    Search: DictSearch,
}

manual.Init(manual)
