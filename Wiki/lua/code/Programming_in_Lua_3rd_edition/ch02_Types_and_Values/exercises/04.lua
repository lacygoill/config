-- Purpose: How can you embed the following piece of XML as a string in Lua?
--
--     <![CDATA[
--       Hello world
--     ]]>

-- Reference: page 19 (paper) / 38 (ebook)


-- The issue  is that the string  contains `]]` which conflicts  with the ending
-- delimiter of the syntax for raw strings (`[[ ... ]]`).
-- The  solution  is to  include  an  equal sign  between  the  brackets of  the
-- delimiters:

--     v
print([=[
<![CDATA[
  Hello world
]]>]=])
--  ^
