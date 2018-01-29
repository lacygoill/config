# coding=utf-8
#
# The previous line  allows us to use unicode characters  in comments (like …)
# without python raising an exception.
#
#     https://stackoverflow.com/a/10589674/9110115
#     https://stackoverflow.com/a/729016/9110115
#
# The `-*-` prefix/suffix are not necessary, unless you use Emacs.

import re
import vim

def my_func(snip):
    return snip.line

def my_index(a_list, pat):
    pattern = re.compile(pat)
    for i, s in enumerate(a_list):
        if pattern.match(s):
            return i
    return -1

def find_tagname(snip):
    # TODO:
    # replace `4` with the number of lines inside the expanded snippet
    # return ''
    a_list = reversed(snip.buffer[0 : vim.current.window.cursor[0] - 4])
    idx = my_index(a_list, '.*lg-lib-\d+')
    address = len(snip.buffer) - 1 - idx - 4
    text = snip.buffer[address - 1]
    # FIXME:
    # Doesn't work.
    # It  does if  you replace  `address  - 1`  in  the previous  line with  the
    # value it gets at runtime.
    # Or if you add after the `address` assignment:
    #
    #     address = address + (idx - {some_number})
    #
    # … where {some_number} is the value of `idx` at runtime.
    #
    # For some reason, because we retrieve the line from `snip.buffer` via
    # `address - 1`, `re.search('…', text)` outputs None. IOW, `search()`
    # fails to find the pattern in the line.
    return get_info(text)

def get_info(text):
    try:
       return re.search('.*lg-lib-(\d+)', text).group(1)
    except AttributeError:
       return ''
