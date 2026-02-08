vim9script

import 'lg.vim'
import autoload './util.vim'

export def Main(type = ''): string #{{{1
    if type == ''
        &operatorfunc = function(lg.Opfunc, [{funcname: Main}])
        return 'g@'
    endif

    # TODO: prevent the function from doing anything if a line is already commented.
    # For example, if you press by accident `+dd` twice on the same line, it
    # shouldn't do anything the second time.
    silent normal! '[y']
    :'[,'] CommentToggle
    execute "silent :'[,']" .. ' substitute/^\s*'
        .. '\V'
        .. util.GetCml()[0]->matchstr('\S*')->escape('\/')
        .. '\m'
        .. '\zs/    /'
    normal! `]]p

    return ''
enddef
