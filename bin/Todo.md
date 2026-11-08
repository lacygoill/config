# Remove any script we never use.

But first, check  whether we could integrate it in  our workflow (possibly after
some more work on it).

Also, check whether it contains any  useful information which we might turn into
a Vim or shell snippet, a Vim syntax highlighting rule, ...

# Replace `xdotool(1)` with `ydotool(1)`

<https://github.com/ReimuNotMoe/ydotool>

Rationale: It works on Wayland too (`xdotool(1)` is limited to X11).
Use it everywhere, in our scripts and config files.
