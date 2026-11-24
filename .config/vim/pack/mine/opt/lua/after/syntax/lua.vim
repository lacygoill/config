vim9script

# highlight `return` like `function`
syntax clear luaStatement
syntax keyword luaStatement break local
syntax keyword luaFunction return

highlight link luaFunction Keyword
highlight link luaFunc Function

# Issue: An embedded lua codeblock might be wrongly highlighted.
# Solution: Clear any problematic rule.
if &filetype == 'markdown'
    # For some reason, `:syntax clear` fails at that point.
    # Let's delay it with a timer.
    timer_start(0, (_) => {
        syntax clear luaParen
        syntax clear luaParenError
    })
endif
