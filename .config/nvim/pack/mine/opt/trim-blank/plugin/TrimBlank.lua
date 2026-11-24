local api, fn = vim.api, vim.fn

-- TODO: Install `+t` and `+tt` mappings.

-- Init {{{1

-- module holding interface functions
local TrimBlank = {}

-- Module holding helper functions.
-- Putting them in a module lets us define them *after* they're called.
local H = {}

-- install `TrimBlank` highlight group
api.nvim_set_hl(0, 'TrimBlank', { link = 'Error' })

-- Autocmds {{{1

local augroup_id = api.nvim_create_augroup('TrimBlank', {})

-- add highlighting
api.nvim_create_autocmd({
  'VimEnter', 'WinEnter', 'BufWinEnter', 'InsertLeave' }, {
  group = augroup_id,
  pattern = '*',
  desc = 'highlight trailing whitespace',
  callback = function() TrimBlank.add_highlight() end,
})

-- remove highlighting
api.nvim_create_autocmd({
  'WinLeave', 'BufLeave', 'InsertEnter' }, {
  group = augroup_id,
  pattern = '*',
  desc = 'remove highlight of trailing whitespace',
  callback = function() TrimBlank.remove_highlight() end,
})

-- Toggle highlighting whenever a buffer becomes special
-- (`:help special-buffers`), or is no longer special.
api.nvim_create_autocmd({
  'OptionSet' }, {
  group = augroup_id,
  pattern = 'buftype',
  desc = 'highlight trailing whitespace only in non-special buffers',
  callback = function() TrimBlank.highlight_update_on_buftype_change() end,
})

-- Command {{{1

--     :TrimBlank -space
--     :TrimBlank -line
vim.api.nvim_create_user_command('TrimBlank', function(opts)
    if opts.args == '-line' then
      TrimBlank.trim_last_blank_lines()
    else
      TrimBlank.trim(opts.range, opts.line1, opts.line2)
    end
  end, {
  nargs = '?',
  range = true,
  complete = function(arglead, _, _)
    return vim.tbl_filter(function(v)
      return v:match('^' .. arglead)
    end, { '-line', '-space' })
  end,
})

-- Functions {{{1
-- Interface {{{2
function TrimBlank.add_highlight() -- {{{3
  if api.nvim_get_mode().mode ~= 'n' then
    TrimBlank.remove_highlight()
    return
  end

  if not H.is_buffer_normal()
    -- don't create duplicate highlight
    or H.get_match_id() ~= nil then
    return
  end

  fn.matchadd('TrimBlank', [[\s\+$]])
end

function TrimBlank.remove_highlight() -- {{{3
  -- `pcall()` to  suppress a possible error  if the highlight has  already been
  -- removed (e.g. `clearmatches()`).
  pcall(fn.matchdelete, H.get_match_id())
end

function TrimBlank.trim(range, line1, line2) -- {{{3
  local curpos = api.nvim_win_get_cursor(0)
  local range = range == 0 and '%' or (line1 .. ',' .. line2)
  vim.cmd(string.format('keepjumps keeppatterns %s substitute/\\s\\+$//e', range))
  api.nvim_win_set_cursor(0, curpos)
end

function TrimBlank.trim_last_blank_lines() -- {{{3
  local n_lines = api.nvim_buf_line_count(0)
  local last_nonblank = fn.prevnonblank(n_lines)
  if last_nonblank < n_lines then
    api.nvim_buf_set_lines(0, last_nonblank, n_lines, true, {})
  end
end

function TrimBlank.highlight_update_on_buftype_change() -- {{{3
  if vim.v.option_new == '' then
    TrimBlank.add_highlight()
  else
    TrimBlank.remove_highlight()
  end
end
-- }}}2
-- Util {{{2
function H.is_buffer_normal() -- {{{3
  return api.nvim_buf_get_option(0, 'buftype') == ''
end

function H.get_match_id() -- {{{3
  for _, match in ipairs(fn.getmatches()) do
    if match.group == 'TrimBlank' then
      return match.id
    end
  end
end
