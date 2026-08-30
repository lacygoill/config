-- Purpose: Which of the following strings are valid identifiers?
--
--     ___ _end End end until? nil NULL
--
-- Reference: page 8 (paper) / 27 (ebook)

-- They are all valid except:
--
--    - `end` and `nil` because they are reserved keywords
--    - `until?` because it contains an invalid character (`?`); also, `until` is reserved
