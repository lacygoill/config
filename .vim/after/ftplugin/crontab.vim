setl cms=#\ %s

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
    \ ..'
    \ | setl cms<
    \ '

