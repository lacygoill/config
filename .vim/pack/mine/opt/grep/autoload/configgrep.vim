vim9script

import autoload './vimgrep.vim' as _vimgrep

# Interface {{{1
export def Main(args: string) # {{{2
    var pat: string = args

    var filetype: string
    if args =~ '^-filetype='
        if args !~ '^-filetype=\S*\s\+\S'
            Error('missing pattern')
            return
        endif
        if $CONFIG_FILETYPES == ''
            Error('cannot find config filetypes cache; $CONFIG_FILETYPES is not set')
            return
        endif

        [filetype, pat] = args->matchlist('\(-\S*\)\s\+\(.*\)')[1 : 2]
        filetype = filetype->matchstr('-filetype=\zs\S*')

        if !$CONFIG_FILETYPES->filereadable()
            echo 'need to re-generate the cache; this will take a few seconds...'
            FileTypesCache(args)
            return
        endif

        if ConfigFilesByFileTypes()->get(filetype, []) == []
            Error($'filetype not supported: {filetype}')
            return
        endif
    endif

    var config_files: list<string>
    if filetype == ''
        silent config_files = systemlist('config ls-files')
    else
        config_files = ConfigFilesByFileTypes()
            ->get(filetype, [])
        if filetype != 'markdown'
            config_files->add($'{$HOME}/Wiki/{filetype}/**/*.md')
        endif
        if filetype != 'snippets'
            config_files->add($'{$HOME}/.vim/pack/mine/opt/snippets/UltiSnips/{filetype}.snippets')
        endif
        config_files->extend([
            $'{$HOME}/Wiki/cheatkeys/{filetype}',
            $'{$HOME}/.config/navi/snippets/{filetype}.cheat',
            $'{$HOME}/.config/navi/snippets/{filetype}/**'
        ])
    endif

    # Even though, technically,  our `vim9asm` and `vim9-syntax`  are not part
    # of our  config (because they're public  Git repos and contain  their own
    # `.git/` directory), we still want to grep their contents.
    if filetype == '' || filetype == 'vim'
        # Warning: Do *not* use brace expansion:{{{
        #
        #     config_files->add($'{$HOME}/.vim/pack/mine/opt/{{vim9asm,vim9-syntax}}/**/*.vim')
        #                                                    ^^                   ^^
        #                                                    ✘                    ✘
        #
        # For  some   reason,  braces  prevent  `**`   from  matching  nothing
        # (*anywhere* on the command-line):
        #
        #     $ mkdir -p /tmp/test/dir/sub
        #     $ cd /tmp/test
        #     $ echo text | tee dir/{foo,sub/bar}
        #     $ vim -Nu NONE +'silent vimgrep /text/ {} ./dir/**/*'
        #     # "text" is found in `bar` but not in `foo`
        #
        #     :silent vimgrep /text/ x ./dir/**/*
        #     # `text` is found in `bar` *and* in `foo`
        #}}}
        config_files->add($'{$HOME}/.vim/pack/mine/opt/vim9asm/**/*.vim')
        config_files->add($'{$HOME}/.vim/pack/mine/opt/vim9-syntax/**/*.vim')
    endif

    config_files
        ->map((_, fname: string) => fname
        # We don't want `fnameescape()` to wrongly escape wildcards.
        ->substitute('\*', '٭', 'g')
        ->fnameescape()
        ->substitute('٭', '*', 'g'))

    var pattern_and_files: string = $'/{pat->escape('/')}/gj {config_files->join()}'
    _vimgrep.Main(pattern_and_files, $':ConfigGrep {args}')
enddef

export def Complete( # {{{2
        arglead: string,
        cmdline: string,
        pos: number
        ): string
    if cmdline =~ '-filetype=\S\+\s'
            && cmdline !~ $'.*-filetype=\S*\%{pos + 1}c'
            || $CONFIG_FILETYPES == ''
        return ''
    endif
    if arglead =~ '^-filetype='
            && $CONFIG_FILETYPES->filereadable()
        return ConfigFilesByFileTypes()
            ->keys()
            ->sort()
            ->map((_, ft: string) => $'-filetype={ft}')
            ->join("\n")
    endif
    return '-filetype='
enddef
# }}}1
# Core {{{1
def ConfigFilesByFileTypes(): dict<list<string>> # {{{2
    return readfile($CONFIG_FILETYPES)
        ->get(0, '')
        ->json_decode()
enddef

def FileTypesCache(args: string) # {{{2
    # Don't use `-u NONE`; we need our  config to be sourced to install custom
    # filetype  detection rules  defined in  `~/.vim/filetype.vim` or  under a
    # `ftdetect/` directory.
    var vimcmd: string = 'vim -i NONE -U NONE +"call g:ConfigFileTypes()"'
    var opts: dict<any> = {
        exit_cb: function(FileTypesCallback, [args]),
        in_io: 'null',
        out_io: 'null',
        err_io: 'null',
    }
    job_start(vimcmd, opts)
enddef

def FileTypesCallback(args: string, ..._) # {{{2
    if $CONFIG_FILETYPES->filereadable()
        echo 'cache generated; grepping...'
        Main(args)
    endif
enddef
# }}}1
# Util {{{1
def Error(msg: string) # {{{2
    echohl ErrorMsg
    echo msg
    echohl NONE
enddef
