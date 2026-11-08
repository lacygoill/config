# Config {{{1

set --local magenta $(set_color --bold magenta)
set --local reset $(set_color normal)
set --global _ABBR_REMINDER_FORMAT $magenta'❬LHS❭'$reset' => ❬RHS❭'

# Functions {{{1
function _abbr_reminder --on-event=space_inserted --argument-names=from_my_execute # {{{2
    set -f cmdline $(string join -- ' ' $(commandline --cut-at-cursor))
    set -f curpos $(commandline --cursor)

    # check for a regular abbreviation
    # The test on the cursor position is only meant to improve the performance.{{{
    #
    # What really matters is the `contains` test.
    # But the more abbreviations we have, the slower it will be.
    # So we try to reduce how often it's executed, by first making sure that the
    # cursor is at least in a valid range.
    #}}}
    if test "$_ABBR_REMINDER_RHS_LENGTH_MIN" -le "$curpos" \
            && test "$curpos" -le "$_ABBR_REMINDER_RHS_LENGTH_MAX" \
            && set -f i $(contains --index -- $cmdline $_ABBR_REMINDER_RHS)
        set -f LHS $_ABBR_REMINDER_LHS[$i]
        set -f RHS $_ABBR_REMINDER_RHS[$i]
        _abbr_reminder_print $LHS $RHS
        _abbr_reminder_expand
        return
    end

    # Check for an *anywhere* abbreviation.
    # First, iterate over their known lengths.
    for len in $_ABBR_REMINDER_RHS_LENGTHS_ANYWHERE
        # For every length, compute where the abbrev should start for the cursor
        # to be where  it is currently.  We don't know  yet whether there exists
        # an abbreviation for  the text between this start and  the cursor.  For
        # now, let's call this text a "suspect".
        set -f start $(math "$curpos - $len + 1")
        if test "$start" -le 0
            continue
        end

        # Make sure the suspect  is not in the middle of a  word; that is, the
        # character before should be whitespace or punctuation.
        set -f pos_char_before $(math "$start - 1")
        if test "$pos_char_before" -gt 0
            set -f char_before $(string sub --start=$pos_char_before --length=1 -- $cmdline)
        else
            set -f char_before ''
        end
        if ! string match --regex --quiet '^[|&;()<>[:blank:]\n]?$' -- $char_before
            continue
        end

        # Now, let's check whether the suspect is a culprit.{{{
        #
        # And that it doesn't start in the middle of a word.
        # From `man bash /DEFINITIONS/;/metacharacter`:
        #
        #    > A character that, when unquoted, separates words.   One  of  the
        #    > following:
        #    > |  & ; ( ) < > space tab newline
        #
        # See also:
        #
        #     $ bind | awk ' /self-insert expand-abbr/ { print $3 }'
        #}}}
        set -f suspect $(string sub --start=$start --end=$curpos -- $cmdline)
        if set -f i $(contains --index -- $suspect $_ABBR_REMINDER_RHS_ANYWHERE)
            set -f LHS $_ABBR_REMINDER_LHS_ANYWHERE[$i]
            set -f RHS $_ABBR_REMINDER_RHS_ANYWHERE[$i]
            _abbr_reminder_print $LHS $RHS
            break
        end
    end

    if test -z "$from_my_execute"
        _abbr_reminder_expand
    end
end

function _abbr_reminder_print --argument-names=LHS RHS # {{{2
    # Print abbreviation reminder in right prompt.

    # Don't print a  reminder if the command was not  typed manually (e.g. we've
    # pressed `C-p` to re-call an old command, or `C-e` to accept a suggestion).
    # But only  if we're at the  end of the  line; if we're not,  we've probably
    # edited the command and did type some text manually.
    if set --query --global _cmdline_not_typed_manually \
            && test "$(commandline --current-buffer)" = "$(commandline --cut-at-cursor)"
        return
    end

    set --global _abbrev_reminder_msg $(string replace -- '❬LHS❭' $LHS \
         $(string replace -- '❬RHS❭' $RHS $_ABBR_REMINDER_FORMAT))

    functions --erase fish_right_prompt
    function fish_right_prompt
        echo $_abbrev_reminder_msg
        set --erase --global _abbrev_reminder_msg
    end
    commandline --function repaint
end

function _abbr_reminder_expand # {{{2
    commandline --function expand-abbr
    # Suppose that we've not typed the command manually (`C-p`, `C-e`, ...).
    # `_cmdline_not_typed_manually` will  be set  to prevent a  useless reminder
    # from being printed.
    # But suppose  we don't  execute the command  immediately; instead  we write
    # more text for which there was an abbreviation.  In that case, we do want a
    # reminder; let's make sure that can happen the next time we insert a space.
    set --erase --global _cmdline_not_typed_manually
end
