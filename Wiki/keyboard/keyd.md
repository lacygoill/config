# Glossary
## binding

Specifiy the behaviour of a particular key.

##
## layer

Collection of bindings.

### default layer

Layer named `[main]`; it should contain definitions of common bindings.

By default, in this layer, each key is bound to itself.

Exception: the  modifier keys  are bound  to eponymously  named layers  with the
corresponding modifiers.

For example,  the `meta`  key is  bound to the  `layer(meta)` action,  where the
layer named `meta` is internally defined as `[meta:M]`.

##
# How does `keyd(1)` handle multiple layers activated at the same time?

They form a stack of "occluding" keymaps consulted in activation order.

That is, when  a layer is activated, it  does not erase all the  bindings of the
previous one;  but if both layers  have different definitions for  the same key,
the last  one wins.  Another  way of putting  it: a binding for  a key in  a top
layer occludes a binding for the same key in a bottom layer.

---

Example:

     - -   3rd layer activated; 3rd consulted
    -- --  2nd layer activated; 2nd consulted
    - - -  1st layer activated; 1st consulted

In this example, there are 3 layers on the stack.
Each hyphen represents a binding for a key.
All the bindings in a given column apply to the same key.
The binding for the k-th key will be taken from the l-th layer, where `(k, l)` is:

    (1, 2)
    (2, 3)
    (3, 1)
    (4, 3)
    (5, 2)
