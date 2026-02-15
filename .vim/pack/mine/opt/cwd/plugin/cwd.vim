vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

# Inspiration: https://github.com/airblade/vim-rooter
# Similar Plugin: https://github.com/mattn/vim-findroot/blob/master/plugin/findroot.vim

# Config {{{1

const ROOT_MARKER: list<string> =<< trim END
    .bzr/
    .git/
    .gitignore
    .hg/
    .svn/
    Rakefile
    _darcs/
END

const BLACKLIST: list<string> =<< trim END

    git
    gitcommit
END

# Declarations {{{1

var bufname: string

# Autocmd {{{1

augroup MyCwd
    autocmd!
    # `++nested` because: https://github.com/airblade/vim-rooter/commit/eef98131fef264d0f4e4f95c42e0de476c78009c
    # `BufReadPost` is not frequent enough.{{{
    #
    # For example,  if – for  some reason –  the CWD has  been wrongly set  in a
    # window, after saving/restoring  a session, it remains  wrong.  Our autocmd
    # should fix this automatically.
    #
    # ---
    #
    # If you notice other cases where  the CWD has not been correctly set/fixed,
    # just listen to `BufEnter`.
    #}}}
    autocmd BufWinEnter * ++nested CdRoot()
augroup END

# Interface {{{1
def CdRoot() #{{{2
    # Changing the CWD automatically can lead to hard-to-debug issues.{{{
    #
    # It  only makes  sense when  we're working  on some  repository in  a known
    # programming language.
    #
    # In the  past, we had  several issues because we  changed the CWD  where it
    # didn't make sense; e.g.: https://github.com/justinmk/vim-dirvish/issues/168
    # Another issue was in an unexpected output of ``expand('`shell cmd`')``.
    #
    # I'm tired of finding bugs which no one else finds/can reproduce...
    #}}}
    if ShouldBeIgnored()
        return
    endif

    # `resolve()` is  useful when editing  a file  within a repository  from a
    # symbolic link outside.
    bufname = expand('<afile>:p')
        ->resolve()
    if bufname == ''
        return
    endif

    var repo_root: string = GetRootDir()
    if repo_root == ''
        # Why this guard?{{{
        #
        #     $ cd /tmp; echo ''>r.vim; vim -S r.vim /tmp/r.vim
        #     Error detected while processing command line:
        #     E484: Can't open file r.vim
        #
        # More generally, any relative file path used in a `+''` command will be
        # completed with Vim's CWD.  If the latter is different than the shell's
        # CWD, this will lead to unexpected results.
        #}}}
        if !has('vim_starting')
            # Do *not* use `$HOME` as a default root directory!{{{
            #
            # Vim would be stuck for too much time after pressing:
            #
            #     :fin * C-d
            #
            # because there are a lot of files in our home.
            #}}}
            SetCWD($'{$HOME}/.vim')
        endif
    else
        SetCWD(repo_root)
    endif
