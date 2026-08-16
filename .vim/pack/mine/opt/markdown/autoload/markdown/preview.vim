vim9script

const HELP: list<string> =<< trim END
    Install the web server:
        $ sudo apt install git nodejs npm
        $ npm install --global instant-markdown-d
END

# If you have an issue, to debug it, you could change the assignment like this:{{{
#
#     var REDIRECTION: string = '>/tmp/log 2>&1 &'
#}}}
const REDIRECTION: string = '>/dev/null 2>&1 &'

# Interface {{{1
export def Main() #{{{2
    if !executable('instant-markdown-d')
        echo HELP->join("\n")
        return
    endif

    silent system('systemctl --user start instant-markdown-d')
    # The server is not available immediately:{{{
    #
    #     #!/bin/bash -
    #     systemctl --user stop instant-markdown-d
    #     systemctl --user start instant-markdown-d
    #     echo 'TEST' | curl --request PUT --upload-file  - http://localhost:8090
    #     curl: (7) Failed to connect to localhost port 8090: Connection refused˜
    #
    # We  need to  delay for  a few  seconds for  the document  to be  previewed
    # initially.
    #}}}
    timer_start(3'000, (_) => Refresh(true))

    augroup InstantMarkdown
        autocmd! * <buffer>
        autocmd CursorHold,InsertLeave <buffer> Refresh()
        # refresh  no   matter  what   when  we  write   the  buffer;   even  if
        # `b:changedtick` did not change
        autocmd BufWrite <buffer> Refresh(true)

        autocmd BufUnload <buffer> DeleteResource()
        # sometimes, after we quit Vim, the server still runs; make sure it does not
        autocmd VimLeave * silent system('systemctl --user stop instant-markdown-d')
    augroup END
enddef
#}}}1
# Core {{{1
def Getlines(): list<string> #{{{2
    var lines: list<string> = getline(1, '$')
    var curlnum: number = line('.')
    var blocks: list<dict<number>>

    # there might be mermaid fenced codeblocks; find where all of them are
    for [lnum: number, line: string] in lines->items()
        if line =~ '^```mermaid$'
            blocks->add({start: lnum + 1})
        elseif line =~ '^```' && !blocks->empty() && !blocks[-1]->empty()
            blocks[-1].end = lnum + 1
        endif
    endfor

    # For the document to be centered around the cursor position in Vim, we need
    # to inject an invisible marker.
    var marker_lnum: number = curlnum
    # But the  latter can  break a mermaid  diagram.  We need  to make  sure our
    # marker is not in the middle of a fenced mermaid codeblock.
    for block: dict<number> in blocks
        if !block->has_key('start') || !block->has_key('end')
            continue
        endif
        # the cursor is in the middle of a diagram
        if block.start <= curlnum && curlnum <= block.end
            # set the marker right after it
            if block.end + 1 <= line('$')
                marker_lnum = block.end + 1
            # there is nothing after; set the marker before
            elseif block.start - 1 >= 1
                marker_lnum = block.start - 1
            # there is nothing before either; don't set the marker
            else
                return lines
            endif
        endif
    endfor

    # Inject an invisible marker.{{{
    #
    # The web server will use it to  scroll the window where we've made our last
    # edit.
    # Source:
    # https://github.com/suan/vim-instant-markdown/pull/74#issue-37422001
    # https://github.com/suan/instant-markdown-d/pull/26
    #}}}
    lines[marker_lnum - 1] ..= ' <a name="#marker" id="marker"></a>'
    return lines
enddef

def DeleteResource() #{{{2
    silent system('curl'
        # silent: don't show progress meter or error messages
        .. ' --silent'
        # Specifies a custom request method to use when communicating with the HTTP server.{{{
        #
        # The  specified request  method  will  be used  instead  of the  method
        # otherwise used (which defaults to `GET`).
        #}}}
        .. $' --request DELETE http://localhost:8090 {REDIRECTION}')
    # What's the meaning of the `DELETE` method?{{{
    #
    #    > The DELETE method requests that  the origin server delete the resource
    #    > identified by the Request-URI.
    #
    # Source: https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
    #}}}
enddef

def Refresh(force: bool = false) #{{{2
    if !exists('b:changedtick_last')
        b:changedtick_last = b:changedtick

    elseif b:changedtick_last != b:changedtick || force
        b:changedtick_last = b:changedtick
        # transfer the specified local file to the remote URL
        silent system('curl --request PUT'
            # use stdin instead of a given file
            .. ' --upload-file -'
            .. ' http://localhost:8090 ' .. REDIRECTION, Getlines())
    endif
enddef
