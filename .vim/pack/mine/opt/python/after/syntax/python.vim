vim9script

# It is allowed to include underscores in a big number to make it more readable.
# But the default syntax plugin doesn't support this feature.
# Let's support it.
syntax match pythonNumber /\<\%([1-9][0-9_]*\|0\)[Ll]\=\>/
#                                        ^

# `Any` and `Dict` in type annotations:{{{
#
#     from typing import Any, Dict
#
#     name: Any = value
#           ^^^
#
#     name: Dict[str, Any] = { ... }
#           ^--^      ^^^
#
#     def func(x: List[Dict[Any]])
#                 ^--^ ^--^ ^^^
#}}}
syntax match pythonTypeAny /\%([[,:]\|->\)\s*\zsAny\>/
syntax match pythonTypeListOrDict /\%([[,:]\|->\)\s*\zs\%(List\|Dict\)\ze\[/
highlight default link pythonTypeAny pythonBuiltin
highlight default link pythonTypeListOrDict pythonBuiltin
