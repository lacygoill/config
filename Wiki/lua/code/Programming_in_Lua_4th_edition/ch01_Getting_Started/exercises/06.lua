-- Purpose: How can  you check whether  a value is  a Boolean without  using the
-- function `type()`?
-- Reference: page 11 (paper) / 25 (ebook)

local function is_bool(x)
  return x == false or x == true
end
