set -f pgm $(
    find $HOME/Wiki/cheatkeys/ -type f -printf '%P\n' \
    | sort \
    | fzf  --bind='alt-e:execute(editor ~/Wiki/cheatkeys/{} >$(tty))' \
)
commandline --function repaint

if test -z "$pgm"
    return
end

editor +"edit ~/Wiki/cheatkeys/$pgm"
commandline --function repaint
