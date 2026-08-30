# Purpose 1: Delegate the interactive menu to `fzf(1)`.{{{
#
# Rationale: `fzf(1)` offers:
#
#    - more configuration options
#    - a nicer view (single column vs several)
#    - the ability to select multiple entries
#
# Inspiration: https://github.com/junegunn/fzf/wiki/Examples-(fish)#completion
#}}}
# Purpose 2: Delegate glob expansion to `fzf(1)` + `eval(1)`.{{{
#
# Rationale: `fzf(1)` + `eval(1)` offer:
#
#    - more configuration options
#    - more control over which entries we want to insert on the command-line
#
# Also, while we could let fish expand a glob all by itself:
#
#     commandline --function complete
#
# The result would be confusing when there are too many matches.
# For example, right now:
#
#     $ vim ~/Wiki/**/*.md
#
# This inserts too  many entries on the  command-line: fish is not  able to draw
# its  contents  (i.e. the  screen  is  empty;  somehow,  even the  prompt  gets
# erased...).  And a repaint doesn't help.
#
# Worse, the expansion might outright fail:
#
#     $ vim /etc/**/*.conf
#}}}
# Purpose 3: Support frec completion:{{{
#
#     $ vim f,rc,lo<Tab>
#     $ vim /etc/rc.local
#
#     $ mv index.html d,www<Tab>
#     $ mv index.html /var/www/
#}}}
# Purpose 4: Expand `!!` into last command.

# I want the original completion on-demand!{{{
#
# Press `S-Tab` instead of `Tab`.
#
# Note that by default, `Tab` is bound  to `complete`, while `S-Tab` is bound to
# `complete-and-search`.  The latter  is closer to `fzf(1)`: it  lets you filter
# out entries by typing a pattern which is matched with a fuzzy algorithm.
#}}}

# Interface {{{1
function my-complete #{{{2
    if commandline --paging-mode
        down-or-search
        return
    end

    set -f current_token $(commandline --current-token)

    # don't complete in the middle of a token (too confusing)
    if test "$current_token" != "$(commandline --current-token --cut-at-cursor)"
        return
    end

    # expand `!!` into previous executed command
    if test "$current_token" = '!!'
        commandline --replace --current-token -- $history[1]
        return
    end

    # expand `f,rc,lo`
    if string match --quiet --regex -- '^[df],' $current_token
        _complete_frec
        return
    end

    # expand `*`
    if string match --quiet --regex -- '\*' $current_token
        _complete_wildcard
        return
    end

    # get the command which we're going to actually complete
    # We use `--cut-at-cursor` because we need to ignore everything after the cursor.{{{
    #
    # For example:
    #
    #     $ echo foo|bar
    #               ^
    #               cursor
    #
    # Here, Tab should complete `foo`; not `foobar`.
    #}}}
    # Be careful if you decide to use `--tokenize`:{{{
    #
    # It might ignore the current token.
    #
    # For example, here, `--tokenize` ignores `foobar`:
    #
    #     echo foobar|
    #                ^
    #                cursor
    #
    # But not here:
    #
    #     echo foobar |
    #                 ^
    #
    # ---
    #
    # Also, it can remove quotes causing `--do-complete` to give unexpected results:
    #
    #     sort --field-separator='|' --nu
    #                            ^ ^
    #}}}
    set -f cmd $(commandline --current-process --cut-at-cursor)
    # support multiline commands
    set -f cmd $(string join -- ' ' $cmd)

    # `--escape` is necessary for a completion containing a space.{{{
    #
    #     $ mkdir /tmp/test ; cd /tmp/test
    #     $ touch a\ b
    #     $ echo a
    #     # press: Tab
    #     # expected: "\ b" is inserted
    #     # actual: " b" is inserted
    #
    # It might be useful for other special characters too.
    #}}}
    set -f completions $(complete --do-complete --escape $cmd)

    # Remove possible duplicates.{{{
    #
    # Sometimes, there are:
    #
    #     $ complete --do-complete 'cargo '
    #     # lots of duplicate entries
    #
    # I guess it comes from the completion(s) which sometimes generates the same
    # entry several times.
    #
    # ---
    #
    # Alternatively, we could use `awk(1)`:
    #
    #     | awk '!seen[$0] { print $0; seen[$0] = 1 }'
    #
    # But `sort(1)` is more readable here,  and sorting the completions makes it
    # easier to find an entry in the menu.
    #}}}
    # If you change this command, test this:{{{
    #
    #     $ complete --do-complete fish_ind
    #     ...
    #     fish_indent     Indenter and prettifier
    #     ...
    #     fish_indent
    #     ...
    #
    # We want to keep the entry with a description.
    # IOW, we want to eliminate this entry:
    #
    #     fish_indent
    #
    # And keep this one:
    #
    #     fish_indent     Indenter and prettifier
    #}}}
    set -f completions $(
        printf '%s\n' $completions \
        | sort --key=1b,1 --field-separator=\t --unique \
    )

    # In command position, we might get too many irrelevant completions.{{{
    #
    # That's because,  for some reason,  `--do-complete` uses a  fuzzy algorithm
    # when completing a command.
    #}}}
    if test "$(commandline --current-buffer)" = "$current_token"
        set -f current_token '^'$current_token
    end

    # Escaped spaces must be escaped twice.{{{
    #
    # That's because for  `fzf(1)`, a backslash is not literal  if it's before a
    # space (even with `--exact`):
    #
    #    > You  can  prepend  a backslash to a space (\ ) to match a literal space
    #    > character.
    #
    # Source: `man fzf /EXTENDED SEARCH MODE/;/backslash`
    #
    #                                     vv
    #     $ echo 'a\\ b'  | fzf --query='a\\ b' --exact --exit-0 --select-1
    #     ✘
    #
    #                                     vvv
    #     $ echo 'a\\ b'  | fzf --query='a\\\ b'--exact  --exit-0 --select-1
    #     a\ b
    #}}}
    set -f current_token $(string replace --regex '\\ ' '\\\ ')
    # Whatever you do, make sure this still works:{{{
    #
    #     $ cd /tmp
    #     $ mkdir a\ b
    #     $ touch a\ b/c
    #     # press tab at the end of this command-line:  touch a\ b/
    #     # expected: c is inserted
    #
    #     $ cd /tmp
    #     $ mkdir a\(b
    #     $ touch a\(b/c
    #     # press tab at the end of this command-line:  touch a\(b/
    #     # expected: c is inserted
    #}}}

    # `column`: Align the possible descriptions in a column.{{{
    #
    # Otherwise, the  descriptions might  be hard  to read  (as an  example, try
    # to  complete the  subcommands  of  `apt(8)`).  Note  that  in the  default
    # completion menu, the descriptions are aligned (although, on the right, not
    # on the left).
    #}}}
    # `$ string replace`: Don't insert the descriptions.
    #   A description does not necessarily start right after the first space.{{{
    #
    # For example, a filename might contains backslash-escaped spaces:
    #
    #     $ mkdir /tmp/test && cd /tmp/test && touch a\ {b,c}
    #     $ vim a
    #     # press: Tab
    #
    #       > a\ b
    #         a\ c
    #
    #     # press: Enter
    #     # expected: a\ b is inserted
    #
    # That's why this regex is a bit tricky:
    #
    #     | string replace --regex '(\S+(\\ \S+)*).*' '$1' \
    #                               ^--------------^
    #
    # It has  to match  an optional  trailing sequence  of tokens  starting with
    # backslash-escaped spaces.
    #}}}
    string join -- \n $completions \
        | column -s\t -t \
        | fzf --bind='alt-e:execute(editor {+} >$(tty))' \
            --exit-0 \
            --multi \
            --query=$current_token \
            --select-1 \
        | string replace --regex '(\S+(\\ \S+)*).*' '$1' \
        | while read -f choice
            set -f --append choices $choice
          end
    commandline --function repaint

    if test -z "$choices"
        return
    end

    commandline --replace --current-token -- "$choices"