enddef
# }}}1
# Core {{{1
def GetRootDir(): string #{{{2
    var repo_root: string = expand('<abuf>')
        ->str2nr()
        ->getbufvar('repo_root', '')
    if repo_root != ''
        return repo_root
    endif

    # Warning: `Cache()` is not  meant *only* for better  performance.  We can
    # also inspect the buffer-local variable  that it sets for other purposes.
    # Like for when and  where we should re-generate tags, or  where to find a
    # README.  So, do not remove one  of its invocation just because you think
    # that it doesn't make the code more efficient.

    # we're in one of our Vim plugins
    if bufname =~ '/pack/mine/opt/[^/]*'
        return bufname
            ->matchstr('.*/pack/mine/opt/[^/]*')
            ->Cache()
    endif

    # we're in a script or plugin (e.g. fish, mpv, tmux, ...)
    if bufname =~ '/\%(plugins\|scripts\)/'
        return bufname
            ->matchstr('.\{-}/\%(plugins\|scripts\)/[^/]*')
            ->Cache()
    endif

    # we're in a config file under `~/.config/some_program/`
    if bufname =~ $'^{$HOME}/\.config/\S\+/'
        return bufname
            ->matchstr($'^{$HOME}/\.config/[^/]*')
            ->Cache()
    endif
    # we're in an essential/non-reproducible data file under `~/.local/share/some_program/`
    if bufname =~ $'^{$HOME}/\.local/share/\S\+/'
        return bufname
            ->matchstr($'^{$HOME}/\.local/share/[^/]*')
            ->Cache()
    endif

    # we're in our wiki
    if bufname->stridx($'{$HOME}/Wiki/') == 0
        # We're in `~/Wiki/foo.md`.
        # The CWD should be `~/Wiki/` .
        if bufname =~ $'^{$HOME}/Wiki/[^/]*$'
            return $'{$HOME}/Wiki'
                ->Cache()
        endif

        var curdir: string = bufname->fnamemodify(':h')

        # We're in `~/Wiki/foo/bar/baz/qux.md`, and there is a `~/Wiki/foo/bar/code/` directory.
        # The CWD should be `~/Wiki/foo/bar/` .
        var stop_dir: string = bufname->matchstr($'^{$HOME}/Wiki/[^/]*')
        var code_dir: string = finddir('code/', $'{curdir};{stop_dir}')
        if code_dir != ''
            return code_dir
                ->fnamemodify(':p')
                ->trim('/', 2)
                ->fnamemodify(':h')
                ->Cache()
        endif

        # We're in `~/Wiki/foo/bar.md`.
        # The CWD should be `~/Wiki/foo/`.
        return curdir
            ->matchstr($'^{$HOME}/Wiki/[^/]*')
            ->Cache()
    endif

    # we're in a subdirectory of our home (e.g. `~/bin`, `~/.ssh`, `~/.vim`, ...)
    if bufname =~ $'^{$HOME}/[^/*]/'
        return bufname
            ->matchstr($'{$HOME}/[^/]*')
            ->Cache()
    endif

    # We've started Vim by pressing `C-X C-E` in fish.
    if bufname =~ $'^{$TMPDIR}/fish\.\w\+/command-line.fish$'
        # In fish, we pressed `C-o` to cycle between different snippets.
        if $_CC_cmd != ''
            return $'{$__fish_config_dir}/plugins/cyclic-completions/snippets/{$_CC_cmd}'
                ->Cache()
        endif
        var cmd: string = getline(1)
            ->matchstr('\%(\w\|-\)\+')
        var dir: string = $'{$HOME}/.config/navi/snippets/{cmd}'
        if dir->isdirectory()
            return dir
                ->Cache()
        endif
        return ''
    endif

    for pat: string in ROOT_MARKER
        repo_root = FindRootForThisMarker(pat)
        if repo_root != ''
            break
        endif
    endfor
    if repo_root != ''
        repo_root->Cache()
    endif
    return repo_root
enddef

def FindRootForThisMarker(pat: string): string #{{{2
    var dir: string = bufname->isdirectory() ? bufname : bufname->fnamemodify(':h')
    var dir_escaped: string = escape(dir, ' ')

    var match: string
    # `.git/`
    if pat->IsDirectory()
        match = finddir(pat, $'{dir_escaped};')
    # `.gitignore`
    else
        var suffixesadd_save: string = &suffixesadd
        &suffixesadd = ''
        match = findfile(pat, $'{dir_escaped};')
        &suffixesadd = suffixesadd_save
    endif

    if match == ''
        return ''
    endif
    # `match` should be something like:{{{
    #
    #    - `/path/to/.git/`
    #    - `/path/to/.gitignore`
    #    ...
    #}}}

    # `.git/`
    if pat->IsDirectory()
        # Why `return full_match` ?{{{
        #
        # If our current file is under the directory where what we found (`match`) is:
        #
        #     /path/to/.git/my/file
        #     ├───────────┘
        #     └ `match`
        #
        # We don't want `/path/to` to be the root of our repository.
        # Instead we prefer `/path/to/.git`.
        # So, we return the latter.
        #
        # It makes  more sense.  If we're  working in a file  under `.git/`, and
        # we're looking for some info, we probably want our search to be limited
        # to only the  files in `.git/`, and  not also include the  files of the
        # working tree.
        #}}}
        # Why `:p:h`?  Isn't `:p` enough?{{{
        #
        # `:p` will add a trailing slash, which might interfere:
        #
        #                                                            v
        #     var full_match: string = '~/.vim/pack/mine/opt/cwd/.git/'
        #     var dir: string = '~/.vim/pack/mine/opt/cwd/.git'
        #     echo stridx(dir, full_match)
        #     -1
        #
        # `:h` will remove this trailing slash:
        #
        #     var full_match: string = '~/.vim/pack/mine/opt/cwd/.git'
        #     var dir: string = '~/.vim/pack/mine/opt/cwd/.git'
        #     echo stridx(dir, full_match)
        #     0
        #}}}
        var full_match: string = match->fnamemodify(':p:h')
        if stridx(dir, full_match) == 0
            return full_match
        endif
        # What we found  is contained right below the root  of the repository,
        # so we return its parent.
        return match->fnamemodify(':p:h:h')
    endif

    # `.gitignore`
    return match->fnamemodify(':p:h')
enddef

def SetCWD(dir: string) #{{{2
    # Why `!dir->isdirectory()`?{{{
    #
    #     :split ~/Wiki/non_existing_dir/file.md
    #     E344: Can't find directory "/home/user/Wiki/non_existing_dir" in cdpath
    #     E472: Command failed
    #}}}
    if !dir->isdirectory() || dir == winnr()->getcwd()
        return
    endif
    execute $'lcd {dir->fnameescape()}'
