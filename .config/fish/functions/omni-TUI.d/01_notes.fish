set -f delim ' '
set -f chosen $(
    $HOME/bin/util/notes-headers $topic \
        | fzf --ansi \
            --bind='alt-e:execute(editor +{4} +"normal! zvzz" {3} >$(tty))' \
            --delimiter=$delim \
            --expect=ctrl-q \
            --multi \
            --print-query \
            --query='!annex !glossary !issues !pitfalls !syntax !todo ' \
            --with-nth=1..2
)
commandline --function repaint

set -f query $chosen[1]
set --erase chosen[1]
set -f query $(string replace --regex '^(\s*!\S*\s*)*' '' -- $query)

if ! set --query chosen[1]
    return
end

set -f key $chosen[1]
set --erase chosen[1]
if test "$key" = 'ctrl-q'
    set -f errorfile $(mktemp)
    string replace --regex -- '([^'$delim']*)'$delim'[^'$delim']*'$delim'([^'$delim']*)'$delim'([^'$delim']*)' '$2:$3:$1' $chosen >$errorfile

    set -f title notes
    if test -n "$query"
        set -f --append title "query=$query"
    end
    set -f title $(string replace --all -- "'" \x01 $title)

    editor +"cfile $errorfile" \
        +"call delete('$errorfile')" \
        +"call setqflist([], 'a', {'title': '$title'->tr(\"\x01\", \"'\")})" \
        +'normal! zvzz'
    return
end

string match --regex --quiet '([^'$delim']*'$delim'){2}(?<filename>[^'$delim']*)'$delim'(?<lnum>.*)' -- $chosen

if test -z "$filename" || test -z "$lnum"
    return
end

editor +$lnum +'normal! zvzz' $filename
