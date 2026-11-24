# This function should cd into the most recently changed directory.{{{
#
# It's especially useful to enter a freshly-cloned repo:
#
#     $ git clone url ; cdd
#}}}

function cdd
    # `%Z` will be replaced with the time of last status change (in seconds since Epoch).
    # `%n` will be replaced with the filename.
    set -f most_recent_dir $(
        find -maxdepth 1 $FIND_OPTS -type d -exec /usr/bin/stat --format='%Z %n' '{}' \+ \
      | sort --key=1bnr,1 \
      | awk 'NR == 1 {
            printf("%s", $2)
            # the directory name might contain spaces
            for (i = 3; i <= NF; i++)
                printf(" %s", $i)
            exit
        }'
    )

    if test -z "$most_recent_dir"
        return 1
    end

    cd -- $most_recent_dir
end
