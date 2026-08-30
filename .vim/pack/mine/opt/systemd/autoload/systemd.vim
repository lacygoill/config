vim9script noclear

import '../import/systemd.vim'

# Init {{{1

if !systemd.cached_parameters->filereadable()
    echomsg $'{systemd.cached_parameters} is not readable'
    finish
endif

const cached_parameters: dict<list<dict<any>>> = systemd.cached_parameters
    ->readfile('', 1)
    ->get(0, '')
    ->json_decode()

# Interface {{{1
export def Complete(findstart: bool, base: string): any #{{{2
    if findstart
        return searchpos('\s\zs', 'bnW', line('.'))[1]
    endif

    var extension: string = GetExtension()
    var section: string = search('^\s*\[.*\]\s*$', 'bnW')
        ->getline()
        ->trim('[]')
    if section == '' || extension == ''
        return []
    endif

    var is_user_file: bool = expand('%:p') =~ '/user/'
    var params: dict<list<dict<any>>> = cached_parameters
        ->deepcopy()
        ->filter((param: string, ld: list<dict<any>>): bool =>
                    param->stridx(base) == 0
                && (!is_user_file || param->CanBeUsedInUserFile()))
    var matches: list<dict<string>>
    for [param: string, contexts: list<dict<any>>] in params->items()
        contexts->filter((_, ctx: dict<any>): bool =>
            IsValidExtensionForThisParam(ctx, extension)
            && IsValidSectionForThisParam(ctx, section))
        if contexts->empty()
            continue
        endif
        var description: string = contexts
            ->copy()
            ->map((_, ctx: dict<any>) => ctx.pum_description)
            ->join(' | ')
        matches->add({word: param, menu: description})
    endfor
    # sort the matches by parameter name
    matches
        ->sort((i: dict<string>, j: dict<string>): number => i.word > j.word ? 1 : -1)

    return matches
enddef
#}}}1
# Util {{{1
def GetExtension(): string #{{{2
    var curbuf: string = bufname('%')
    var tail: string = curbuf->fnamemodify(':t')
    var extension: string = curbuf->fnamemodify(':e')
    # We might need to remove some trailing number.{{{
    #
    # That happens if we edit a unit  file with `$ systemctl edit`.
    # In that  case, systemd makes  us work in a  temporary file whose  name has
    # been appended with a 16-digits hexadecimal number:
    #
    #     $ sudo systemctl edit --full auditd.service
    #     :echo expand('%:p')
    #     /etc/systemd/system/.#auditd.service00db55f60b302a4f
    #                                         ^--------------^
    #                                         we need to remove this
    #}}}
    if tail =~ '^\.#.*\.[^.]*\x\{16}'
        extension = extension->substitute('\x\{16}$', '', '')
    endif
    return extension
enddef

def IsValidExtensionForThisParam(ctx: dict<any>, extension: string): bool #{{{2
    return ctx.file_extensions->index(extension) >= 0
enddef

def IsValidSectionForThisParam(ctx: dict<any>, section: string): bool #{{{2
    return ctx.sections->index(section, 0, true) >= 0
enddef

def CanBeUsedInUserFile(param: string): bool #{{{2
    return systemd.system_only->index(param) == -1
enddef
