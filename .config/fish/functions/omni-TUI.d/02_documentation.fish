set -f interesting changelog contrib examples faq news readme
set -f interesting $(string join -- ' | ' $interesting)
set -f interesting "$interesting "

find /usr/share/doc $FIND_OPTS -type f,l -print \
    | sort \
    | fzf --bind='alt-e:execute(editor {})' \
        --bind='enter:become(editor {+})' \
        --delimiter=/ \
        --multi \
        --preview-window=nohidden \
        --query=$interesting \
        --with-nth=5..

commandline --function repaint
