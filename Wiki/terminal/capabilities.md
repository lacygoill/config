# Basic
## What does it mean for a terminal to have the capability
### `am`?

When the end of a line is reached, an automatic carriage return and line-feed is
performed.

### `bw`?

Programs can backspace around the left edge.
And a cub1 (move cursor 1 position to  the left) from the left edge will move to
the right edge of the previous row.

Mnemonic: BackWard

### `ul`?

The terminal can generate underlined characters.

### `bel=^G`?

The key to ring the bell is `C-g`.

### `cols#80`?

The terminal has 80 columns (in its default geometry?).

### `lines#24`?

The terminal has 24 lines (in its default geometry?).

##
# Character attributes
## How to change the character attributes (bold, italic, underline, color, ...) of some text?

    CSI Pm m

---

    $ printf '\e[1m   bold             \e[0m\n'
    $ printf '\e[3m   italic           \e[0m\n'
    $ printf '\e[4m   underline        \e[0m\n'
    $ printf '\e[5m   blinking         \e[0m\n'
    $ printf '\e[7m   negative image   \e[0m\n'
    $ printf '\e[8m   invisible image  \e[0m\n'
    $ printf '\e[9m   strikethrough    \e[0m\n'

### How is this sequence also called?

SGR, because it invokes the [Select Graphic Rendition][1] control function.

#### What's the effect of the “negative image” attribute?

It reverses the foreground and background colors of the text.

##### What about the “invisible image” attribute?

It hides the text.

####
### How to apply multiple attributes?

Since the syntax of  the sequence contains Pm (and not Ps),  you can combine the
codes of multiple attributes by separating them with semicolons:

    $ printf '\e[1;4;5m bold + underline + blinking\n'
                 ^---^

#### How to reset a specific attribute out of multiple ones?

Use the sequence `CSI 123 m` where  123 stands for the number resulting from the
addition of 20 with the code of the attribute you want to reset.

    $ printf '\e[3;4m italic + underlined \e[24m just italic\n'
                                             ^^
                                             4+20
                                             ^
                                             underlined

#### How to reset *all* attributes?

Use the sequence `CSI 0 m`.

    $ printf '\e[1;4;5m bold + underline + blinking \e[0m no more attributes\n'
                                                    ^---^

##
## How to test whether my terminal supports common sequences to set character attributes?

    $ msgcat --color=test

Useful to test whether we can send sequences to:

   - change the color of the text / background
   - set some styles (bold, italic, underlined)

See `info gettext /=test`.

##
# Cursor
## What are the coordinates of "home" for an X terminal?

    (1,1)

##
## What is the purpose of the capability
### `cup`?

It describes how to move the cursor to an arbitrary location.

#### How is it different from most other string capabilities?

Simple string capabilities tell **what string to send**, while `cup` – and other
string  capabilities with  arguments –  tell the  program **how  to build**  the
string to send.

Indeed, the desired location is specified by a program at run time, and thus the
capability  must provide  a  mechanism  to encode  the  coordinates  of the  new
location.

#### What is the data structure used by a terminal to process a `cup` string?

A stack which is manipulated like a Reverse Polish Notation calculator.
Arguments or constants are pushed onto  the stack, manipulated and combined, and
a single final result is output (popped from the stack).

#### Break down this value `\E[%i%p1%d;%p2%dH`.

`\E` is an escape character, while `[`, `;` and `H` are literal characters.

`%i%p1%d` and `%p2%d` encode the coordinates of the new desired cursor location.

`%i` increments the values given by one.
This is  necessary for X  terminals whose  home is based  on upper left  = (1,1)
rather than (0,0).
`%p1` pushes the first parameter onto the stack.
`%d` pops the  value as a signed  decimal number, and the  number is incremented
because of `%i`.

`%p2` pushes the second parameter onto the stack.
`%d` pops the  value as a signed  decimal number, and the  number is incremented
because of `%i`.

For more info, see page 31 of “Termcap and Terminfo” (40 of the original book).

##### What is the purpose of `%`?

It's used as an escape character;  when combined with some valid character, it's
interpreted as an operation on some runtime argument.

##
### `smcup`?

