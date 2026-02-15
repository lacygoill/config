vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import autoload '../autoload/fish.vim'

augroup FishTemplate
    autocmd!
    autocmd BufNewFile */completions/*.fish fish.ReadTemplate()
augroup END

# We could be in a bash shell, where `__fish_config_dir` is not set.
if getenv('__fish_config_dir') == null
    finish
endif

var conf_files: list<string> = [$__fish_config_dir .. '/config.fish']
    + readdir($__fish_config_dir .. '/conf.d/')
    ->map((_, v: string) => $__fish_config_dir .. '/conf.d/' .. v)

# Let's erase universal variables.  They interfere too much when we try to change our config.{{{
#
# Their purpose is  to configure all the currently running  shells, as well as
# all the future ones.  To achieve this, they need a file cache:
#
#     ~/.config/fish/fish_variables
#}}}
augroup FishRemoveUniversalVariables
    autocmd!
    execute 'autocmd BufWritePost ' .. conf_files->join(',') .. ' fish.RemoveUniversalVariables()'
augroup END
