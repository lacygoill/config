# Table of (some) operators in descending order of precedence

    ┌───────────┬────────────────────────────┬─────────────────────────┐
    │ Symbol(s) │ Name                       │ Associativity           │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ []        │ Array subscripting         │ Left                    │
    │ ()        │ Function call              │ Left                    │
    │ .  ->     │ Structure and union member │ Left                    │
    │ ++        │ Increment postfix          │ Left                    │
    │ --        │ Decrement postfix          │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ ++        │ Increment prefix           │ Right                   │
    │ --        │ Decrement prefix           │ Right                   │
    │ &         │ Address                    │ Right                   │
    │ *         │ Indirection                │ Right                   │
    │ +         │ Unary plus                 │ Right                   │
    │ -         │ Unary minus                │ Right                   │
    │ ~         │ Bitwise complement         │ Right                   │
    │ !         │ Logical negation           │ Right                   │
    │ sizeof    │ Size                       │ Right                   │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ ()        │ Cast                       │ Right                   │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ * / %     │ Multiplicative             │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ + -       │ Additive                   │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ <<  >>    │ Bitwise shift              │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ < > <= >= │ Relational                 │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ == !=     │ Equality                   │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ &         │ Bitwise and                │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ ^         │ Bitwise exclusive or       │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ |         │ Bitwise inclusive or       │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ &&        │ Logical and                │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ ||        │ Logical or                 │ Left                    │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ ?:        │ Conditional                │ Right                   │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ =  *= /=  │ Assignment                 │ Right                   │
    │ %= += -=  │                            │                         │
    │ <<= >>=   │                            │                         │
    │ &= ^= |=  │                            │                         │
    ├───────────┼────────────────────────────┼─────────────────────────┤
    │ ,         │ Comma                      │ Left                    │
    └───────────┴────────────────────────────┴─────────────────────────┘

Operators in the same cell have the same precedence.
If you have several operators of  equal precedence adjacent to the same operand,
you need to know  another one of their property to  determine how the operations
will be grouped: their associativity.