It makes  the terminal  enter a  mode in which  the programs  can use  the `cup`
capability (absolute cursor motion).

### `rmcup`?

It makes the terminal leave the mode entered after `smcup`.

###
### How are `smcup` and `rmcup` called in Vim's builtin termcap db?

`t_ti` and `t_te`.

#### What is special about them?

They contain one of the first and last sequence sent to the terminal.

###
## relative motions
### What does it mean for a terminal to have the capability
#### ?

    ┌───────────┬───────────────────────────────────────────────┐
    │ cbt=\E[Z  │ backtab                                       │
    ├───────────┼───────────────────────────────────────────────┤
    │ cr=^M     │ return                                        │
    ├───────────┼───────────────────────────────────────────────┤
    │ cub1=^H   │ move CUrsor Back 1 column                     │
    ├───────────┼───────────────────────────────────────────────┤
    │ cuf1=\E[C │ move CUrsor Forward 1 column                  │
    ├───────────┼───────────────────────────────────────────────┤
    │ cud1=^J   │ move CUrsor Down 1 line                       │
    ├───────────┼───────────────────────────────────────────────┤
    │ cuu1=\EM  │ move CUrsor Up 1 line                         │
    ├───────────┼───────────────────────────────────────────────┤
    │ home=^^   │ move cursor home                              │
    ├───────────┼───────────────────────────────────────────────┤
    │ ht=^I     │ move cursor to next 8-space hardware tab stop │
    ├───────────┼───────────────────────────────────────────────┤
    │ ind=^J    │ scroll forward                                │
    │ ri=\EI    │ scroll backward                               │
    ├───────────┼───────────────────────────────────────────────┤
    │ kbs=\177  │ backspace key                                 │
    │           │ (177 is the octal code of C-?)                │
    ├───────────┼───────────────────────────────────────────────┤
    │ nel=\EE   │ newline (behaves like cr followed by lf)      │
    └───────────┴───────────────────────────────────────────────┘

##
## How to hide the cursor?

Use the `civis` capability:

    $ tput civis

### How to show it again?

Use the `cnorm` capability:

    $ tput cnorm

##
## How to save the cursor position and use the alternate screen buffer, clearing it first?

    $ tput smcup

### How to use the normal screen buffer and restore the cursor position?

    $ tput rmcup

Try this:

    $ ls
    $ tput smcup
    $ echo 'hello'
    $ tput rmcup

###
## How to change the shape of the cursor?

    CSI Ps SP q

---

    # block
    $ printf '\e[2 q'

    # underline
    $ printf '\e[4 q'

    # bar
    $ printf '\e[6 q'

    # blinking block
    $ printf '\e[0 q'

    # blinking underline
    $ printf '\e[3 q'

    # blinking bar
    $ printf '\e[5 q'

### How is this sequence called?

    DECSCUSR
    ││││├┘││
    │││││ │└ ?
    │││││ └ Style
    ││││└ CUrsor
    │││└ Set
    ││└ Corporation
    │└ Equipment
    └ Digital

##
# Arrows

    ┌────────────┬─────────────────┐
    │ kcud1=\EOB │ down  arrow key │
    ├────────────┼─────────────────┤
    │ kcuu1=\EOA │ up    arrow key │
    ├────────────┼─────────────────┤
    │ kcub1=\EOD │ left  arrow key │
    ├────────────┼─────────────────┤
    │ kcuf1=\EOC │ right arrow key │
    └────────────┴─────────────────┘

## What's the difference between `kcuu1` and `cuu1`?

`cuu1` tells a program which string to *send* to move the cursor 1 line up.

`kcuu1` tells a program which string it will *receive* when the user has pressed
the up arrow key.
The latter  could move the  cursor 1 line  up, or could  be mapped to  some user
custom function.

---

Read “Termcap and Terminfo”, page 89 (156 of the original book).

I think this excerpt applies to capabilities prefixed by `k`:
   > [...] not listing  a key may cause  serious problems while running  a program if
   > the unlisted key were accidentally hit.
   > The  program will  not be  able to  translate the  sequence into  a recognizable
   > function key  sequence and will  be forced to interpret  the sequence as  if the
   > characters had been typed, which may be disastrous.

   > Many of these  capabilities have "twin" capabilities elsewhere  in termcap and
   > terminfo.
   > For example, in  termcap, kC= specifies the  code sent by the  CLEAR SCREEN key,
   > and cl= is the string that programs use to clear the screen.
   > The capabilities in this section describe what is sent when a key is pressed, so
   > that programs know what  special keys are available and to  realize when one has
   > been pressed.
   > The twin capabilities for each of  these keys (described elsewhere in this book)
   > are the  functional capabilities, which  is how  programs learn what  strings to
   > send to produce the desired action.

   > Although  in most  cases the  twins will  be identical  twins, there  are a  few
   > reasons and special cases where the twins will not be identical.
   > [...] you might want to [...] use the keys to indicate something other than they
   > say on them (for  example, using the arrow keys for  something other than moving
   > the cursor in application programs).
   > In these cases, your program would turn  off echoing and watch the input for the
   > characters sent by the redefined keys.
   > [...] Thus,  while it is  often redundant to  have twin capabilities,  there are
   > cases when it is useful, and it is historically ingrained.

When the  excerpt uses  the word  “echo”, I think  it refers  to the  fact that,
often, when you press a non-function key  like `a`, the terminal sends it to the
program, and then the  program sends it back to the terminal to  write it on the
screen; in this sense, it echoes the character:

             message: the user has pressed `a`
             v
    terminal → editor
    terminal ← editor
             ^
             message: ok, write it as is

## What happens if `kcuu1` is not properly set?

When the user presses the up arrow key, each key in the emitted sequence will be
processed independently.

As an experiment, run this in Vim:

    :set t_ku=

Then, press the up arrow key in normal mode.
The `A` character is inserted above the current line.
This is because pressing  the up arrow key makes the  terminal send the sequence
`Esc O A`, and  without `'t_ku'` being properly set, Vim  is unable to recognize
this sequence.

---

But why can't I reproduce this experiment for the shell?

    $ infocmp -x >entry
    $ vim entry
    :%s/kcuu1=\zs[^,]*//
    :x
    $ tic -sx entry

Press the up key: it still correctly recalls the previous command!

I think that's because the shell is not a TUI application.
This is explained here:
<https://invisible-island.net/xterm/xterm.faq.html#xterm_arrows>

   > Since   termcaps  and   terminfo  descriptions   are  written   for  full-screen
   > applications,  shells and  similar programs  often  rely on  **built-in tables**  of
   > escape sequences which they use instead.
   > Defining keys  in terms of  the termcap/terminfo  entry (e.g., by  capturing the
   > string sent by tputs) is apt to confuse the shell.

##
# Clipboard
## What is the purpose of the `Ms` capability?

It's a way for the terminal to  tell the applications how they should encode and
send  some arbitrary  text, if  they  want the  terminal  to store  it into  its
clipboard.

### Where can I find more information about it?

    OSC Ps ; Pt BEL /Ps = 5 2

See also:

    $ curl -L -O http://invisible-island.net/datafiles/current/terminfo.src.gz
    $ gzip --decompress terminfo.src.gz
    $ vim terminfo.src
    /\m\C\<Ms\>

### What's its default value?

    Ms=\E]52;%p1%s;%p2%s\007

#### What's the meaning of the two parameters?

   - p1 = the storage unit (clipboard, selection or cut buffer)
   - p2 = the base64-encoded clipboard content.

##
## How to set the terminal clipboard?

Use the OSC 52 sequence:

    Esc]52;base64-encoded-string;BEL

