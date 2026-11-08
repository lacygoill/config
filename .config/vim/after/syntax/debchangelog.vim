vim9script

# The default  syntax plugin highlights the  header at the bottom  of the file
# like an error, presumably because the author finds the color pretty:
#
#                                              v------------v
#     " Associate our matches and regions with pretty colours
#     hi def link debchangelogHeader  Error
#                                     ^---^
#
# We don't want to  use a HG because it's pretty in a  given color scheme.  We
# want to use a  HG because it has some relevant  meaning.  Let's try `Title`;
# maybe not the best choice, but still less distracting than `Error`.
highlight link debchangelogHeader Title
