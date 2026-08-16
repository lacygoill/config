"""Save content of current buffer into a file."""
# Adapted from: https://weechat.org/scripts/source/bufsave.py.html/
# Original author: xt <xt@bash.no>

from os import environ
from os.path import exists

import weechat as w

SCRIPT: str = '_bufsave'
AUTHOR: str = 'lacygoill'
VERSION: str = '1.0'
LICENSE: str = 'GPL3'
DESC: str = 'save content of current buffer into file'

DEFAULT_LOGFILE: str = f'{environ["TMPDIR"]}/weechat/bufsave.log'

if w.register(SCRIPT, AUTHOR, VERSION, LICENSE, DESC, '', ''):
    # Can't call `config_*()` functions from the `weechat` module until the script is registered:{{{
    #
    #     ✘ │ python: unable to call function "config_get", script is not initialized (script: -)
    #     ✘ │ python: unable to call function "config_string", script is not initialized (script: -)
    # }}}
    PREFIX_SUFFIX: str = w.config_string(w.config_get('weechat.look.prefix_suffix'))
    PREFIX_ALIGN_MAX: int = w.config_integer(
        w.config_get('weechat.look.prefix_align_max')
    )
    PREFIX_ALIGN_MORE: str = w.config_string(
        w.config_get('weechat.look.prefix_align_more')
    )

    COMMAND: str = 'bufsave'
    ARGS: str = '<file>'
    ARGS_DESC: str = 'file: target file (must not exist)\n'
    #    > Plugin  |   Name   | Description
    #    > [...]
    #    > weechat | filename | filename; optional argument: default path (evaluated, see /help eval)
    #
    # Source: https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#_hook_command
    COMPLETION: str = '%(filename)'
    CALLBACK: str = 'bufsave_cb'

    w.hook_command(COMMAND, DESC, ARGS, ARGS_DESC, COMPLETION, CALLBACK, '')


