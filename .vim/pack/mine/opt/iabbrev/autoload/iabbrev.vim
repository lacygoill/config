vim9script

# Digraphs {{{1

# For en dashes (`–`), don't forget we also have a sandwich!{{{
#
# It's defined  in `~/.vim/plugin/sandwich.vim`.   If you  need to  surround a
# text with en  dashes, visually select it, and press  `sad`.  The plugin also
# supports text-objects/motions (e.g.  press `sa$d` to surround  until the end
# of the line).
#}}}
const DIGRAPHS: list<string> =<< trim END
    ns  
    nd –
    o/ ∅
    ok ✔
    no ✘
    aa â
    ee ê
    ii î
    oo ô
    uu û
    um ù
    pp …
    tl ┌
    bl └
    tr ┐
    br ┘
    fa ∀
    te ∃
    e_ ∈
    e/ ∉
    co ⊥
    nt ¬
    an ∧
    or ∨
    |v ↓
    |^ ↑
    |> ↳
    =~ ≈
    f> →
    in ∫
    pi π
    sq √
    ti ˜
END

DIGRAPHS
    ->mapnew((_, v: string): list<string> => v->split())
    ->digraph_setlist()

# Abbreviations {{{1

# TODO: Review the abbreviations and their triggers.
# Keep only the useful ones.
#
# Use `:WordFrequency`,  but if you find  a frequent word (like  "result"), it
# doesn't necessarily mean you should create an abbreviation just for it.
#
# Maybe it's frequently  used in a group  of words (like "as  a result"); look
# for it in your file, and see  in which context it's used before creating the
# abbreviation.

# adjectives/adverbs {{{2

inoreabbrev alt   alternative
inoreabbrev alT   Alternatively,

inoreabbrev auto  automatic
inoreabbrev autO  automatically

inoreabbrev cur   current
inoreabbrev cuR   currently

inoreabbrev def   default

inoreabbrev dif   different
inoreabbrev diF   differently
inoreabbrev diff  difference

inoreabbrev gen   general
inoreabbrev geN   generally

inoreabbrev imm   immediate
inoreabbrev imM   immediately

inoreabbrev nec   necessary
inoreabbrev neC   necessarily

inoreabbrev prob  probable
inoreabbrev proB  probably

inoreabbrev prev  previous
inoreabbrev preV  previously

inoreabbrev tmp   temporary
inoreabbrev tmP   temporarily

inoreabbrev otc   on the condition that
inoreabbrev unC   unconditionally

inoreabbrev unx   unexpected
inoreabbrev unX   unexpectedly

inoreabbrev unf   unfortunate
inoreabbrev unF   Unfortunately,

inoreabbrev uni   unintentional
inoreabbrev unI   unintentionally

inoreabbrev unn   unnecessary
inoreabbrev unN   unnecessarily

# conjunctions {{{2

inoreabbrev aar   as a result
inoreabbrev Aar   As a result,

inoreabbrev bd    by default
inoreabbrev Bd    By default,

inoreabbrev bec   because
inoreabbrev tbec  that's because
inoreabbrev Tbec  That's because

inoreabbrev fe    for example
inoreabbrev Fe    For example,

inoreabbrev fsr   for some reason
inoreabbrev Fsr   For some reason,

inoreabbrev iff   if, and only if,

inoreabbrev ow    otherwise
inoreabbrev Ow    Otherwise,

inoreabbrev rt    rather than

# labels {{{2

inoreabbrev fm  FIXME:
inoreabbrev td  TODO:

# latin phrases {{{2

inoreabbrev eg  e.g.
inoreabbrev ie  i.e.

# nouns {{{2

inoreabbrev app   application
inoreabbrev arg   argument
inoreabbrev bg    background
inoreabbrev bs    backslash
inoreabbrev buf   buffer
inoreabbrev cert  certificate
inoreabbrev cli   command-line
inoreabbrev cmd   command
inoreabbrev db    database
inoreabbrev dir   directory
inoreabbrev env   environment
inoreabbrev ex    example
inoreabbrev expr  expression
inoreabbrev fg    foreground
inoreabbrev fn    function
inoreabbrev fs    filesystem
inoreabbrev kbd   key binding
inoreabbrev msg   message
inoreabbrev ns    namespace
inoreabbrev occ   occurrence
inoreabbrev oper  operator
inoreabbrev opt   option
inoreabbrev pam   parameter
inoreabbrev par   paragraph
inoreabbrev paren parentheses
inoreabbrev pat   pattern
inoreabbrev pgm   program
inoreabbrev pkg   package
inoreabbrev proc  process
inoreabbrev reg   register
inoreabbrev rep   replacement
inoreabbrev sth   something
inoreabbrev stt   statement
inoreabbrev sub   substitution
inoreabbrev syn   syntax
inoreabbrev ter   terminal
inoreabbrev var   variable
inoreabbrev win   window
inoreabbrev wsp   whitespace

