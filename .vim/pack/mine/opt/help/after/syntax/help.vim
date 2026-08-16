vim9script

# Conceal syntax item helpNotVi.
#
# We found `helpNotVi` with `zs`.
# Its definition was found with:
#
#     :Verbose syntax list helpNotVi
syntax region help_noise_NotInVi start="{only" start="{not" start="{Vi[: ]" end="}"  contains=helpLeadBlank,helpHyperTextJump conceal
# We still want to see sth like `{classes are not implemented yet}` (from `:help Vim9`).
syntax match help_not_implemented /{.*not implemented yet}/

syntax match help_noise_env_vrb      /\%(- \)\=Environment\_s*variables\_s*are\_s*expanded\_s*|:set_env|./ conceal
syntax match help_noise_op_backslash /,\=\_s*(\=\_s*[sS]ee\_s*|option-backslash|\_s*about\_s*including\_s*spaces\_s*and\_s*backslashes)\=./ conceal
syntax match help_noise_modeline /This\_s*option\_s*cannot\_s*be\_s*set\_s*from\_s*a\_s*|modeline|\_s*or\_s*in\_s*the\_s*|sandbox|,\_s*for\_s*security\_s*reasons./ conceal

# Functions arguments containing an underscore are not highlighted.{{{
#
# Example: `:help syn-region`
#
#     :sy[ntax] region {group-name} [{options}]
#                     [matchgroup={group-name}]
#                     [keepend]
#                     [extend]
#                     [excludenl]
#                     start={start_pattern} ..
#                           ^-------------^
#                     ...
#}}}
syntax match helpSpecial @{[-_a-zA-Z0-9'"*+/:%#=[\]<>.,]\+}@
#                            ^

# support language annotation in codeblocks (e.g. `>vim` or `>lua`)
syntax clear helpExample
syntax region helpExample
    \ matchgroup=helpIgnore
    \ start=/ >[a-z0-9]*$/
    \ start=/^>[a-z0-9]*$/
    \ end=/^[^[:blank:]]/me=e-1
    \ end=/^</
    \ concealends
