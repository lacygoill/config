# read the README page

<https://github.com/junegunn/fzf>

It seems that some options/functions are not documented anywhere else.
Like `FZF_COMPLETION_TRIGGER` and `_fzf_comprun`.

# read the wiki

#
# support fuzzy completion

- <https://github.com/junegunn/fzf#fuzzy-completion-for-bash-and-zsh>
- <https://github.com/junegunn/fzf/issues/484>
- <https://github.com/oh-my-fish/plugin-expand>
- <https://github.com/oh-my-fish/plugin-expand/issues/2>
- <https://github.com/oh-my-fish/plugin-expand/pull/6>

# do we need to convert these zsh init scripts?

    # for auto-completion
    ~/.fzf/shell/completion.zsh

    # for key bindings
    ~/.fzf/shell/key-bindings.zsh

# try to use `--track`

The man page says it's useful when  browsing logs while sorting is disabled with
`--no-sort`.

# create mapping to fuzzy search old commit messages

It would be handy to paste an old commit messages.
Easier  than blindly  pressing `[m`  or `]m`  (custom mappings)  in a  gitcommit
buffer until we stumble upon the one we're looking for.
