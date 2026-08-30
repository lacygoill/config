"""Change the characters' case till the word's end if the input is not empty.

Otherwise, execute given useful interactive command.
"""

import re
import weechat as w

SCRIPT: str = '_change_case'
AUTHOR: str = 'lacygoill'
VERSION: str = '1.0'
LICENSE: str = 'GPL3'
DESC: str = "change case till word's end (fall back on given command if input empty)"

# Alternative commands to execute instead of changing case of word (when input is empty).
#
#                                              toggle `/fset` buffer
#                                v-----------------------------------------------v
ALTERNATIVE_TO_LOWER_CMD: str = '/eval ${if:${name} != fset ?/fset :/buffer close}'
ALTERNATIVE_TO_UPPER_CMD: str = '/window scroll_unread'

if w.register(SCRIPT, AUTHOR, VERSION, LICENSE, DESC, '', ''):
    COMMAND: str = 'change_case'
    ARGS: str = ''
    ARGS_DESC: str = ''
    COMPLETION: str = ''
    CALLBACK: str = 'change_case_cb'
    w.hook_command(COMMAND, DESC, ARGS, ARGS_DESC, COMPLETION, CALLBACK, '')


def change_case_cb(_: str, buf: str, how: str) -> int:
    """Callback for /change_case command.

    Args:
        buf: Buffer in which the input line should be changed.

        how: How the case of the word should be changed:
            - `upper` to uppercase
            - `lower` to lowercase
            - `capitalize` to capitalize
    """

    # Special Case: input is empty (no case to change)
    line: str = w.buffer_get_string(buf, 'input')
    if not line:
        if how == 'lower':
            w.command(buf, ALTERNATIVE_TO_LOWER_CMD)
        elif how == 'upper':
            w.command(buf, ALTERNATIVE_TO_UPPER_CMD)
        return w.WEECHAT_RC_OK

    # General Case: change case

    old_pos: int = w.buffer_get_integer(buf, 'input_pos')
    w.command(buf, '/input move_next_word')
    new_pos: int = w.buffer_get_integer(buf, 'input_pos')

    input_before: str = line[: old_pos]
    input_after: str = line[new_pos :]

    old_word: str = line[old_pos : new_pos]
    new_word: str
    if how == 'capitalize':
        new_word = re.sub(
            r'(\W*)(\w+)', lambda m: m.group(1) + m.group(2).capitalize(), old_word
        )
    else:
        new_word = getattr(old_word, how)()

    new_input: str = f'{input_before}{new_word}{input_after}'

    w.buffer_set(buf, 'input', new_input)
    return w.WEECHAT_RC_OK
