# fzf doesn't find some text in my comment!

I *think* it's a known issue:

- <https://github.com/denisidoro/navi/issues/249#issuecomment-598633887>
- <https://github.com/denisidoro/navi/issues/459>

It might be an fzf limitation.

For the moment, make sure that your  commands descriptions are not too long (≈
80 characters),  and that you've configured  navi so that the  comment column is
wide enough.

In the future, investigate whether replacing fzf with [skim][1] fixes this issue:

> skim is already supported --as a binary, not as a library.
> Maybe this issue already has a workaround?
source: <https://github.com/denisidoro/navi/issues/249#issuecomment-627347756>

# I can't include literal angle brackets in my shell snippet!

Yes,  this  is  especially problematic  if  you  want  use  them to  surround  a
placeholder argument value:

    $ image: printf '<repository>:<tag>'
                     ^          ^ ^   ^

It's a known issue:
<https://github.com/denisidoro/navi/issues/250>

In the meantime, try to use special angle brackets:

    $ image: printf '❬repository❭:❬tag❭'
                     ^          ^ ^   ^

# My shell snippet contains several arguments.  In the preview window, I can only read the first one!

You could press `M-j` to scroll the preview window down.
But navi would scroll back to the top every time you modify your input.

---

But why can't we make fzf automatically jump to the bottom of the preview window
whenever we modify the query?

    $ mkdir -p /tmp/snippets
    $ echo '# some comment' >/tmp/snippets/snippet.cheat
    $ printf '<arg%d> ' $(seq 1 50) >>/tmp/snippets/snippet.cheat
    $ navi --best-match --print --path=/tmp/snippets/ --fzf-overrides-var='--bind=change:preview-bottom'
                                                                                         ^------------^

It works when we run fzf manually (i.e. without navi):

    $ echo '/tmp/bar' >/tmp/foo
    $ seq 1 50 >/tmp/bar
    $ cat /tmp/foo | fzf --bind 'change:preview-bottom' --preview='cat {}' --preview-window=up:nohidden
                                        ^------------^
    # press: /
    # the preview window automatically jumps to the last line

---

Is  there some  way to  detect that  the  preview window  is too  small, and  to
dynamically increase its height?
