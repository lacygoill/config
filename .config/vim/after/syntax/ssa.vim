vim9script

# The `ssaText` rule installed by the default syntax plugin kills the CPU:
#
#     syn match ssaText /\(^Dialogue:\(.*,\)\{9}\)\@<=.*$/ contained contains=@ssaTags,@Spell
#
# That's because  of the  variable-width lookbehind  which is a  big no  no in
# general.
syntax clear ssaText
