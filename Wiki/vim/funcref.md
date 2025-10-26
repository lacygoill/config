# What's the signature of `function()`?

    function({name} [, {arglist}] [, {dict}])

---

Note that it's *not*:

    function({name} [, {arglist} [, {dict}]])

IOW, `function()` is an **overloaded** function which has a different semantics,
depending on the *types* of its arguments.

When the  second argument is  a list, the  function is automatically  passed the
latter as arguments; but when it's a dictionary, the function is bound to it.

So, if you need to bind a function to a dictionary, you don't need to do:

    let Fn = function('Func', [], dict)
                              ^^
You can simply do:

    let Fn = function('Func', dict)

---

`function()` is not the first example of overloaded function.
Any function which  accepts optional arguments is, by  definition, an overloaded
function;  so `mapcheck()`  which accepts  two optional  arguments is  *also* an
overloaded function.
However, so  far, we  only saw  functions whose  semantics changed  according to
their arity; `function()` is the first  one whose semantics changes according to
the type of its arguments.

   > The functions must differ either by the arity or types of their parameters

Source: [Function overloading][1]

# What's the limitation imposed to `funcref()`, but not to `function()`?

`funcref()`  can  not  be  passed  the  name  of  a  builtin  function;  only  a
user-defined function:

    :echo funcref('strlen')
    E700: Unknown function: strlen˜

##
# Which condition must a variable name satisfy to store a funcref?

It must begin with an uppercase character, if it's global:

          ✘
          v
    let g:length = function(exists('*strcharlen') ? 'strcharlen' : 'strlen')
    echo g:length('hello')
    E704: Funcref variable name must start with a capital: g:length˜

          ✔
          v
    let g:Length = function(exists('*strcharlen') ? 'strcharlen' : 'strlen')
    echo g:Length('hello')
    5˜

or if it's local to a function:

    unlet! g:Length
    fu Length(string) abort
        "     ✘
        "     v
        let l:length = function(exists('*strcharlen') ? 'strcharlen' : 'strlen')
        return l:length(a:string)
    endfu
    echo Length('hello')
    E704: Funcref variable name must start with a capital: l:length˜

    unlet! g:Length
    fu Length(string) abort
        "     ✔
        "     v
        let l:Length = function(exists('*strcharlen') ? 'strcharlen' : 'strlen')
        return l:Length(a:string)
    endfu
    echo Length('hello')
    5˜

---

There's no such requirement if the variable is local to sth else than a function:

    let t:length = function(exists('*strcharlen') ? 'strcharlen' : 'strlen')
    echo t:length('hello')
    5˜

## Why?

In the global scope, you can drop the `g:`.
In the scope of a function, you can drop the `l:`.

So, if  a variable  storing a  funcref could start  with a  lowercase character,
there could be a conflict with a builtin function.

##
# I save a funcref in a global variable, then define a function whose name is identical to the variable:

    let g:Length = function('toupper')
    fu Length(string) abort
        let l:Length = function(exists('*strcharlen') ? 'strcharlen' : 'strlen')
        return l:Length(a:string)
    endfu

## What will be the output of `Length('hello')`?

The first definition (funcref) seems to win:

    echo Length('hello')
    HELLO˜

---

But the definition of the function is weird:

    fu Length
                v-------------v
       function toupper(string) abort˜
    1          let l:Length = function(exists('*strcharlen') ? 'strcharlen' : 'strlen')˜
    2          return l:Length(a:string)˜
       endfunction˜

## What would happen if I reversed the order of the funcref definition and the function definition?

It would raise `E705`.

    unlet! g:Length
    fu Length(string) abort
        let l:Length = function(exists('*strcharlen') ? 'strcharlen' : 'strlen')
        return l:Length(a:string)
    endfu
    let g:Length = function('toupper')
    E705: Variable name conflicts with existing function: g:Length˜

It seems that `:let` is careful about avoiding conflicts, but not `:fu`.

##
# When calling a function, with what can I replace its name?

Any expression whose value is a funcref.

    fu Func(i,j)
        return a:i + a:j
    endfu
    let list = [function('Func')]
    echo list[0](1, 2)
    3˜

Here, `list[0]` is an expression whose value is a funcref of `Func()`.
So, when calling `Func()`, we can replace the name `Func` with `list[0]`

##
# What does it mean for a function to be bound to a dictionary?

