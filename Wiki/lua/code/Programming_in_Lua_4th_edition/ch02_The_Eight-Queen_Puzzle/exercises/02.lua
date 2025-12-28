-- Purpose: An alternative  implementation for the eight-queen  problem would be
-- to generate all possible permutations of 1 to 8 and, for each permutation, to
-- check whether  it is valid.   Change the program  to use this  approach.  How
-- does the  performance of the  new program compare  with the old  one?  (Hint:
-- compare the  total number of permutations  with the number of  times that the
-- original program calls the function `is_position_ok()`).

-- Reference: page 14 (paper) / 28 (ebook)


local H = {}

local function generate_valid_permutations(a, n) -- {{{1
  -- default for `n` is size of `a`
  n = n or #a

  if n <= 1 then
    if H.is_permutation_ok(a) then
      H.draw(a)
    end
    return
  end

  -- To get all permutations, at some point,  each element must have been in all
  -- possible positions.   In particular,  each element must  have been  in last
  -- position.  Iterate over them to make sure that happens.
  for i = 1, n do
    -- switch i-th element with last one
    a[n], a[i] = a[i], a[n]
    -- Now, we need to make sure each element has been in last but one position.{{{
    --
    -- We could write a  nested `for` loop but we would still  need to make sure
    -- that  each  element  has been  in  last  but  two,  last but  three,  ...
    -- positions.  Every time, we would need to write an additional nested `for`
    -- loop.  That's too  cumbersome and repetitive to write;  besides, we don't
    -- know how many  such nested loops we  would need to write,  since we don't
    -- know `n` in advance.  This is a job for a recursion.
    --}}}
    generate_valid_permutations(a, n - 1)
    -- The current loop  assumes that the permutation does not  change between 2
    -- iterations, but the previous assignments  did change it.  Let's fix this;
    -- move back the i-th element where it was.
    a[n], a[i] = a[i], a[n]
  end
  -- Confused by the algorithm?
  -- See: https://stackoverflow.com/a/7537933
end

function H.is_permutation_ok(queens) -- {{{1
  for row = 1, #queens do
    if not H.is_position_ok(row, queens[row], queens) then
      return false
    end
  end
  return true
end

function H.is_position_ok(row, col, queens) -- {{{1
  for r = 1, row - 1 do
    if col == queens[r] + (row - r)
      or col == queens[r] - (row - r) then
      return false
    end
  end
  return true
end

function H.draw(queens) -- {{{1
  for row = 1, 8 do
    for col = 1, 8 do
      io.write(queens[row] == col and 'X ' or '_ ')
    end
    io.write('\n')
  end
  io.write('\n')
end
-- }}}1

generate_valid_permutations({ 1, 2, 3, 4, 5, 6, 7, 8 })

-- This new program is much slower.{{{
--
-- It  becomes noticeable  starting  from  a chessboard  with  10 rows.   That's
-- because this new program recurses *un*conditionally:
--
--     for i = 1, n do
--       ...
--       generate_valid_permutations(a, n - 1)
--
-- It doesn't  care whether  the position  it's considering  can be  attacked by
-- another queen.
--
-- In contrast,  the old program recurses  on the *condition* that  the position
-- it's considering cannot be attacked:
--
--     for col = 1, chessboard_size do
--          v--------------v
--       if H.is_position_ok(row, col, queens) then
--         ...
--         add_next_queen(row + 1, queens)
--
-- IOW, the old program was less recursive; and the less recursive a program is,
-- the faster it is.
--}}}
