vim9script

# used by `FixWrongBacktickInterpolations()`
const FILETYPE_TO_COMMENT_LEADER: dict<string> = {
    authorizedkeys: '#',
    awk: '#',
    bash: '#',
    c: '//',
    dot: '//',
    fish: '#',
    gitignore: '#',
    knownhosts: '#',
    lua: '--',
    navi: ';',
    python: '#',
    sed: '#',
    snippets: '#',
    sshconfig: '#',
    sshdconfig: '#',
    systemd: '#',
    tex: '%%',
    vim: '#',
    weechat: '#',
}

# Give a  warning if  we've created a  snippets file for  a new  filetype, but
# forgot to teach what its comment leader is.
const SNIPPETS_DIR: string = globpath(&runtimepath, 'UltiSnips')
{
    var supported: list<string> = SNIPPETS_DIR
        ->readdir((fname: string): bool => fname =~ '\.snippets$'
        && fname !~ '^\%(all\|help\|markdown\|nroff\).snippets$')
        ->map((_, fname: string) => fname->fnamemodify(':r'))
    for filetype: string in supported
        if !FILETYPE_TO_COMMENT_LEADER->has_key(filetype)
            unsilent echowindow $'{expand('<script>')}: {filetype} key is missing from FILETYPE_TO_COMMENT_LEADER'
        endif
    endfor
}

export def FixNumberedTriggers() #{{{1
    var view: dict<number> = winsaveview()
    var number_trigger: number
    FN_Rep = () => {
        ++number_trigger
        return $'t{printf('%02d', number_trigger)}'
    }

    try
        undojoin
        silent keepjumps keeppatterns lockmarks :% substitute/^snippet\s\+\zst\d\+\ze\s\+/\=FN_Rep()/e
    # E790: undojoin is not allowed after undo
    catch /^Vim\%((\a\+)\)\=:E790:/
    endtry

    view->winrestview()
enddef

var FN_Rep: func

export def FixWrongBacktickInterpolations() #{{{1
    var filetype: string = expand('%:t:r')
    if !FILETYPE_TO_COMMENT_LEADER->has_key(filetype)
        return
    endif
    var cml: string = FILETYPE_TO_COMMENT_LEADER[filetype]
    var unescaped_backtick_in_comment: string = $'^\s*{cml}.*\\\@1<!\zs`'
    var view: dict<number> = winsaveview()
    cursor(1, 1)
    while search(unescaped_backtick_in_comment, 'W') > 0
        if synstack('.', col('.'))
                ->map((_, synID: number): string => synID->synIDattr('name'))
                ->indexof((_, name: string): bool => name == 'snipSnippetBody') >= 0
            keepjumps keeppatterns substitute/\%.c`/\\`/e
        endif
    endwhile
    winrestview(view)
enddef

export def GetAutoloadFuncname(): string #{{{1
    return expand('%:p') =~ 'autoload\|plugin'
        ?     expand('%:p')
            ->matchstr('\%(autoload\|plugin\)/\zs.*\ze.vim')
            ->tr('/', '#') .. '#'
        :     ''
enddef

export def GetLgTagNumber(): string #{{{1
    var lines: list<string> = getline(1, line('.') - 1)
        ->reverse()
        ->filter((_, v: string): bool => v =~ '^\s*\*lg-lib-\%(\d\+\)\*\s*$')
    return empty(lines)
        ?     ''
        :     lines[0]->matchstr('^\s*\*lg-lib-\zs\d\+\ze\*\s*$')
enddef

export def RemoveTabsInGlobalBlocks() #{{{1
    var pos: list<number> = getcurpos()
    var start: string = ':1/^\Cglobal !p$/'
    var end: string = '/^\Cendglobal$/'
    # Don't replace `4` with `&l:shiftwidth`.
    # Python expects you indent your code with exactly 4 spaces.
    RT_Rep = (m: list<string>): string => repeat(' ', m[0]->strcharlen() * 4)
    var substitution: string = 'substitute/^\t\+/\=RT_Rep()/'
    execute 'silent! keepjumps keeppatterns '
        .. start .. ';' .. end .. 'global/^/' .. substitution
    setpos('.', pos)
enddef

var RT_Rep: func

export def UndoFtplugin() #{{{1
    set expandtab<
    set iskeyword<
    set shiftwidth<
    set tabstop<
    unlet! b:match_words
    autocmd! FormatSnippets * <buffer>
    nunmap <buffer> q
enddef
