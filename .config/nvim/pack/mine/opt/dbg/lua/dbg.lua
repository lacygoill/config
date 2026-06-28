local dbg = {}

function dbg.pretty_print(...) -- {{{1
  -- Evaluates to a table like this one:{{{
  --
  --     {
  --       lastlinedefined = 15,
  --       linedefined = 7,
  --       short_src = "/home/lgc/.config/nvim/init.lua",
  --       source = "@/home/lgc/.config/nvim/init.lua",
  --       what = "Lua"
  --       ^--^   ^---^
  --       field  element
  --     }
  --
  -- If the outer function was defined:
  --
  --    - in a string, `source` is that string
  --    - in a file, `source` starts with a `@` followed by the filename
  --
  -- `short_src` is a short version of  `source` (up to 60 characters); useful
  -- for error messages.
  -- `linedefined`  and `lastlinedefined`  are the  addresses of  the function
  -- starting/ending lines.
  --
  -- `what` is the string:
  --
  --    - `"Lua"` if the function is a Lua function
  --    - `"C"` if it is a C function
  --    - `"main"` if it is the main part of a chunk
  --    - `"tail"` if it was a function that did a tail call
  --
  -- For more info, see `:help lua_Debug`.
  --}}}
  -- Why `2` and not `1`?{{{
  --
  -- `1` is for for the immediate outer function, here `inspect()`.
  -- We're not interested in that function.
  -- We're interested  in the outer  function; the  one from which  we'll call
  -- `inspect()` to debug some issue it has.
  --}}}
  local info = debug.getinfo(2, 'S')

  -- `sub()` trims the `@` prefix
  local source = info.source:sub(2)
  source = vim.loop.fs_realpath(source)
  source = vim.fn.fnamemodify(source, ':~:.') .. ':' .. info.linedefined

  print('Debug: ' .. source)
  for _, v in ipairs({ ... }) do
    vim.pretty_print(v)
  end
end

return dbg