end
# }}}1
# Core {{{1
function _complete_wildcard --no-scope-shadowing #{{{2
    # There might be an option before the glob (e.g. `--option=abc*)`.
    string match --regex --quiet '^(?<option>-[^\s=]+=)?(?<glob>.*)' -- $current_token

    # expand glob
    if ! _commandline_has_unbalanced_quotes
        eval set -f matches $glob
    end

    # `string escape`: To support the case where an entry contains a space or quote.{{{
    #
    #     $ mkdir /tmp/test ; cd /tmp/test
    #     $ touch a\ b
    #     $ vim ./
    #
    # Here, if we press Tab, we want this command-line:
    #
    #     $ vim ./a\ b
    #              ^
    #              ✔
    #
    # And not this one:
    #
    #     $ vim ./a b
    #              ^
    #              ✘
    #
    # ---
    #
    # Same issue with a filename containing a quote:
    #
    #     $ mkdir /tmp/test ; cd /tmp/test
    #     $ touch a\"b
    #     $ vim ./
    #
    # Here, if we press Tab, we want this command-line:
    #
    #     $ vim ./a\"b
    #              ^
    #              ✔
    #
    # And not this one:
    #
    #     $ vim ./a"b
    #              ^
    #              ✘
    #}}}
    printf '%s\n' $matches \
      | string escape --no-quoted \
      | fzf --bind='alt-e:execute(editor {+} >$(tty))' \
            --exit-0 --multi --scheme=path --select-1 \
      | while read -f choice
          set -f --append choices $choice
        end
    commandline --function repaint

    if test -z "$choices"
        return
    end

    # `test`: Before inserting a directory name, make sure it's followed by a slash.{{{
    #
    # Rationale: It makes it easier to "chain" several completions.
    #
    #     $ cd
    #     $ vim .f*
    #
    #     # press Tab
    #     $ vim .fzf/
    #
    #     # press Tab again
    #     $ vim .fzf/
    #     > .fzf/install
    #       .fzf/uninstall
    #       .fzf/doc
    #       ...
    #}}}
    # `string unescape`: `choices` might be the name of a directory with spaces.{{{
    #
    # In which case, we need to unescape it for the test to work as expected:
    #
    #     $ mkdir /tmp/test ; cd /tmp/test
    #     $ mkdir a\ b
    #     $ set choice $(string escape --no-quoted 'a b')
    #     $ test -d "$choice" ; echo $status
    #     1
    #}}}
    if test "$(count $choices)" -eq 1 \
            && test -d "$(string unescape -- $choices)"
        commandline --replace --current-token -- "$option$choices/"
        return
    end

    # remove token under cursor
    commandline --replace --current-token ''

    # insert the choices
    for choice in $choices
        commandline --insert -- $option
        commandline --insert -- $choice
        commandline --insert -- ' '
    end
end

function _complete_frec --no-scope-shadowing #{{{2
    string match --regex --quiet -- '(?<frec_option>[^,]),(?<frec_query>.*)' $current_token
    set -f frec_query $(string replace -- ',' ' ' $frec_query)
    frec -$frec_option -- $frec_query \
        | while read -f choice
            set -f --append choices $choice
          end
    commandline --function repaint
    if test -n "$choices"
        commandline --replace --current-token -- "$choices"
    end
end
