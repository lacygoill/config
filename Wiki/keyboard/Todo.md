# Briefly mention alternative programs

- <https://github.com/wez/evremap>
- <https://github.com/samvel1024/kbct>
- <https://github.com/kmonad/kmonad>
- <https://github.com/snyball/Hawck>

#
# document
## the benefits of `keyd(1)` over our old suite of tools

<https://github.com/rvaiya/keyd>

The old suite was too complex:

   - to change layout: `xmodmap(1)` or  `xkbcomp(1)`, and `loadkeys(1)` (for the virtual console)
   - overload Capslock with Escape+Ctrl: `xcape(1)` or `caps2esc` (interception plugin)
   - overload right Enter with Enter+Control: `enter2ctrl` (our interception plugin)

`keyd(1)` can replace all of them:

   - replace `xmodmap(1)`/`xkbcomp(1)`
   - replace `loadkeys(1)`
   - replace `xcape(1)`/`caps2esc`
   - replace `enter2ctrl`
   - support X11 *and* Wayland

---

In  particular,  `keyd(1)`  is  an improvement  over  the  interception  plugins
(`caps2esc` and `enter2ctrl`).

With those, in Firefox, `Ctrl+mousewheel` does  not change the zoom level of the
current webpage.  It does with `keyd(1)`

Besides, our  `enter2ctrl` plugin needed  more work to make  it work as  well as
`caps2esc`.  It did not work in a virtual  console at all.  And even in the GUI,
it  did not  work properly.   When pressing  `C-a`, control  and `a`  had to  be
pressed in a  too specific manner: it was  not enough for `a` to  be pressed, it
*also* had to be released (and it had to be released while control was held).

---

Note that  `keyd(1)` cannot change the  keyboard repeat rate; that's  the job of
the display server.  You can use:

   - `xset(1)` on X11
   - `kbdrate(8)` in the virtual console
   - some GUI/tool provided by the desktop environment on Wayland

<https://github.com/rvaiya/keyd/issues/97#issuecomment-1012404919>

---

A benefit of `keyd(1)` over `xkbcomp(1)` is that it works even in a VM.
No need to transfer your custom keyboard layout from the guest to the host.
That's because `xkbcomp(1)` only works at the display server level.
Each  time your  keyboard  talks to  a  different display  server,  you need  to
customize the latter; which is brittle and tiresome.

`keyd(1)` is a lower-level tool; you only need to configure it once.

## `--expression`

    -e, --expression <expression> [<expression>...]

      Modify bindings of the currently active keyboard.

## the formal definition of a layer heading/binding

Formally, a layer heading has the form:

        "[" <layer name>[:<modifier set>] "]"
        <modifier_set> =: <modifier1>[-<modifier2>]...
        <modifierN> =: C|M|A|S|G

        C = Control
        M = Meta/Super
        A = Alt
        S = Shift
        G = AltGr

And a layer heading is followed by a set of bindings which take the form:

    <key> = <keycode>|<macro>|<action>

---

Should we write a template, a shell snippet, a markdown note, ...?

## Composite Layers

    [ids]
    *

    [main]
    capslock = layer(capslock)

    [capslock:C]
    [capslock+shift]

    h = left

Pressing control+shift+h produces left.   The expected functionality of capslock
and shift pressed in isolation are preserved.

