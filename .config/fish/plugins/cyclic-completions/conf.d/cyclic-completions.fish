bind \co cyclic-completions

# Interface {{{1
function cyclic-completions # {{{2
    if test -z "$_CC_cycling"
        # We can't  complete anything in the  middle (or at the  start/end) of a
        # word.  An abbreviation doesn't expand there.
        # Do *not* move this `return` earlier.{{{
        #
        # We  want  to  assert that  the  cursor  is  not  in the  middle  of  a
        # token  *only*  if we're  not  cycling  completions for  this  command.
        # Otherwise,  most often,  we would  break cycling.   Indeed, generally,
        # after completing a command, the cursor is right after a word.
        #}}}
        if test -n "$(commandline --current-token)"
            return
        end
        # Problem: If the cursor is on a trailing backslash followed by a newline, the expansion still fails.{{{
        #
        # Because, in  that case, the current  token is considered to  be empty,
        # and the previous test unexpectedly fails.
        #}}}
        # Solution: Bail out if the character under the cursor is a backslash.
        set -f cmdline $(commandline --current-buffer | string collect)
        set -f curpos $(commandline --cursor)
        set -f idx $(math "$curpos + 1")
        set -f char_under_cursor $(string sub --start=$idx --end=$idx $cmdline)
        if test "$char_under_cursor" = '\\'
            return
        end

        set -f process $(commandline --current-process)
        # Alternative:
        #     string match --regex --quiet -- '(?<cmd>(\w|-)+)' $process
        set -f cmd $(string match --regex -- '(\w|-)+' $process)[1]
        #                                                       ^^^
        # `string-match(1)` also reports texts matched by capturing groups (i.e.
        # here, the last character in the command name).  Ignore them.

        if test -z "$cmd" \
                || ! test -d "$__fish_config_dir/plugins/cyclic-completions/snippets/$cmd"
            return
        end

        # `--export`: We  want our  `-r`  Vim mapping  to be  able  to find  the
        # relevant README file if we start Vim by pressing `C-x C-e` in fish.
        set --global --export _CC_cmd $cmd
        set --global _CC_cycling yes
        set --global _CC_original_cmd $cmdline
        set --global _CC_original_curpos $curpos
        set --global _CC_pos 1
    else
        # restore original command-line
        commandline --replace -- $_CC_original_cmd
        commandline --cursor -- $_CC_original_curpos

        # increment last position in cycle
        set --global _CC_pos $(math "$_CC_pos + 1")
        # if we got beyond last file, get back to original command
        if ! test -f "$__fish_config_dir/plugins/cyclic-completions/snippets/$_CC_cmd/$_CC_pos.fish"
            set --global _CC_pos 0
            return
        end
    end

    # We *must* re-install an abbreviation unconditionally.
    # Do *not* try to create separate abbreviations, and test their existence.{{{
    #
    #     ✘
    #     if ! abbr --query _{$_CC_cmd}_{$_CC_pos}
    #         _cyclic_completions_install_abbrev
    #     end
    #}}}
    #   If you do, you won't correctly handle a corner case:{{{
    #
    #           cursor
    #           v
    #     $ cmd ¦
    #     # press C-o
    #     $ cmd --opt  # comment
    #     # press C-o
    #     $ cmd ¦
    #     # append '; echo'
    #     $ cmd ; echo
    #     # press C-a M-f C-f
    #     $ cmd ¦; echo
    #     # press C-o
    #     # expected: $ cmd --opt; echo
    #     # actual: $ cmd --opt  # comment; echo
    #                          ^---------^
    #                               ✘
    #
    # Notice that `; echo`  has been wrongly commented out.   That's because the
    # first time we completed `cmd`, we were at the end of the command-line, and
    # so the abbreviation was defined with its trailing comment.  But the second
    # time, we were no longer at the end.
    #
    # This  illustrates  that   `_cyclic_completions_install_abbrev`  must  test
    # whether we're at  the end of the command-line *every*  time we press `C-o`
    # (even  if we  cycle  back to  the  same completion).   Not  just once  per
    # completion.
    #
    # ---
    #
    # Besides,  this  design might  create  many  abbreviations which  you  will
    # probably want to clean up later.
    #}}}
    _cyclic_completions_install_abbrev

    # insert and expand the next abbreviation in the cycle
    commandline --insert _CC_abbrev
    commandline --function expand-abbr
    # NOTE: The expansion is queued to be processed later.{{{
    #
    #    > -f or --function
    #    >        Causes any additional arguments to be interpreted as input func‐
    #    >        tions, and puts them into the **queue**, so that they will  be  read
    #    >        before  any additional actual key presses are.
    #
    # Source: `man commandline`
    #
    # Because of that, `commandline --cursor` and `commandline --current-buffer`
    # still give the position and command-line  as they are right before the LHS
    # of the abbreviation is expanded.   IOW, your knowledge of the command-line
    # stops at the  insertion of the LHS;  your code has no way  of knowing what
    # the command-line will look like after the abbreviation is expanded.
    #
    # BTW,  `commandline --insert` is  processed immediately;  it's not  queued;
    # only `commandline --function` is.
    #}}}
