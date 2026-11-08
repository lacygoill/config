vim9script

import autoload '../fz.vim'

export def Files(pattern: string) # {{{1
    fz.Run({
        options: ['--multi', $'--prompt="locate {pattern} {$FZF_PROMPT}"'],
        source: $'locate --ignore-case {pattern}',
    })
enddef