## errors
```diff
diff --git a/docs/keyd.scdoc b/docs/keyd.scdoc
index 50c4332..3288eaa 100644
--- a/docs/keyd.scdoc
+++ b/docs/keyd.scdoc
@@ -411,7 +411,7 @@ arguments.
 	Activates the given layer while held and executes <action> on tap.
 
 *timeout(<action 1>, <timeout>, <action 2>)*
-	If the key is held in isolation for more than _<timeout> ms_, activate the first
+	If the key is held in isolation for more than _<timeout> ms_, activate the second
 	action, if the key is held for less than _<timeout> ms_ or another key is struck
 	before <timeout> ms expires, execute the first action.
 
@@ -420,7 +420,7 @@ arguments.
 	timeout(a, 500, layer(control))
 
 	Will cause the assigned key to behave as _control_ if it is held for more than
-	500 ms.
+	500 ms, otherwise it will emit _a_.
 
 *swap(<layer>)*
 	Swap the currently active layer with the supplied one. The supplied layer is
```
```diff
diff --git a/docs/keyd-application-mapper.scdoc b/docs/keyd-application-mapper.scdoc
index 4c2518b..89b120c 100644
--- a/docs/keyd-application-mapper.scdoc
+++ b/docs/keyd-application-mapper.scdoc
@@ -55,7 +55,7 @@ E.G:
 	alt.t = C-t
 ```
 
-Will remap _A-1_ to the the string 'Inside st' when a window with a class
+Will remap _A-1_ to the string 'Inside st' when a window with a class
 that begins with 'st-' (e.g st-256color) is active. 
 
 Window class and title names can be obtained by inspecting the log output while the
```
---
```diff
diff --git a/docs/keyd.scdoc b/docs/keyd.scdoc
index 50c4332..ed81246 100644
--- a/docs/keyd.scdoc
+++ b/docs/keyd.scdoc
@@ -229,6 +229,9 @@ layers and cannot be explicitly assigned.
 E.G
 
 ```
+[ids]
+*
+
 [main]
 capslock = layer(capslock)
 
@@ -238,7 +241,7 @@ capslock = layer(capslock)
 h = left
 ```
 
-Will cause the sequence _control+shift+h_ to produce _left_, while preserving
+Will cause the sequence _capslock+shift+h_ to produce _left_, while preserving
 the expected functionality of _capslock_ and _shift_ in isolation.
 
 *Note:* composite layers *must* always be defined _after_ the layers of which they
```
---
```diff
diff --git a/examples/capslock-esc-basic.conf b/examples/capslock-esc-basic.conf
index 939ae9a..ec263e9 100644
--- a/examples/capslock-esc-basic.conf
+++ b/examples/capslock-esc-basic.conf
@@ -1,4 +1,4 @@
-# NOTE: to use this, rename this file to `your keyboard name`.cfg and put in /etc/keyd/
+# NOTE: to use this, rename this file to `your file`.conf and put in /etc/keyd/
 
 # Basic use of capslock as a dual function key:
 #
```
---
```diff
diff --git a/docs/keyd.scdoc b/docs/keyd.scdoc
index 50c4332..397d15d 100644
--- a/docs/keyd.scdoc
+++ b/docs/keyd.scdoc
@@ -88,7 +88,7 @@ For example:
 ```
 
 
-Will match all devices which *do not*(2) have the id _0123:4567_, while:
+Will match all devices which *do not* have the id _0123:4567_, while:
 
 ```
 	[ids]
```
## improvements
```diff
diff --git a/docs/keyd.scdoc b/docs/keyd.scdoc
index 50c4332..a193090 100644
--- a/docs/keyd.scdoc
+++ b/docs/keyd.scdoc
@@ -522,15 +522,15 @@ Make _esc+q_ toggle the dvorak letter layout.
 	[main]
 	esc = layer(esc)
 
-	[dvorak]
-
-	a = a
-	s = o
-	...
-
 	[esc]
 
 	q = toggle(dvorak)
+
+	[dvorak]
+
+	a = a
+	s = o
+	...
 ```
 
 ## Example 2
```
Makes more sense.  In  the current order, to understand what  the code is doing,
we need to read the 1st section, then  the 3rd, then the 2nd.  In the new order,
we can read the sections in their natural order.

---

The word "depress" is used twice:

    •   a group of key codes delimited by + to be depressed as a unit.
                                                  ^-------^

    The supplied layer is active for the duration of the depression of the current layer's activation key.
                                                         ^--------^

This might be confusing for non-native english readers.
Using "press" would be better:

    •   a group of key codes delimited by + to be pressed as a unit.
                                                  ^-----^

    The supplied layer is active while the current layer's activation key is pressed.
                                 ^-------------------------------------------------^