When calling  the function, the dictionary  will be automatically passed  to the
function; the  latter will be  able to access  the dictionary through  the local
variable `self`.

## How to do it
### without modifying the dictionary?

Pass the dictionary as an argument to `function()`.
The resulting funcref binds the function to the dictionary.

    let adict = {'name': 'toto'}
    fu Func() dict
        return 'my name is: ' .. self['name']
    endfu
    let Fn = function('Func', adict)
                              ^---^

    " the dictionary was not modified
    echo adict
    {'name': 'toto'}˜

    " `Func()` is able to access the dictionary
    echo Fn()
    my name is: toto˜

### modifying the dictionary, and giving a proper name to the function?

   1. define the function with the `dict` attribute

   2. store a funcref referring to the function inside the dictionary

Example:

    fu s:size() dict
        return len(self.data)
    endfu
    let adict = {'data': [0, 1, 2], 'size': function('s:size')}
    echo adict.size()
    3˜

---

There's nothing special in the syntax `adict.size()`.
`adict.size` is an expression whose value is a funcref.
So, it  can be used to  call the function referred  to by the funcref,  like any
other expression.

### modifying the dictionary, and without giving a proper name to the function?

Follow this scheme for the name of the function:

    dictionary.key

Example:

    let adict = {'data': [0, 1, 2]}
    fu adict.size()
        return len(self.data)
    endfu
    echo adict.size()
    3˜

This time, you didn't have to:

   - include a funcref in the dictionary

   - give a proper name to the function

   - give it the `dict` attribute

`dictionary.key()` is syntaxic sugar.

##
## What does the `dict` attribute allow a function to do?

If the function is bound to a dictionary, it can access the latter via the local
variable `self`; it couldn't without.

### What does it prevent to do?

You can't call a function defined with `dict` directly:

    fu Func() dict
        return 1
    endfu
    echo Func()
    E725: Calling dict function without Dictionary: Func˜

### Is it always necessary?

Only if the function has a proper name (!= number).

##
## What does Vim do automatically when you name a function `adict.size`?

It  adds the  key `size`  to `adict`,  and give  it a  funcref referring  to the
currently defined function, as a value.

    let adict = {'data': [0, 1, 2]}
    fu adict.size()
        return len(self.data)
    endfu
    echo adict.size

     ┌ `adict.size` is a funcref˜
     │        ┌ its name is `13`˜
     │        │    ┌ it's bound to this dictionary˜
     │        ├┐   ├─────────────────────────────────────────┐˜
    function('13', {'data': [0, 1, 2], 'size': function('13')})˜
                                       ├────────────────────┘˜
                                       └ a funcref has been added to the dictionary˜
                                         to implement the binding˜

---

If `adict` already contains a `size` key, the definition of the function fails:

    let adict = {'data': [0, 1, 2], 'size': 0}
    fu adict.size()
        return len(self.data)
    endfu
    E718: Funcref required˜

### What kind of special function is it?

A numbered or anonymous function.

### Why is it called like that?

Because technically, Vim gives it a simple number as a name.

### What should I pass to `:function` to print its definition?

    :fu {123}
         │
         └ numbered name of the function

### Why should I avoid defining such a function?

Debugging it is hard.

If it raises an error, `:WTF` can't show you its location.

Besides, it's automatically  removed as soon as there's no  funcref which refers
to it anymore.
So, if  you think you can  infer where the location  of the function is  in your
codebase, by looking at its definition, you may not even be able to do that:

    let adict = {'data': [0, 1, 2]}
    fu adict.size()
        return len(self.data)
    endfu
    echo adict.size
    function('13', {'data': [0, 1, 2], 'size': function('13')})˜
              ^^

    fu {13}
       function 13() dict˜
    1          return len(self.data)˜
       endfunction˜

    unlet adict
    fu {13}
    E123: Undefined function: 13˜

For more info, see: <https://github.com/LucHermitte/lh-vim-lib/blob/master/doc/OO.md>

#### ?

Document that you can't write `string(dict)->eval()` if `dict` contains a numbered
function.

Visit `~/.vim/pack/mine/opt/quickhl/autoload/quickhl.vim` and  look for `a:func`
to see why this can be an issue.

Also, document that you can *read* `function('123')` in some command output, but
you can't *write* it in an executed command:

    let a = function('123')
    E129: Function name required˜
    E475: Invalid argument: 123˜

