-- Purpose: The  number `12.7`  is equal  to  the fraction  `127/10`, where  the
-- denominator is a power of ten.  Can you express it as a common fraction where
-- the denominator is a power of two?  What about the number `5.5`?

-- Reference: page 18 (paper) / 37 (ebook)


-- `12.7` cannot  be expressed as a  common fraction where the  denominator is a
-- power of two, because:
--
--    - the prime factor decomposition of `10` is `2 * 5`
--    - `127` is a prime number
--
-- For the denominator to be a power of two, we would need to get rid of `5`.
-- That is, we would need to divide the numerator `127` by `5`.
-- We  can't, because  `127` is  prime  (i.e. can  only  be divided  by `1`  and
-- itself).
--
-- ---
--
-- `5.5` is equal  to the fraction `11/2`.   The denominator in the  latter is a
-- power of two.