Rationale: I was  wondering whether  the "de"  prefix was  meant to  reverse the
meaning of "press".   Similar to what happens in "deregulate"  vs "regulate", or
"declutter" vs  "clutter".  But that  doesn't seem to  be the case  here.  Here,
"depress" seems to be meant as a synonym for "press".

---

    Swap the currently active layer with the supplied one. The supplied
    layer is active for the duration of the depression of the current
    layer's activation key.

What is the "current layout"?
Remember that the man page says:

    Multiple  layers  may be  active  at  any given  time,  forming  a stack  of
    occluding keymaps consulted in activation order.

How about this instead:

    Swap the top layer with the supplied one.
    The supplied layer is active while the top layer's activation key is pressed.

---

    Subsequent actuations of will thus produce A-tab instead of M-\.

"Subsequent actuations of" what?  backtick?
And why is `M-\` mentioned?
And why is the text underlined:
    Subsequent actuations of will thus produce A-tab instead of M-\.
                             ^------------------------------------^

I think this patch is needed:
```diff
diff --git a/docs/keyd.scdoc b/docs/keyd.scdoc
index 50c4332..41c15a8 100644
--- a/docs/keyd.scdoc
+++ b/docs/keyd.scdoc
@@ -586,7 +586,7 @@ behaviour.
 
 Meta behaves as normal except when \` is pressed, after which the alt_tab layer
 is activated for the duration of the leftmeta keypress. Subsequent actuations
-of _will thus produce A-tab instead of M-\\_.
+of \` will thus produce A-tab instead of M-\`.
 
 ```
 	[meta]
```
---
```diff
diff --git a/docs/keyd.scdoc b/docs/keyd.scdoc
index 50c4332..c1ed29b 100644
--- a/docs/keyd.scdoc
+++ b/docs/keyd.scdoc
@@ -603,8 +603,8 @@ of _will thus produce A-tab instead of M-\\_.
 
 ```
 	# Uses the compose key functionality of the display server to generate
-	# international glyphs.  # For this to work 'setxkbmap -option
-	# compose:menu' must # be run after keyd has started.
+	# international glyphs.  For this to work 'setxkbmap -option
+	# compose:menu' must be run after keyd has started.
 
 	# A list of sequences can be found in /usr/share/X11/locale/en_US.UTF-8/Compose
 	# on most systems.
```
## aliases

It was added in a recent commit:
<https://github.com/rvaiya/keyd/commit/1135ec29c222dc6827ea352cf5c94d195a2c2a35>

Didn't have the time to read the doc yet.

## `macro_sequence_timeout` (global option)

It's not documented in the man page yet.

<https://github.com/rvaiya/keyd/issues/255#issuecomment-1203549054>

## `toggle2()`

Introduced in this commit:
<https://github.com/rvaiya/keyd/commit/fd6840ddf4fe6f1e4bc27fba268ded475d975a68>

## the new layout type, simply named `layout`

<https://github.com/rvaiya/keyd/commit/f4efe1f3648948fa7dbc18be90c56e56ac4d710c>

## `setlayout()`

<https://github.com/rvaiya/keyd/commit/2ec886b6687f0f9ca927ff08215eb9112e58acca>

## `clear()`

<https://github.com/rvaiya/keyd/commit/f6f8793c4292a36525293e578f470d28f1221338>

## `listen` command

<https://github.com/rvaiya/keyd/commit/8b16e02de55ab2ebe1be91dbd2dbb5d186587a2c>

## `reload` command

- <https://github.com/rvaiya/keyd/commit/53f0a85781c706dae44bec40b420aa8598081d16>
- <https://github.com/rvaiya/keyd/commit/2280d509dfdb7bda91acf75e1bd285ad06b0c00d>

## input command

<https://github.com/rvaiya/keyd/commit/959996080447e8c4930526627229179a0572cac3>

## do command

<https://github.com/rvaiya/keyd/commit/abb056ba2c0a2062c67f5937207ccda3d11cd088>

