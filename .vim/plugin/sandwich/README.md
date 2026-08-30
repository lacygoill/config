# Design
## What are the two main parts making up `vim-sandwich`?

   - operator-sandwich
   - textobj-sandwich

## Can they cooperate?   Can they be used independently?

Yes and yes.

IOW:

   - any object   provided by `textobj-sandwich`  can be composed with any operator
   - any operator provided by `operator-sandwich` can be composed with any object

##
## In which variables can any kind of recipe be stored? (from the highest priority to the lowest)   (3)

   - b:sandwich_recipes
   - g:sandwich#recipes
   - g:sandwich#default_recipes

## In which variables can a recipe implementing an operator be stored?   (3)

   - b:operator_sandwich_recipes
   - g:operator#sandwich#recipes
   - g:operator#sandwich#default_recipes

## In which variables can a recipe implementing an object be stored?   (3)

   - b:textobj_sandwich_recipes
   - g:textobj#sandwich#recipes
   - g:textobj#sandwich#default_recipes

##
## What's a magiccharacter?

When  the plugin  requests the  user  to input  keys  to determine  the text  to
add/delete, usually they are not interpreted.

But there are some exceptions.
For example, `sdf`  doesn't try to delete two surrounding  `f` characters, but a
surrounding function name.

##
# Operators
## What are the three operators provided by the plugin?

    ┌─────┬─────────────────────────────────────────┐
    │ LHS │                   RHS                   │
    ├─────┼─────────────────────────────────────────┤
    │ sa  │ <plug>(operator-sandwich-add)           │
    ├─────┼─────────────────────────────────────────┤
    │ sd  │ <plug>(operator-sandwich-delete)        │
    │     │ <plug>(operator-sandwich-release-count) │
    │     │ <plug>(textobj-sandwich-query-a)        │
    ├─────┼─────────────────────────────────────────┤
    │ sr  │ <plug>(operator-sandwich-replace)       │
    │     │ <plug>(operator-sandwich-release-count) │
    │     │ <plug>(textobj-sandwich-query-a)        │
    └─────┴─────────────────────────────────────────┘

## On what condition do they work?

`sa` work unconditionally.

However, for  `v_sd` and  `v_sr` to work,  the first and  last character  of the
selection must be identical, or they must be stored in a recipe (`buns` key).

##
## What are the key sequences to which the following operators are mapped?   (2 answers each time)
### the operator adding surroundings

        sa
        <plug>(operator-sandwich-add)

It works in normal and visual modes.

### the operator deleting surroundings

        sd
        <plug>(operator-sandwich-delete)

It works in visual mode if the ends  of the selected region are identical, or if
they're included in the set of registered surroundings.

### the operator replacing surroundings

        sr
        <plug>(operator-sandwich-replace)

It works in visual mode if the ends  of the selected region are identical, or if
they're included in the set of registered surroundings.

##
# Objects
## What are the four objects provided by the plugin?

                            ┌ look for the surrounding characters automatically
                            │    ┌ but don't include them in the object
                            │    │
    <plug>(textobj-sandwich-auto-i)      bound to `ib` by default
    <plug>(textobj-sandwich-auto-a)      "        `ab` "
    <plug>(textobj-sandwich-query-i)     "        `is` "
    <plug>(textobj-sandwich-query-a)     "        `as` "
                            │     │
                            │     └ and include it in the object
                            └ ask the user what's the surrounding character

## What are the key sequences to which the following objects are mapped?   (2 answers each time)
### the object selecting, automatically, a sandwiched text

        <plug>(textobj-sandwich-auto-i)
        <plug>(textobj-sandwich-auto-a)

They are mapped to the key sequences `ib` and `ab`.
They are valid in both operator-pending mode and visual mode.
`ib` selects the text INSIDE the surroundings.
`ab` selects the text INCLUDING surroundings.

### the object selecting, depending on user input, a sandwiched text

        <plug>(textobj-sandwich-query-i)
        <plug>(textobj-sandwich-query-a)

They are mapped to the key sequences `is` and `as`.
They are valid in both operator-pending mode and visual mode.
`is` selects the text INSIDE the surroundings.
`as` selects the text INCLUDING surroundings.

##
# Exercises
## 1

           normal mode: ↣ saiw( ↢

    foo    ---->    (foo)

           visual mode: ↣ viwsa( ↢

## 2

               normal mode: ↣ sd( ↢ 1st solution
                            ↣sb ↢ 2nd solution

    (foo)    ---->    foo

               visual mode: ↣ va(sd ↢

More generally, every time you have  to provide a surrounding character to `sa`,
`sd`, `sr`, you can give `b` to ask the plugin to look for it automatically.

## 3

               normal mode: ↣ sr(" ↢

    (foo)    ---->    "foo"

               visual mode: ↣ va(sr" ↢

## 4

               normal mode: ↣ 2sdb ↢

    (bar(foo)baz)    ---->    bar(foo)baz
          ^
          cursor

## 5

               ↣ saiwffunc CR ↢

    arg      ---->     func(arg)
