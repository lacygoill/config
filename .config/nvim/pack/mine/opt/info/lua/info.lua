local info = {}
local fn, uv = vim.fn, vim.loop

-- Interface {{{1
function info.full_path() -- {{{2
  if vim.bo.buftype == 'quickfix' then
    local out = vim.w.quickfix_title or 'no title'
    fn.setreg('o', { out }, 'c')
    print(fn.getreg('o'))
    return
  end

  local fname = fn.expand('%:p')

  -- later, we'll  compare `fname`  with its resolved  form, and  the comparison
  -- might be wrongly different because of an extra ending slash
  fname = string.gsub(fname, '/$', '')

  if fname == '' then
    fn.setreg('o', { '[No Name]' }, 'c')
  else
    if fname:sub(1, 1) == '/' or fname:match('^%l+://') then
      local resolved = uv.fs_realpath(fname)
      local out = resolved == fname and fname or fname .. ' -> ' .. resolved
      fn.setreg('o', { out }, 'c')
    else
      -- Why is adding the current working directory sometimes necessary? {{{
      --
      -- If you edit a new buffer whose path is relative (to the working
      -- directory), `expand('%:p')` will return a relative path:
      --
      --     :cd /tmp
      --     :edit foo/bar
      --     :echo expand('%:p')
      -- }}}
      local out = fn.getcwd() .. '/' .. fname
      fn.setreg('o', { out }, 'c')
    end
  end

  print(fn.getreg('o'))
end

function info.current_working_directory() -- {{{2
  fn.setreg('o', {
    'window:  ' .. fn.getcwd(),
    'tabpage: ' .. fn.getcwd(-1, 0),
    'global:  ' .. fn.getcwd(-1)
  }, 'c')
  -- 'c' instead of 'l' to prevent the insertion of a trailing newline

  vim.cmd.echo('@o')
end
-- }}}1

return info
