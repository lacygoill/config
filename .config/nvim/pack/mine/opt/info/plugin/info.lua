vim.keymap.set('n', '-p', function() require('info').full_path() end,
{ desc = 'print full path of current file' })

vim.keymap.set('n', '-P', function() require('info').current_working_directory() end,
{ desc = 'print current working directory' })
