"""Jump to the next most interesting buffer with unread messages."""

from math import inf
from typing import Any, Dict

import weechat as w

SCRIPT: str = '_jump_smart'
AUTHOR: str = 'lacygoill'
VERSION: str = '1.0'
LICENSE: str = 'GPL3'
DESC: str = 'jump to next buffer containing unread messages in "smart" way'

if w.register(SCRIPT, AUTHOR, VERSION, LICENSE, DESC, '', ''):
    COMMAND: str = 'jump_smart'
    ARGS: str = ''
    ARGS_DESC: str = ''
    COMPLETION: str = ''
    CALLBACK: str = 'jump_smart_cb'
    w.hook_command(COMMAND, DESC, ARGS, ARGS_DESC, COMPLETION, CALLBACK, '')

PRIORITY_HIGHLIGHT: int = 3
PRIORITY_PRIVATE: int = 2
PRIORITY_MESSAGE: int = 1
PRIORITY_LOW: int = 0

UNSET: int = -1


def jump_smart_cb(*_: Any) -> int:
    """Callback for /jump_smart command.

    Jump to the most interesting buffer in the hotlist.

    In descending order of interest:

       - non-server buffers with highlights
       - non-server buffers with private messages
       - core buffer
       - server buffers with highlights
       - server buffers with private messages
       - buffers with user messages
       - buffers with low importance messages

    For private buffers or with highlights, find the one with the oldest
    creation time.  For other buffers, find the one with the most unread
    messages.
    """

    result: Dict[str, float] = {
        'bufnr': UNSET,
        'priority': UNSET,
        'time': inf,
        'count': inf,
    }

    hdata_buffer: str = w.hdata_get('buffer')
    # `hotlist` vs `gui_hotlist`:{{{
    #
    # WeeChat remembers more than what is  currently displayed in the hotline of
    # the status bar, in order to implement `/hotlist restore [-all]`.
    #
    # I *think* `hotlist` contains info about all items which are or were in the
    # hotlist, while `gui_hotlist` only contains info  about a given item in the
    # currently displayed hotlist.
    #}}}
    hdata_hotlist: str = w.hdata_get('hotlist')
    gui_hotlist: str = w.hdata_get_list(hdata_hotlist, 'gui_hotlist')

    # iterate over items in displayed hotlist
    while gui_hotlist:
        # get buffer out of item in displayed hotlist
        buf: str = w.hdata_pointer(hdata_hotlist, gui_hotlist, 'buffer')
        # always make sure a pointer is not NULL
        if not buf:
            gui_hotlist = w.hdata_pointer(hdata_hotlist, gui_hotlist, 'next_hotlist')
            continue

        # get other info out of this item
        priority: int = w.hdata_integer(hdata_hotlist, gui_hotlist, 'priority')
        time: int = w.hdata_time(hdata_hotlist, gui_hotlist, 'creation_time.tv_sec')
        count: int = w.hdata_integer(hdata_hotlist, gui_hotlist, f'{priority}|count')

        # get some buffer's properties
        bufnr: int = w.hdata_integer(hdata_buffer, buf, 'number')
        buftype: str = w.buffer_get_string(buf, 'localvar_type')
        is_core: bool = w.buffer_get_string(buf, 'localvar_plugin') == 'core'

        is_interesting: bool = False

        # non-server buffer with highlights
        if (
            priority == PRIORITY_HIGHLIGHT and buftype != 'server'
            # prioritize oldest highlight
            and time < result['time']
        ):
            is_interesting = True

        # non-server buffer with private messages
        # Don't replace `elif` with `if`.{{{
        #
        # You could;  the logic  would remain  the same.  But  it would  be less
        # efficient.  As soon as we find  out that the buffer is interesting for
        # a given  reason, there is  no point checking whether  it's interesting
        # for yet another reason.
        #}}}
        elif (
            priority == PRIORITY_PRIVATE and buftype != 'server'
            # make sure current result is *less* relevant than this buffer
            and (
                result['priority'] < PRIORITY_PRIVATE
                or (result['priority'] == PRIORITY_PRIVATE and result['time'] > time)
            )
        ):
            is_interesting = True

        # core buffer
        elif is_core:
            is_interesting = True

        # server buffer with highlights
        elif (
            priority == PRIORITY_HIGHLIGHT and buftype == 'server'
            and (
                result['priority'] < PRIORITY_HIGHLIGHT
                or (result['priority'] == PRIORITY_HIGHLIGHT and result['time'] > time)
            )
        ):
            is_interesting = True

        # server buffer with private messages
        elif (
            priority == PRIORITY_PRIVATE and buftype == 'server'
            and (
                result['priority'] < PRIORITY_PRIVATE
                or (result['priority'] == PRIORITY_PRIVATE and result['time'] > time)
            )
        ):
            is_interesting = True

        # buffer with user messages
        elif (
            priority == PRIORITY_MESSAGE
            and (
                result['priority'] < PRIORITY_MESSAGE
                or (result['priority'] == PRIORITY_MESSAGE and result['count'] > count)
            )
        ):
            is_interesting = True

        # buffer with low importance messages
        elif (
            priority == PRIORITY_LOW
            and result['priority'] <= PRIORITY_LOW and result['count'] > count
        ):
            is_interesting = True

        if is_interesting:
            result = {
                'bufnr': bufnr,
                'priority': priority,
                'time': time,
                'count': count,
            }

        # get next item in hotlist
        gui_hotlist = w.hdata_pointer(hdata_hotlist, gui_hotlist, 'next_hotlist')

    if result['bufnr'] != UNSET:
        w.command(buf, f'/buffer {result["bufnr"]}')

    return w.WEECHAT_RC_OK
