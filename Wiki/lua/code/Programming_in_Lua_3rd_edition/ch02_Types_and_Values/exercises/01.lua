-- Purpose: What is the value of the expression `type(nil) == nil`?
-- You can use Lua to check your answer.
-- Can you explain this result?

-- Reference: page 18 (paper) / 37 (ebook)


-- `type(nil) == nil`  is `false`  because the  output of  `type()` is  always a
-- string.  The contents of that string might be `nil`, but it's still a string.
-- OTOH, `type(nil) == 'nil'` is `true`.
