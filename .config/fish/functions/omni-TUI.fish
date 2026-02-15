# TODO: Extract any "Annex", "Glossary", "Issues", "Pitfalls", "Syntax", "Todo" section from a `README.md` file.
#
#     $ config jump grep '^#+ (annex|glossary|issues|pitfalls|syntax|todo)$'
#
# Issue: Sometimes, it's not  possible to extract a given  section because there
# are several  files in  the same  directory all with  the same  section.  Also,
# sometimes, it makes more sense to keep  the section inside the file, when it's
# really  more  about the  topic  of  that file  then  about  the topic  of  the
# containing directory.
#
# ---
#
# Try to replace "Issues" with "Pitfalls" (the former seems too generic).
#
# ---
#
# We've used "conventions" once.  Should we use that more often?  If so, support
# it here.
#
# Same question about:
#
#    - "FAQ"
#    - "antipatterns"
#    - "changelog"
#    - "compiling"
#    - "config" (or "configuration")
#    - "debug"
#    - "documentation"
#    - "examples"
#    - "install" (or "installation")
#    - "style"
#    - "syntax"
#    - "tricks"
#    - "usage" (lots of "how to" in there; turn that into snippets?)
#
# For more, see:
#
#     $ config jump grep --no-ignore-case '^# [[:upper:]]\S*\w$'
#
# ---
#
# We don't  have many `Bugs.md`  files, but use this  name for issues  which you
# think should be  fixed upstream.  Those files should contain  MREs, as well as
# expected/actual behaviors.

# TODO: Review all "Pitfalls" files.
# Try to turn some of their headers into custom lints.

function omni-TUI #{{{1
    set -f drop_in_dir $HOME/.config/fish/functions/omni-TUI.d
    set -f chosen_script $(find $drop_in_dir -maxdepth 1 -type f -execdir /usr/bin/basename --suffix='.fish' '{}' \; \
        | sort \
        | fzf --bind="alt-e:execute(editor $drop_in_dir/{}.fish >\$(tty))" \
            --delimiter='_' \
            --prompt="omni $FZF_PROMPT" \
            --with-nth='2..' \
    )
    commandline --function repaint

    if ! test -f "$drop_in_dir/$chosen_script.fish"
        return
    end
    source $drop_in_dir/$chosen_script.fish
end
