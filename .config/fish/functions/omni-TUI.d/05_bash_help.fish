set -f topic $(bash -c 'compgen -A helptopic' | sort | fzf)
commandline --function repaint

if test -z "$topic"
    return
end

bash -c "help $topic" | less
