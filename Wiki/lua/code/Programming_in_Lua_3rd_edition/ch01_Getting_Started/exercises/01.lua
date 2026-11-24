-- Purpose: Run  the factorial  example.  What  happens to  your program  if you
-- enter a negative number?  Modify the example to avoid this problem.
-- Reference: page 8 (paper) / 27 (ebook)

-- define the factorial function
local function fact(n)
  -- The original code was:
  --
  --     if n == 0 then
  --
  -- Problem: It doesn't handle correctly the case where `n` is negative.
  -- In that case, a stack overflow error is given.
  -- Solution: Handle a negative number like zero.
  if n <= 0 then
    return 1
  end
  return n * fact(n - 1)
end

-- ask the user for a number
print('Enter a number:')
local a = io.read('*n')

-- print the factorial of that number
print(fact(a))