end
# }}}1
# Core {{{1
function _cyclic_completions_install_abbrev # {{{2
    # We're at the end of the command-line.
    if test "$(commandline --current-buffer)" = "$(commandline --cut-at-cursor)"
        # `--line`: do not tokenize the line
        while read --line line
            if ! set --query expansion
                # If a completion starts with `^W`, it wants us to kill the word before the cursor.
                # Unfortunately, we can't use `commandline --function backward-kill-word`.{{{
                #
                # That's because the kill would  not be executed immediately; it
                # would only be queued to be processed later:
                #
                #    > -f or --function
                #    >        Causes any additional arguments to be interpreted as input func‐
                #    >        tions, and puts them into the **queue**, so that they will  be  read
                #    >        before  any additional actual key presses are.
                #
                # Source: `man commandline`
                #
                # But we'll  insert the  LHS of our  abbreviation (`_CC_abbrev`)
                # immediately:
                #
                #     commandline --insert _CC_abbrev
                #
                # So, `backward-kill-word` would not kill the command before the
                # cursor; it would wrongly kill `abbrev` from `_CC_abbrev`.
                #}}}
                # Instead,  we'll compute  the new  command-line, with  the last
                # word killed, then use it to replace the current one.
                if string match --regex --quiet -- '^\^W ' $line
                    set -f expansion $(string sub --start=4 -- $line)
                    set -f old $(commandline --current-buffer)
                    # Warning: In the past, we used the pattern `\w* $`.{{{
                    #
                    # But it  assumes that the previous  token is the name  of a
                    # command (`$_CC_cmd`  actually).  It  might not  be.  There
                    # might be  arguments and/or options in-between  the command
                    # name and  the cursor.  If  that happens, `\w* $`  gives an
                    # unexpected result.
                    #}}}
                    # Note: `$_CC_cmd'.* $'` is technically not correct.{{{
                    #
                    # Because  it matches  from the  first occurrence,  while it
                    # should match  from the  last one.   For now,  let's assume
                    # that it  won't cause  too much trouble;  we have  very few
                    # snippets using  `^W`, and  when we use  one of  them, it's
                    # unlikely  that `$_CC_cmd`  will be  present several  times
                    # before the cursor.
                    #}}}
                    set -f new $(string replace --regex -- $_CC_cmd'.* $' '' $old)
                    commandline --replace -- $new
                else
                    set -f expansion $line
                end
            else
                # Do *not* use `--append`.{{{
                #
                #     ✘
                #     set -f --append expansion \n $line
                #
                # It might *seem*  as if it works, but actually,  this would add
                # an  extra space  at the  end of  every line,  which you  would
                # probably only see in Vim (`C-x C-e`).
                #
                # MRE:
                #
                #     $ set expansion a
                #     $ set --append expansion \n
                #     $ set --append expansion b
                #     $ abbr --add LHS $expansion
                #     # insert LHS and press Space to expand it
                #     # expected: the command-line contains:
                #     a
                #     b_
                #      ^
                #      stands for the space inserted to expand the abbreviation
                #
                #     # actual: the command-line contains:
                #      extra space
                #      v
                #     a_
                #     _b_
                #     ^
                #     extra space
                #}}}
                set -f expansion $expansion\n$line
            end
        end <$__fish_config_dir/plugins/cyclic-completions/snippets/$_CC_cmd/$_CC_pos.fish

    # We're  not.   Don't  `echo`  a  trailing  comment  to  avoid  accidentally
    # commenting out the end of the original command.
    else
        while read --line line
            # stop reading on a commented line
            if string match --regex --quiet -- '^\s*#\s' $line
                break
            end

            # After the first line of a completion, there is no special syntax to process.{{{
            #
            # In particular, we only allow `^W ` at the very start of a completion.
            # And, while an inline comment is  allowed at the end of a multiline
            # command:
            #
            #     $ some \
            #     multiline \
            #     command  # inline comment
            #              ^--------------^
            #
            # In practice, we write such a comment on a separate line:
            #
            #     $ some \
            #     multiline \
            #     command
            #         # comment
            #         ^-------^
            #}}}
            if set --query expansion
                set -f expansion $expansion\n$line
                continue
            end

            # trim an inline comment (which  we typically never write at the
            # end of a multiline command)
            set -f expansion $(string replace --regex -- '(\S)   *# .*' '$1' $line)

            # the completion starts with `^W `
            if string match --regex --quiet -- '^\^W ' $line
                # kill it, as well as the previous word
                set -f expansion $(string sub --start=4 -- $line)
                _commandline_replace_before_cursor '\w* ' ''
            end

        end <$__fish_config_dir/plugins/cyclic-completions/snippets/$_CC_cmd/$_CC_pos.fish
    end

    abbr --add --position=anywhere --set-cursor=⌖ -- _CC_abbrev $expansion
end

function _cyclic_completions_cleanup --on-event=fish_prompt # {{{2
    abbr --erase _CC_abbrev

    set --erase --global _CC_cmd
    set --erase --global _CC_cycling
    set --erase --global _CC_original_cmd
    set --erase --global _CC_original_curpos
    set --erase --global _CC_pos
end

function _cyclic_completions_cleanup_on_cancel --on-event=fish_cancel # {{{2
    _cyclic_completions_cleanup
end

function _cyclic_completions_stop_cycling --on-event=space_inserted # {{{2
    # Warning: If you think about another mechanism with which you don't need to
    # erase this ad-hoc flag whenever we insert a space, make sure it correctly
    # handles these corner cases:{{{
    #
    #     $ cmd
    #     # press C-o
    #     $ cmd --opt
    #     # insert '; cmd '
    #     $ cmd --opt; cmd ¦
    #                      ^
    #                      cursor
    #
    # With the last  command-line, pressing `C-o` again should  not complete the
    # first `cmd`, but the second one.
    #
    # ---
    #
    #     $ cmd1
    #     # press C-o
    #     $ cmd1 --opt | cmd2 ¦
    #                         ^
    #
    # With  the last  command-line,  pressing `C-o`  again  should not  complete
    # `cmd2`, but `cmd1`.
    #}}}
    set --erase --global _CC_cycling
end
