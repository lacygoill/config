-- Purpose: Modify the eight-queen program so that it stops after printing the first solution.
-- Reference: page 14 (paper) / 28 (ebook)


local chessboard_size = 8
-- let's use an ad-hoc flag to detect when a solution has been found
local found_solution = false
local H = {}

local function add_next_queen(row, queens) -- {{{1
  if row > chessboard_size then
    -- remember that a solution has been found
    found_solution = true
    return H.draw(queens)
  -- bail out as soon as a solution has been found
  elseif found_solution then
    return
  end

  for col = 1, chessboard_size do
    if H.is_position_ok(row, col, queens) then
      queens[row] = col
      add_next_queen(row + 1, queens)
    end
  end
end

function H.is_position_ok(row, col, queens) -- {{{1
  for r = 1, row - 1 do
    if col == queens[r]
      or col == queens[r] + (row - r)
      or col == queens[r] - (row - r) then
      return false
    end
  end
  return true
end

function H.draw(queens) -- {{{1
  for row = 1, chessboard_size do
    for col = 1, chessboard_size do
      io.write(queens[row] == col and 'X ' or '_ ')
    end
    io.write('\n')
  end
  io.write('\n')
end
-- }}}1

add_next_queen(1, {})