enddef

def Cache(repo_root: string): string #{{{2
    setbufvar(expand('<abuf>')->str2nr(), 'repo_root', repo_root)
    # If you want the cache to be cleared when we reload the buffer:
    #
    #     setbufvar(expand('<abuf>')->str2nr(),
    #         'undo_ftplugin',
    #         (get(b:, 'undo_ftplugin') ?? 'execute') .. ' | unlet! b:repo_root')
    return repo_root
enddef
# }}}1
# Utilities {{{1
def ShouldBeIgnored(): bool #{{{2
    # Alternatively, you could use a whitelist, which by definition would be more restrictive.{{{
    #
    # Something like that:
    #
    #     return WHITELIST->index(&filetype) == -1 || ...
    #}}}
    # Why the `filereadable()` condition?{{{
    #
    # If we're editing  a new file, we don't want  any discrepancy between Vim's
    # CWD  and the  shell's one.   Otherwise,  Vim could  write the  file in  an
    # unexpected location:
    #
    #     $ cd /tmp
    #     $ vim x/y.vim
    #     :echo expand('%:p')
    #     x/y.vim
    #     :write
    #     :echo expand('%:p')
    #     ~/.vim/x/y.vim
    #     # this is wrong; I would expect the new file to be written in `/tmp/x/y.vim`
    #
    # Here's what happens.
    # When we enter the buffer, `vim-cwd` resets Vim's CWD from `/tmp` to `~/.vim`.
    # Then, before writing the buffer, a custom autocmd in our vimrc runs this:
    #
    #     :call fnamemodify('x/y.vim', ':h')->mkdir()
    #     ⇔
    #     :call mkdir('x')
    #     ⇔
    #     # create directory `getcwd() .. '/x'`
    #     ⇔
    #     # create directory `~/.vim/x`
    #
    # Finally, Vim writes the file `~/.vim/x/y.vim`.
    #
    # ---
    #
    # You might wonder why this issue affects `$ vim x/y.vim`, but not `$ vim y.vim`.
    # Watch this:
    #
    #     $ rm -rf /tmp/a /tmp/b; mkdir -p /tmp/a /tmp/b && cd /tmp/a
    #     $ vim -Nu NONE +'cd /tmp/b' x/y
    #     :write
    #     E212
    #     :call mkdir('/tmp/b/x')
    #     :write
    #     :echo expand('%:p')
    #     /tmp/b/x/y
    #          ^
    #
    #     $ rm -rf /tmp/a /tmp/b; mkdir -p /tmp/a /tmp/b && cd /tmp/a
    #     $ vim -Nu NONE +'cd /tmp/b' y
    #     :write
    #     /tmp/a/y
    #          ^
    #
    #     $ rm -rf /tmp/a /tmp/b; mkdir -p /tmp/a/x /tmp/b/x && cd /tmp/a
    #     $ vim -Nu NONE +'cd /tmp/b' x/y
    #     :write
    #     /tmp/a/x/y
    #          ^
    #
    #     $ rm -rf /tmp/a /tmp/b; mkdir -p /tmp/a/x /tmp/b/x && cd /tmp/a
    #     $ vim -Nu NONE +'cd /tmp/b' y
    #     :write
    #     /tmp/a/y
    #          ^
    #
    # It seems that most  of the time, Vim writes a file  (with a relative path)
    # in the CWD of the *shell*.  Except on one occasion; when:
    #
    #    - the file path contains a slash
    #    - there is no subdirectory in the shell's CWD matching the file's parent directory
    #
    # In that case, Vim writes the file in its *own* CWD.
    #
    # Note that changing  `+` with `--cmd` changes the name  of the buffer (from
    # relative to absolute), but it doesn't  change the file where the buffer is
    # written.
    #
    # ---
    #
    # What about a file path provided via `:edit` instead of the shell's command-line?
    # In that case,  it seems that Vim always  uses its own CWD, at  the time of
    # the first successful writing of the buffer.
    #
    #     $ rm -rf /tmp/a /tmp/b; mkdir -p /tmp/a /tmp/b
    #     $ cd /tmp
    #     $ vim -Nu NONE
    #     :cd /tmp/a
    #     :edit x/y
    #     :write
    #     E212
    #     :cd /tmp/b
    #     :call mkdir('/tmp/b/x')
    #     :write
    #     /tmp/b/x/y
    #          ^
    #}}}
    return BLACKLIST->index(&filetype) >= 0
        || &buftype != ''
        || !expand('<afile>:p')->filereadable()
enddef

def IsDirectory(pat: string): bool #{{{2
    return pat[-1] == '/'
enddef
