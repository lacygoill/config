vim9script noclear

if exists('loaded') || stridx(&runtimepath, '/vim-sandwich,') == -1
    finish
endif
var loaded = true

# Mappings {{{1

# The  plugin  shadows  `:help ib`  which  lets us  operate  on  the  inside  of
# parentheses even while the cursor is *before* the parens:
#
#     # ~/.vim/pack/vendor/opt/vim-sandwich/plugin/sandwich.vim
#     silent! omap <unique> ib <Plug>(textobj-sandwich-auto-i)
#
# Unfortunately, the plugin's replacement does not support this feature.
# Same thing with `:help ab`.  Let's disable these mappings:
onoremap <unique> ib ib
onoremap <unique> ab ab
# We could also set this config variable:
#
#     g:textobj_sandwich_no_default_key_mappings = true
#
# But it would disable more mappings.
# In particular `is`, which I think we're used to press sometimes.

nmap <unique> <Space>s saiw
nmap <unique> <Space>S saiW

# The plugin installs the following mappings:
#
#     x  is  <Plug>(textobj-sandwich-query-i)
#     x  as  <Plug>(textobj-sandwich-query-a)
#     o  is  <Plug>(textobj-sandwich-query-i)
#     o  as  <Plug>(textobj-sandwich-query-a)
#
# They  shadow the  built-in  sentences objects.   But we  use  the latter  less
# frequently than the sandwich objects.  So, we won't remove the mappings.  But,
# instead, to restore the sentences objects, we install these mappings:

onoremap <unique> iS is
onoremap <unique> aS as

xnoremap <unique> iS is
xnoremap <unique> aS as

# Recipes {{{1

{
    # Don't we need `deepcopy()`?{{{
    #
    # If we executed this simple assignment:
    #
    #     g:sandwich#recipes = g:sandwich#default_recipes
    #
    # ... then, yes, `deepcopy()` would probably be needed.
    # Because, `g:sandwich#recipes` and `g:sandwich#default_recipes` would share
    # the same reference.
    # So, when we  would try to modify  the first one, we would  also modify the
    # second one, which is not possible because it's locked.
    #
    # However, the  RHS of our  assignment not a  simple variable name,  it's an
    # expression using the `+` operator.
    # Thus,  Vim has  to create  a  new reference  to  store the  result of  the
    # expression
    #}}}
    # What's this `–`?{{{
    #
    # An en dash.
    #
    # https://english.stackexchange.com/a/2126/313834
    # https://en.wikipedia.org/wiki/Dash#En_dash
    # https://en.wikipedia.org/wiki/Dash#En_dash_versus_em_dash
    # https://en.wikipedia.org/wiki/Whitespace_character#Hair_spaces_around_dashes
    # https://tex.stackexchange.com/a/60038/169646
    #}}}
    # Why the recipe for ['`', "'"]?{{{
    #
    # It's often used to quote some word in man pages.
    # See here for more info:
    # https://english.stackexchange.com/q/17695/313834
    # https://www.cl.cam.ac.uk/~mgk25/ucs/quotes.html
    #}}}
    # Why the input 'g'?{{{
    #
    # 'g' for Grave accent.
    #}}}
    # TODO: https://www.reddit.com/r/vim/comments/c3aeoy/always_loathed/
    g:sandwich#recipes = g:sandwich#default_recipes
        + [{buns: ["\<Esc>[3m", "\<Esc>[0m"],   input: ['si']}]
        + [{buns: ["\<Esc>[1m", "\<Esc>[0m"],   input: ['sb']}]
        + [{buns: ["\<Esc>[1;3m", "\<Esc>[0m"], input: ['sB']}]
        + [{buns: ['– ', ' –'],         input: ['d']}]
        + [{buns: ['`', "'"],           input: ['g']}]
        + [{buns: ['“', '”'],           input: ['u"']}]
        + [{buns: ['‘', '’'],           input: ["u'"]}]
        + [{buns: ['«', '»'],           input: ['u<']}]
        + [{buns: ['```diff', '```'],   input: ['D'],
        # make sure that the diff is clamped to the right border of the window
              command: ['execute ":''[,''] substitute/^\\s\\{" .. indent("''[") .. "}//e"']}]

    # We need to remove some recipes.{{{
    #
    # Otherwise, sometimes, when  we press `srb` from normal mode,  or `sr` from
    # visual  mode, Vim  doesn't respond  anymore  for several  seconds, and  it
    # consumes a lot of cpu.
    #
    # This  is because,  sometimes,  when  the plugin  must  find  what are  the
    # surrounding characters itself, it *wrongly* finds a tag.
    #
    #     <Plug>(textobj-sandwich-tagname-a)
    #
    #     sandwich#magicchar#t#a()
    #     ~/.vim/pack/vendor/opt/vim-sandwich/autoload/sandwich/magicchar/t.vim
    #
    #     call s:prototype('a')
    #             execute printf('normal! v%dat', v:count1)
    #
    #             v1at
    #             E65: Illegal back reference˜
    #}}}
    # Removing these recipes may make us lose the tag object.{{{
    #
    # We could:
    #
    #    - submit a bug report:
    #
    #         The plugin detection of surrounding characters should be improved.
    #         If it can't, when `E65` occurs, the plugin should stop and show it to us.
    #         Why doesn't that happen?
    #
    #    - try and tweak the definition of these recipes
    #
    #      IMHO, it's the best solution.
    #      We should have a minimum of global recipes.
    #      And add relevant recipes for some filetypes via `b:sandwich_recipes`.
    #      For example, a tag recipe is not very useful in a vim file.
    #      But it's certainly useful in an html file.
    #
    #      Bottom Line:
    #
    #        * Better understand how to define/customize a recipe.
    #        * Define a minimum of recipes.
    #        * Make them relevant to the current filetype.
    #
    #    - let the recipes in, and disable the problematic operators:
    #
    #         nnoremap srb <Nop>
    #         xnoremap sr  <Nop>
    #}}}

    # TODO: Instead  of  removing  some  problematic recipes,  we  should  add
    # recipes which we know not to cause  any issue.  IOW, a whitelist is more
    # reliable than a blacklist.
    var problematic_recipes: list<dict<any>> = [{
        noremap: 0,
        expr_filter: ['operator#sandwich#kind() ==# "replace"'],
        kind: ['replace', 'textobj'],
        external: ["\<Plug>(textobj-sandwich-tagname-i)", "\<Plug>(textobj-sandwich-tagname-a)"],
        input: ['t']
    }]

    for recipe: dict<any> in problematic_recipes
        var idx: number = g:sandwich#recipes->index(recipe)
        if idx >= 0
            remove(g:sandwich#recipes, idx)
        endif
    endfor
}
