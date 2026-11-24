vim9script

export def Link(from: string, to: string)
    execute 'highlight clear ' .. from
    execute 'highlight default link ' .. from .. ' ' .. to
enddef