def bufsave_cb(_: str, buf: str, fname: str) -> int:
    """Callback for /bufsave command."""

    where_to_save: str = (
        DEFAULT_LOGFILE
        if not fname
        else w.string_eval_path_home(fname, {}, {}, {})
    )

    if where_to_save != DEFAULT_LOGFILE and exists(where_to_save):
        w.prnt(buf, f'Cannot overwrite existing file: {where_to_save}')
        return w.WEECHAT_RC_OK

    try:
        with open(where_to_save, 'w', encoding='utf-8') as fh:
            # What's the difference between `lines` and `own_lines`?{{{
            #
            # When multiple buffers are merged,  `lines` contains lines from all
            # of  them.  OTOH,  `own_lines`  only contains  lines  from a  given
            # buffer.
            # }}}
            # Breaking down:{{{
            #
            # There are several hdata.  We want the one about buffers:
            #
            #     own_lines: str = w.hdata_pointer(w.hdata_get('buffer'), buf, 'own_lines')
            #                                      ^-------------------^
            #
            # Inside that hdata, we're only  interested in the buffer object for
            # which `/bufsave` was executed:
            #
            #     own_lines = w.hdata_pointer(w.hdata_get('buffer'), buf, 'own_lines')
            #                                                        ^^^
            #
            # Inside that object, we're only interested in `own_lines`:
            #
            #     own_lines: str = w.hdata_pointer(w.hdata_get('buffer'), buf, 'own_lines')
            #                                                                  ^---------^
            #
            # And we need to call `hdata_pointer()`:
            #
            #     own_lines: str = w.hdata_pointer(w.hdata_get('buffer'), buf, 'own_lines')
            #                        ^-----------^
            #
            # Because `own_lines` is documented as a pointer:
            #
            #    > own_lines   (**pointer**, hdata: "lines")
            #
            # Source: https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#hdata_buffer
            # See also: https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#_hdata_pointer
            # }}}
            own_lines: str = w.hdata_pointer(w.hdata_get('buffer'), buf, 'own_lines')
            if not own_lines:
                return w.WEECHAT_RC_OK

            hdata_line: str = w.hdata_get('line')
            hdata_line_data: str = w.hdata_get('line_data')

            buftype: str = w.buffer_get_string(buf, 'localvar_type')
            # We use the `own_lines` pointer to retrieve the relevant lines out of the hdata `lines`.{{{
            #
            #     first_line: str = w.hdata_pointer(
            #         w.hdata_get('lines'), own_lines, 'first_line'
            #         ^------------------^  ^-------^
            #     )
            #
            # This is documented in the description of `own_lines`:
            #
            #    > own_lines   (pointer, **hdata: "lines"**)
            #
            # Source: https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#hdata_buffer
            # }}}
            # And out of those lines, we retrieve `first_line`.{{{
            #
            # This is documented in the description of `lines`:
            #
            #    > **first_line**   (pointer, hdata: "line")
            #
            # Source: https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#hdata_lines
            # }}}
            first_line: str = w.hdata_pointer(
                w.hdata_get('lines'), own_lines, 'first_line'
            )
            while first_line:
                # We use the `first_line` pointer to retrieve the relevant first text line out of the hdata `line`.{{{
                #
                #     data: str = w.hdata_pointer(hdata_line, first_line, 'data')
                #                                 ^--------^  ^--------^
                #
                # This is documented in the description of `first_line`:
                #
                #    > first_line   (pointer, **hdata: "line"**)
                #
                # Source: https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#hdata_lines
                # }}}
                # And out of this line, we retrieve `data`.{{{
                #
                # This is documented in the description of `line`:
                #
                #    > **data**   (pointer, hdata: "line_data")
                #
                # Source: https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#hdata_line
                # }}}
                data: str = w.hdata_pointer(hdata_line, first_line, 'data')
                # move  `first_line`  pointer to  next  line  so that  the  loop
                # iterates over all the lines in the buffer
                # https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#_hdata_move
                first_line = w.hdata_move(hdata_line, first_line, 1)
                if not data:
                    continue

                # We use the `data` pointer to retrieve the relevant line data out of the hdata `line_data`.{{{
                #
                #     prefix: str = remove_color(
                #         w.hdata_string(hdata_line_data, data, 'prefix')
                #                        ^-------------^  ^--^
                #     )
                #
                # This is documented in the description of `data`:
                #
                #    > data   (pointer, **hdata: "line_data"**)
                #
                # Source: https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#hdata_line
                # }}}
                # And out of this line data, we retrieve the `prefix` and `message` variables.{{{
                #
                #     prefix: str = remove_color(
                #         w.hdata_string(hdata_line_data, data, 'prefix')
                #         ^-------------^                       ^------^
                #     )
                #
                #     message: str = remove_color(
                #         w.hdata_string(hdata_line_data, data, 'message')
                #         ^------------^                        ^-------^
                #     )
                #
                # These are documented in the description of `line_data`:
                #
                #    > prefix   (shared_string)
                #    > [...]
                #    > message   (string)
                #
                # https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#hdata_line_data
                # }}}
                prefix: str = remove_color(
                    w.hdata_string(hdata_line_data, data, 'prefix')
                )
                message: str = remove_color(
                    w.hdata_string(hdata_line_data, data, 'message')
                )

                # don't save filtered lines
                displayed: int = w.hdata_char(hdata_line_data, data, 'displayed')
                if not displayed:
                    continue

                # right align prefixes inside a fixed width column
                if buftype == 'channel':
                    last_char: str = PREFIX_ALIGN_MORE if len(prefix) > PREFIX_ALIGN_MAX else ' '
                    #                    right alignment
                    #                  v-----------------v
                    prefix = f'{prefix:>{PREFIX_ALIGN_MAX}.{PREFIX_ALIGN_MAX}s}{last_char}'
                    #                                     ^-----------------^
                    #                                     truncate if necessary

                fh.write(f'{prefix}{PREFIX_SUFFIX} {message}\n')

    except OSError:
        w.prnt(buf, f'Failed to write {where_to_save}')
        return w.WEECHAT_RC_OK

    if 'TMUX' in environ:
        w.command(
            buf,
            '/exec -bg tmux display-popup'
            ' -E'
            ' -xC -yC'
            ' -w75% -h75%'
            ' -d "#{pane_current_path}"'
            f' editor {where_to_save}'
        )

    return w.WEECHAT_RC_OK


def remove_color(text: str) -> str:
    """Remove color codes from given text."""
    return w.string_remove_color(text, '')
