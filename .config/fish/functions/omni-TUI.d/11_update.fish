set -f script $($HOME/bin/drop-in/update)

if test -z "$script"
    return
end

# Do *not* execute the script directly:{{{
#
#     $script
#
# It would cause weird issues.
# For example, the last line of a multiline message might be unexpectedly erased.
# Or you might be unable to answer a prompt from an `apt(8)` command.
#
# It's  better to  type the  path  to the  script on  the command-line,  and
# execute it.   Besides, this makes it  explicit which script ends  up being
# executed.
#}}}
commandline --replace -- $script
commandline --function execute
