# Find a consistent design to display a scratch buffer
## check how plugin authors implement one

How do they implement the filetype detection and the syntax highlighting?

Which mappings and local settings do they set?
For which purpose exactly?
Look for `bt=nofile` or `buftype=nofile`.

## when should the window be horizontal instead of vertical?

## to read

    :help special-buffers
    :help new-buftype
    :help 'bt

##
## consider using
### a preview window

If you don't need to interact with  the scratch buffer, only read it, maybe make
it use a preview window:

    let &l:pvw = 1

---

In that case, you need `'cul'` to be enabled.
Otherwise,  when  you move  with  `M-j`  and `M-k`,  you  may  not see  anything
happening for  quite some  time; you  may wrongly  end up  thinking that  sth is
broken.

Note that there would be no issue if we scrolled (!= moved) with `C-e` and `C-y`.
But that doesn't work well with `zMzv` which we use to open just enough folds to
see the current line.

---

Edit: Pro:

   - keep focus where it currently is

   - auto-open-fold for free

    Otherwise, you'll need to run `:norm coz`.

    But that's unreliable, because you may change the LHS of your `coz` mapping.

    And because,  if you install a  shell function to start  Vim and immediately
    open the scratch buffer, it won't work (`coz` is installed on `CursorHold`).
    Although,  you could  convert  `s:auto_open_fold()` into  a public  function
    though, and call the latter...

Con:

   - `z}` is harder to press to close the window (vs `q`)

   - you may want to implement some interactive features; if so, you'll need to
     focus the window cancelling the main benefit of a preview window

   - if there is already a preview window, its contents is replaced

   - adds noise in the status line (`[Preview]` flag)

### `(`, `)`, `[[`, `]]`, `{`, `}`, `<`, `>` as LHS in various local mappings