Example:

    $ printf '\e]52;c;%s\x07' $(printf 'hello' | base64)
    $ xsel -b
    hello˜

See `OSC Ps ; Pt BEL/;/Ps = 5 2`.

### It doesn't work!

Make sure your terminal supports the sequence.
Check whether its description includes the `Ms` capability:

    $ infocmp -1x | grep Ms
    Ms=\E]52;%p1%s;%p2%s\007,˜

---

If you're using xterm, make sure to have these lines in `~/.Xresources`:

    XTerm*disallowedWindowOps: 20,21,SetXprop
    XTerm*selectToClipboard: true

The  first line  makes  xterm  accept most  extended  window control  sequences,
including OSC 52 because it doesn't include the name 'SetSelection'.
The value is taken from `man tmux /set-clipboard`.

The second line makes xterm write in the clipboard selection by default, instead
of the primary selection.

Indeed,  when  tmux sends  an  OSC  52 sequence,  it  always  removes the  first
parameter specifying the storage unit:

    \e]52;;...\x07
         ^^
         no 'c' parameter to specify the clipboard

When  xterm  receives  such a  sequence,  it  writes  the  text in  its  primary
selection, which is not where you want it to be if you're used to paste the text
by pressing C-S-v.

---

If you're inside tmux, make sure `set-clipboard` is set to 'on'.

