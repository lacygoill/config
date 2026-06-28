vim9script

import autoload '../fz.vim'

# Interface {{{1
export def Fz() # {{{2
    fz.Run({
        options: [
            '--expect=ctrl-s,ctrl-v,alt-T',
            $'--prompt="Cheat Keyfiles {$FZF_PROMPT}"',
        ],
        sinklist: Open,
        source: Keyfiles(),
    })
enddef
# }}}1
# Core {{{1
def Keyfiles(): list<string> # {{{2
    return readdir($'{$HOME}/Wiki/cheatkeys/', true, {sort: 'none'})
enddef

def Open(chosen: list<string>) # {{{2
    var expected_key: string = chosen[0]
    var pgm: string = chosen[1]

    var cmd: string = {
        ctrl-s: 'split',
        ctrl-v: 'vsplit',
        alt-T: 'tab split',
    }->get(expected_key, 'edit')

    execute $'{cmd} ~/Wiki/cheatkeys/{pgm}'
enddef
