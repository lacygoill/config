# We want to be able to complete both media files and paths.
# We decide which one based on the nature of the current token:
#
#    - empty: media files in CWD
#    - given directory: media files inside the latter
#    - anything else: let regular path completion do its job
complete --command=mpv \
    --no-files \
    --condition='test -z "$(commandline --cut-at-cursor --current-token)" || _complete_is_directory' \
    --arguments='$(_complete_media_files)'

# We still  want to  be able  to complete  `--option`s.  Include  the completion
# shipped with fish.
source $__fish_data_dir/completions/mpv.fish
