# Config
## In a custom key binding, how to represent
### the space key?

    0x20

### the enter key?

    <LF>, <KEY_ENTER>

Note that  `<KEY_ENTER>` by itself  is unreliable and  should always be  used in
conjunction with `<LF>`.

### a plain key?

With either an uppercase/lowercase character:

   - `Q`
   - `q`
   - `1`
   - `?`

or the hexadecimal number referring to its ascii code:

   - `0x20` (space)
   - `0x3c` (less-than sign)

For reference, see:
<https://en.wikipedia.org/wiki/ASCII#ASCII_printable_code_chart>

### a control character like `Enter` or `Escape`?

Surround its name with `<>`.
For the name, see: <https://en.wikipedia.org/wiki/ASCII#ASCII_control_code_chart>
Use the abbreviation name.

Examples:

   - `<LF>` (Enter)
   - `<ESC>` (Escape)
   - `<EOT>` (C-d)
   - `<NAK>` (C-u)

### a special key like `Left` or `PageDown`?

Prefix its name with `KEY_`, and surround the result with `<>`.
For the name, see: <https://docs.python.org/2/library/curses.html#constants>

Examples:

   - `<KEY_LEFT>` (Left)
   - `<KEY_F5>`
   - `<KEY_NPAGE>` (PageDown)

##
# Usage
## How to log in or log out?

Press `C-l` (which we've bound to the `LOGIN` command).

##
## How to open
### the main page of a subreddit I regularly visit?

Press `s` to get a list of all the subreddits you're subscribed to.
Press `j`, `k`, `gg`, `G`, until you select the desired subreddit.
Finally, press `Enter`.

---

If you don't want  to visit any subscribed subreddit, and  simply get back where
you were, press `h` or `Escape`.

### the foo, bar, and baz subreddits merged together?

    /foo+bar+baz

### my front page?

    /front

#### How to cycle between the current subreddit and my front page?

Press `C-^` (which we've bound to the `SUBREDDIT_FRONTPAGE` command).

###
## How to quit without confirmation?

Press `Q` (capitalized; i.e. not `q`).

By default, it's bound to the `FORCE_EXIT` command.

## How to reload the current page (to refresh its contents)?

Press `r` (boud to `REFRESH` by default).

##
## How to save the current comment?

Press `C-s` (which we've bound to the `SAVE` command).

This feature is only available if you're logged in.

### How to get the list of all the comments I've saved?

    /u/me/saved

##
## How to look for submissions containing a particular keyword?

Press `f` (which is bound to the `SUBREDDIT_SEARCH` command by default).
It should open a prompt in which you can type your query.

## How to hide a submission?

Press `H` (which we've bound to the `SUBREDDIT_HIDE` command).

##
## How to get the list of all the comments and submissions of the user “spez”?

    /u/spez

### only their comments?

    /u/spez/comments

### only their submissions?

    /u/spez/submitted

##
## How to copy into the clipboard
### the permalink of the current submission or comment?

Press `y` (bound to the `COPY_PERMALINK` command by default).

### the URL to which the current submission refers to?

Press `Y` (bound to the `COPY_URL` command by default).