## `-t` flag

- <https://github.com/rvaiya/keyd/commit/5fc6cde3de65d53de240601d70a7a23830031711>
- <https://github.com/rvaiya/keyd/commit/55c4477b8917924d6d8cd4f3da6ef92bbd00afa9>

## `overload2` and `overload3` actions

- <https://github.com/rvaiya/keyd/commit/b1fdaa4d0156c24e626cc3612814c8964bf8afa0>
- <https://github.com/rvaiya/keyd/commit/ae4909ac53b15355e9af152da467abddb08e0616>

## `toggle2`, `swap2`, `overload2`, `overload3` have been renamed (old names will be deprecated)

    toggle2 -> togglem
    swap2 -> swapm
    overload2 -> overloadt
    overload3 -> overloadt2

<https://github.com/rvaiya/keyd/commit/190bd68242a21abb490947537d828590f0a75be3>

## chording

<https://github.com/rvaiya/keyd/commit/afd6fb73a5f07a0a004743a8b743a37205868f11>

    man keyd /CONFIGURATION/;/Chording

## `oneshot_timeout` option

<https://github.com/rvaiya/keyd/commit/7f2dc665fb230a4c16e712f2941c8b392593b2d1>

## `diable_modifier_guard` option

<https://github.com/rvaiya/keyd/commit/115cdece6f2f9b4b9032851d346e7e2869681bc2>

## `overload_tap_timeout` option

<https://github.com/rvaiya/keyd/commit/0ccb1bf900e172a29d9c6d002b837ac25dd9f476>

#
# What do these sentences from man page mean?

    Note: All keyboards defined within a given config file will share the
    same state. This is useful for linking separate input devices together
    (e.g foot pedals).

I *think* the state of the keyboard refers to the currently active layer.
Which means that  if you change the  layer of a keyboard which  is configured in
file A, you change the layer of all the other keyboards configured in A.

---

    These layers play nicely with other modifiers and preserve existing
    stacking semantics.

I *think* this means that if you have this layer:

    [main]
    capslock = layer(foo)

    [foo:C]

And you  press `alt`,  `capslock` and  `x` simultaneously,  then keyd  will emit
`alt`  + `ctrl`  +  `x`.   The modifiers  `alt`  (pressed  manually) and  `ctrl`
(obtained from  the config) stack.   There is not  one cancelling the  other, or
cancelling the overall sequence altogether.

---

    Non-english layouts include a dedicated shift layer (mak‐
    ing order of inclusion important) and require the use of keyd's compose
    definitions (see Unicode Support)

Why is the order important?  Which pitfall is implied here?

Why is keyd's compose definitions required for a non-english layout?
Answer: I guess it's useless for `fr` but not in the general case.
For example, there are unicode characters in `ara` and `ru`.

---

    macro_timeout: The time (in milliseconds) separating the initial
    execution of a macro sequence and the first repetition. (default:
    600)

    macro_repeat_timeout: The time separating successive executions of
    a macro. (default: 50)

When you press a key bound to a macro, keyd executes it immediately.
But if you maintain the key pressed, it's not repeated immediately.
The first repetition is done only after `macro_timeout`.
And the next repetitions are done only after `macro_repeat_timeout`.

# What's the difference between `layer()`, `oneshot()`, `toggle()` and `swap()`?

I think `layer()` and `oneshot()` are similar.
They only activate a given layer temporarily.
For `layer()`, the activation ends as soon as the key to which it is bound is no
longer pressed.  For `oneshot()`, the activation  ends as soon as the *next* key
is pressed.

BTW, `overload()`  is a  variant of  `layer()` which lets  you specify  an extra
behavior on tap.

`toggle()` and `swap()` also look similar.
I think `toggle()` adds or removes a given layer on the stack.
OTOH, `swap()` *replaces* the top layer on the stack with the given one.
Also, I think the swapping ends when the bottom layer is no longer activated.
For example:

    [ids]

    *

    [main]

    rightalt = layer(foo)

    [foo]

    w = swap(bar)

