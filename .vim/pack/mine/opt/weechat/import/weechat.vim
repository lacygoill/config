vim9script

import autoload 'myfuncs.vim'

# https://weechat.org/files/doc/stable/weechat_user.en.html#colors_attributes
var attribute: string = '[%.*!/_|]'

# https://weechat.org/files/doc/stable/weechat_user.en.html#colors_basic
var basic_color: any =<< trim END
    black
    darkgray
    red
    lightred
    green
    lightgreen
    brown
    yellow
    blue
    lightblue
    magenta
    lightmagenta
    cyan
    lightcyan
    gray
    white
END
basic_color = $'\<\%({basic_color->join('\|')}\)\>'

const COLOR_VALUE: string = $'{attribute}\=\zs\%(\d\{{1,3}}\|{basic_color}\)\ze'
const COLOR_PAT: string = $'^/set .*color\S* {COLOR_VALUE}$'
    .. '\|' .. $'${{color:{COLOR_VALUE}[}},]'
    .. '\|' .. $'${{color:[^,]*,{COLOR_VALUE}[}}]'
    # special case: multiline value of `weechat.color.chat_nick_colors`
    .. '\|' .. $'^,\={COLOR_VALUE}\\'

export def HighlightColorValues()
    myfuncs.HighlightColorValues(COLOR_PAT)
enddef
