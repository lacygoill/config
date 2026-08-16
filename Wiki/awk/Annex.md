# operators precedence

In descending order:

    ┌─────────────────────────┬──────────────────────────────────────────────┐
    │ ()                      │ grouping                                     │
    │ $ Field                 │ reference                                    │
    │ ++ --                   │ increment, decrement                         │
    │ ^                       │ exponentiation                               │
    │ !+-                     │ logical “not”, unary plus, unary minus       │
    │ */%                     │ multiplication, division, modulo (remainder) │
    │ +-                      │ addition, subtraction                        │
    │                         │ concatenation                                │
    │ < <= == != > >= >> | |& │ relational and redirection                   │
    │ ~ !~                    │ regex (non)matching                          │
    │ in                      │ array membership                             │
    │ &&                      │ logical “and”                                │
    │ ||                      │ logical “or”                                 │
    │ ?:                      │ ternary conditional                          │
    │ = += -= *= /= %= ^=     │ assignment                                   │
    └─────────────────────────┴──────────────────────────────────────────────┘

# regex operators precedence

In descending order:

    ┌────────┬─────────────────────────────────┐
    │ ()     │ grouping + capture              │
    │ ?      │ question mark                   │
    │ +      │ plus                            │
    │ *      │ star                            │
    │        │ concatenation                   │
    │ |      │ alternation                     │
    │ [^abc] │ complemented bracket expression │
    │ [abc]  │ bracket Expression              │
    │ .      │ any character                   │
    │ $      │ end of string                   │
    │ ^      │ beginning of string             │
    │ \c     │ escape sequence                 │
    └────────┴─────────────────────────────────┘

The order was found in the book `The AWK Programming Language`, appendix A, page
191 of the book.
