vim9script

# TODO: All of this should be handled by a git hook.{{{
#
# We can't write a global hook; it would make it difficult to use hooks local to
# a repo.
#
# First, we need to write the hook.
#
# Then, we need to  write a template which automatically creates  this hook in a
# new repo.  We'll also need to copy  that hook in various old repos (mainly Vim
# plugins?).
#
# Also, if we re-use an old message, rename the files so that it's sorted first.
# It should appear first in our Vim fuzzy popup.
# To achieve this, when the hook finds  out that the message is already saved in
# a file, before bailing out, it should  first check whether that file is sorted
# first; and if it's not, then it should rename the files.
#
# BTW, this might help:
# https://superuser.com/questions/386199/how-to-remove-duplicated-files-in-a-directory
#}}}

# Interface {{{1
export def SaveNextMessage(when: string) #{{{2
    if when =~ '\cBufWinLeave'
        augroup MyCommitMsgSave
            autocmd! * <buffer>
            autocmd BufWinLeave <buffer> SaveNextMessage('now')
        augroup END
    else
        # Leave this statement at the very beginning.{{{
        #
        # If an error occurred in the function, the rest of the statements would
        # not be processed.  We want our autocmd to be cleared no matter what.
        #}}}
        silent! autocmd! MyCommitMsgSave * <buffer=abuf>

        cursor(1, 1)
        var msg_last_line: number = search('^#', 'cnW') - 1
        if msg_last_line > 0
            var msg: list<string> = getline(1, msg_last_line)
            var md5: string = GetMd5(msg)
            # save the message in a file if it has never been saved
            if readfile(CHECKSUM_FILE)->match($'^\C{md5}  ') == -1
                Write(msg, md5)
                g:GITCOMMIT_LAST_MSGFILE = GetMsgfiles()[-1]
            endif
        endif
        # can't save too many old messages
        MaybeRemoveOldestMsgfile()
    endif
enddef
# }}}1
# Core {{{1
def MaybeRemoveOldestMsgfile() #{{{2
    var msgfiles: list<string> = GetMsgfiles()
    if len(msgfiles) > MAX_MESSAGES
        var oldest: string = msgfiles[0]
        delete(oldest)
    endif
enddef

def Write(msg: list<string>, md5: string) #{{{2
    # generate filename with current time and date
    var file: string = $'{$COMMIT_MESSAGES_DIR}/{strftime(FMT)}.txt'
    # save message in a file
    writefile(msg, file)
    # update checksum file
    writefile([$'{md5}  {file->fnamemodify(':t')}'], CHECKSUM_FILE, 'a')
enddef
# }}}1
# Utilities {{{1
def GetMsgfiles(): list<string> #{{{2
    return $COMMIT_MESSAGES_DIR
        ->readdir((n: string): bool => n =~ '\.txt$')
        ->map((_, v: string) => $'{$COMMIT_MESSAGES_DIR}/{v}')
enddef

def GetMd5(msg: list<string>): string #{{{2
    silent return ('md5sum <<< ' .. msg->join("\n")->string())
        ->system()
        ->matchstr('[a-f0-9]*')
enddef

def CreateChecksumFile() #{{{2
    # create the file
    writefile([], CHECKSUM_FILE)
    for file: string in GetMsgfiles()
        var msg: list<string> = readfile(file)
        var md5: string = GetMd5(msg)
        var m: string = $'{md5}  {file->fnamemodify(':t')}'
        # append a line in the file for each past git commit message
        writefile([m], CHECKSUM_FILE, 'a')
    endfor
enddef
#}}}1
# Init {{{1

# The init section needs to be at the end because it calls `CreateChecksumFile()`.
# The function must exist.

const MAX_MESSAGES: number = 100
# Isn't `%S` overkill?{{{
#
# No, we need the seconds in a file title to avoid overwriting a message file if
# we commit twice in less than a minute.
#}}}
const FMT: string = '%Y-%m-%d__%H-%M-%S'
const CHECKSUM_FILE: string = $'{$COMMIT_MESSAGES_DIR}/checksums'
if !filereadable(CHECKSUM_FILE)
    CreateChecksumFile()
endif
