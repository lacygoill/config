function _complete_media_files
    set -f raw_starting_point $(commandline --cut-at-cursor --current-token)

    # Need to expand the tilde for `find(1)` (as well as possible environment variables).{{{
    #
    #             ✘
    #             v
    #     $ find '~/' -name '*.mkv'
    #     find: ‘~/’: No such file or directory
    #
    #     $ find '/home/lgc/' -name '*.mkv'
    #             ^-------^
    #                 ✔
    #}}}
    if test -n "$raw_starting_point"
        if ! _commandline_has_unbalanced_quotes
            eval set -f starting_point $raw_starting_point
        else
            set -f starting_point $raw_starting_point
        end
    end

    # https://github.com/mpv-player/mpv/wiki/Zsh-completion-customization#file-extensions
    #
    # We've added the  `.part` extension, because it's convenient to  be able to
    # play a video/audio file while it's still being downloaded.
    set -f extensions flv mp4 webm mka mkv wmv mov avi mp3 ogg wma flac wav aiff m4a m4b m4v gif ifo part
    #     flv mp4 ...
    #     →
    #     -o name *.flv -o name *.mp4 ...
    #             ^             ^
    #             No need to be quoted.
    #             Globbing and quote removal are performed before parameter expansion.
    set -f names $(string split -- ' ' '-o -name *.'$extensions)
    # Remove `-o` at the start.{{{
    #
    # We're going  to use  `$names` after `$FIND_OPTS`,  and the  latter already
    # ends with `-o`.  If we don't remove `-o`, we'll end up with `-o -o`, which
    # is syntactically incorrect.
    #}}}
    set --erase -f names[1]

    # In a replacement string, `$` is special.{{{
    #
    # Which might cause an error if `$raw_starting_point` contains a dollar.
    #
    #     $ set rep \$ENV; string replace --regex 'x' $rep 'x'
    #     string replace: Regular expression substitute error: unknown substring
    #
    #     $ set rep \$ENV \
    #         ; set rep $(string escape --style=regex -- $rep) \
    #         ; string replace --regex 'x' $rep 'x'
    #     $ENV
    #
    #    > If -r  or --regex is  given, PATTERN  is interpreted as  a Perl-compatible
    #    > regular expression,  and REPLACEMENT can contain  C-style escape sequences
    #    > like t as well  as **references to capturing groups by number  or name as $n**
    #    > or ${n}.
    #
    # Source: `string-replace(1)`
    #}}}
    set -f no_dollar $(string replace --all -- '$' \x01 $raw_starting_point)
    find -- $starting_point $FIND_OPTS \( $names \) -printf '%P\n' 2>/dev/null \
        | string replace --regex -- '^' $no_dollar \
        | string replace --all -- \x01 '$'
end