'external' should also be a good value, because:

   > If set to external, tmux will attempt to set the terminal clipboard but ignore
   > attempts by applications to set tmux buffers.

But in practice, for some reason, it doesn't work:
<https://github.com/tmux/tmux/issues/1864>

Note that this issue doesn't affect `copy-pipe` nor `copy-selection`.
IOW, tmux will correctly set the terminal clipboard when you press a key binding
whose RHS  invokes `copy-pipe`  or `copy-selection`  even if  `set-clipboard` is
'external'.

If you  need `set-clipboard`  to be  'external', then wrap  the OSC  52 sequence
inside a DCS sequence with the prefix `tmux;`:

    $ printf '\ePtmux;\eseq\e\\'
                      ^^
                      All the characters inside the OSC 52 sequence should be doubled.
                      If you use BEL instead of ST at the end of OSC 52,
                      there should be only one escape character at its start,
                      so you just need to double this first character.

Example:

    $ printf '\ePtmux;\e\e]52;c;%s\x07\e\\' $(printf 'hello' | base64)

###
## How to read the terminal clipboard?

Use the `OSC 52` sequence with `?` as the second parameter:

    Esc];c;?BEL
           ^
           special parameter

See `OSC Ps ; Pt BEL/;/Ps = 5 2/;/.*?`.

   > If the second parameter is a ? , xterm replies to the host
   > with the selection data encoded using the same protocol.

---

Usage example:

    # write 'hello' in the clipboard
    $ printf '\033]52;c;%s\007' "$(printf 'hello' | base64)"

    # read the clipboard
    $ printf '\033]52;c;?\007'
    52;c;aGVsbG8=˜

    # decode the clipboard
    $ base64 -d <<<'aGVsbG8='
    hello˜

### I can't redirect the output of `printf` to `base64(1)` and get a one-liner!

You can:

    $ printf '\033]52;c;?\007' | base64 -d
    base64: invalid input˜

but that's not what you want.

The output of `printf` is not the contents of the base64-encoded clipboard (`aGVsbG8=`).
It's just  the string of  characters `\033]52;c;?\007`, where `\033`  and `\007`
have been replaced by an ESC and a BEL.

What you  can read on  the shell's command-line  – `52;c;aGVsbG8=` –  does *not*
belong to `printf`'s output; it's a reply from the terminal *process* which is
written on the  shell stdin (and more  generally – probably –  on the foreground
process stdin).

If your foreground  process is the shell, the terminal  process writes its reply
on the shell stdin.
In  return, the  shell asks  the  terminal process  to  print the  reply on  its
command-line in the terminal window.

If your foreground process is a script, the terminal process writes its reply on
the stdin of the script.
And if  the script runs `read`,  the latter inherits  the stdin of the  former –
i.e. the terminal – and thus consumes the terminal's reply.

#### ?

