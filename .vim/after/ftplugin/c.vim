setl cms=/*%s*/

" teardown {{{1

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
    \ . (empty(get(b:, 'undo_ftplugin', '')) ? '' : '|')
    \ . "
    \ setl cms<
    \ "

