vim9script

if exists('b:current_syntax')
    finish
endif

#     syntax match mermaidStartOfLine /^/ nextgroup=@mermaidCanBeAtStartOfLine skipwhite
#     syntax cluster mermaidCanBeAtStartOfLine contains=...

syntax match mermaidComment /^\s*%%.*$/ contains=@Spell
syntax keyword mermaidDiagramType classDiagram
syntax match mermaidBrace /[(){}]/ containedin=ALL

syntax keyword mermaidStatement direction
syntax keyword mermaidKeyword class

# m..n: from m to n (range)
# n..*: n to many
syntax match mermaidMultiplicity /"\d\+\.\.\%(\d\+\|\*\)"\s\@=/
# n: specific number
syntax match mermaidMultiplicity /"\d\+"\s\@=/

syntax match mermaidLabelText /:.*$/ contains=@Spell

# attributes and methods
syntax match mermaidVisibility /^\s*[-+#]/ nextgroup=mermaidAttribute,mermaidMethod
syntax match mermaidAttribute /[^:]*/ contained nextgroup=mermaidTypeHint skipwhite
syntax match mermaidMethod /\l\w*\ze(/ contained nextgroup=mermaidMethodSignature
syntax match mermaidMethodSignature /([^)]*)/ contained nextgroup=mermaidTypeHint
syntax match mermaidTypeHint /:.*$/hs=s+1 contained

# relation types {{{1

# these ones must come first
syntax match mermaidLinkDashed /\.\.\s\@=/
syntax match mermaidLinkSolid /--/

syntax match mermaidAggregation /--o\|o--/
syntax match mermaidAssociation /-->\|<--/
syntax match mermaidComposition /--\*\|\*--/
syntax match mermaidInheritance /--|>\|<|--/
syntax match mermaidDependency /\.\.>\|<\.\./
syntax match mermaidRealization /\.\.|>\|<|\.\./
#}}}1

# Highlight Groups {{{1

highlight default link mermaidComment Comment
highlight default link mermaidDiagramType Keyword
highlight default link mermaidStatement Statement
highlight default link mermaidKeyword Keyword

highlight default link mermaidLinkDashed Operator
highlight default link mermaidLinkSolid Operator
highlight default link mermaidAggregation Operator
highlight default link mermaidAssociation Operator
highlight default link mermaidComposition Operator
highlight default link mermaidDependency Operator
highlight default link mermaidInheritance Operator
highlight default link mermaidRealization Operator

highlight default link mermaidAttribute Identifier
highlight default link mermaidBrace Delimiter
highlight default link mermaidLabelText String
highlight default link mermaidMethod Function
highlight default link mermaidMultiplicity Number
highlight default link mermaidTypeHint Type
highlight default link mermaidVisibility Operator

b:current_syntax = 'mermaid'
