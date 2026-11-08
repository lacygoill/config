set -f config_file $(config ls-files \
    | fzf --bind='alt-e:execute(editor {} >$(tty))' \
        --multi \
        --scheme=path \
)
commandline --function repaint

if test -z "$config_file"
    return
end

editor $config_file
