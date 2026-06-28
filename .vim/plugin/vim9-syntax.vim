vim9script noclear

if stridx(&runtimepath, '/vim9-syntax,') == -1
    finish
endif

g:vim9_syntax = {
    builtin_functions: true,
    data_types: true,
    user_types: true,
    fenced_languages: [],
    errors: {
        event_wrong_case: true,
        octal_missing_o_prefix: true,
        range_missing_space: true,
        range_missing_specifier: true,
        strict_whitespace: true,
    }
}
