vim9script

import autoload './fold/foldexpr.vim'
import autoload './fold/foldtitle.vim'

export def Settings()
    &l:foldmethod = 'expr'
    &l:foldtext = 'foldtitle.Get()'
    &l:foldexpr = 'foldexpr.Stacked()'
    &l:conceallevel = 2
    &l:concealcursor = 'nc'
enddef
