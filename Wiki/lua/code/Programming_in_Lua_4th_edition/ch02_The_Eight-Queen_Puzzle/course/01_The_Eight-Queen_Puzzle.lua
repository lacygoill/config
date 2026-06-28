-- Purpose: Position eight  queens in a chessboard  in such a way  that no queen
-- can attack another one.
-- Reference: page 12 (paper) / 26 (ebook)


local chessboard_size = 8
local H = {}

local function add_next_queen(row, queens) -- {{{1
  -- `queens` contains the column positions of the queens on the first `row - 1`
  -- rows.  Try to  add a queen on the  next row, if a suitable  position can be
  -- found.

  -- We've reached the last row; there's no queen left to position.
  -- Just draw the final board with a queen on each row.
  if row > chessboard_size then
    return H.draw(queens)
  end

  -- iterate over  the columns of  the board to find  a position which  can't be
  -- attacked
  for col = 1, chessboard_size do
    -- if we find a good position
    if H.is_position_ok(row, col, queens) then
      -- add it to `queens`
      queens[row] = col
      -- and recurse to position the next queen on the next row
      add_next_queen(row + 1, queens)
      -- We don't break out of the loop.{{{
      --
      -- There might be another column on this row where we could put a queen.
      -- If there  is, `queens[row]` will be  overwritten with a new  `col`, and
      -- `add_next_queen()` will recurse again with a mutated `queens`.
      --}}}
      -- `queens` might now contain a position from a board which is no longer relevant.
      -- But that's not an issue:{{{
      --
      --    - any position which belongs to a past board will have to be
      --      overwritten to complete a new printed board
      --
      --    - `is_position_ok()` ignores queens on later rows
      --
      --         for r = 1, row - 1 do
      --                    ^-----^
      --}}}
    end
  end
end

function H.is_position_ok(row, col, queens) -- {{{1
-- A position is OK if, and only if, it can't be attacked by an existing queen.
-- That is, by a queen which is on the same column, or on the same diagonal.
-- No need to check whether it's on the same row.{{{
--
-- The way we build `queens`, we can't position 2 queens on the same row:
--
--     add_next_queen(row + 1, queens)
--                    ^-----^
--}}}
  for r = 1, row - 1 do
    if col == queens[r]  -- on same column
      or col == queens[r] + (row - r)  -- on same diagonal (top-left to bottom-right)
      or col == queens[r] - (row - r) then  -- on same diagonal (top-right to bottom-left)
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
    -- separate 2 consecutive rows in the same chessboard
    io.write('\n')
  end
  -- separate 2 consecutive chessboards
  io.write('\n\n')
end
-- }}}1

-- First argument: index of the row on which we want to position a queen.
-- We have to start from the 1st row.
-- Second argument: table containing a set of positions for a queen on each row.
-- We haven't positioned any queen yet; hence an empty table.
add_next_queen(1, {})
