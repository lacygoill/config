# I can't test the existence of `g:sandwich#default_recipes` from `~/.vim/after/plugin/sandwich.vim`!

It's an *autoloaded* variable.
It doesn't exist until you ask for its value:

    echom exists('g:sandwich#default_recipes')
        → 0 ✘

    echom get(g:, 'sandwich#default_recipes', [])
        → [] ✘

    echom g:sandwich#default_recipes
        → [ ... ] ✔

When you  ask for  its value,  Vim will  look in  all `plugin/`  and `autoload/`
subdirectories of the rtp, for a  file named `sandwich` (because that's the path
before the last number sign #), and then for the variable itself.

---

As a  workaround, to be  reasonably sure that the  variable can be  defined, you
could test whether the plugin has been sourced:

    if !exists('g:loaded_sandwich')
        finish
    endif

Or use a `try` conditional before trying to use its value in an assignment.
