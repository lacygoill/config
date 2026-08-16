-- Purpose: What is the value of the expression `type(nil) == nil`?
-- Reference: page 10 (paper) / 24 (ebook)


-- The evaluation is `false`.
-- That's because the output of `type()` is always a string.
-- For the test to pass, the RHS should be quoted:

--                 v   v
print(type(nil) == 'nil')
--     true