The `bar` layer is only activated while `AltGr` is pressed.
With `toggle()`, the  toggling only ends when  you re-tap the key  to which it's
bound.

# Does `keyd(1)` load *all* `.conf` files under `/etc/keyd`?

    Configuration files are stored in /etc/keyd/ and are loaded upon ini‐
    tialization.
    [...]
    A valid config file has the extension .conf and must begin with an
    [ids] section that has one of the following forms:
    [...]

# In a layer heading what does `:<modifier>` mean?

I  *think* it's  used as  a fallback,  in case  the layer  does not  contain any
binding for the pressed key.

For example, if you  press the key `x`, while the  layer `[foo:C]` is activated,
then `keyd(1)` will send `control+x`.

Similarly, if  you press the  key `y`, while  the layer `[bar:A]`  is activated,
then `keyd(1)` will send `alt+y`.

Make sure our understanding is correct.

# What's the point of `swap2()`?

The only difference with `swap()` is that `swap2()` accepts a 2nd argument which
seems to be a macro which will be sent before swapping with the specified layer.

But it seems that `swap()` also accepts a 2nd optional argument.
For example, in the man page, this example is given:

    ` = swap(alt_tab, A-tab)
                      ^---^

Another example is given in `examples/macos.conf`:

    # ~/VCS/keyd/examples/macos.conf
    tab = swap(app_switch_state, M-tab)
                               ^-----^

---

Also why isn't this 2nd optional argument not documented?

                why no `[, <macro>]`
                v
    swap(<layer>)
        Swap the currently active layer with the supplied one. The supplied
        layer is active for the duration of the depression of the current
        layer's activation key.

#
# study these examples:  https://github.com/rvaiya/keyd/tree/master/examples

# Unicode Support doesn't work

    $ ln -s /usr/share/keyd/keyd.compose ~/.XCompose
    # add this line in the [main] layer of `/etc/keyd/default.conf`:
        w = µ
    # start a new terminal, and press z (not w)
    # expected: µ is inserted
    # actual: àà(" is inserted

Same result with `m = mu`.

# `swap()` bug

Consider this `default.conf`:

    [ids]

    *

    [main]

    w = swap(foo)
    shift = layer(bar)

    [foo]
    2 = 102nd
    w = swap(main)

Tap the `w` key (`z` keycap on azerty keyboard).
Then, tap the `2` key (on the row above the `qwerty` line; not on the keypad).
The `<` character is emitted, which is correct.

Now, tap the `w` key to swap back to the `main` layer.
Next, tap the shift key.
Finally, tap the `2` key again.
Expected: the `<` character is emitted again.
Actual: another is emitted (probably `2` on a qwerty keyboard, `é` on an azerty one).

#
# interface improvements

`swap2()`  and `macro2()`  are  poor  names, because  the  `2`  doesn't tell  us
anything about the difference in semantics compared to `swap()` and `macro()`.

More telling names would be better.
How about this:
`swap2()` → `swap_with_macro()`

And this:
`macro()` → `local_macro()`

"local" because  the provided arguments  overrides the  global options set  in a
`GLOBAL` section.

---

IMO, writing an abbreviation or acronym in lowercase is confusing.  For example,
`IDs` looks better than `ids`.  As a benefit, this makes it easier to understand
that the trailing `s` is not part of the abbreviation, but just a plural suffix.

# doesn't work on the GRUB command-line in a VM

Probably on the GRUB command-line in the host too.
I understand the  issue on the host:  `keyd(1)` has not been  started by systemd
yet; not even the kernel has.  But why is there an issue in a VM too?
Why does it matter for `keyd(1)` that the VM's kernel has not started yet?

---

If  you  need  to  do  tests,  you might  need  to  increase  `GRUB_TIMEOUT`  in
`/etc/default/grub` so that the menu is visible long enough.  Then run:

    $ sudo update-grub

Also, you might need to keep pressing Escape to make the menu appear.
