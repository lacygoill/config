system logging facility used for monitoring and troubleshooting purposes

# priorities

    ┌────────────┬────────────────────────────────────┐
    │ level      │ meaning                            │
    ├────────────┼────────────────────────────────────┤
    │ emerg, 0   │ system is unusable                 │
    ├────────────┼────────────────────────────────────┤
    │ alert, 1   │ action must be taken immediately   │
    ├────────────┼────────────────────────────────────┤
    │ crit, 2    │ critical conditions                │
    ├────────────┼────────────────────────────────────┤
    │ err, 3     │ error conditions                   │
    ├────────────┼────────────────────────────────────┤
    │ warning, 4 │ warning conditions                 │
    ├────────────┼────────────────────────────────────┤
    │ notice, 5  │ normal, but significant, condition │
    ├────────────┼────────────────────────────────────┤
    │ info, 6    │ informational message              │
    ├────────────┼────────────────────────────────────┤
    │ debug, 7   │ debug-level message                │
    └────────────┴────────────────────────────────────┘

See: `man syslog /DESCRIPTION/;/Values for level`.