##
# Expression lambda / closure

Document that  when you define  a lambda which refers  to some variables  in the
RHS, absent  from the  LHS, they should  all be assigned  before the  lambda (at
least one).

MRE:

    fu Func()
        let l:Test = { -> foo + bar == 3 }
        let foo  = 1
        let bar  = 2
        return l:Test()
    endfu
    echo Func()
    E121˜

    fu Func()
        let foo  = 1
        let l:Test = { -> foo + bar == 3 }
        let bar  = 2
        return l:Test()
    endfu
    echo Func()
    1˜

Explanation: <https://github.com/vim/vim/issues/2643#issuecomment-366954582>

---

The name of a variable storing a  lambda or funcref must begin with an uppercase
character, because  you could  drop the  `l:`, in  which case  there could  be a
conflict with a builtin function (e.g. you've used the variable name `len`).
The name **must** start with an uppercase character.

But now that your variable starts with  an uppercase character, there could be a
conflict with a global custom function.
So, the name **should** be scoped with `l:` to avoid E705.
From `:help E705`:

   > You cannot have both a Funcref variable and a function with the same name.

Indeed, without `l:`, if you run this inside a function:

    let Lambda = {-> 123}
    echo Lambda()

and you have  a global custom function  named `Lambda`, Vim will  not know which
definition to use.

Review this section, and add `l:` whenever it makes sense.

Note that the  reason why we use  the word "should" regarding the  `l:` scope is
because `E705` is only  raised if an existing custom function  has the same name
as the variable.
In  contrast,  an error  is  *always*  raised if  your  variable  starts with  a
lowercase character.

---

    {args -> expr}

Il  s'agit d'une  expression lambda,  qui crée  une nouvelle  fonction numérotée
retournant l'évaluation d'une expression.
Elle diffère d'une fonction régulière de 2 façons:

   - Le corps de l'expression lambda est une expression et non une séquence de
     commandes Ex.

   - Les arguments ne sont pas dans le scope `a:`.

---

    let F = {arg1, arg2 -> arg1 + arg2}
    echo F(1,2)
    3˜

---

    fu A()
        return 'i am A'
    endfu
    fu B()
        let A = {-> 42}
        return A()
    endfu
    echo B()
    E705: Variable name conflicts with existing function: A˜

    fu A()
        return 'i am A'
    endfu
    fu B()
        let l:A = { -> 42 }
        return l:A()
    endfu
    echo B()
    42˜

Qd  on  se trouve  à  l'intérieur  d'une fonction,  et  qu'on  doit stocker  une
expression  lambda, ou  une funcref,  dans une  variable, il  faut toujours  lui
donner le scope `l:`.
En effet, le nom doit commencer par  une majuscule, ce qui pourrait provoquer un
conflit entre avec une fonction publique de même nom.

---

    let F = { -> 'hello' .. 42 }
    echo F()
    hello42˜

Une expression lambda peut ne pas avoir d'arguments.

---

    <lambda>123

Le nom de la fonction numérotée créée par une expression lambda suit ce schéma.
En cas d'erreur au sein de cette dernière, on pourra donc exécuter:

    fu <lambda>123

... pour lire son code:

    :let F = {-> 'hello' .. [42]}
    :echo F()
    Error detected while processing function <lambda>123:˜
    line    1:˜
    E730: using List as a String˜

    :fu <lambda>123
        function <lambda>123(...)˜
     1  return 'hello' .. [42]˜
        endfunction˜

---

    echo map([1, 2, 3], {_, v -> v + 1})
    [2, 3, 4]˜

    echo sort([3,7,2,1,4], {a,b -> a - b})
    [1, 2, 3, 4, 7]˜

On peut,  entre autres,  utiliser des  expressions lambda  comme 2e  argument de
`filter()`, `map()` et `sort()`.

---

    let timer = timer_start(500, {-> execute("echo 'Handler called'", '')}, {'repeat': 3})
    Handler called˜
    Handler called˜
    Handler called˜

Les expressions lambda sont aussi utiles pour des timers, canaux, jobs.

---

Si un timer est  exécuté au moment où on se trouve sur  la ligne de commande, le
curseur peut temporairement quitter cette dernière et s'afficher dans le buffer.

    nno cd <cmd>call Func()<cr>
    fu Func()
        let my_timer = timer_start(2000, {-> execute('sleep 1', '')})
    endfu

Taper `cd`, puis écrire qch sur la ligne de commande et attendre.

---

    ✘
    call timer_start(0, {-> execute('call FuncA() | call FuncB()')})
    ✔
    call timer_start(0, {-> [FuncA(), FuncB()]})

    ✘
    call timer_start(0, {-> execute('if expr | call Func() | endif')})
    ✔
    call timer_start(0, {-> expr && Func()->type()})
                                            ^--^
                                    not necessary if the output of `Func()` is:
                                        - a boolean
                                        - a number
                                        - a string

    ✘
    call timer_start(0, {-> execute('if expr | call FuncA() | endif | call FuncB()})
    ✔
    call timer_start(0, {-> [expr && FuncA()->type(), FuncB()]})

On  n'a  pratiquement  jamais  besoin d'utiliser  `execute()`  et  `:call`  pour
exécuter une fonction via un lambda.

`:call` est nécessaire sur la ligne de  commande car Vim s'attend à exécuter une
commande.
`:call` n'est pas toujours nécessaire dans un lambda, car Vim s'attend à évaluer
une expression, et une fonction EST un type d'expression.

---

Qd  on exécute  une fonction  via  un lambda,  sa  valeur de  sortie n'a  aucune
importance.

---

N'utilise `||` et `&&` comme connecteur  logique que lorsque c'est nécessaire et
qu'ils correspondent réellement à ce que tu veux faire.
Autrement, préfère un opérateur plus simple tq `+`:

                           exécute 2 fonctions
    ┌────────────────────┬─────────────────────────────────────────┐
    │ FuncA() && FuncB() │ à condition que la 1e ait réussi        │
    ├────────────────────┼─────────────────────────────────────────┤
    │ FuncA() || FuncB() │ à condition que la 1e ait échoué        │
    ├────────────────────┼─────────────────────────────────────────┤
    │ FuncA() + FuncB()  │ peu importe que la 1e ait réussi ou non │
    └────────────────────┴─────────────────────────────────────────┘

---

        expr && FuncA() + FuncB()
    ⇔
        exécute `FuncA` ET `FuncB` à condition que `expr` soit vraie


        (expr && FuncA()) + FuncB()
    ⇔
        exécute `FuncA` à condition que `expr` soit vraie, PUIS `FuncB`


Cette différence découle du fait que l'opérateur `+` a priorité sur `&&`.

Confirmation via:

    echo 0 && 1 + 1
    0˜

    echo (0 && 1) + 1
    1˜

---

    echo range(65, 90)->map({x -> nr2char(x)})
    [ 'A', 'B', ... ]          attendu˜
    [ '', '^A', '^B', ... ]    obtenu˜

Pk n'obtient-on pas la liste des lettres majuscules ?
Car  qd  le 2e  argument  de  `map()` est  une  funcref,  `map()` lui  envoit  2
arguments:

   1. l'index (pour une liste) ou la clé (pour un dico) de l'item courant
   2. la valeur de l'item courant

`map()` utilise ensuite la fonction associée  à la funcref pour remplacer chaque
item de la liste.

Donc, dans l'exemple précédent, pour remplacer les nbs 65 à 90, `map()` envoit à
`nr2char()` les valeurs suivantes:

   - nr2char(0, 65)
   - nr2char(1, 66)
     ...
   - nr2char(25, 90)

Or, pour `nr2char()`, le 2e argument est un simple flag:

   - 0 signifie qu'on veut utiliser l'encodage courant

   - 1 l'encodage utf-8

`65` ... `90` sont interprétés comme un `1`.

De plus, `nr2char()` ne reçoit pas les bons codepoints:

    65 ... 90  ✔ ce qu'ell devrait recevoir
    0  ... 25  ✘ ce qu'elle reçoit

Solution:

    range(65, 90)->map({_, v -> nr2char(v)})
                        ^^

Conclusion:

Pour pouvoir se  référer à un argument  reçu par une expression  lambda, il faut
correctement tous les déclarer.
Donc,  qd une  fonction  accepte  une expression  lambda  en argument,  toujours
regarder quels arguments elle envoit à cette dernière.
Ici, `map()` n'en envoit pas 1 (`x`), mais 2 (`_`, `v`).


    fu Foo(arg)
        let i = 3
        return {x -> x + i - a:arg}
    endfu
    let Bar = Foo(4)
    echo Bar(6)
    5˜

L'expression lambda utilise dans son calcul les variables `i` et `a:arg`.

`i` appartient  à la portée  locale à `Foo()`,  tandis que `a:arg`  appartient à
celle des arguments de `Foo()`.
L'expression lambda ne se plaint pas que les variables ne sont pas définies :

    E121: Undefined variable: i˜
    E121: Undefined variable: a:arg˜

... car elle  a la particularité de  pouvoir accéder aux variables  de la portée
extérieur; on parle de “closure“ (clôture).


    fu Foo()
        let x = 0
        fu! Bar() closure
            let x += 1 " pas d'erreur, grâce à `closure`
            return x
        endfu
        return funcref('Bar')
    endfu

    let F = Foo()
    echo F()
    1˜
    echo F()
    2˜
    echo F()
    3˜

L'incrémentation  de `x` au sein de `Bar()` ne soulève pas d'erreur:

    E121: Undefined variable: x˜

...  car  `Bar()`  porte  l'attribut  `closure` qui  lui  permet  d'accéder  aux
variables de la portée extérieure (`Foo()`).

La sortie de `F()` est incrémentée à chaque appel.
Ceci prouve  qu'une fonction  portant l'attribut `closure`  peut continuer  à se
référer à la portée d'une fonction  extérieur même après qu'elle ait terminé son
exécution.

##
# ?

Document that expression strings are faster than lambdas.

Test lambdas:

    $ for i in {1..10}; do vim -es -i NONE -Nu <(tee <<'EOF'
      let time = reltime()
      call range(999999)->map({_, v-> v+1})
      pu=reltime(time)->reltimestr()->matchstr('\v.*\..{,3}') .. ' seconds to run the command'
      %p
      qa!
    EOF
    ) ; done

Results in seconds:

    lambdas before 8.2.499:

        4.236
        4.270
        4.204
        4.409
        4.316
        4.356
        4.448
        4.369
        4.250
        4.248
        -----
        avg: 4.311

    lambdas after 8.2.499:

        1.032
        1.004
        1.125
        1.179
        1.120
        1.066
        1.030
        1.045
        1.147
        1.194
        -----
        avg: 1.094

---

Test expression strings:

    $ for i in {1..10}; do vim -es -i NONE -Nu <(tee <<'EOF'
      let time = reltime()
      call range(999999)->map('v:val+1')
      pu=reltime(time)->reltimestr()->matchstr('\v.*\..{,3}') .. ' seconds to run the command'
      %p
      qa!
    EOF
    ) ; done

Results:

    0.569
    0.549
    0.573
    0.564
    0.574
    0.576
    0.584
    0.576
    0.559
    0.577
    -----
    avg: 0.57

---

Edit: In a `:def` function, the opposite is true.

# ?

Document that you can use `get()` to get some "properties" of a funcref.
See `:help get() /func`:

   > get({func}, {what})
   >                 Get an item with from Funcref {func}.  Possible values for
   >                 {what} are:
   >                         "name"      The function name
   >                         "func"      The function
   >                         "dict"      The dictionary
   >                         "args"      The list with arguments

Found it used here: <https://vi.stackexchange.com/a/24654/17449>
Although, it doesn't seem to be really needed in the answer (nor `call()`, nor `string()`):

    fu InstallMapping(funcref) abort
        exe printf('nno <buffer><nowait> cd <cmd>call %s()<cr>', a:funcref)
    endfu
    fu Func() abort
        echom 'called from Func()'
    endfu
    call function('Func')->InstallMapping()
    " press cd

# ?

Document that you don't need to assign a lambda to a variable in order to echo its output:

    :echo {-> 'test'}()
    test˜

But you do need to assign it in order to call it:

    :call {-> 'test'}()
    E15: Invalid expression: > 'test'˜
    E475: Invalid argument: {-> 'test'}()˜

---

Document that if you refer to a lambda directly, and not via a variable, then it
can't access its outer scope:

    fu Func()
        let msg = 'test'
        let s:lambda = {-> msg}
        au SafeState * ++once echo s:lambda()
    endfu
    call Func()
    test˜

    fu Func()
        let msg = 'test'
        au SafeState * ++once echo {-> msg}()
    endfu
    call Func()
    Error detected while processing function <lambda>1234:˜
    line    1:˜
    E121: Undefined variable: msg˜

It seems the issue is specific to an autocmd.
Without an autocmd, the code works as expected:

    fu Func()
        let msg = 'test'
        echo {-> msg}()
    endfu
    call Func()
    test˜

I think that when  you refer to a lambda directly, it's as  if it was defined on
the spot.
So, if you refer  to a lambda directly in an autocmd, it's  as if it was defined
in the autocmd, and the latter has no outer scope.
Therefore, the lambda can't access the function variables.

OTOH, if you refer to a lambda directly in a function, it's as if it was defined
in the function; so the lambda's outer scope is the function, which it can access.

---

Document this: <https://github.com/vim/vim/issues/5373#issuecomment-567502480>

# ?

    fu Func() dict
        return 'called from '.self['which dict am I']
    endfu
    let adict = {'which dict am I': 'adict'}


    let adict.myFunc = function('Func')
    echo adict.myFunc()

    let adict.myFunc = function('Func')
    let bdict = {'which dict am I': 'bdict'}
    let bdict.myFunc = adict.myFunc
    echo bdict.myFunc()

    let adict.myFunc = function(function('Func'), adict)
    let bdict = {'which dict am I': 'bdict'}
    let bdict.myFunc = adict.myFunc
    echo bdict.myFunc()

---

Note that binding a function to a Dictionary also happens when the function is a
member of the Dictionary:

    let myDict.myFunction = MyFunction
    call myDict.myFunction()

Here `MyFunction()` will get `myDict` passed as "self".
This happens when the "myFunction" member is accessed.
When assigning  "myFunction" to otherDict  and calling it,  it will be  bound to
otherDict:

    let otherDict.myFunction = myDict.myFunction
    call otherDict.myFunction()

Now "self" will be "otherDict".
But when the dictionary was bound explicitly:

    let myDict.myFunction = function(MyFunction, myDict)

it won't happen:

    let otherDict.myFunction = myDict.myFunction
    call otherDict.myFunction()

Here "self" will be "myDict", because it was bound explicitly.

# ?

    let adict = {'data': [0, 1, 2]}
    fu adict.size()
        return len(self.data)
    endfu
    let bdict = {'data': [0, 1], 'size': function(adict.size)}
    echo bdict.size()
    2˜

On  peut se  référer à  la fonction  `adict.size()` (qui  techniquement est  une
fonction numérotée) via une funcref, comme pour n'importe quelle fonction.
Elle n'a pas de statut à part.

Pk `2` et pas `3` comme tout à l'heure?

        echo bdict.size()
      ⇔ echo adict.size()
      ⇔ echo len(self.data)
                 │
                 └ sauf que cette fois `self` ne contient pas `adict` mais `bdict`
                                                               │            │
                                                               │            └ taille 2
                                                               └ taille 3

Ça peut  paraître étrange  puisque c'est  `adict`, et non  pas `bdict`,  qui est
associé à `adict.len()`.

Theory:

`bdict.size()` est une fonction dictionnaire, comme `adict.size()`.
`bdict` lui est donc associé; qd elle  est invoquée Vim lui passe via `bdict` la
variable `self`.

Le  code final  est celui  de `adict.size()`,  mais le  dictionnaire qui  lui est
associé est `bdict`; Vim ne le remplace pas plus tard par `adict`.

Remark:

Comme pour  toute fonction dictionnaire,  Vim ajoute  une funcref se  référant à
elle dans le dico:

    echo bdict
    {˜
                                        ┌ fonction “7”˜
                                        │˜
      'data': [0, 1], 'size': function('7',˜
      \                                {'data': [0, 1, 2], 'size': function('7')})˜
                                        ├────────────────────────────────────────┘˜
                                        └ associée à ce dictionnaire˜
    }˜

On remarque que `function()` accepte un dictionnaire comme argument optionnel.
Qd elle en reçoit un, elle l'associe à la fonction.

# ?

    fu Hello()
        echo 'hello'
    endfu

    fu World()
        echo 'world'
    endfu

    let Fn = function('Hello')
    call Fn()
    hello˜

    let Fn = function('World')
    call Fn()
    world˜

On peut  invoquer une  fonction en remplaçant  son nom par  une funcref,  ou une
expression dont l'évaluation est une funcref.
Ici,  on  remplace  le  nom  de  fonction  `Func`  par  la  variable  `Fn`  dont
l'évaluation est une funcref:

    call Func()  →  call Fn()

---

    fu Func(i,j)
        return a:i + a:j
    endfu
    let Fn = function('Func')
    let list = [3, 4]
    echo call(Fn, list)
    7˜

`call()` permet de passer une liste d'arguments à une funcref.
Équivaut à :

    echo Fn(3, 4)

Toutefois, cette 2e  syntaxe n'est utilisable que si on  déballe les éléments de
la liste, pas si on les laisse dedans:

    echo call(Fn, list)
    ✔
    echo Fn(list)
    ✘ E119: Not enough arguments for function: Func˜

---

On peut  aussi utiliser `call()`  pour passer une  liste d'arguments
directement à une fonction:

    fu Func(...)
        let sum = 0
        for i in a:000
            let sum += i
        endfor
        return sum
    endfu

    echo call('Func', [1, 2])
    3˜
    echo call('Func', [1, 2, 3])
    6˜

Utile pour  passer à une fonction  un ensemble d'arguments dont  la taille n'est
pas connue à l'avance.

---

    fu Func()                   ┊ "
        return 'foo'            ┊ "
    endfu                       ┊ "
                                ┊
    let Fn = function('Func')   ┊   let Fn = funcref('Func')
                                ┊
    fu Func()                   ┊ "
        return 'bar'            ┊ "
    endfu                       ┊ "
                                ┊
    echo Fn()                   ┊ "
                                ┊
    bar                         ┊ foo˜


Si on crée une funcref, et qu'on  change la définition de la fonction à laquelle
elle se réfère, la funcref se réfère désormais:

   - à la nouvelle définition, si elle a été créée par `function()`

   - à la définition originelle, si elle a été créée par `funcref()`

IOW, la funcref produite par:

   - `function('Func')` cherche `Func` via son nom (la
     définition associée peut changer)

   - `funcref('Func')`  cherche `Func` via sa référence (i.e.
     adresse mémoire)

---

    :echo function('system')->type() == v:t_string
    0˜

Confirme que  la sortie  de `function()`  qui s'affiche à  l'écran est  bien une
référence et non une chaîne.
Une funcref est un type de donnée à part entière.

Pour  obtenir le  nom  d'une funcref  sous  forme de  chaîne,  il faut  utiliser
`string()`:

    string(Fn)

---

    fu Func()
        return 42
    endfu
    let Func = function('Func')
    E705: Variable name conflicts with existing function: Func˜

On  ne peut  pas ré-utiliser  le  nom d'une  fonction pour  nommer une  variable
contenant une funcref se référant à elle.

---

En revanche, on  peut ré-utiliser le nom  d'une fonction pour nommer  une clé de
dico dont la valeur est une funcref se référant à elle:

    fu Func()
        return 42
    endfu
    let mydict = {'data': [0, 1], 'Func': function('Func')}
    echo mydict.Func()
    42˜

# ?

    fu Describe(i, j, object)
        echo (a:i + a:j).' '.a:object
    endfu
    let Description = function('Describe', [1, 2])
    call Description('piggies')
    3 piggies˜

`function()` peut lier une liste d'arguments à une fonction.
On dit que le résultat est un “partiel“.

Sans partiel, les 2 dernières lignes du code se ré-écriraient comme ceci:

    let Description = function('Describe')
    call Describe(1, 2, 'piggies')

---

Un partiel est une funcref particulière:

    echo type(Description) == v:t_func
    1˜

---

Vim passe les arguments inclus dans  la définition d'un partiel avant ceux qu'on
peut passer au moment de l'invocation:

    1 et 2  avant  'piggies'

---

D'où vient le terme “partiel“ ?

En informatique, une  application de fonction partielle décrit  le processus qui
consiste à  fixer un sous-ensemble des  arguments d'une fonction en  les liant à
des valeurs prédéterminées, produisant une autre fonction, d'arité inférieure.

<https://en.wikipedia.org/wiki/Partial_application>

Pour rappel, en mathématiques, l'arité  d'une fonction est le nombre d'arguments
qu'elle requiert.

Exemple:

    f:           x,y  →  x/y
    partial(f):    y  →  1/y

En fixant/liant le 1er argument de la fonction  `f` à la valeur 1, on obtient la
fonction inverse.

Il est possible que  le terme fut choisi car une  fonction partielle est obtenue
en ne fournissant à une autre fonction qu'une partie de ses arguments.

---

    fu Describe() dict
        echo 'here are some ' .. self.name
    endfu
    let object = {'name': 'fruits'}
    let Description = function('Describe', object)
    call Description()
    here are some fruits˜

`function()` peut aussi lier un dico à une fonction.
Ici, on lie le dico `object` à la fonction `Describe()`.
Le résultat est stocké dans le partiel `Description`.

Pour que la fonction puisse y accéder, elle doit porter l'attribut `dict`.
Elle peut alors se référer au dico via sa variable locale `self`.

---

    fu Describe(count, adj) dict
        echo a:count .. ' ' .. a:adj .. ' ' .. self.name
    endfu
    let object = {'name': 'piggies'}
    let Description = function('Describe', [3], object)
    call Description('little')
    3 little piggies˜

Illustre qu'on peut  lier à une fonction  à la fois une liste  d'arguments et un
dico.

Le dico d'un partiel ne fait pas partie de la liste des arguments.
Il s'agit de 2 ensembles totalement séparés.

San partiel, l'exemple précédent se ré-écrirait de la façon suivante:

    let object = {'name': 'piggies'}
    fu object.Describe(count, adj)
        echo a:count .. ' ' .. a:adj .. ' ' .. self.name
    endfu
    call object.Describe(3, 'little')

---

    fu Describe(i, j, object)
        echo (a:i + a:j) .. ' ' .. a:object
    endfu
    let Desc = function('Describe', [1])
    let NewDesc = function(Desc, [2])
                           │
                           └ partial

    call NewDesc('piggies')
    3 piggies˜

Montre que le nom du 1er argument donné à `function()` n'est pas forcément celui
d'une fonction.
Ce peut  être celui d'une funcref  ou d'un partiel (comme  dans l'affectation de
`NewDesc`).

Montre  aussi  qu'on peut  imbriquer  des  appels  à `function()`  pour  ajouter
progressivement des arguments à un partiel.
Ils sont ajoutés les uns à la suite des autres.

Ici, le 1er appel à `function()` ajoute `1` à la liste des arguments du partiel:

    [] + [1]

Et, le 2e appel lui ajoute `2`:

    [1] + [2]

On pourrait continuer:

    [1,2] + [3]

La dernière commande équivaut à :

    call Describe(1, 2, 'piggies')

---

    fu Func() dict
        echo self.name
    endfu

    let Fn = function('Func')
    let mydict = {'name': 'foo'}
    let mydict.myfunc = Fn

    call mydict.myfunc()
    foo˜

Un partiel n'est pas le seul moyen de lier une fonction à un dico.
On peut aussi le faire en affectant sa funcref à une clé du dico.
Ici, `Func()` reçoit `mydict` via `self` qd on accède à la clé `myfunc`.

---

    fu Func() dict
        echo self.name
    endfu

    let Fn                = function('Func')
    let mydict            = {'name': 'foo'}
    let mydict.myfunc     = Fn
    let other_dict        = {'name': 'bar'}
    let other_dict.myfunc = mydict.myfunc

    call other_dict.myfunc()
    bar˜

Si on duplique la fonction `mydict.myfunc` en `other_dict.myfunc`:

    let other_dict.myfunc = mydict.myfunc

... en ayant au préalable associé à cette dernière clé de dico une funcref:

    let mydict.myfunc = Fn

... la copie est liée au nouveau dico, pas à l'original.
C'est pourquoi  elle reçoit `other_dict` via  `self`, et elle affiche  `bar`, au
lieu de `foo`.

---

    fu Func() dict
        echo self.name
    endfu

    let Fn                = function('Func')
    let mydict            = {'name': 'foo'}
    let mydict.myfunc     = function(Fn, mydict)
    let other_dict        = {'name': 'bar'}
    let other_dict.myfunc = mydict.myfunc

    call other_dict.myfunc()
    foo˜

En revanche, si on la duplique en l'ayant au préalable définie comme un partiel,
qu'on utilise pour EXPLICITEMENT lier la fonction au dico:

    let mydict.myfunc = function(Fn, mydict)

... la copie reste liée à l'ancien dico.

# ?

Read:

   - :h `function()`
   - :h `funcref()`
   - :h `Funcref`
   - :h `Partial`

##
# Reference

[1]: https://en.wikipedia.org/wiki/Function_overloading
