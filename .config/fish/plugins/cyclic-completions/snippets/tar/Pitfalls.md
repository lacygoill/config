# `--null` should always come *before* `--files-from`, because it's a positional argument.

That is, `--null` affects arguments positioned later (not before).
Otherwise, `tar(1)` gives an error:

                                         ✘
                    v----------v       v----v
    $ ... | tar ... --files-from=- ... --null
    tar: -: file name read contains nul character
    tar: The following options were used after any non-optional arguments in archive create or update mode.
    These options are positional and affect only arguments that follow them.
    Please, rearrange them properly.
    tar: --null has no effect
    tar: Exiting with failure status due to previous errors
