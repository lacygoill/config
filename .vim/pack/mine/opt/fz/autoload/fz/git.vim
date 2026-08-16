vim9script

import autoload '../fz.vim'

# Interface {{{1
export def Messages() # {{{2
    fz.Run({
        options: [$'--prompt="Commits Messages {$FZF_PROMPT}"'],
        sink: PutCommitMessage,
        source: GetSource(),
    })
enddef
# }}}1
# Core {{{1
def GetSource(): list<string> # {{{2
    if getenv('COMMIT_MESSAGES_DIR') == null
        return []
    endif

    var msg_files: list<string> = readdir($COMMIT_MESSAGES_DIR)
    msg_files->remove(msg_files->index('checksums'))

    return msg_files
        ->copy()
        ->map((_, fname: string) => $'{$COMMIT_MESSAGES_DIR}/{fname}'->readfile('', 1)->get(0, ''))
enddef

def PutCommitMessage(msg: string) # {{{2
    cursor(1, 1)

    var msg_last_line: number = search('^#', 'cnW') - 1
    if msg_last_line <= 0
        return
    endif
    deletebufline(bufnr('%'), 1, msg_last_line)

    [msg, '']->append(0)
    cursor(1, 1)
enddef
