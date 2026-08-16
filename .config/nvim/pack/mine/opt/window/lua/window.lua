local M = {}
local api, fn = vim.api, vim.fn

-- TODO: How to define the interface function before the core/util one(s)?
-- https://stackoverflow.com/questions/6067369/forward-define-a-function-in-lua

local function PreviousWindowIsInSameDirection(dir) --{{{1
  local cnr = fn.winnr()
  local pnr = fn.winnr('#')
  if dir == 'h' then
    local leftedge_current_window = fn.win_screenpos(cnr)[2]
    local rightedge_previous_window = fn.win_screenpos(pnr)[2] + fn.winwidth(pnr) - 1
    return leftedge_current_window - 1 == rightedge_previous_window + 1
  end

  if dir == 'l' then
    local rightedge_current_window = fn.win_screenpos(cnr)[2] + fn.winwidth(cnr) - 1
    local leftedge_previous_window = fn.win_screenpos(pnr)[2]
    return rightedge_current_window + 1 == leftedge_previous_window - 1
  end

  if dir == 'j' then
    local bottomedge_current_window = fn.win_screenpos(cnr)[1] + fn.winheight(cnr) - 1
    local topedge_previous_window = fn.win_screenpos(pnr)[1]
    return bottomedge_current_window + 1 == topedge_previous_window - 1
  end

  if dir == 'k' then
    local topedge_current_window = fn.win_screenpos(cnr)[1]
    local bottomedge_previous_window = fn.win_screenpos(pnr)[1] + fn.winheight(pnr) - 1
    return topedge_current_window - 1 == bottomedge_previous_window + 1
  end
  return false
end

function M.Navigate(dir) --{{{1
  -- Purpose:{{{
  --
  --     $ nvim -u NONE +'split | vsplit | vsplit | wincmd l'
  --     :wincmd j
  --     :wincmd k
  --
  --     $ nvim -u NONE +'vsplit | split | split | wincmd j'
  --     :wincmd l
  --     :wincmd h
  --
  -- In both cases, we don't focus back the middle window; that's jarring.
  --}}}
  if PreviousWindowIsInSameDirection(dir) then
    vim.cmd('wincmd p')
  else
    vim.cmd('wincmd ' .. dir)
  end
end
--}}}1

return M
