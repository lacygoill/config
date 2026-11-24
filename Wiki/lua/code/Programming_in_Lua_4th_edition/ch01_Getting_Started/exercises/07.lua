-- Purpose: Consider the following expression:
--
--     (x and y and (not z)) or ((not y) and x)
--
-- Are  the  parentheses necessary?   Would  you  recommend  their use  in  that
-- expression?

-- Reference: page 11 (paper) / 25 (ebook)


-- No, the parens  are not required, because the operations  would be grouped in
-- the  same way  without.  Indeed,  according  to their  precedence level,  the
-- operators are ranked in that order: `not`, `and`, `or`.
-- Still, it's better  to use parens, because it removes  any confusion that the
-- reader might have with regard to how the operations are grouped.
