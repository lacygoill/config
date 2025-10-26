# ?

Let's write a shell and Vim script to  test how a given Vim function handles all
possible types of values.

We need to test these functions:

    vim9script

    var IsCustomFunc: func = (v) => v[0] !~ '[a-z]'
    var AcceptArg: func = (v) => v[-1] == '('
    var NoAutoload: func = (v) => v !~ '#'

    new

    getcompletion('*', 'function')
        ->filter((_, v) => !IsCustomFunc(v) && AcceptArg(v) && NoAutoload(v))
        ->setline(1)

Let's start with the first ten ones:

    abs(              done
    acos(             done
    add(              tricky because 2 arguments, not 1 (test each one separately?)
    and(
    append(
    appendbufline(
    argc(
    arglistid(
    argv(
    asin(

---

Source this script to generate snippets for the `abs()` function:

    vim9script

    # Config {{{1

    const TESTDIR: string = '/tmp/test'
    const LOGFILE: string = '/tmp/log'

    const VALUES = [
      123,
      1.23,
      0z1234,
      '''string''',
      true,
      v:none,
      [0],
      {key: 'val'},
      'function(''len'')',
      'job_start('':'')',
      'job_start('':'')->job_getchannel()',
      'test_null_blob()',
      'test_null_channel()',
      'test_null_dict()',
      'test_null_function()',
      'test_null_job()',
      'test_null_list()',
      'test_null_partial()',
      'test_null_string()',
      'test_void()',
    ]

    def GenerateSnippets(funcname: string) #{{{1
        mkdir(TESTDIR .. '/1_script/' .. funcname, 'p')
        mkdir(TESTDIR .. '/2_def/' .. funcname, 'p')

        var fname: string
        var lines: list<string>
        var scriptname: string

        for value in VALUES
            if value->typename() == 'string' && value =~ '^test_'
                scriptname = value->matchstr('test_\zs[^()]\+')

            elseif value->typename() == 'string' && value != '''string'''
                scriptname = value =~ '_getchannel()$'
                    ?     'channel'
                    : value =~ '^job'
                    ?     'job'
                    : value =~ '^function('
                    ?     'function'
                    :     value->typename()

            else
                scriptname = value->typename()
            endif

            def ExpandPercentItems(lines: list<string>): list<string>
              var newlines: list<string>
              for line in lines
                var expand_b = [v:t_blob, v:t_list, v:t_dict]->index(type(value)) >= 0
                  ? value->string()
                  : value
                var expanded: string = line
                  ->substitute('%a', funcname, 'g')
                  ->substitute('%b', expand_b, 'g')
                  ->substitute('%c', LOGFILE, 'g')
                newlines->add(expanded)
              endfor
              return newlines
            enddef

            fname = printf(TESTDIR .. '/1_script/%s/%s.vim', funcname, scriptname)
            lines =<< trim END
                vim9script
                nnoremap ZZ ZQ
                ['---------------', 'at script level', "%a(%b) ="]
                  ->writefile('%c', 'a')
                try
                  [%a(%b)->string()]
                    ->writefile('%c', 'a')
                catch
                  writefile([v:exception], '%c', 'a')
                endtry
            END
            ExpandPercentItems(lines)->writefile(fname)

            fname = printf(TESTDIR .. '/2_def/%s/%s.vim', funcname, scriptname)
            lines =<< trim END
              vim9script
              nnoremap ZZ ZQ
              ['---------------', 'in def function', "%a(%b) ="]
                ->writefile('%c', 'a')
              def Func()
                  [%a(%b)->string()]
                    ->writefile('%c', 'a')
              enddef
              try
                Func()
              catch
                writefile([v:exception], '%c', 'a')
              endtry
            END
            ExpandPercentItems(lines)->writefile(fname)
        endfor
    enddef
    #}}}1

    delete(LOGFILE)
    delete(TESTDIR, 'rf')
    GenerateSnippets('abs')

Run this shell command to test each snippet:

    $ for f in /tmp/test/**/*.vim; do vim -Nu NONE -S "$f"; done

## ?

    $ vim -Nu NONE +'eval test_unknown()->abs()'
    E685: Internal error: tv_get_number(UNKNOWN)

## ?
```vim
vim9script
def Func()
    function('len')->abs()
enddef
defcompile
```
    E1013: Argument 1: type mismatch, expected number but got func(...): any
                                                                   ^^^
                                                                   ???

Why a triple dot?  That can't be this:

   > The common type of function references, if they do not all have the same
   > number of arguments, uses "(...)" to indicate the number of arguments is not
   > specified.  For example: >
   >         def Foo(x: bool)
   >         enddef
   >         def Bar(x: bool, y: bool)
   >         enddef
   >         var funclist = [Foo, Bar]
   >         echo funclist->typename()
   > Results in:
   >         list<func(...)>

That's for a list/dict of funcrefs.  There is no list/dict here.
So, what is this `...`?

Shouldn't it rather be:

    E1013: Argument 1: type mismatch, expected number but got func([unknown]): any
                                                                   ^-------^

Or maybe:

    E1013: Argument 1: type mismatch, expected number but got func(any): any
                                                                   ^^^

---

Similar issue here:
```vim
vim9script
def Func()
    test_null_function()->abs()
enddef
defcompile
```
    E1013: Argument 1: type mismatch, expected number but got func(...): any

Although, here, `...` might make sense.
We don't know anything about the signature of a null function.
Therefore, `[unknown]`  and `any` would be  wrong; because they assume  that the
function expect  1 argument;  we don't  know that; the  function could  expect 0
arguments, or more than 2.

But if we don't know anything about the function, shouldn't Vim simply report `func`?
