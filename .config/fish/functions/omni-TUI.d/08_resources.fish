set -f resources_dir "$HOME/Wiki/resources"

set -f topic $(
    find -- $resources_dir -type f -printf '%f\n' \
    | sed 's/\.md$//' \
    | sort \
    | fzf \
        --bind="alt-e:execute(editor +'normal! zvzz' $resources_dir/{}.md >\$(tty))" \
        --preview="head --lines=1 $resources_dir/{}.md" \
        --preview-window=66%,nohidden \
)
commandline --function repaint

if test -z "$topic"
    return
end

set -f resource $(
    awk '/^#.*[^ #]/ { sub("^# ", ""); print $0 "\t" NR }' $resources_dir/$topic.md \
    | fzf --bind="alt-e:execute(editor +{-1} +'normal! zvzz' $resources_dir/$topic.md >\$(tty))" \
        --delimiter=\t \
        --preview="sed -n '{-1},/^#/ { /^#/,+1 d; p }' $resources_dir/$topic.md \
                    | bat --language=markdown --line-range=:500 --color=always --style=plain" \
        --preview-window=66%,nohidden \
        --with-nth=1 \
)
commandline --function repaint

# remove line address
set -f resource $(string replace --regex -- '\t.*' '' $resource)

# Prevent next `awk(1)` invocation from interpreting parens as grouping operators.{{{
#
# `string escape --style=regex` doesn't  work here,  because our  awk script
# needs the  parens to be escaped  twice (that's because it  reads the regex
# from a string).
#}}}
set -f resource $(string replace --regex --all -- '[()]' '.' $resource)

if test -z "$resource"
    return
end

set -f fetch_resource_cmd $(
    awk -v resource=$resource \
        -f $HOME/bin/util/fish/omni-TUI-parse-resource \
        $resources_dir/$topic.md
)

if test -z "$fetch_resource_cmd"
    return
end

# Don't quote `$fetch_resource_cmd`; it could be a multiline shell command.
commandline --replace -- $fetch_resource_cmd
