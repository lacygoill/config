# cannot `print()` multi line message from function called from mapping
```lua
function func()
  print('aaa\nbbb\nccc')
end

vim.keymap.set('n', '<F3>', func)
local key = vim.api.nvim_replace_termcodes('<F3>', true, false, true)
vim.api.nvim_feedkeys(key, 't', false)
```
Expected:  This is echo'ed at the hit-enter prompt:

    aaa
    bbb
    ccc

Actual:  Only  `ccc` is  readable (run  `:messages` to  see the  missing lines).
There is no hit-enter prompt.

---

No issue if we call the function from the Vim context:
```lua
function func()
  print('aaa\nbbb\nccc')
end

vim.keymap.set('n', '<F3>', '<Cmd>call v:lua.func()<CR>')
local key = vim.api.nvim_replace_termcodes('<F3>', true, false, true)
vim.api.nvim_feedkeys(key, 't', false)
```
---

No issue if we call the function without mapping:
```lua
function func()
  print('aaa\nbbb\nccc')
end
func()
```
---

All of this is inconsistent.
Are there other exceptions (autocmd, timer, ...)?

---

Workaround:  Use `vim.cmd.echo()`:
```lua
function func()
  vim.cmd.echo('"aaa\nbbb\nccc"')
end

vim.keymap.set('n', '<F3>', function() func() end)
local key = vim.api.nvim_replace_termcodes('<F3>', true, false, true)
vim.api.nvim_feedkeys(key, 't', false)
```
##
# Crash when

To get a backtrace:
- <https://github.com/neovim/neovim/wiki/FAQ#debug>
- <https://github.com/neovim/neovim/issues/21729#issuecomment-1377463390>

## maximizing terminal window at hit-enter prompt while pager has more than 1 page of output

    # open xterm with default geometry (24 lines x 80 columns)
    $ nvim -u NONE +highlight
    # press Alt-F10 to maximize xterm

The issue  is absent  from the  release 0.8.3, but  last time  I checked  it was
present on a non-tagged commit pushed a  few weeks later.  Anyway, we're back to
0.8.0 which – hopefully  – should be even more stable  than 0.8.3; but check
whether the crash has been fixed on the next major release (i.e. 0.9.0).

##
# Documentation
## `:help string.gsub()`
```diff
diff --git a/runtime/doc/luaref.txt b/runtime/doc/luaref.txt
index aafdd5c43..cd9ecd6ee 100644
--- a/runtime/doc/luaref.txt
+++ b/runtime/doc/luaref.txt
@@ -4101,16 +4101,16 @@ string.gsub({s}, {pattern}, {repl} [, {n}])                    *string.gsub()*
            x = string.gsub("hello world from Lua", "(%w+)%s*(%w+)", "%2 %1")
            --> x="world hello Lua from"
 
-           x = string.gsub("home =  `HOME, user = ` USER", "%$(%w+)", os.getenv)
+           x = string.gsub("home = $HOME, user = $USER", "%$(%w+)", os.getenv)
            --> x="home = /home/roberto, user = roberto"
 
-           x = string.gsub("4+5 =  `return 4+5` ", "% `(.-)%` ", function (s)
+           x = string.gsub("4+5 = $return 4+5$", "%$(.-)%$", function (s)
                  return loadstring(s)()
                end)
            --> x="4+5 = 9"
 
            local t = {name="lua", version="5.1"}
-           x = string.gsub(" `name%-` version.tar.gz", "%$(%w+)", t)
+           x = string.gsub("$name-$version.tar.gz", "%$(%w+)", t)
            --> x="lua-5.1.tar.gz"
 <
 
```
