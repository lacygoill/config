vim9script

import autoload '../fz.vim'

export def Files() # {{{1
    fz.Run({
        options: ['--multi', $'--prompt="Config Files {$FZF_PROMPT}"'],
        source: systemlist('config ls-files'),
    })
enddef