Then how to get a one-liner?

    $ printf '\033]52;c;?\007' ; \
      IFS= read -d $'\a' -s -t 0.1 ; \
      base64 -d <<<${REPLY#$(printf "\e]52;c;")}

The code works  because `read` reads from  its stdin which it  inherits from the
shell; and by default, the shell's stdin is the terminal.

---

The first semicolon is essential (not the second one).
You need  it to prevent a  new command-line from being  printed between `printf`
and `read`; if that were to happen  you couldn't run `read` without removing the
reply from the terminal.

    ✘
    $ printf ...
    $ terminal_reply read ...
      ^------------^

    ✔
    $ printf ... ; read ...

---

In a script,  you can eliminate the semicolons, because  there's no command-line
in a non-interactive shell; the commands are not taken from the readline editing
buffer, but from the script.
As  a  result,  there's  no  risk  for  the  terminal's  reply  to  pollute  the
command-line.

    #!/bin/bash

    printf '\033]52;c;?\007'

    IFS= read -d $'\a' -s -t 0.1
    #         ├──────┘  │ ├────┘
    #         │         │ └ time out after 0.1s if you haven't been able to read an input line
    #         │         └ be silent (don't echo the reply from the terminal)
    #         └ stop consuming input when the first BEL character is encountered (instead of newline)

    base64 -d <<<${REPLY#$(printf "\e]52;c;")}
    #              ├───┘├───────────────────┘
    #              │    └ remove an undesired prefix from the reply
    #              └ if no names are supplied to `read`, the line read is assigned to the variable REPLY

#### ?

Document `sgr0` and `el`.

    To better understand:

    Start a bash shell with no config:

         $ bash --noprofile --norc

    This is  necessary because zsh  and a customized bash  behave differently,
    and can make the experiments harder to explain.

    ---

    Test the `setab` capability:

         $ printf '123 \e[48;5;123m'; clear

    The whole screen is redrawn in cyan.
    This is because the printf statement tells the terminal to redraw any cell in cyan.

    ---

    Test the `sgr0` capability:

         $ tput sgr0; clear

    The whole screen is redrawn normally.
    This is because the sgr0 capability  tells the terminal to redraw any cell
    with no graphical attribute (so no custom color).

    ---

    Test the `el` (Erase Line) capability:

         $ printf '123 \e[48;5;123m'; tput el

    On the next line,  '123 ' is printed on non-colored  cells, then the shell
    prompt is colored in cyan, as well as the rest of the line.
    The line is in  cyan because `$ tput el` has made  the terminal redraw all
    the cells on the line.

    ---

         $ printf '123 \e[48;5;123m'; tput el; tput sgr0

    Same result as previously, but with one difference: the prompt is not in cyan.

    This is because the prompt was drawn *after* `$ tput sgr0`.
    So, right after `$ tput el`, the cells occupied by the prompt were in cyan.
    Right after `$ tput sgr0`, they were still in cyan.
    Finally, after the contents of the prompt was drawn, they were not in cyan
    anymore, thanks  to `$ tput  sgr0` which had  told the terminal  to redraw
    cells with no attributes.

    ---

         $ printf '123 \e[48;5;123m'; tput el; tput sgr0; echo

    Same result as previously, but with one difference: the prompt is drawn on
    the next line.
    Thanks to this, the next typed  characters won't cause the colorized cells
    to be redrawn and lose their color.

---

Show how to clear the current line.

    $ read -n 1 -e -p "What's 2 + 2? " answer; echo; if (( answer == 4 )); then echo 'right'; else echo 'wrong'; fi
vs:
    $ read -n 1 -e -p "What's 2 + 2? " answer; tput cr; tput el; echo; if (( answer == 4 )); then echo 'right'; else echo 'wrong'; fi

---

Be consistent in how you write ESC and BEL across all wikis.
I think we should  always use `\033` and `\007`, because  it's probably the most
portable notation.
For example, I don't think you can write `\x07` or `\a` in tmux's 'terminal-overrides' option.

---

Document how to temporarily change a color in the terminal palette:

    $ printf '\e[48;5;123m some colored text \e[0m\n'
    $ printf '\e]4;123;?\a'; IFS= read -s -d $'\a'
    $ printf '\e]4;123;red\a'
    $ printf '%s\a' "$REPLY"

###
### It doesn't work in st!

Yes, st doesn't support the `OSC52;c;?BEL` sequence.

Besides, upon  receiving it,  st clears  its clipboard; this  is similar  to how
xterm reacts  when receiving an  `OSC52;c;Pt` sequence  where `Pt` is  neither a
base64 string nor `?`.

   > If the second parameter is neither a base64 string nor ? ,
   > then the selection is cleared.

###
##
##
# Clearing

    ┌────────────────┬─────────────────────────┐
    │ clear=\E[H\E[J │ clear the screen        │
    ├────────────────┼─────────────────────────┤
    │ ed=\E[J        │ clear to end of display │
    ├────────────────┼─────────────────────────┤
    │ el=\E[K        │ clear to end of line    │
    └────────────────┴─────────────────────────┘
## How to temporarily clear the screen while executing arbitrary code?

    $ tput smcup
    $ clear
    # arbitrary code
    $ tput rmcup

The screen is saved with `$ tput smcup`, then restored with `$ tput rmcup`.

Saving/restoring the screen  is not the primary purpose of  `smcup` and `rmcup`;
it's just a – here useful – side effect.
The purpose of these capabilities is to  make the terminal enter/leave a mode in
which the programs can use the `cup` capability.

`$ clear` is used to move the cursor back to home.

# Adding and deleting

    ┌───────────┬────────────────────┐
    │ dch1=\E[P │ delete 1 character │
    ├───────────┼────────────────────┤
    │ dl1=\E[M  │ delete 1 line      │
    ├───────────┼────────────────────┤
    │ ich1=\E[@ │ insert 1 character │
    ├───────────┼────────────────────┤
    │ il1=\E[L  │ insert 1 line      │
    └───────────┴────────────────────┘

# Styles

Standout mode:

    ┌─────────────┬─────────────────────┐
    │ smso=\E[3m  │ start standout mode │
    ├─────────────┼─────────────────────┤
    │ rmso=\E[23m │ exit standout mode  │
    └─────────────┴─────────────────────┘

Memotechnics:

smso = Starts  Mode StandOut
rmso = Removes Mode StandOut

---

Underline mode:

    ┌─────────────┬──────────────────────┐
    │ smul=\E[4m  │ start underline mode │
    ├─────────────┼──────────────────────┤
    │ rmul=\E[24m │ exit underline mode  │
    └─────────────┴──────────────────────┘

# Function key definitions

    ┌──────────┬────────┐
    │ kf1=\EOP │ F1 Key │
    ├──────────┼────────┤
    │ kf2=\EOQ │ F2 Key │
    ├──────────┼────────┤
    │ kf3=\EOR │ F3 Key │
    ├──────────┼────────┤
    │ ...      │ ...    │
    └──────────┴────────┘

#
# Editing the db
## How to cancel a capability?

In the terminal description, append the character `@` to the name of the capability.

See `man terminfo /Similar Terminals/;/canceled`:

   > A capability can be  canceled by placing xx@ to the left  of the use reference
   > that imports it, where xx is the capability.

---

nicm uses this syntax in some issues on github:

   - <https://github.com/tmux/tmux/issues/1593#issuecomment-460004714>
   - <https://github.com/tmux/tmux/issues/1419#issuecomment-409111029>

## How to insert a control character when I edit an entry of the terminfo db?

Use the caret notation.

Do *not* insert the character literally.
For example, to express `C-k`, you must *not* press `C-v C-k` in Vim.
Instead, insert the 2 characters `^` and `K`.

## How to express common unprintable characters?

    ┌──────────────────────────────────────┬─────────────────────────┐
    │ C-x                                  │ ^X                      │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ escape                               │ \E                      │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ backspace                            │ \b                      │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ formfeed                             │ \f                      │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ linefeed                             │ \l                      │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ newline                              │ \n                      │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ return                               │ \r                      │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ space                                │ \s                      │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ tab                                  │ \t                      │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ character whose octal value is `123` │ \123                    │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ null                                 │ \0    \000 doesn't work │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ caret                                │ \^                      │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ backslash                            │ \\                      │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ comma                                │ \,                      │
    ├──────────────────────────────────────┼─────────────────────────┤
    │ colon                                │ \:                      │
    └──────────────────────────────────────┴─────────────────────────┘

Some of them are specific to terminfo, or have another representation in termcap.
See page 20 in the book `Termcap and Terminfo` (O'Reilly).

##
# Documentation
## Where can I find a list of all control sequences supported by
### xterm?

<http://invisible-island.net/xterm/ctlseqs/ctlseqs.html>

If the `xterm` package is installed on your machine, you can also read:

    /usr/share/doc/xterm/ctlseqs.txt.gz

### VT100?

<https://vt100.net/docs/vt510-rm/contents.html>

##
## What's the meaning of BEL, ESC, ST and SP?

    ┌─────┬──────────────────┐
    │ BEL │ Bell             │
    ├─────┼──────────────────┤
    │ ESC │ Escape           │
    ├─────┼──────────────────┤
    │ ST  │ String Terminator│
    ├─────┼──────────────────┤
    │ SP  │ a space          │
    └─────┴──────────────────┘

### What about their notations?

    ┌─────┬─────────────────────┐
    │ BEL │ C-g  \a  \007  \x07 │
    ├─────┼─────────────────────┤
    │ ESC │ C-[  \e  \033  \x1b │
    ├─────┼─────────────────────┤
    │ ST  │ Esc \               │
    ├─────┼─────────────────────┤
    │ SP  │                     │
    └─────┴─────────────────────┘

##
##
##
# Miscellaneous
## What are the different types of terminal capabilities?

There are 3 types of capabilities, depending on the type of values they receive:

    ┌─────────┬─────────┬─────────────────────────────────────────┐
    │ type    │ example │                 meaning                 │
    ├─────────┼─────────┼─────────────────────────────────────────┤
    │ boolean │ am      │ does automatic margins                  │
    ├─────────┼─────────┼─────────────────────────────────────────┤
    │ numeric │ cols#80 │ the terminal has 80 columns             │
    ├─────────┼─────────┼─────────────────────────────────────────┤
    │ string  │ cuu1=^K │ the sequence `C-k` will move the cursor │
    │         │         │ up one line                             │
    └─────────┴─────────┴─────────────────────────────────────────┘

### How to infer the type of a capability from its name?

If it contains:

   - `#`, it's a numeric one
   - `=`, it's a string one
   - neither `#` nor `=`, it's a boolean one

##
## What's the difference between CSI and OSC sequences?

The CSI sequences finish with a printable character.
The OSC sequences finish with ST (BEL can also be used in xterm).

###
## How to test whether my terminal supports an arbitrary sequence?

You must *manually* send it via `printf`, or `echo [-e]`.

`echo` is a shell builtin command.
`-e` enables the interpretation of some backslash-escaped characters.
`-e` is necessary in bash, so that `\e` is replaced by a real escape character.
`-e` is useless in zsh, because its builtin `echo` command already uses `-e` by default.

It's impossible to *programmatically* detect  whether a sequence is supported by
a given terminal.

Even querying the terminfo db is not reliable.
For example, by default, xfce4-terminal sets `$TERM` to `xterm`.
The `xterm` entry in the terminfo db contains a `sitm` field with the value `\E[3m`.
Which means  xfce4-terminal reports to  all programs  it runs, that  it supports
italics; it's false, it doesn't.

Bottom line: terminals lie to the programs they're running about their identity.

## Why should I use raw sequences as little as possible?

A raw sequence may work on one terminal but not on another.
Use `$ tput` instead.  It's more portable.

`tput` will query the terminfo db and return the right sequence (if any) for any
given terminal:

    ✘
    $ printf 'some \e[1m bold \e[0m text\n'

    ✔
    $ printf 'some %s bold \e[0m text\n' $(tput bold)

## How to (re)initialize the terminal and the serial line interface?

    $ tput
    $ tset

Useful when a program  has left either of those in an  unexpected state, and the
terminal is no longer usable.

## How to get the list of user-defined capabilities?

    $ diff -U $(wc -l < <(infocmp -1x | sed '1,2d')) \
      <(infocmp -1x | sed '1,2d' | sort) \
      <(infocmp -1 | sed '1,2d' | sort) \
      | sed -n 's/^-//p'

## How to make the terminal report whenever a FocusIn or FocusOut event has been fired?

Use this sequence:

    CSI ? 1004 h

### How to disable this?

    CSI ? 1004 l

###
# Reference

[1]: https://vt100.net/docs/vt510-rm/SGR.html
