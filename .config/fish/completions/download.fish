complete --command=download --no-files

# subcommands {{{1
# `$ download audio` {{{2

complete --command=download \
    --condition='__fish_use_subcommand' \
    --arguments=audio \
    --description='download audio from URL as mp3 file'

# `$ download comments` {{{2

complete --command=download \
    --condition='__fish_use_subcommand' \
    --arguments=comments \
    --description='download comments from video URL as JSON file'

# `$ download playlist` {{{2

complete --command=download \
    --condition='__fish_use_subcommand' \
    --arguments=playlist \
    --description='download playlist from URL'

# `$ download subtitle` {{{2

complete --command=download \
    --condition='__fish_use_subcommand' \
    --arguments=subtitle \
    --description='download subtitle for local video file'

# `$ download subtitle-URL` {{{2

complete --command=download \
    --condition='__fish_use_subcommand' \
    --arguments=subtitle-URL \
    --description='download subtitle from video URL'

# `$ download P2P` {{{2

complete --command=download \
    --condition='__fish_use_subcommand' \
    --arguments=P2P \
    --description='download torrent or magnet link'

# `$ download URI` {{{2

complete --command=download \
    --condition='__fish_use_subcommand' \
    --arguments=URI \
    --description='download any kind of file from URI'

# `$ download video` {{{2

complete --command=download \
    --condition='__fish_use_subcommand' \
    --arguments=video \
    --description='download video from URL'
# }}}1
# subcommands arguments {{{1
# `$ download subtitle` {{{2

complete --command=download \
    --condition='__fish_seen_subcommand_from subtitle' \
    --long-option 'de' \
    --description='german'

complete --command=download \
    --condition='__fish_seen_subcommand_from subtitle' \
    --long-option 'en' \
    --description='english'

complete --command=download \
    --condition='__fish_seen_subcommand_from subtitle' \
    --long-option 'es' \
    --description='spanish'

complete --command=download \
    --condition='__fish_seen_subcommand_from subtitle' \
    --long-option 'fr' \
    --description='french'

complete --command=download \
    --condition='__fish_seen_subcommand_from subtitle' \
    --long-option 'ja' \
    --description='japanese'

complete --command=download \
    --condition='__fish_seen_subcommand_from subtitle' \
    --long-option 'zh' \
    --description='chinese'

complete --command=download \
    --condition='__fish_seen_subcommand_from subtitle' \
    --arguments='$(_complete_media_files)'

# `$ download P2P` {{{2

# `$ download P2P some.torrent`
complete --command=download \
    --condition='__fish_seen_subcommand_from P2P' \
    --arguments='$(find . $FIND_OPTS -name "*.torrent" -printf "%P\n" 2>/dev/null)'

# `$ download URI` {{{2

# `$ download URI some.torrent`
complete --command=download \
    --condition='__fish_prev_arg_in URI' \
    --arguments='$(find . $FIND_OPTS -name "*.torrent" -printf "%P\n" 2>/dev/null)'
