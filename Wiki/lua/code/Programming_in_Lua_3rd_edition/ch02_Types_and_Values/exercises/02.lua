-- Purpose: Which of the following are valid numerals?
-- What are their values?
--
--     .0e12
--     .e12
--     0.0e
--     0x12
--     0xABFG
--     0xA
--     FFFF
--     0xFFFFFFFF
--     0x
--     0x1010
--     0.1e1
--     0x0.1p1

-- Reference: page 18 (paper) / 37 (ebook)


-- `.0e12` is  valid.  It  evaluates to  `0` (when the  significand is  `0`, the
-- exponent doesn't matter).

-- `0.0e` is not valid.  The exponent is missing.

-- `0x12` is valid.  It's an hexadecimal number which is written `18` in base `10`.

-- `0xABFG` is not valid.  `G` is an invalid digit in hexadecimal.

-- `0xA` is valid.  It's an hexadecimal number which is written `10` in base `10`.

-- `FFFF`  is not  valid.  It  would be  a valid  hexadecimal number  if it  was
-- prefixed with `0x`.

-- `0xFFFFFFFF`  is  valid.   It's  an   hexadecimal  number  which  is  written
-- `68719476735` in base `10`.

-- `0x` is not valid.   It could be the prefix of a  valid hexadecimal number if
-- it was followed by digits in `[0-9A-F]`.

-- `0x1010` is  valid.  It's an  hexadecimal number  which is written  `987152` in
-- base `10`.

-- `0.1e1` is valid.  It evaluates to `1`.

-- `0x0.1p1` is  not valid.   The dot and  `p` are not  valid in  an hexadecimal
-- number.
