set -f cmd $(
      commandline --current-process \
    | string match --regex --groups-only '^\s*([-_[:alnum:]]+)' \
)
if test -n "$cmd"
    set -f pgm $cmd
else
    set -f pgm $(
          complete --do-complete \
        | awk '/command( link)?$/ { print $1 }' \
        | uniq \
        | fzf \
    )
    commandline --function repaint
end

if test -z "$pgm"
    return
end

if ! tldr $pgm >/dev/null 2>&1
    return
end

set -f snippet $(navi --tldr=$pgm --print)
commandline --function repaint

if test -z "$snippet"
    return
end

commandline --replace --current-process -- $(string trim -- $snippet)
commandline --function repaint
