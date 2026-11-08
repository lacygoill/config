# What are the benefits of making a function autoloaded?  (3)

   - it becomes available automatically to all running shells

   - if its definition is changed, all running shells will automatically reload
     the altered version, after a while

   - startup time and memory usage is improved

##
# Where does fish look for an autoloaded function?

It iterates over the directories in the list variable `$fish_function_path`.
In each of them, it  looks for a file with a name consisting  of the name of the
function plus the suffix `.fish`.  The first matching file is sourced.

## What's the value of this variable?

By default, it contains:

   - `~/.config/fish/functions/`: that's for you
     ^--------^
     `$XDG_CONFIG_HOME`

   - `$__fish_sysconf_dir/functions`: that's for all users on the system

   - `/usr/local/share/fish/vendor_functions.d`: that's for other software
     ^---------------^
     `$XDG_DATA_DIRS`

   - `$__fish_data_dir/functions`: that's for the devs

Remember the name of `$__fish_data_dir`.
That's where you'll find most of the functions (aside from yours).
It's somewhat similar to `$VIMRUNTIME`.

### What's this “vendor” directory?

If a sofware  wants to provide some function(s) to  improve its integration with
the fish shell, that's where they should put it.

If  you are  a  dev  of such  a  software,  and you  want  to  get its  location
programmatically, use `pkgconfig(1)`:

    $ pkg-config --variable functionsdir fish
    /usr/local/share/fish/vendor_functions.d

`pkg-config(1)` can give metadata about installed packages.
`--variable` can specify which information you want exactly.
Here, we ask for the `functionsdir` variable in the `fish` package.

##
# Can I put several autoload functions in a single file?

No.

Suppose you have:

   - 2 autoload functions in a single file: A and B
   - an autoload file whose name is `A.fish`
   - a key binding which calls B (say `<F3>`)

When  you press  `<F3>`, fish  won't find  B's definition  (because there  is no
`B.fish` file).   Unless, you already  called A at least  once, causing B  to be
loaded at the same time.

Writing 2 autoload functions  in the same file implies that  one of them depends
on the other.  You probably don't want that.

---

This doesn't mean that you can't put several functions in the same file.
It makes perfect sense to split a long autoload function into several functions:

    function A
        B
        C
    end
    function B
        ...
    end
    function C
        ...
    end

But, only A is meant to be called directly; not B, nor C.
Here, the dependency makes sense, because the sole purpose of B and C is to help A.

# How can I override the definition of an autoload function provided by the devs?

Simply redefine it in `~/.config/fish/functions/`.
The devs put their functions in `$__fish_data_dir/functions`.
But the latter comes later in `$fish_function_path`.
And fish stops looking for a definition as soon as it finds one.
IOW, once it finds yours, it won't load the devs' one.
