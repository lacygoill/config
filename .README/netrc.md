# Do *not* put any comment in `~/.netrc`!

It *might* work if it's at the very start of the file, but it will give errors otherwise.

    $ echo '# comment' >>~/.netrc
    $ ftp ftp.vim.org
    ...
    Unknown .netrc keyword #
    Unknown .netrc keyword comment
    ...

This affects netrw (and `:VimPatches`) which  will open a popup window with some
error message:

    **error** (netrw) Unknown .netrc keyword # comment

Besides, there is no mention of any comment syntax at `man 5 netrc`.

##
# What's the purpose of `~/.netrc`?

It contains configuration and auto-login information for the FTP client `ftp(1)`.

## Which permissions should the file have?

`600`

>     Since this file contains passwords, make very sure nobody else can
>     read this file!  Most programs will refuse to use a .netrc that is
>     readable for others.  Don't forget that the system administrator can
>     still read the file!  Ie. for Linux/Unix: chmod 600 .netrc

Source:

- `:help netrw-netrc`
- <https://unix.stackexchange.com/questions/28435/use-configuration-file-for-ftp-with-auto-login-enabled-upon-initial-connection/28440#comment522037_28440>

## As an alternative to this file, how can I auto-login when `ftp(1)` is invoked by Vim?

You can configure the netrw plugin.

For example:

    $ tee --append ~/.vim/plugin/netrw.vim <<'EOF'
    let g:netrw_uid = 'ftp'
    let g:netrw_passwd = '123'
    EOF

See:

   - `:help netrw_uid`
   - `:help netrw_passwd` (you can use the global scope in your config file)

##
# What's the purpose of `default login anonymous password user@site`?

It gives you automatic anonymous login to machines not specified in the file.

From `man netrc`:

>     default   This is the same as machine name except that default matches
>               any name.  There can be only one default token, and it must be
>               after all machine tokens.  This is normally used as:
>
>                     default login anonymous password user@site
>
>               thereby giving the user automatic anonymous ftp login to
>               machines not specified in .netrc.  This can be overridden by
>               using the -n flag to disable auto-login.

Without, you would need to give credentials when logging into `ftp.vim.org`:

    $ ftp ftp.vim.org
    ...
    220-You may login as "ftp" or "anonymous".
    220-
    220
    Name (ftp.vim.org:lgc):

---

Make sure  the line is  always present at  the end of  the file, after  all more
specific machine lines.  An example of such a line could be:

    machine ftp.vim.org login anonymous password user@example.com
