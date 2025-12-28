"""Transpose words if the input is not empty.  Otherwise, toggle timestamps."""

from typing import List

import re
import weechat as w

SCRIPT: str = '_transpose_words'
AUTHOR: str = 'lacygoill'
VERSION: str = '1.0'
LICENSE: str = 'GPL3'
DESC: str = 'transpose words if input is not empty; otherwise, toggle timestamps'

ALTERNATIVE_TO_TRANSPOSE_CMD: str = '/mute /toggle weechat.look.buffer_time_format'

if w.register(SCRIPT, AUTHOR, VERSION, LICENSE, DESC, '', ''):
    COMMAND: str = 'transpose_words'
    ARGS: str = ''
    ARGS_DESC: str = ''
    COMPLETION: str = ''
    CALLBACK: str = 'transpose_words_cb'
    w.hook_command(COMMAND, DESC, ARGS, ARGS_DESC, COMPLETION, CALLBACK, '')


def transpose_words_cb(_: str, buf: str, __: str) -> int:
    """Callback for /transpose_words command."""

    # Special Case: input is empty (nothing to transpose)
    line: str = w.buffer_get_string(buf, 'input')
    if not line:
        w.command(buf, ALTERNATIVE_TO_TRANSPOSE_CMD)
        return w.WEECHAT_RC_OK

    # General Case: transpose words

    #        line
    #     v---------v
    #     'a bb+-ccc'
    #     =>
    #     ['a', ' ', 'bb', '+-', 'ccc']
    #     ^---------------------------^
    #                tokens
    tokens: List[str] = re.split(r'(?<=\w)(?=\W)|(?<=\W)(?=\w)', line)

    n_tokens: int = len(tokens)
    if (
        #     ▫a
        #     ^
        #     space
        n_tokens < 3
        #     ▫a▫
        or n_tokens == 3 and re.search(r'\W', tokens[0])
    ):
        return w.WEECHAT_RC_OK

    # find the index of the token under the cursor
    i: int = 0
    pos: int = 0
    cursor_pos: int = w.buffer_get_integer(buf, 'input_pos')
    for i, token in enumerate(tokens):
        pos += len(token)
        if pos > cursor_pos:
            break
    cursor: int = i

    # nothing to transpose if there is no word before
    if cursor == 0 or cursor == 1 and re.search(r'\W', tokens[0]):
        return w.WEECHAT_RC_OK

    last: int = n_tokens - 1
    cursor = min([cursor, last])

    # We're on a non-word character after the last word.
    #
    #     # cursor is somewhere here
    #              vvv
    #     foo+++bar---
    #     →
    #     bar---+++foo
    #     # `bar---` has been exchanged with `foo`
    if not re.search(r'\w', ''.join(tokens[cursor:])):
        if len(tokens) >= 5:
            tokens = tokens[0:-4] + tokens[-2:] + [tokens[-3]] + [tokens[-4]]
        else:
            tokens = tokens[-2:] + [tokens[-3]] + [tokens[-4]]
        w.buffer_set(buf, 'input', ''.join(tokens))
        w.command(buf, '/input move_end_of_line')
        return w.WEECHAT_RC_OK

    offset: int = (
        2 if cursor == last and re.search(r'\W', tokens[-1])
        else 1 if re.search(r'\w', tokens[cursor])
        else 0
    )

    word_1: str
    between: str
    word_2: str
    word_1, between, word_2 = tokens[cursor - 1 - offset : cursor + 2 - offset]

    before: str = ''.join(tokens[: cursor - 1 - offset])
    after: str = ''.join(tokens[cursor + 2 - offset :])

    w.buffer_set(buf, 'input', f'{before}{word_2}{between}{word_1}{after}')
    # Alternative to set cursor position:
    #     w.buffer_set(buf, 'input_pos', str(len(line) - len(after)))
    w.command(buf, '/input move_next_word')

    return w.WEECHAT_RC_OK


# Alternative to transpose words:{{{
#
#         pos: int = w.buffer_get_integer(buf, 'input_pos')
#         if not something_to_transpose(line, pos):
#             return w.WEECHAT_RC_OK
#
#         w.command(buf, '/input move_previous_word')
#         if should_move_back_2_words(line, pos):
#             w.command(buf, '/input move_previous_word')
#         word_1_start: int = w.buffer_get_integer(buf, 'input_pos')
#         w.command(buf, '/input move_next_word')
#         word_1_end: int = w.buffer_get_integer(buf, 'input_pos')
#
#         w.command(buf, '/input move_next_word')
#         word_2_end: int = w.buffer_get_integer(buf, 'input_pos')
#         w.command(buf, '/input move_previous_word')
#         word_2_start: int = w.buffer_get_integer(buf, 'input_pos')
#
#         word_1: str = line[word_1_start : word_1_end]
#         word_2: str = line[word_2_start : word_2_end]
#
#         before: str = line[: word_1_start]
#         after: str = line[word_2_end :]
#
#         between: str = line[word_1_end : word_2_start]
#
#         new_input: str = f'{before}{word_2}{between}{word_1}{after}'
#         w.buffer_set(buf, 'input', new_input)
#         w.buffer_set(buf, 'input_pos', str(word_2_end))
#
#         return w.WEECHAT_RC_OK
#
#     def something_to_transpose(line: str, pos: int) -> bool:
#         """Return True if a transposition is possible on the current input line.
#
#         That is, there should be at least 2 words on the input line.
#         And the cursor should be after at least 1 whole word.
#         """
#         if not re.match(r'\W*\w+\W+\w+', line):
#             return False
#
#         m: Optional[Match[str]] = re.match(r'\W*\w+', line)
#         assert m is not None
#         if pos < len(m.group(0)):
#             return False
#
#         return True
#
#     def should_move_back_2_words(line: str, pos: int) -> bool:
#         """Return True if we should move back 2 words instead of just 1."""
#
#         char_under_cursor: str
#         try:
#             char_under_cursor = line[pos]
#         except IndexError:
#             return True
#
#         # we're in the middle of a word, or at its end (but not on its first character)
#         if re.search(r'\w', char_under_cursor) and re.search(r'\w', line[pos - 1]):
#             return True
#
#         # we're not on a word, and there is no word anywhere afterward
#         if re.search(r'\W', char_under_cursor) and not re.search(r'\w', line[pos :]):
#             return True
#
#         return False
#
# Requires this import:
#
#     from typing import Match, Optional
#
# Edit: Actually, it doesn't correctly handle the  special case where we're on a
# non-word character after the last word.
