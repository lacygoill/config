# When is `conf.d/` loaded?

On  startup,  any  `.fish`  script   inside  is  automatically  executed  before
`config.fish`.   That's  true  no  matter   the  type  of  shell:  whether  it's
interactive, and whether it lets you log in.

# Where are universal variables stored?

    $__fish_config_dir/fish_variables

# Which convention should I follow when naming my functions?

Make them  all start with  a single underscore, so  that they don't  pollute tab
completions.

---

As a plugin author, I suggest you follow this convention:

   - functions and variables expected to be used by average users
   = no leading underscore

   - functions and variables documented and guaranteed to have a stable interface,
     but meant for people doing advanced things
   = single leading underscore

   - anything truly private; i.e. the behavior can change at any time
   = two leading underscores (aka a dunderscore)

Inspiration: <https://github.com/fish-shell/fish-shell/issues/4191#issuecomment-314305425>
