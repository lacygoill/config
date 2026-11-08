# Mappings
## normal mode
### `dg/` & friends

   - `dg<Space>`: should delete empty lines
   - `vg<Space>`: should delete non empty lines
   - `dg#`: should delete commented lines
   - `vg#`: should delete non commented lines
   - `dg/`: should delete lines matching search register
   - `vg/`: should delete lines not matching search register

### `!m`

Should print `:messages` in floating window.

Starting point (see `:help api-floatwin`):

    local api = vim.api
    local buf = api.nvim_create_buf(false, true)
    local messages = vim.split(vim.api.nvim_exec('messages', true), '\n')
    api.nvim_buf_set_lines(buf, 0, -1, true, messages)
    local opts = {
      relative = 'cursor',
      width = math.floor(vim.o.columns * 2 / 3),
      height = math.floor(vim.o.lines / 3),
      col = 0,
      row = 1,
      anchor = 'NW',
      style = 'minimal',
      border = 'single',
    }
    local win = api.nvim_open_win(buf, 0, opts)
    -- Optional: Change highlight, otherwise Pmenu is used.
    -- Warning:  Don't  change the  global value  of the  option, otherwise  a newly
    -- created  window  could inherit  the  option,  which  would be  unexpected  if
    -- you  override  `Normal`  with  a  different HG.   In  particular,  don't  use
    -- `nvim_win_set_option()` (because it doesn't only set the local value; it also
    -- sets the global one).
    api.nvim_set_option_value('winhighlight', 'Normal:Normal', { scope = 'local', win = win })

This looks like it's going to be a long snippet.
Turn it into a library function.

### `!p`

Should append this line:

    require('dbg').inspect(identifier under cursor)

### `!o`

Should display output of last executed Ex command in floating window.

---

We often press  `<C-l>` in command-line mode after a  `:verbose` command to jump
to a file location.  Try to get rid of this habit.

First,  our `<C-l>`  shadows `:help c^l`  which  forces us  to re-implement  the
latter (complex and possibly brittle).  Second, `!o` might be better, because it
displays more context.

##
# Autocmds
## enforce the usage of `vim.api.nvim_get_mode().mode` instead of `fn.mode()`

Install an autocmd listening to  `BufWritePost`, which opens the location window
with all occurrences of `\<fn\.mode\>`.

Rationale: `vim.api` is faster than `vim.fn`.
Also: <https://github.com/neovim/neovim/commit/3ea10077534cb1dcb1597ffcf85e601fa0c0e27b>

##
# Style
## Make sure that we always add spaces around fold markers.

It's nicer to read.

## Make sure to not use `vim.fn.strlen()` when the length operator `#` is enough.
```lua
msg = 'abc'
print(vim.fn.strlen(msg))
```
	✘
```lua
msg = 'abc'
print(#msg)
```
	✔

We could install an autocmd (or a syntax rule) highlighting `vim.fn.strlen()` as
an error, but there might be cases where we need `strlen()`.
Are there?  `#` seems to work even for a function expression:
```lua
function func()
    return 'abc'
end
print(#func())
```
    3

##
# Configure luacheck

Inspiration:
<https://github.com/mfussenegger/nvim-lint/blob/master/.luacheckrc>

## Also, port `~/.vim/pack/mine/opt/lua/` to Neovim

Is a `compiler/` plugin still the **idiomatic** way to run a linter?

Check out how `nvim-lint` runs a linter:
<https://github.com/mfussenegger/nvim-lint>

It seems to be able to parse the linter output without `'errorformat'`:
<https://github.com/mfussenegger/nvim-lint#from_pattern>
The latter option can be tricky to  set properly; consider running linters in an
easier-to-maintain way.

##
# Plugins
## better support for markdown fenced codeblock

<https://github.com/AckslD/nvim-FeMaco.lua>

Maybe it could replace `:help syn-include`.

## small plugin manager

<https://github.com/savq/paq-nvim/blob/master/lua/> 287 sloc

## find a plugin to automatically split logical blocks

    if cond then do sth end

    →

    if cond then
        do sth
    end

##
# To read:
## guides

<https://github.com/nanotee/nvim-lua-guide>

   > A more up-to-date version of this guide is available in the Neovim documentation,
   > see :help lua-guide warning warning warning

That's not true.  The guide on GitHub contains information which is absent from the help.

## help pages/tags

   - `:help extmarks` 73 (instead of `:help sign.txt`)
   - `:help editorconfig.txt` 87
   - `:help pi_health.txt` 122
   - `:help lsp-extension.txt` 129
   - `:help remote_plugin.txt` 141
   - `:help job_control.txt` 147
   - `:help deprecated.txt` 164
   - `:help recover.txt` 177
   - `:help channel.txt` 259
   - `:help provider.txt` 295
   - `:help shada` 434 (down to *shada-critical-contents-errors*)
   - `:help diff.txt` 442
   - `:help terminal_emulator.txt` 510
   - `:help vim_diff.txt` 694
   - `:help diagnostic.txt` 706
   - `:help lua-guide.txt` 757
   - `:help ui.txt` 804
   - `:help tagsrch.txt` 938
   - `:help treesitter.txt` 978
   - `:help lsp.txt` 2038
   - `:help lua.txt` 2410
   - `:help api.txt` 3501
   - `:help luvref.txt` 3898

No   need  to   read  the   whole   of  `:help luvref.txt`;   just  the   intro,
[these examples][3],  and the  functions  which  are the  most  used in  popular
plugins.

---

Write a  script (in awk?)  to count all the  occurrences of lsp  functions under
`~/VCS/neovim_plugins/` (and sort it numerically).  You  can get the list of LSP
functions like this:

    :new | put =getcompletion('help vim.lsp.', 'cmdline')

The goal is to determine which functions  are the most useful, and which part of
the (long) documentation we should read.

Do the same for other APIs like the one for treesitter.

##
# To watch:

   - for ChatGPT: [Writing Neovim Plugins With ChatGPT][1]
   - for Tree-sitter: [Let's create a Neovim plugin using Treesitter and Lua][2]

##
# Reference

[1]: https://www.youtube.com/watch?v=sHXQczQHbDk
[2]: https://www.youtube.com/watch?v=dPQfsASHNkg
[3]: https://github.com/luvit/luv/blob/master/examples/
