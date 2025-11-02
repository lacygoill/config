"""Automatic buffer sorting based on arbitrary eval'ed expressions."""
# Adapted from: https://weechat.org/scripts/source/autosort.py.html/
# Original author: Maarten de Vries <maarten@de-vri.es>

from math import log10
from typing import Any, List

import weechat as w

SCRIPT: str = '_autosort'
AUTHOR: str = 'lacygoill'
VERSION: str = '1.0'
LICENSE: str = 'GPL3'
DESC: str = "automatic buffer sorting based on arbitrary eval'ed expressions"

# Delay in milliseconds  to wait after a signal has  been caught, before sorting
# the buffer list.  This prevents needlessly  sorting too many times if multiple
# signals arrive  in a short  time.  It  can also be  needed to wait  for buffer
# localvars to be available.
#
# In the original script, the delay was much shorter: 5ms.  But there was also a
# limit on the  frequency with which the sorting callback  could be invoked; not
# more than once every 100ms.  The overall  code was quite complex, so we simply
# use a long enough delay.
SIGNAL_DELAY: int = 100

# For a  buffer A  to be  sorted before a  buffer B,  write an  expression whose
# evaluation in the context  of A sorts before its evaluation  in the context of
# B; and put it as near from the start of the list as possible.
SORTING_EXPRESSIONS: List[str] = [
    # core first
    '${if:${buffer.full_name} != core.weechat}',
    # sort by servers (programming before warez)
    '${info:autosort_order,${server},libera,oftc,abjects,rizon,highway,undernet}',
    # for a given server, first the server buffer itself, then its channels, and
    # finally its private messages
    '${info:autosort_order,${type},server,channel,private}',
    # for channels and private buffers, sort by names
    '${buffer.name}',
]

pending_sort = None

# Interface {{{1
def autosort_cb(*_: List[Any]) -> int: # {{{2
    """Called when /autosort is executed."""

    buffers: List[str] = sorted(get_buffers(), key=evaluated_sorting_expressions)
    reorder(buffers)

    return w.WEECHAT_RC_OK

def signal_cb(*_: List[Any]) -> int: # {{{2
    """Called when a signal is caught."""

    global pending_sort

    # make sure no sort is already pending
    if pending_sort is None:
        pending_sort = w.hook_timer(SIGNAL_DELAY, 0, 1, 'sort_later_cb', '')

    return w.WEECHAT_RC_OK
# }}}1
# Core {{{1
def reorder(buffers: List[str]) -> None: # {{{2
    """Sort the buffer list according to the given order."""

    for i, buf in enumerate(buffers):
        w.buffer_set(buf, 'number', str(i + 1))

def sort_later_cb(*_: List[Any]) -> int: # {{{2
    """Called when the pending_sort timer triggers."""

    global pending_sort
    pending_sort = None

    autosort_cb()
    return w.WEECHAT_RC_OK
# }}}1
# Util {{{1
def get_buffers() -> List[str]: # {{{2
    """Get a list of all the buffers."""

    buffer: str = w.hdata_get('buffer')
    gui_buffers: str = w.hdata_get_list(buffer, 'gui_buffers')

    result: List[str] = []
    while gui_buffers:
        result.append(gui_buffers)
        gui_buffers = w.hdata_pointer(buffer, gui_buffers, 'next_buffer')

    return result

def evaluated_sorting_expressions(buf: str) -> List[str]: # {{{2
    """Return list of values eval'ed from arbitrary sorting expressions.

    Those expressions are all eval'ed in the context of a given buffer.
    The resulting list will be used to sort the buffer.
    """

    evaluations: List[str] = []

    for expr in SORTING_EXPRESSIONS:
        evaluation: str = w.string_eval_expression(expr, {'buffer': buf}, {}, {})
        # We want  caseless comparisons  when this expression  will be  used for
        # sorting,  because case  doesn't  matter for  the  IRC protocol;  hence
        # `.casefold()`.
        evaluations.append(evaluation.casefold())

    return evaluations

def info_order_cb(_: Any, __: Any, args: str) -> str: # {{{2
    """Called when an ${info:autosort_order,...} expression is evaluated.

    args should be an expression followed by a comma-separated list of values.
    The function should return the index of the evaluated expression inside the
    list.
    """

    split: List[str] = args.split(',')
    if len(split) < 2:
        return ''

    expr: str = split[0]
    values: List[str] = split[1 :]

    lv: int = len(values)
    try:
        result = values.index(expr)
    except ValueError:
        result = lv

    # pad result with leading 0s to make sure string sorting works
    width: int = int(log10(lv)) + 1
    return f'{result:0{width}}'
# }}}1

if w.register(SCRIPT, AUTHOR, VERSION, LICENSE, DESC, '', ''):
    w.hook_command('autosort', '', '', '', '', 'autosort_cb', '')
    w.hook_info('autosort_order', '', '', 'info_order_cb', '')

    # execute `/autosort` when given signals are caught
    w.hook_signal('buffer_opened;buffer_renamed', 'signal_cb', '')

    autosort_cb()
