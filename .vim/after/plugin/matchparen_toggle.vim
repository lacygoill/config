" Purpose:{{{
"
" The current script will be sourced when Vim starts.
" It will disable the `matchparen` plugin.
" But we also source it in a mapping to toggle the plugin.
"
"         ~/.vim/plugged/vim-toggle-settings/autoload/toggle_settings.vim:441
"}}}
" Warning: DO NOT rename this file to `matchparen.vim`!{{{
"
" If you do, when you'll press `cop`, you'll execute:
"     runtime! plugin/matchparen.vim
"
" This will source the current script (✔), then `$VIMRUNTIME/plugin/matchparen.vim` (✘).
" The default script would undo our toggling.
"}}}

if exists(':DoMatchParen') !=# 2 || exists('g:no_after_plugin')
    finish
endif

if exists('g:loaded_matchparen')
    " command defined in `$VIMRUNTIME/plugin/matchparen.vim`
    NoMatchParen

    " We need to always have at least one autocmd listening to `CursorMoved`.
    " Otherwise, Vim may detect the motion of the cursor too late.
    " For an explanation of the issue, see:
    "         https://github.com/vim/vim/issues/2053#issuecomment-327004968
    augroup default_cursor_moved
        au!
        au CursorMoved * "
        "                │
        "                └─ just execute a commented line
        "                   does nothing, but is just enough to register an
        "                   autocmd listening to `CursorMoved`
    augroup END

else
    " We remove the autocmd before `:DoMatchParen`, because if the latter raises
    " an error, the function would abort, and our autocmd wouldn't be removed.
    au! default_cursor_moved
    aug! default_cursor_moved
    noa DoMatchParen
endif