Right now,  we tend  to use  `)` and  `(` to  preview the  next/previous "entry"
(whatever that means in the context of the current buffer):

    :vim /nno.*<buffer>\S*\s\+\%([()]\|\[\[\|\]\]\)\s/gj $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/**
                                       ^--------^
                                       we also use `[[` and `]]` as a secondary pair of LHS

We chose  `(`/`)` – instead of  `{`/`}` – because  previewing sth seems to  be a
feature we  frequently want, and  because we rarely  press `(`/`)` (so  we don't
lose much).

OTOH:

   - we use `{`/`}` more frequently
   - `{`/`}` is harder to press

If you  need other  pairs of  LHS, I would  recommend –  in descending  order of
preference:

   - `[[`/`]]`
   - `{`/`}`
   - `<`/`>`

##
## the buffer should be reloadable

If you want  the buffer to be  reloadable via `:e`, do not  populate it directly
from the function called by a mapping.
It should be populated from an autocmd (maybe listening to `BufNewFile`).
If the  autocmd needs  some additional  info, make  it inspect  the name  of the
buffer, and use the latter to pass the info.
Look at what we did with `:Tree` for inspiration.

---

The cursor position should be preserved.

---

Should we also make a scratch buffer reloadable via a custom mapping?
(LHS = `r` or `R`; maybe `R` to not be too easy to press by accident...)

---

All of the above is irrelevant if the info in your scratch buffer is read from a
regular file; in which case, you should just edit it in read-only mode.

The read-only mode will prevent you from wrongly editing the file by accident.
In particular, the auto-save feature won't save a modified read-only buffer.
But it will still allow you to edit the file if you really want to (`:w!`).

## the buffer should not be displayed in several windows if we keep pressing its mapping/executing its Ex command

## at most, only one scratch buffer should be displayed per tab page

IOW, if we run the command which opens a window displaying a scratch buffer of a
given type, while there's already one opened, the latter should be closed first.

## the name of the buffer should be carefully chosen

Which one to choose?

    'foobar'
    tempname().'foobar'
    'plugin://foobar'
    ...

## how to handle the name of a scratch buffer in the status line?

Look at what we did for `fex_tree` buffers.
Should we do the same for all scratch buffers?

##
## mappings
### decide how to close the window

We should not run `:q` to close a scratch buffer via custom buffer-local mapping.

Instead, maybe we should use:

    exe winnr('$') > 1 ? 'close' : 'q'

Why?

    $ vim
    :h
    :FreeKeys
    :2q

If you now run `:q` to close the freekeys window, Vim quits.
With `:close`, Vim would not have quit, and you could still read the help window.

---

It seems that `:close`  doesn't make Vim quit when there's  only one help window
left, and that it's not documented.

Is it a good idea to rely on an undocumented feature?

---

Edit: I  think that  now we  use `:q`  everywhere; probably  because we  thought
`:close` was too annoying when it raised  an error...  Is it a good idea? Should
we use `:close` back? Or this:

    exe winnr('$') > 1 ? 'close' : 'q'

?

---

`:close` doesn't fire `QuitPre`; `:q` does.
If you need to react to the closing of a window, you probably need `:q`.

### never install custom mappings to open filepaths using special keys (C-s, C-v C-v, C-t)

There are already default commands for that:

   - gf
   - gF
   - C-w f
   - C-w F
   - C-w gf
   - C-w gF
   - C-w T

You should rely on default commands as much as possible.
It gives a more consistent global interface.
Besides,  when they're  improved (by  you, a  plugin, Vim's  developers), you'll
benefit from it automatically.

Avoid  the NIH  syndrome:  don't  create an  ad-hoc  system  which doesn't  work
everywhere, and not always in the same manner.

[Reuse code][1] as much as possible.

### `q` should close the window *and* focus back the previous one

    let winid = lg#win_getid('#')
    close
    call win_gotoid(winid)

### if you open a vertical split window, closing it may reset the heights of your main horizontal splits

Suppose you have several horizontal splits.
You open a scratch buffer in a vertical window (like undotree or vim-fex).
Next, you open a split window from it (e.g. diff panel in undotree).
When you'll close the latter, the heights of your main horizontal splits will be
equalized if `'ea'` is set.

This is jarring.
You can't fix the issue by temporarily  resetting `'ea'`, because as soon as you
set the option, Vim will equalize the windows.

I can see 2 solutions:

   - initially, save the id of the window from which the scratch buffer is opened,
     then later, call `win_execute(saved_id, 'do WinEnter')`

   - before opening the scratch buffer, save the values of `'wfh'` in all the windows of the current tab page,
     then execute `windo setl wfh`,
     finally, when closing the scratch buffer, restore `'wfh'` everywhere

I implemented the 1st solution in `plugin#undotree#diff_toggle()`:

    ~/.vim/autoload/plugin/undotree.vim
    /fu plugin#undotree#diff_toggle(/;/call lg#win_execute(

It's good enough, but not totally reliable; see our warning inside `plugin#undotree#show()`.

For the second solution, you would need to call a function looking like this:

    fu Func() abort
        let s:wfh_save = {}
        let winnr = range(1, winnr('$'))
        call copy(winnr)->map({_, v -> extend(s:wfh_save, {v : getwinvar(v, '&wfh', 0)})})
        echo s:wfh_save
        call copy(winnr)->map({_, v -> setwinvar(v, '&wfh', 1)})
        q
        call timer_start(0, {-> copy(winnr)->map({_, v -> setwinvar(v, '&wfh', s:wfh_save[v])})})
    endfu

Notice the timer; for some reason, it doesn't work without.
I don't like the idea of restoring option values with a timer though...

---

We have fixed the issue by resetting `'ea'` in `vim-window`.

We still have an issue regarding undotree, but that's because the latter focuses
a bunch of windows before closing the diff panel.

---

Earlier, you said that we couldn't fix the issue by temporarily resetting `'ea'`.
Are you sure?
blueyed seems to handle the issue by doing exactly that:

- <https://github.com/vim/vim/issues/2682#issuecomment-372850659>
- <https://github.com/vim/vim/issues/908#issuecomment-249459047>

##
## options
### `'winfixwidth'` (or `'winfixheight'`) should be set

Without, the  width of the window  may change when closing/opening  a window, or
simply when you change the focused window.
As an example, if you don't use `'wfw'`  in vim-freekeys, when you get back to a
regular window, the width of the freekeys window slightly increases by one cell.

MRE:

    $ vim +vs
    :FreeKeys
    :2q

The width of the freekeys window increases by a lot.

---

If you use a horizontal window, then `'winfixheight'` should be set instead.

---

Edit: The issue was due to `'equalalways'` which is set by default.
Now, we reset it, so the issue should not occur anymore.

However,  the width  of the  window may  still be  altered when  closing another
window, although in a different way;  the windows are not equalized anymore, but
the space  previously taken  by the closed  window may be  given to  the current
window; it seems to be due to `'splitbelow'` and `'splitright'`:

                              vv v-v
    $ vim -Nu NONE +'set noea sb spr|au VimEnter * wincmd =' +vs +vs
    :2q
    " the width of the first window increases

                              v--v v---v
    $ vim -Nu NONE +'set noea nosb nospr|au VimEnter * wincmd =' +vs +vs
    :2q
    " the width of the first window stays fixed

Is it a Vim bug?
Why should `'sb'` and  `'spr'` have any effect on whether  the width/height of a
window stays fixed when another window is closed and `'ea'` is reset?

In any case, this shows that `'wfh'` and `'wfw'` are still useful.

### `bh` should be set to `delete`, not `wipe`

Never use `bh=wipe`.
It would prevent  you from recovering the  buffer if you lose  it temporarily by
accident, by pressing `C-^` or `--` for example.

If  the  buffer  is  automatically   populated  on  `BufNewFile`,  you  can  use
`bh=delete`.
Indeed, if  you lose  it by pressing  `C-^`, pressing `C-^`  a second  time will
trigger `BufNewFile` (whose definition is: starting  to edit a file that doesn't
exist) which will re-populate the buffer.

### `bt` should be set to `nofile`, not `nowrite`

You  probably don't  want to  create a  real file  every time  you display  some
temporary info.
Besides, contrary  to `nowrite`, `nofile`  makes the  name of the  buffer fixed,
i.e. it's not updated whenever you change the working directory (`:cd`).

See `:help special-buffers`:

   > directory   Displays directory contents. [...]
   >             The buffer is created with these settings:
   >                         :setlocal buftype=nowrite
   >                         ...
   >             The buffer name is the name of the directory and is adjusted
   >             when using the |:cd| command.

See also `:help 'bt`:

   > nofile only:    The buffer name is fixed, it is not handled like a
   >                 file name.  It is not modified in response to a |:cd|
   >                 command.

##
## by default, the window should be opened with either `:leftabove` or `:topleft`

We read from the left to the right.
So, it makes more sense to display the information on the left than on the right.

If the information is specific to the current buffer, choose `:leftabove`.
Otherwise, choose `:topleft`.

### the custom command should still support a modifier (`:to`, `:bo`, `:lefta`, `:rightb`)

Useful to change where the window is opened at runtime.

    " uses `:lefta` or `:to` by default
    :MyCmd

    " uses `:bo` when specified
    :bo MyCmd

More generally, make  sure that any custom  command that we have  created in the
past, and which opens a window to display some information, supports a modifier.

##
## make sure no error is raised when
### we reload a scratch buffer which is in a tab page containing only 1 window

Find a design which prevents this possible issue.

### we try to open a scratch buffer while another one is already open

For example, right now, if you run:

    :WordFrequency

It opens a preview window.

Now, if you're also debugging some code, have a `g:d_` variable, and press `!d`, this error is raised:

    E590: A preview window already exists: pvw

That should not happen.

##
## once you've come up with a design
### use it to bring consistency (and fix errors) in the way we've created a scratch buffer in the past

    :vim /setl.*bt=nofile/gj $MYVIMRC ~/.vim/**/*.vim ~/.vim/**/*.snippets ~/.vim/template/**

### enforce it via library functions/snippets/templates/vim-projectionist...
