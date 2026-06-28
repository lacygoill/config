# Vim gives `E474` on startup!

    Error detected while processing function submode#enter_with[3]..<SNR>141_define_entering_mapping:
    line   55:
    E474: Invalid argument

Make  sure that  the first  argument  you pass  to `submode#enter_with()`  never
contains more than 17 characters:

    call submode#enter_with('xxx', ...)
                             ^^^
                             17 characters or less