# prepositions {{{2

inoreabbrev bet  between

inoreabbrev wrt  with regard to
inoreabbrev Wrt  With regard to

# phrases {{{2

inoreabbrev fmi  For more info:
inoreabbrev tqb  the quick brown fox jumps over the lazy dog

# quantifiers {{{2

inoreabbrev alo  a lot of
inoreabbrev sev  several

# typos {{{2

inoreabbrev ecoh  echo
inoreabbrev ot    to
inoreabbrev hte the
inoreabbrev teh the
inoreabbrev vai   via
inoreabbrev wich  which

# verbs {{{2

inoreabbrev dis  display
inoreabbrev dl   download
inoreabbrev exe  execute
inoreabbrev hl   highlight
inoreabbrev xt   extract

# Don't write `inoreabbrev cd could`
# It shadows `cd(1)` which we often need to write, even in comments.
inoreabbrev cdn  couldn't

inoreabbrev sd   should
inoreabbrev sdn  shouldn't
inoreabbrev wd   would
inoreabbrev wdn  wouldn't

inoreabbrev dn   don't
inoreabbrev dsn  doesn't
inoreabbrev isn  isn't
# }}}1
# Init {{{1

var ABBREVS: list<list<any>>
{
    for line: string in execute('iabbrev')->split('\n')
        var [lhs: string, rhs: string] = line->matchlist('^i\s\+\(\S\+\)\s\+\*\s\+\(.*\)')[1 : 2]
        ABBREVS->add([lhs, rhs, rhs->strcharlen()])
    endfor
}

const ABBREVS_LENGTHS: list<number> = ABBREVS
    ->copy()
    ->map((_, abbrev: list<any>): number => abbrev[2])
    ->sort('n')
    ->uniq()
    # Need to reverse the sorting in case we have two abbreviations which end in the same way.{{{
    #
    # For example, suppose we have these abbreviations:
    #
    #     inoreabbrev bec   because
    #     inoreabbrev Tbec  That's because
    #
    # Now, suppose we type "That's because".
    #
    # We want this reminder:
    #
    #     ✔
    #     Tbec => That's because
    #
    # Not this one:
    #
    #     ✘
    #     bec => because
    #}}}
    ->reverse()

# `:help abbreviations`
const ABBREV_PATTERN: string = '\%('
    # full-id
    .. '\k\+'
    # end-id
    .. '\|' .. '[^[:keyword:]]\+\k'
    # non-id
    .. '\|' .. '\k\+[^[:keyword:]]'
    .. '\)'
# }}}1
# Functions {{{1
# Interface {{{2
export def Space(): string #{{{3
    # Remind us whenever we forget to use an abbreviation.

    # Abbreviations should not kick in when we write code.
    # Only in comments/prose.
    if ['', 'markdown', 'text']->index(&filetype) == -1
            && !InComment()
        return ' '
    endif

    # Don't give a  reminder if the inserted text was  not typed manually, but
    # selected from a completion menu.
    if pumvisible()
        return ' '
    endif

    var curpos: number = getcurpos()[2]
    var line: string = getline('.')

    # We  iterate  over the  lengths  of  the  abbreviations rather  than  the
    # abbreviations themselves, because it seems more efficient.
    # For  example,  you  might  have  100 abbreviations,  but  with  only  10
    # different lengths.  There  is no reason to compute  `suspect` 100 times;
    # 10 times is enough.
    for length: number in ABBREVS_LENGTHS
        # For a  given length, compute where  the abbrev should start  for the
        # cursor to be where it is currently.  We don't know yet whether there
        # exists  an abbreviation  for the  text  between this  start and  the
        # cursor.  For now, let's call this text a "suspect".
        var start: number = curpos - length - 1
        if start < 0
            continue
        endif

        # Make sure the suspect  is not in the middle of a  word; that is, the
        # character before should be whitespace or punctuation.
        var char_before: string = start - 1 >= 0 ? line[start - 1] : ''
        if char_before !~ '^[[:space:][:punct:]]\=$'
            continue
        endif

        # Now, let's check whether that suspect is a culprit.
        var suspect: string = line[start : curpos - 2]
        var i: number = ABBREVS
            ->indexof((_, abbrev: list<any>): bool => abbrev[1] == suspect)
        if i >= 0
            var lhs: string = ABBREVS[i][0]
            var rhs: string = ABBREVS[i][1]
            # Don't give a reminder for an abbreviation which fixes a typo.
            if rhs->strcharlen() - lhs->strcharlen() <= 1
                return ' '
            endif
            var msg: string = $'{lhs} => {rhs}'
            popup_notification([msg], {
                line: 1,
                col: &columns - msg->strcharlen() - 1,
            })
            return ' '
        endif
    endfor

    # Our mapping breaks automatic expansions of abbreviations.
    # To fix this, we need to expand them manually.
    var previous_word: string = line->matchstr($'{ABBREV_PATTERN}\%.c')
    var i: number = ABBREVS
        ->indexof((_, abbrev: list<any>): bool => abbrev[0] == previous_word)
    if i >= 0
        return "\<C-]> "
    endif

    return ' '
