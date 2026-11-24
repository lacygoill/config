-- Purpose: Run the  `twice` example,  both by  loading the  file with  the `-l`
-- option and with `dofile()`.  Which way do you prefer?
-- Reference: page 8 (paper) / 27 (ebook)

local function twice(x)
  return 2 * x
end

-- With `-l`:{{{
--
-- Write the code in `/tmp/test/lua.lua`, then:
--
--     $ cd /tmp
--     $ mkdir test
--     $ lua -l test.lua
--     > print(twice(5))
--     10
--}}}
-- With `dofile()`:{{{
--
-- Write the code in `/tmp/test.lua`, then:
--
--     $ cd /tmp
--     $ lua
--     > dofile('/tmp/test.lua')
--     > print(twice(5))
--     10
--}}}

-- I  prefer `dofile()`  because  it doesn't  require  to put  the  script in  a
-- directory of `package.path`.
