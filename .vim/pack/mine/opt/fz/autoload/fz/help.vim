vim9script

import autoload '../fz.vim'

# Interface {{{1
export def Tags() # {{{2
    fz.Run({
        options: [
            '--nth=1',
            $'--prompt="Help Tags {$FZF_PROMPT}"',
        ],
        sink: Sink,
        source: GetSource(),
    })
enddef
# }}}1
# Core {{{1
def GetSource(): string # {{{2
    var tagfiles: list<string> = globpath(&runtimepath, 'doc/tags', true, true)

    # What's the purpose of this formatting command?{{{
    #
    # It should format the output of `grep(1)` so that:
    #
    #    - the path of the tagfile is removed at the start
    #    - the tag regex is removed at the end (`/*some-tag*`)
    #    - the tag name is left-aligned in a 40 bytes string
    #
    # Basically, we want to go from this:
    #
    #                                       tab
    #                                     v------v
    #     /home/user/.fzf/doc/tags:fzf-toc        fzf.txt /*fzf-toc*
    #                              ^-----^        ^-----^
    #                              we're only interested in this
    #
    # To that:
    #
    #     fzf-toc                                 fzf.txt
    #}}}
    #   But I can do the same thing in Vim!{{{
    #
    # Yes, but you can't make Vim functions like `printf()` async.
    # OTOH, `mawk(1)` is async when started by `fzf(1)`.
    #
    # Besides, `mawk(1)` is much faster than Vim (≈ 6 times).
    #}}}
    # Perl alternative:{{{
    #
    #     formatting_cmd = 'perl -n -e ''/.*?:(.*?)\t(.*?)\t/; printf(qq/%-40s\t%s\n/, $1, $2)'''
    #
    # ---
    #
    # `-n`: Iterate over the input lines somewhat like `awk(1)`.
    #
    # See `man perlrun /^\s*-n`.
    # This man page is provided by the `perl-doc` package.
    #
    # ---
    #
    # `-e`: Execute the code from the next string argument.
    # Without, perl would look for a filename from which to read the program.
    #
    # See `man perlrun /^\s*-e`.
    #
    # ---
    #
    # `*?`: Lazy quantifier, equivalent to `\{-}` in Vim.
    # See `man perlreref /QUANTIFIERS/;/\*?`.
    #
    # ---
    #
    # `qq`: Operator which quotes a string.
    # See `man perlop /^\s*Quote-Like Operators/;/qq`
    #}}}
    # Give the preference to `mawk(1)`, because it's a bit faster than perl on
    # our machine. `gawk(1)` is twice slower than `mawk(1)`.
    var awk_pgm: list<string> =<< trim END
        {
            split($0, a, /\t/)
            sub(/[^:]*:/, "", a[1])
            printf("%-40s\t%s\n", a[1], a[2])
        }
    END
    var formatting_cmd: string = 'mawk ' .. awk_pgm->join(';')->shellescape()

    return 'grep --with-filename ".*" '
        .. tagfiles
        ->map((_, v: string) => shellescape(v))
        ->sort()
        ->uniq()
        ->join()
        .. ' | ' .. formatting_cmd
        .. ' | sort'
enddef

def Sink(chosen: string) # {{{2
    var [helptag: string, filename: string] = split(chosen, '\t')

    # Why passing `true, true` as argument to `globpath()`?{{{
    #
    # The  first `true`  can  be useful  if for  some  reason `'suffixes'`  or
    # `'wildignore'` are misconfigured.  The second `true` is useful to handle
    # the case where `globpath()` finds several files.  It's easier to extract
    # the first one from a list than from a string.
    # }}}
    var fullpath: string = globpath(&runtimepath, 'doc/' .. filename, true, true)->get(0, '')
    if fullpath == ''
        return
    endif

    helptag = helptag
        ->trim()
        ->escape('\')
    execute $'help {helptag}'
enddef