enddef

export def ForceExpansion(): string #{{{3
    var line: string = getline('.')
    var match: list<any> = line
        ->matchstrpos($'{ABBREV_PATTERN}\ze\s*\%.c')
    var previous_word: string = match[0]
    var previous_word_pos: list<number> = match[1 : 2]

    var i: number = ABBREVS
        ->indexof((_, abbrev: list<any>): bool => abbrev[0] == previous_word)
    if i == - 1
        return "\<C-]>"
    endif

    var abbrev: string = ABBREVS[i][0]
    var expanded: string = ABBREVS[i][1]
    var new_line: string = line
        ->substitute($'\%{previous_word_pos[0] + 1}c.*\%{previous_word_pos[1]}c.', expanded, '')
    var col_from_end: number = col('$') - col('.')
    timer_start(0, (_) => {
        new_line->setline('.')
        setpos('.', [0, line('.'), col('$') - col_from_end, 0])
    })

    return ''
enddef

export def SuppressUnexpectedExpansion() #{{{3
# Problem1: an abbreviation might sometimes be unexpectedly expanded at the end of a word.{{{
#
#     set backspace=start
#     inoreabbrev ab cd
#     'yyyy'->setline(1)
#     normal! 3|
#     feedkeys("i\<C-U>xxab ", 't')
#
# The buffer contains the line:
#
#     xxcd yy
#
# Notice how `ab`  has been expanded into  `cd`, even though `ab` was  part of a
# bigger word `xxab`.
#
# Not sure what's the rationale behind this behavior but it's documented at
# `:help abbreviations /rule`:
#
#    > full-id   In front of the match is a non-keyword character, **or this is where**
#    >           **the line or insertion starts.**
#
# In any case, we never want this,and when that happens we have to roll back the
# expansion which is distracting.  Let's try to disable it.
#}}}
# Problem2: also when we type some punctuation character.{{{
#
# For example, if we type `${arg}` in a bash script, we don't want "arg" to be
# expanded into "argument" as soon as we press `}`.
#}}}
# Solution:  suppress  an unexpected  expansion  by  preceding the  triggering
# non-keyword (typically a space) with `<C-V>`.

    # If we  press `<C-]>` to  manually expand an abbreviation,  `<C-V>` would
    # cause a literal `^]` to be inserted which is confusing.
    if v:char == "\<C-]>"
            || v:char !~ '[[:punct:]]'
        return
    endif

    # Do *not* pass the `i` flag to `feedkeys()`!{{{
    #
    # If you do, the keys returned by an insert mode mapping whose RHS evaluates
    # an expression would be reversed:
    #
    #     autocmd InsertCharPre * feedkeys("\<C-V>" .. v:char, 'i') | v:char = ''
    #     inoremap X <C-R>='abc'<CR>
    #     feedkeys('iX')
    #
    #     # actual buffer:   cba
    #     # expected buffer: abc
    #
    # ---
    #
    # This issue should be avoided thanks to the previous `state()` guard, but still...
    #}}}
    feedkeys("\<C-V>" .. v:char)
    v:char = ''
enddef
# }}}2
# Util {{{2
def InComment(): bool #{{{3
    var cml: string = &commentstring->split('%s')->get(0, '')
    if &filetype == 'navi'
        cml = '[;#]'
    endif

    return cml != '' && getline('.') =~ '^\s*' .. cml
    # Better alternative:{{{
    #
    #     return synstack('.', col('.') - 1)
    #         ->indexof((_, id: number): bool => id->synIDattr('name') =~ '\ccomment') >= 0
    #
    # But slower.
    #}}}
enddef
