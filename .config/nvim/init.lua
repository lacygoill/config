if vim.fn.has('vim_starting') == 0 then
  return
end

-- Constants {{{1

local HOME = vim.env.HOME
local fn = vim.fn

-- Global Variables {{{1

-- Use the Python executable from the venv where we installed the `pynvim` module.{{{
--
-- For more info:
--
--    - `:help python-virtualenv`
--    - `:help g:python3_host_prog`
--
-- To check if Nvim can find it, run `:checkhealth`.
--}}}
vim.g.python3_host_prog = HOME .. '/.local/lib/nvim/venv/bin/python'

-- Disable perl and ruby providers.
-- We don't need them, and they create noise in `:checkhealth`.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Plugins {{{1

-- We never use the `vimball` plugin.
-- The less code, the fewer bugs.
-- Besides, it installs some custom commands which pollute tab completion on the
-- command-line.
vim.g.loaded_vimballPlugin = true
vim.g.loaded_vimball = true
-- TODO: `vimball` might be removed in the future:
-- https://github.com/neovim/neovim/pull/22402
-- If so, remove these lines.

-- How to disable netrw?{{{
--
--     -- no interface
--     vim.g.loaded_netrwPlugin = true
--
--     -- no autoload/
--     vim.g.loaded_netrw = true
--
-- See `:help netrw-noload`.
-- }}}
--   Why would it be a bad idea?{{{
--
-- Some third-party plugins might  rely on netrw, and I don't  want to lose time
-- debugging them.
--
-- netrw also lets us edit a remote file located at an arbitrary URL.
--
-- For example, if we press `<C-w>f` on this URL:
-- https://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-demo.txt
--
-- It will open the `UTF-8-demo.txt` file in a new split.
--
-- Same thing with this file:
-- ftp://ftp.vim.org/pub/vim/patches/9.0/README
-- }}}

vim.o.packpath = HOME .. '/.config/nvim,' .. vim.env.VIMRUNTIME

-- third-party plugins
vim.cmd([[
  packadd! matchit
  packadd! ultisnips
  packadd! undotree
  packadd! unicode.vim
  packadd! vim-sandwich
]])

-- my plugins
-- Don't name your debug plugin `debug`.{{{
--
-- It would conflict with the built-in `debug` library.
-- See `:help luaref-libDebug`
--
-- It  would also  prevent us  from  making Git  ignore files  under a  `debug/`
-- directory (which is useful in a Rust project; see `~/.cvsignore`).
--}}}
vim.cmd([[
  packadd! dbg
  packadd! info
  packadd! readline
  packadd! trim-blank
  packadd! window
]])

-- }}}1
-- Options {{{1

vim.o.termguicolors = true
vim.cmd.colorscheme('peachpuff')

-- Mappings {{{1
-- Visual {{{2
-- A  I  gI    niceblock {{{3

-- https://github.com/kana/vim-niceblock/blob/master/doc/niceblock.txt
-- v_b_I = Visual-block Insert
-- v_b_A = Visual-block Append
--
--    - Make |v_b_I| and |v_b_A| available in all kinds of Visual mode.
--    - Adjust the selected area to be intuitive before doing blockwise insertion.

-- Why appending `h` for the `$` motion in characterwise and blockwise visual mode? {{{
--
-- In characterwise visual mode, `$` selects the trailing newline.
-- We don't want that; `h` makes sure we leave it alone.
--
-- ---
--
-- In blockwise  visual mode, if you  set `'virtualedit'` with the  value `block`
-- (which we do by default), then something unexpected happens.
--
-- MRE:
--
--     abc
--     def
--     ghi
--
-- Position the  cursor on  `a` and  press `<C-v>jj$`, then  yank or  delete the
-- block.  Put it below by executing `:put` (or pressing our custom `]p`):
-- a trailing space is added on every put line.
--
-- What's weird, is  that the contents and  type of the unnamed  register is not
-- affected by our  custom `'virtualedit'`.  You only see a  difference when you
-- put the register.
--
-- Anyway, I don't like that trailing space.
-- That's not how Vim behaves without config;  so this makes it harder to follow
-- instructions found on forums.  Besides, a trailing space is useless.
-- }}}

local niceblock_keys = {
  ['$'] =  { v = 'g$h',     V = '$',         ['\22'] = '$h' },
  I =      { v = '<C-v>I',  V = '<C-v>^o^I', ['\22'] = 'I' },
  A =      { v = '<C-v>A',  V = '<C-v>0o$A', ['\22'] = 'A' },
  gI =     { v = '<C-v>0I', V = '<C-v>0o$I', ['\22'] = '0I' },
  ['>'] =  { v = '<C-v>>',  V = '0<C-v>>',   ['\22'] = '>' },
  ['<'] =  { v = '<C-v><',  V = '0<C-v><',   ['\22'] = '<' },
}

local function nice_block(key)
  return niceblock_keys[key][vim.api.nvim_get_mode().mode]
end

-- The purpose  of this  mapping is to  not include a  newline when  selecting a
-- characterwise text until the end of the line.
vim.keymap.set('x', '$', function() return nice_block('$') end,
  { desc = 'more intuitive selection', expr = true })

vim.keymap.set('x', 'I', function() return nice_block('I') end,
  { desc = 'more intuitive selection', expr = true })

vim.keymap.set('x', 'gI', function() return nice_block('gI') end,
  { desc = 'more intuitive selection', expr = true })

vim.keymap.set('x', 'A', function() return nice_block('A') end,
  { desc = 'more intuitive selection', expr = true })

-- Why these assignments:
--
--     niceblock_keys['>']['V'] = '0<C-v>>'
--     niceblock_keys['<']['V'] = '0<C-v><'
--
-- ... and not simply:
--
--     niceblock_keys['>']['V'] = '>'
--     niceblock_keys['<']['V'] = '<'
--
-- ? Because, without `<C-v>`, sometimes the alignment is lost.

vim.keymap.set('x', '>', function() return nice_block('>') end,
  { desc = 'more intuitive selection', expr = true })

vim.keymap.set('x', '<', function() return nice_block('<') end,
  { desc = 'more intuitive selection', expr = true })
-- }}}2
-- Terminal {{{2

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'quit Terminal mode like other modes' })
-- }}}1
-- Abbreviations {{{1
-- Command-line mode {{{2

local cabbrev = vim.cmd.cnoreabbrev
-- Warning: Don't write this:{{{
--
--     cabbrev('uv', [[<C-r>=getcmdtype() =~ '[:>]' && getcmdpos() == 1 ? 'lua vim.loop.' .. feedkeys("\<lt>Left>", "n")[-1] : 'uv'<CR>]])
--
-- For some reason, in xterm, it would cause the command-line to temporarily get 1 line higher.
-- Besides, wrapping  the code inside a  function makes the code  easier to read
-- and maintain.
--}}}

--     l → lua
cabbrev('l', [[<C-r>=v:lua.restricted_cabbrev('l', 'lua')<CR>]])

--     pp → lua vim.pretty_print()
cabbrev('pp', [[<C-r>=v:lua.restricted_cabbrev('pp', 'lua vim.pretty_print()')<CR>]])

--     uv → lua vim.loop.
cabbrev('uv', [[<C-r>=v:lua.restricted_cabbrev('uv', 'lua vim.loop.')<CR>]])

-- "restricted" means that the abbreviation should expand only on an Ex or debug
-- command-line, and only at the start.
function restricted_cabbrev(lhs, rhs)
  if vim.fn.getcmdtype():match('[:>]')
    -- NOTE: For  some reason,  when  the  expansion of  an  abbreviation is  an
    -- expression, `getcmdpos()` evaluates to the start of the abbreviation when
    -- evaluated from `<C-r>=`, but to its end from `<expr>`.
    and vim.fn.getcmdpos() == 1 then

    vim.fn.setcmdline(rhs)

    -- Problem: The cursor is not always where we want.{{{
    --
    --     uv → lua vim.loop. |
    --                        ^
    --                        ✘
    --
    --     uv → lua vim.loop.|
    --                       ^
    --                       ✔
    --
    --     lua vim.pretty_print() |
    --                            ^
    --                            ✘
    --
    --     lua vim.pretty_print(|)
    --                          ^
    --                          ✔
    --}}}
    -- Solution: Press `<Left>` once or twice.
    if not rhs:match('%w$') then
      local key = '<Left>' .. (rhs:match('[])}]$') and '<Left>' or '')
      key = vim.api.nvim_replace_termcodes(key, true, true, true)
      vim.api.nvim_feedkeys(key, 'n', false)
    end

  else
    return lhs
  end
  return ''
end
-- }}}1
-- Commands {{{1
-- }}}1
-- Autocmds {{{1

local group
-- Highlight on yank {{{2

-- `:help lua-highlight`
group = vim.api.nvim_create_augroup('highlight_on_yank', {})

vim.api.nvim_create_autocmd('TextYankPost', {
    group = group,
    pattern = '*',
    desc = 'briefly highlight the yanked text',
    callback = function()
      pcall(vim.highlight.on_yank, {
        higroup = 'IncSearch',
        timeout = 150,
        on_visual = false
      })
    end,
})

-- LSP {{{2

group = vim.api.nvim_create_augroup('lsp', {})

-- vim.api.nvim_create_autocmd('FileType', {
--     group = group,
--     pattern = 'lua',
--     callback = function()
--         vim.lsp.start({
--           name = 'lua-language-server',
--           cmd = { HOME .. '/VCS/lua-language-server/bin/lua-language-server' },
--           root_dir = vim.fs.dirname(vim.fs.find({ '.git, tags' }, { upward = true })[0]),
--         })
--     end,
-- })
-- }}}1
