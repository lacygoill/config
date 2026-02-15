# What's the output of the next command?

    $ awk '{ print $1 "" + 0 }' <<<'0123'
    ↣ 01230 ↢

## Why?

The addition operator has priority over the concatenation.
And `"" + 0` evaluates to the number `0`.
Finally, the  concatenation operator expects  strings, so it coerces  the number
`0` into the string `"0"`, and concatenates it to `$1`.

##
# What's the output of the next command?

    $ awk '{ print $1 ? "true" : "false" }' <<<'0'
    ↣ false ↢

## Why?

`"0"` is false because it has the strnum attribute, and `awk(1)` first considers
its numeric value, which is `0`.

##
# Regex
## Which syntax (BRE, ERE, ...) can I use in a regex?

Gawk only recognizes a superset of the ERE syntax.

##
# ?

For which operators may a strnum data need a dummy concatenation or `+ 0`?

    # `!` parses '0' as a number
    $ awk '{ print !($0) }' <<<'0'
    1˜

    # if you want `!` to parses '0' as a string, you need a dummy concatenation
    $ awk '{ print !($0 "") }' <<<'0'
    0˜

---

    # contrary to VimL, can't use `printf()` to convert to decimal
    $ awk '{ printf("%d", "0123") }' <<<''
    123˜

    # contrary to VimL, can't use `printf()` to convert to decimal
    $ awk '{ printf("%d", "0x123") }' <<<''
    123˜

    # but you can use `printf()` to convert from decimal
    $ awk '{ printf("%#x", "291") }' <<<''
    0x123˜
    # same thing in python
    $ python -c "print('{:#x}'.format(291))"

    $ awk '{ printf("%#o", "83") }' <<<''
    0123˜
    $ python -c "print('{:#o}'.format(83))"
    0o123˜

# ?

`3` sorts lexicographically after `1`:

    $ awk '{ x = "3.14"; print (x < 12) }' <<<''
    0˜

`CONVFMT` is used whenever a number needs to be coerced into a string:

    $ awk '{ CONVFMT="%.6e"; x = 3.14; print x "" }' <<<''
    3.140000e+00˜

As a result, a comparison with a string may be influenced by `CONVFMT`:

    $ awk '{ x = 3.14; print (x == "3.14") }' <<<''
    1˜

    $ awk '{ CONVFMT = "%.6e"; x = 3.14; print (x == "3.14") }' <<<''
    0˜

# ?

For more info, see page 433 of the gawk user's guide, and:

- <http://gawkextlib.sourceforge.net/>
- <https://sourceforge.net/projects/gawkextlib/files/>

Install gawk shared library:

    $ git clone git://git.code.sf.net/p/gawkextlib/code gawkextlib
    $ cd ~/VCS/gawkextlib/lib
    $ autoreconf -i && ./configure && make && make check

    $ sudo make install

If you try to build a deb package, name it `libgawkextlib`, and use the `README`
for the  summary.  The  version is  given in `configure.ac`  (look for  the line
`AC_INIT`).

---

Build `tre` which is a dependency of the `aregex` library extension:

    $ cd ~/VCS/
    $ git clone https://github.com/laurikari/tre/
    $ cd tre
    $ ./utils/autogen.sh

    $ ./configure && make && make check

If one  of the test fails,  read the logfile;  you probably need to  install the
locale `en_US ISO-8859-1`.
On Ubuntu, run: `$ locale-gen en_US`.
On Debian, edit `/etc/locale.gen` and run `$ sudo locale-gen`.

You don't need to specify `ISO-8859-1`, because that's the default codepage.
<https://unix.stackexchange.com/a/446762/289772>

You  don't run  the  same command  in  Debian, because  Ubuntu  has tweaked  the
`locale-gen` utility.
<https://unix.stackexchange.com/a/38735/289772>

    $ sudo make install

---

Build the `aregex` library extension.

    $ cd ~/VCS/gawkextlib/aregex
    $ autoreconf -i && ./configure && make && make check
    $ sudo make install

For more info, see:

    man 3am aregex

“am” stands for Awk Module.

---

Similarly install other library extensions in `gawkextlib/`.

    # Exit gawk without running END rules
    abort

    # test fails atm
    csv

    # convert errno values to strings and vice versa
    errno

    # need the `libgd-dev` package
    # test fails atm
    gd

    # need the `libhpdf-dev` package
    # there's no documentation, except for `~/VCS/gawkextlib/haru/test/pdftest.awk`
    haru

    json
    lmdb

    # add 4 functions to work with multibyte strings
    mbs

    # test fails atm
    mpfr

    nl_langinfo
    pgsql
    redis

    # enable I/O multiplexing, non-blocking I/O, and signal trapping
    select

    xml

For more info, see:

    man 3am [abort|csv|...]

---

Also, document how to install and use this library:
<https://github.com/e36freak/awk-libs>

I found it in the topic of the #awk  channel on libera.  BTW, have a look at the
other links of the topic; some of them might contain useful information.

# ?

    # STRING STRING: string comparison
    # if 'ab' and 'cd' had been converted into 0, the test would have failed
    #     $ awk '{ print (strtonum("cd") > strtonum("ab")) }' <<<''
    #     0
    $ awk '{ print ("cd" > "ab") }' <<<''
    1˜

    # STRING NUMERIC: string comparison
    # if 'ab' had been converted into 0, the test would have failed;
    # it succeeds because digits come before letters in the lexicographical order
    $ awk '{ print ("ab" > 123) }' <<<''
    1˜

    # STRING STRNUM: string comparison
    # if 'ab' had been converted into 0, the test would have failed
    $ awk '{ print ("ab" > $1) }' <<<'123'
    1˜



    # NUMERIC NUMERIC: numeric comparison
    # if 089 and 89 had been treated as strings, the test would have failed
    $ awk '{ print (089 == 89) }' <<<''
    1˜

    # STRNUM STRNUM: numeric comparison
    # if 089 and 89 had been treated as strings, the test would have failed
    $ awk '{ print ($1 == $2) }' <<<'089 89'
    1˜

    # NUMERIC STRNUM: numeric comparison
    # if 089 and 89 had been treated as strings, the test would have failed
    $ awk '{ print ($1 == 89) }' <<<'089'
    1˜

# ?

What's the output of the next commands:

    $ awk '{ print 0128 }' <<<''
    ↣ 0 ↢

    $ awk '{ print 0x12g }' <<<''
    ↣ 18 ↢

    $ awk '{ var = $1; print typeof(var) }' <<<'0123'

An octal number can't contain digits beyond `7`, and so `0128` is evaluated as `0`.
An hexadecimal number can't contain digits beyond `f`, and so `0128` is evaluated as `0`.

---

    print (031 < 30)
    1˜
    print (310 < 30)
    0˜
    print (0318 < 300)
    0˜

Le 1er test réussit car `031` est interprété comme un nombre octal:

    031₈ < 30₁₀    ✔
    ^
    031₈ = 1 + 3*8 = 25

Le 2e test échoue car `0310` est interprété comme un nombre octal:

    0310₈ < 30₁₀    ✘
    ^
    0310₈ = 0 + 8 + 3*8*8 = 200

Le 3e test échoue car `0318` est interprété comme un nombre décimal.
En effet, même s'il  commence par un zéro, il ne peut  pas être interprété comme
un nombre octal, car il contient le chiffre 8.


Dans  du code  awk, quand  c'est possible  (pas de  chiffres inexistant  en base
8/16), un nombre commençant par:

   - 0           est interprété comme un nombre octal
   - 0x (et 0X?) est interprété comme un nombre hexadécimal

# ?

How to write an octal or hexadecimal constant
in a program text?

Prefix it with `0`, `0x` or `0X`:

    $ awk '{ print 0123 }' <<<''
    83˜

    $ awk '{ print 0x123 }' <<<''
    291˜

in the input data?  (2)

Use `strtonum()` and a dummy concatenation:

    $ awk '{ print strtonum($1 "") }' <<<'0123'
    83˜

---

What's the output of these commands:

    $ awk '{ print 0123 }' <<<''
    ↣ 83 ↢

    $ awk -n '{ print $1 }' <<<'0123'
    ↣ 0123 ↢

Why the difference?

`print` treats its arguments as strings.
Although field  references can  act as  numbers when  necessary, they  are still
strings, so `print` does not try to treat them numerically.

You need to add zero to a field to force it to be treated as a number:

    $ awk -n '{ print $1 + 0 }' <<<'0123'
    83˜

---

Can an octal/hexadecimal number be used in a decimal fraction or in scientific notation?

No, you won't get the expected result:

    $ awk '{ print 012.34 }' <<<''
    12.34˜

    $ awk '{ print 0x12.34 }' <<<''
    18˜

    $ awk '{ print 012.34e-1 }' <<<''
    1.234˜

    $ awk '{ print 0x12.34e-1 }' <<<''
    18˜

IOW, the base of a number is *not* orthogonal to its form.
You can't use a non-decimal base with any form; only with the integer form.

# ?

Coercion

On peut  séparer les  opérateurs en  3 catégories, en  fonction des  types de
données sur lesquels ils peuvent travailler:

   - nombre
   - chaîne
   - chaîne et nombre

Pour chacune de ces catégories, une coercition peut avoir lieue:

    ┌───────────┬────────────────────┬──────────────────┬─────────────────┐
    │ opérateur │  opérande attendu  │ opérande reçu    │   coercition    │
    ├───────────┼────────────────────┼──────────────────┼─────────────────┤
    │   +-*/%^  │      nombre        │      chaîne      │ chaîne → nombre │
    ├───────────┼────────────────────┼──────────────────┼─────────────────┤
    │   concat  │      chaîne        │      nombre      │ nombre → chaîne │
    ├───────────┼────────────────────┼──────────────────┼─────────────────┤
    │    ~ !~   │      chaîne        │      nombre      │ nombre → chaîne │
    ├───────────┼────────────────────┼──────────────────┼─────────────────┤
    │ ==  !=    │      chaîne        │      nombre      │ nombre → chaîne │
    │ < > >= <= │                    │                  │                 │
    ├───────────┼────────────────────┼──────────────────┼─────────────────┤
    │ ==  !=    │      nombre        │      chaîne      │ nombre → chaîne │
    │ < > >= <= │                    │                  │                 │
    └───────────┴────────────────────┴──────────────────┴─────────────────┘

Ex1:

    $ awk '{ print $1 $2, $3 + 123 }' <<<'123 foo bar'
    123foo 123˜

Dans cet exemple, le premier champ est un  nb converti en chaîne, et le 3e champ
est une chaîne convertie en nb.

Ex2:

    # Why using `089` instead of `0123`?
    # To be sure the number is not parsed as octal, and some unexpected
    # conversion alters the test.
    $ awk '{ print $1 == "89" }' <<<'089'
    0˜

Dans cet exemple, le 1er champ est un nb converti en chaîne.

Conclusion:

Awk  est  cool,  et  il  convertira  si  besoin  un  nombre  en  une  chaîne  et
réciproquement.

Mais un pb se  pose qd on passe un nombre et une  chaîne à un opérateur binaire,
*et* qu'il peut travailler à la fois sur des nombres et des chaînes.

Awk  doit alors  choisir  quelle  coercition réaliser:  il  choisit toujours  de
convertir le nombre en chaîne.
Contrairement à Vim:

    $ awk '$1 == "089" { print "match!" }' <<<'89'
    ''˜

    $ awk '$1 == "089" { print "match!" }' <<<'089'
    match!˜

    :echo "89" == 089
    1˜

En cas d'ambiguïté, awk donne la priorité aux chaînes, Vim aux nombres.

---

    $ awk '$1 == 042 { print "match!" }' <<<'042'
    ''˜

    $ awk '$1 == 142 { print "match!" }' <<<'142'
    match!˜

    $ awk '$1 == 0428 { print "match!" }' <<<'0428'
    match!˜

Dans du code (!= input), awk interprète `042` comme un nb octal.

---

Qd awk doit convertir une chaîne en nb, il le fait comme Vim.

Rappel, pour Vim:

    :echo 'string'   + 10
    10˜
    :echo 'string10' + 10
    10˜
    :echo '10string' + 10
    20˜

Exception (chaîne commençant par un flottant):

    " VimL
    :echo '10.10' + 10
    20˜

    # awk
    $ awk '{ print 10 + $0 }' <<<'10.10string'
    20.1˜

---

    string + 0
    number   ""

Force awk à convertir la chaîne `string` en nb et le nb `number` en chaîne.

Pour ce  faire, on  utilise les opérateurs  `+` et  implicite (concaténation).
`+0` et ` ""` sont des idiomes permettant de s'assurer qu'une variable a bien le
type désiré.  En jargon anglais, on dit parfois ’cast to int / string’.


Il  est particulièrement  important  de  forcer la  conversion  d'une chaîne  en
nombre, qd elle contient  un nombre qui va être utilisé  comme opérande dans une
comparaison numérique.

Ex:

    ✘                                  ✔
    var = substr($1, 1, 3)             var = substr($1, 1, 3) + 0
    if (var < 42)                      if (var < 42)
        print "success!"                   print "success!"

Même si le  1er champ est purement  numérique, on sait que  `var` contiendra une
chaîne, car c'est ce que `substr()` retourne toujours.
Ici, `var` contiendra les 3 premiers caractères du 1er champ.

Sans forcer la coercition de `var` en  nombre, `var < 42` comparerait l'ordre de
chaînes, ce qui n'est probablement pas ce qu'on souhaite en général.

---

    $1     == $2
    $1 + 0 == $2 + 0
    $1  "" == $2

Compare le contenu des champs 1 et 2, en les traitant comme des:

   - nombres ou chaînes, en fonction du type de contenu stocké dans $1 et $2:
     comparaison numérique si les 2 champs sont des nombres, comparaison de
     chaînes autrement

   - nombres

   - chaînes


Dans la 3e comparaison, il n'y a pas  besoin de convertir le 2e champ en chaîne,
car il  suffit qu'un  seul des  opérandes soit une  chaîne pour  que l'opérateur
traite les 2 opérandes comme des chaînes.

---

    $1+0 != 0 ? 1/$1 : "undefined"

Exemple d'expression conditionnelle.
Elle inverse  le 1er champ  numérique s'il est non  nul, autrement elle  vaut la
chaîne "undefined".


Pourquoi `$1+0` et pas simplement `$1` ?
Pour forcer la coercition de `$1` en nb, au cas où ce serait une chaîne.

Explication:

Supposons qu'on écrive `$1 != 0` et que le 1er champ soit "hello".
Voici ce qu'il va se passer:

   1. `!=` convertit le nb `0` en chaîne "0" (règle)

   2. `!=` compare "hello" à "0"

   3. la comparaison échoue

   4. awk évalue 1/"hello"

   5. `/` convertit "hello" en `0`

   6. `/` tente de calculer `1/0`    →    erreur

`!=` et `/` sont tous deux des opérateurs binaires et reçoivent une chaîne et un
nb.
`!=` convertit un nb en chaîne, mais `/` convertit une chaîne en nb.

Pk ne réalisent-ils pas la même coercition?
Car `/` ne travaille que sur des nb,  tandis que `!=` peut travailler sur des nb
ou des chaînes.

---

    print ("11" < 12)
    1˜
    print ("1a" < 12)
    0˜

Retournent resp. 1 (vrai) et 0 (faux).

Car 12 est converti en "12" *et*  sur ma machine, les lettres sont rangées après
les chiffres donc "a" > "2".


Illustre qu'un  opérateur relationnel  d'infériorité ou de  supériorité, opérant
sur  des chaînes,  teste l'ordre  alphabétique  dans lequel  les opérandes  sont
rangés; l'ordre dépend de la machine.

Montre aussi qu'une expression incluant un opérateur relationnel retourne tjrs 1
ou 0, selon que la relation est vraie ou fausse.

---

    $1 < 0 { print "abs($1) = " -$1 }      ✘
    $1 < 0 { print "abs($1) = " (-$1) }    ✔
    $1 < 0 { print "abs($1) = ", -$1 }     ✔

L'objectif, ici, est  d'afficher la chaîne "abs($1) = "  puis l'opposé numérique
du 1er champ.

La 1e règle pattern-action échoue, les 2 suivantes réussissent.
Illustre que l'opérateur `-` peut provoquer une coercition indésirable.

Explication:

    $1 < 0 { print "abs($1) = " -$1 }      ✘
    │
    └ l'opérateur `-` voit une chaîne et un nb,
    donc il convertit la chaîne en nb

    $1 < 0 { print "abs($1) = " (-$1) }    ✔
    │ │
    │ └ l'opérateur `-` voit juste un nb
    └ l'opérateur de concaténation voit une chaîne et un nb
    donc il convertit le nb en chaîne
    Dans l'ordre, le parser d'awk traite:    () > - > concaténation

    $1 < 0 { print "abs($1) = ", -$1 }     ✔
    │
    └ affiche une chaîne puis un nb

##
# Syntax
## When can an assignment be merged with another statement?

When this other statement includes an expression.

    $ awk '{ print (n = 2) + 1, n }' <<<''
    3 2˜

    $ awk '{ if ((n = length($1)) > 2) print "has", n, "characters" }' <<<'hello'
    has 5 characters˜

### How is it possible?

For awk, an  assignment is an expression  – with the side effect  of assigning a
value to a variable.

---

Wait a minute...
So, an assignment is both an expression *and* a statement at the same time?

Theory: An assignment or a function call is just an expression, not a statement.
However, they can be written alone on a line; in this case, it's syntactic sugar
for a command which evaluates the expression.

##
## Where can I break a single statement (or expression) (S) with a newline
### (S) not being a control flow statement?  (4)

After a logical operator:

    1 &&
    2

    3 ||
    4

After `?` or `:`:

    1 ?
    2 :
    3

After a comma:

    print $1,
          $2

After an arbitrarily placed backslash:

    print \
          $1,
          $2

---

All these kinds of locations can be mixed in a single statement:

    printf(\
        "%10s %6s %5s   %s",
        "COUNTRY",
        "AREA",
        "POP",
        "CONTINENT\n\n"\
        )

Here, some newlines are placed after a backslash, others after an argument and a comma.

### (S) being a control flow statement?  (3)

After `(condition)` or `(initialization; condition; increment)`:

    if (e) s

    ⇔

    if (e)
        s

After the `else` or `else if` keyword:

    if (e) s1; else s2

    ⇔

    if (e) s1
    else s2

    ⇔

    if (e)
        s1
    else
        s2

After each  statement in  the body,  provided that  they're surrounded  by curly
braces (to form a compound statement):

    if (e) { s1; s2 } else s3

    ⇔

    if (e) {
        s1
        s2
    } else
        s3

##
## When do I need to put a semicolon between an `if` and `else` statement?

When you put the `else` statement on a line of the `if` statement:

    if (e) s1; else s2

    if (e)
        s1; else s2

But you don't need a semicolon, if the body of `if` is a compound statement:

    if (e) {
        s1
        s2
    } else
        s3

## How can I increase the readability of a `print` statement with several arguments?  (2)

Break it down on several lines, and comment each one:

    {
        print \
              $1,    # middle of action
              $2     # after action
    }                # after rule

This shows that you can comment *any* end of line.

##
# Pattern
## What are the five kind of patterns?

   - a special keyword:

      * `BEGIN`
      * `END`

      * `BEGINFILE`
      * `ENDFILE`

   - an expression whose value is a scalar (number or string)

   - a (regex) matching expression:

      * `expr  ~ /pat/`
      * `expr !~ "pat"`

   - a compound expression which combines previous expressions
     with `&&`, `||`, `!`, `()`

   - a range:

      *  expr1 , expr2
      * /pat1/ , /pat2/

### When does each of them match?

`BEGIN` matches before the first record.
`END` matches after the last record.

`BEGINFILE` matches before the first record of every file in the input.
`ENDFILE` matches after the last record of every file in the input.

An expression matches if it evaluates to a non-zero number or a non-null string.
Note that a relational, matching or  compound expression always evaluates to `0`
or `1` depending on whether it's true.

A range matches a set of consecutive  records.  The first record in the range is
any record matched by the first expression, let's call it `R1`.  The last record
in the range is the next record after `R1` matched by the second expression.

##
## These expressions are syntactic sugar for what?
### `/pat/`

    $0 ~ /pat/

... which is a particular case of:

    (regular) expr

### `!/pat/`

    $0 !~ /pat/

### `/pat1/,/pat2/`

    $0 ~ /pat1/,$0 ~ /pat2/

... which is a particular case of:

    expr1,expr2

##
# Modifying Fields
## What's the side effect of a field modification?

Awk automatically splits  the record into fields to access  the field to modify,
then replaces every `FS` with `OFS` to create the output record.

    $ tee /tmp/file <<'EOF'
    This_old_house_is_a_great_show.
    I_like_old_things.
    EOF

    $ tee /tmp/awk.awk <<'EOF'
    BEGIN { FS = "_"; OFS = "|" }
    { $(NF + 1) = ""; print }
    EOF

    $ awk -f /tmp/awk.awk /tmp/file
    This|old|house|is|a|great|show.|˜
    I|like|old|things.|˜
                      ^
                      separates the previous field (`things.`)
                      from the new last empty field

## What happens if I assign a value to a non-existent field (index bigger than the last one)?

Awk will create as many empty fields as necessary to allow this new field to exist.

Example:

    $ tee /tmp/file <<'EOF'
    This_old_house_is_a_great_show.
    I_like_old_things.
    EOF

    $ tee /tmp/awk.awk <<'EOF'
    BEGIN { FS = "_"; OFS = "|" }
    { $(NF + 3) = ""; print }
    EOF

    $ awk -f /tmp/awk.awk /tmp/file
    This|old|house|is|a|great|show.|||˜
    I|like|old|things.|||˜
                      ^^^
                      there are 3 new empty fields at the end

##
# Printing
## I have the following file:

    $ tee /tmp/emp.data <<'EOF'
    Beth    4.00   0
    Dan     3.75   0
    Kathy   4.00   10
    Mark    5.00   20
    Mary    5.50   22
    Susie   4.25   18
    EOF

The three columns contain:

   - the name of employees
   - their pay rate in dollars per hour
   - the number of hours they've worked so far

### How to print and sort the names of the employees in reverse order?

Write the names on a pipe connected to the `sort` command:

    $ awk '{ print $1 | "sort -r" }' /tmp/emp.data
    Susie˜
    Mary˜
    Mark˜
    Kathy˜
    Dan˜
    Beth˜

It seems that the RHS of a pipe  inside an action is not processed like the LHS.
The LHS is executed once for each record matching the pattern.
The RHS is executed once for the whole input.

awk probably closes the pipe only after the last record has been processed.

---

Instead of using a built-in pipe, you could also have used an external one:

    $ awk '{ print $1 }' /tmp/emp.data | sort -r

### How to sort the lines according to the total pay?

    $ awk '{ printf("%6.2f  %s\n", $2 * $3, $0) | "sort -n" }' /tmp/emp.data
      0.00  Beth    4.00   0˜
      0.00  Dan     3.75   0˜
     40.00  Kathy   4.00   10˜
     76.50  Susie   4.25   18˜
    100.00  Mark    5.00   20˜
    121.00  Mary    5.50   22˜

### How to save all records inside a list?

Use `NR` to uniquely index them in an array.

    a[NR] = $0

---

    $ tee /tmp/awk.awk <<'EOF'
        { a[NR] = $0 }
    END { print a[2] }
    EOF

    $ awk -f /tmp/awk.awk /tmp/emp.data
    Dan     3.75   0˜

##
# Functions
## What are the outputs of the next snippets?

    $ tee /tmp/awk.awk <<'EOF'
    END {
        a = "foo"
        myfunc(a)
        print a
    }
    function myfunc(a) {
        a = a 42
    }
    EOF

    $ awk -f /tmp/awk.awk <<<''
↣
    foo

`myfunc()` has not modified the global variable `a`.
↢

    $ tee /tmp/awk.awk <<'EOF'
    END {
        b[1] = "foo"
        myfunc(b)
        print b[1]
    }
    function myfunc(b) {
        b[1] = b[1] 42
    }
    EOF

    $ awk -f /tmp/awk.awk <<<''
↣
    foo42

`myfunc()` *has* modified the first element of `b`.
↢

### Why are they different?

Awk passes scalars by value, and arrays by reference.

##
# Operators
## How are consecutive operators of equal precedence grouped?

Most operators are *left*-associative:

    7-4+2
    ⇔
    (7-4)+2
     ^^^
     7 and 4 are grouped first (not 4 and 2)

except for the assignment, conditional,  and exponentiation operators, which are
*right*-associative.

Example:

    $ awk '{ print 2^3^4 }' <<<''
    2417851639229258349412352˜

Here, we can see that:

    2 ^ 3 ^ 4
    ⇔
    2 ^ (3 ^ 4)
    ⇔
    2 ^ 81

If `^` was left-associative:

    2 ^ 3 ^ 4
    ⇔
    (2 ^ 3) ^ 4
    ⇔
    8 ^ 4
    ⇔
    4096

## What does grouping allow me to change?

The precedence of an arbitrary operator.

##
## How to simplify multiple assignments, all of which have the same RHS?

    var1 = val
    var2 = val

    ⇔

    var1 = var2 = val

### Why does this work?

Because an assignment is an expression:

           expression returning `val`, and assigning it to `var2`
           v--------v
    var1 = var2 = val
    ^---------------^
    expression returning `val`, and assigning it to `var1`

and because the assignment operator is *right*-associative:

    var1 = var2 = val
    ⇔
    var1 = (var2 = val)

##
##
##
# Affichage
## Alignement

Il existe 3 méthodes pour aligner la sortie d'awk:

   - utiliser `printf` en donnant une largeur de champ suffisante pour chaque colonne
   - jouer sur les variables `FS` et/ou `OFS`
   - pipe la sortie d'awk vers `column`


    BEGIN {      OFS = "\t" }
    BEGIN { FS = OFS = "\t" }

Préserve l'alignement des champs de l'input qd ils sont séparés par des:

   - espaces
   - tabs

En  effet, modifier  un champ  peut  changer sa  largeur, et  donc faire  perdre
l'alignement d'une colonne.  En ajoutant un tab après chaque champ, on restaure
l'alignement.


Explication:

Qd on ne modifie pas le contenu d'un record, awk le produit tel quel.
En revanche,  si on modifie directement  le contenu d'un champ  dont l'index est
non nul, awk effectue le remplacement `FS` → `OFS`, sur son record.

En clair, par défaut, awk remplace chaque séquence d'espaces et de tabs par un
espace.  Si on a utilisé des tabs pour aligner des colonnes au sein d'un texte,
ce remplacement peut ruiner l'alignement.

Avec la  2e commande  précédente, awk  ne supprimera  que les  tabs (car  `FS` =
"\t"), qu'il remplacera par des tabs (car `OFS` = "\t").

Edit: Playing with  `FS` and `OFS` doesn't  seem reliable enough if  you've used
several tabs to align some fields.

        $ tee /tmp/emp.data <<'EOF'
        Beth			4.00	0
        Dan			3.75	0
        KathySomeVeryLongName	4.00	10
        Mark			5.00	20
        Mary			5.50	22
        Susie			4.25	18
        EOF

        $ awk 'BEGIN { FS = "\t+"; OFS = "\t" }; { $3 = "foo"; print }' /tmp/emp.data
        Beth	4.00	foo˜
        Dan	3.75	foo˜
        KathySomeVeryLongName	4.00	foo˜
        Mark	5.00	foo˜
        Mary	5.50	foo˜
        Susie	4.25	foo˜

Note that playing with `FS` and `OFS` is still useful to preserve some alignment:

        $ awk '{ $3 = "foo"; print }' /tmp/emp.data
        Beth 4.00 foo˜
        Dan 3.75 foo˜
        KathySomeVeryLongName 4.00 foo˜
        Mark 5.00 foo˜
        Mary 5.50 foo˜
        Susie 4.25 foo˜

But it's not always perfect.

---

    $ awk ... | column -t [-s:]

Aligne les  colonnes de  texte de  la sortie d'awk.   Par défaut,  l'espace est
utilisé comme séparateur  entre 2 champs (`-s:` = utiliser  le double-point à
la place)

Commande pratique si awk a transformé du texte et perdu l'alignement des champs.

L'avantage par  rapport aux règles  awk précédentes (`BEGIN` ...),  est qu'on
n'a pas besoin de se soucier de savoir comment l'input d'awk était alignée, ni
même si elle était alignée.

## Précision numérique

When a float is printed, it's formatted according to the format specifier `OFMT`
(no coercion number → string) or `CONVFMT` (coercion).

But when an integer  is printed, it remains an integer, no  matter the values of
`OFMT` and `CONVFMT`:

    $ awk '{ OFMT = CONVFMT = "%.2f"; print 1E2 }' <<<''
    100˜

    $ awk '{ OFMT = CONVFMT = "%.2f"; print 1E2 "" }' <<<''
    100˜



    { printf "%.6g", 12E-2 }
    0.12˜
    { printf "%.6g", 123.456789 }
    123.457˜

Il  semble  que les  spécificateurs  de  conversion  `%e`,  `%f`, et  `%g`  sont
identiques entre les fonctions `printf()` de Vim et awk, à deux exceptions près.

Le `%g` du `printf()` d'awk supprime les 0 non significatifs, *et* il interprète
la précision comme le nb de chiffres significatifs.

Celui de Vim ne supprime pas les 0 non significatifs, et interprète la précision
comme le nb de chiffres après la virgule:

    :echo printf("%.6g", 12*pow(10,-2))
    0.120000˜
    :echo printf("%.6g", 123.456789)
    123.456789˜

---

    BEGIN { var = 1.23456789 }
    END {
        OFMT = "%.2f"
        print (var > 1.234)
    }

Il  faut des  parenthèses autour  de  `var >  1.234`  pour éviter  que `>`  soit
interprété comme une redirection.

Les  parenthèses  forcent  awk  à  évaluer  l'expression  `var  >  1.234`  avant
d'exécuter   `print`  Sans   elles,  awk   exécuterait  d'abord   `print`,  puis
redirigerait la sortie le fichier `1.234`.


L'expression `var > 1.234` retourne `1`  (réussite), ce qui signifie que `var` a
été formatée *après* l'évaluation de `var > 1.234`:

    1.23456789 > 1.234 ✔
    1.23       > 1.234 ✘

... mais *avant* d'afficher le résultat:

    print (var - 1.234)
    0.00 (au lieu de 0.00056789)˜

Conclusion: qd  une expression  arithmétique est  affichée, elle  n'est formatée
qu'après son évaluation.

## Print(f)

    Syntaxes des fonctions `print()`, `close()` et `system()`:

    ┌──────────────────────────┬──────────────────────────────────────────────────────────┐
    │ print e1, e2, ...        │ concatène les valeurs des expressions                    │
    │                          │ en incluant OFS entre elles et ORS à la fin,             │
    │                          │ puis écrit le résultat sur la sortie standard du shell   │
    ├──────────────────────────┼──────────────────────────────────────────────────────────┤
    │ print e1, e2, ... >expr  │ écrit dans le fichier dont le nom est la valeur chaîne   │
    │                          │ de `expr`                                                │
    │                          │                                                          │
    │ print e1, e2, ... >>expr │ mode append                                              │
    ├──────────────────────────┼──────────────────────────────────────────────────────────┤
    │ print e1, e2, ... | expr │ écrit sur l'entrée standard de la commande shell         │
    │                          │ stockée dans la valeur chaîne de `expr`                  │
    ├──────────────────────────┼──────────────────────────────────────────────────────────┤
    │ system(expr)             │ exécute la commande shell stockée dans `expr`            │
    │                          │ et affiche sa sortie                                     │
    │                          │                                                          │
    │                          │ retourne son code de sortie                              │
    ├──────────────────────────┼──────────────────────────────────────────────────────────┤
    │ close(expr)              │ la valeur de `expr` doit être une chaîne dont le contenu │
    │                          │ est un chemin vers un fichier ou une commande shell,     │
    │                          │ ayant servi dans une redirection (>, |)                  │
    └──────────────────────────┴──────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────┐
    │ printf(fmt, e1, e2, ...)        │
    ├─────────────────────────────────┤
    │ printf(fmt, e1, e2, ...) >expr  │
    │ printf(fmt, e1, e2, ...) >>expr │
    ├─────────────────────────────────┤
    │ printf(fmt, e1, e2, ...) | expr │
    └─────────────────────────────────┘

Les syntaxes de `printf` sont similaires à `print`, à ceci près que:

   - il faut ajouter l'argument `fmt` (chaîne format)
     ce qui donne à `printf` plus de puissance

   - `printf` ne remplace *rien*:
     ni `FS` → `OFS` entre 2 expressions,
     ni `RS` → `ORS` à la fin

Il faut donc en tenir compte.
Pex, si on veut un newline à la fin, il faut l'inclure dans `fmt`:

    printf("...\n", e1, ...)

---

Si  on passe  en argument  à `print`  ou `printf`,  une expression  utilisant un
opérateur relationnel,  il faut entourer  soit l'expression soit toute  la liste
des arguments avec des parenthèses.

En effet, un opérateur relationnnel  pourrait être interprété comme un opérateur
de redirection:

    print 3 > 2     ✘ écrit `3` dans le fichier dont le nom est `2`
    print(3 > 2)    ✔ affiche 1 car la relation est vraie

Avec les parenthèses, `>` ne "voit" pas `print`, et est donc interprété comme un
opérateur relationnel.

---

    print $1, $2
    print $1  $2

Affiche le contenu des champs 1 et 2 en les séparant par:

   - `OFS`
   - rien

Illustre que  l'opérateur de concaténation  (implicite) n'ajoute rien  entre les
expressions.

---

        { names = names $1 " " }
    END { print names }

Affiche tous les noms des employés sur une même ligne.
Montre comment convertir une colonne en ligne.

---

Une suite d'expressions dans  le RHS d'une affectation n'a pas  de sens, awk les
concatène donc en une seule expression.
Il  a le  droit  de le  faire  car l'opérateur  de  concaténation est  implicite
(contrairement à VimL où il est explicite `.`).

Au passage, si l'une des expressions  est un nb, il est automatiquement converti
en chaîne; c'est  logique puisque l'opérateur de concaténation  ne travaille que
sur des chaînes.

---

    { temp = $2; $2 = $1; $1 = temp; print }

Affiche tous les records en inversant les 2 premiers champs.
Le résultat est obtenu en 3 étapes:

   - sauvegarde temporaire du 2e champ dans la variable `temp`
   - duplication du champ 1 dans le champ 2
   - restauration du champ 2 dans le champ 1 via `temp`


On aurait aussi pu utiliser `printf`.
Pex, pour un input ayant 3 champs:

    { printf "%s %s %s\n", $2, $1, $3}


On remarque qu'on peut utiliser `$1` et `$2` à la fois comme:

   - valeur (expression)    normal
   - nom de variable        surprise!

Il semble qu'en awk  comme en VimL (mais pas en bash), il  y a symétrie entre le
LHS et le RHS d'une affectation.

---

    printf "total pay for %-8s is $%6.2f\n", $1, $2*$3
    total pay for Beth     is $  0.00˜
    total pay for Dan      is $  0.00˜
    total pay for Kathy    is $ 40.00˜
    total pay for Mark     is $100.00˜
    total pay for Mary     is $121.00˜
    total pay for Susie    is $ 76.50˜

On peut utiliser la commande `printf` pour formater un record.

Ici, on  utilise les items  `%-8s` et `%6.2f` pour  insérer le nom  des employés
(`$1`), et leur salaire (`$2*$3`) dans la chaîne principale.

Rappel:

   * -8s     champ de taille 8, alignement à gauche
   * 6.2f    champ de taille 6, flottant avec 2 chiffres signifcatifs après la virgule


Si on n'avait  pas donné la largeur `8`  à la colonne des noms,  ou que certains
noms avaient plus  de 8 caractères, alors les colonnes  suivantes n'auraient pas
été alignées.

Donner  une largeur  de champ  suffisante à  la valeur  d'une expression  permet
d'aligner les colonnes des expressions suivantes.

---

    for (i in a)
        print a[i] | "sort -nr >/tmp/file"

Trie le contenu de l'array `a` dans `/tmp/file`.

Illustre qu'on  peut écrire  toute une  boucle d'instructions  sur un  pipe, pas
seulement une simple instruction; similaire au shell.

---

    print message | "cat 1>&2"
    system("echo '" message "' 1>&2")

    print message >"/dev/tty"

Les 2  premières commandes écrivent le  contenu de la variable  `message` sur la
sortie d'erreur du shell.
La 3e écrit sur le terminal.

Ces 3 commandes résument les différents idiomes qu'il est possible d'utiliser qd
on veut écrire sur la sortie d'erreur ou standard du shell.

##
# Calcul

    atan2(0,-1)
    π˜
    exp(1)
    𝑒˜
    log(42)/log(10)
    logarithme de 42 en base 10˜

Illustre comment utiliser  les fonctions arithmétiques de awk  pour exprimer des
constantes célèbres en maths.


La fonction `atan2()` est une variante de la fonction arc tangente.

Quelle différence entre `atan2()` et `arctan()`?

`atan2()`  retourne  des  angles   dans  l'intervalle  ]-π,π],  `arctan()`  dans
]-π/2,π/2].

On remarque que l'intervalle image de `arctan()` est 2 fois plus petit que celui
de `atan2()`.
En effet, pour chaque  nombre réel `y` il existe 2 angles distincts  `x` et `x +
π` ayant pour image `y` via la fonction tangente:

    y = tan(x) = tan(x+π)

Il faut donc que `arctan()` choisisse entre les 2.
Pour lever cette ambigüité, on utilise l'intervalle ]-π/2,π/2].


Quelle différence entre `atan2(y,x)` et `arctan(y/x)`?

Le rapport `y/x` nous fait perdre de l'information: les signes de `x` et `y`.

    arctan(y/x) = arctan(-y/-x)
    atan2(y,x) != atan2(-y,-x)

IOW, si on imagine un point A  de coordonnée `(x,y)`, `arctan()` ne nous donnera
pas forcément son angle (Ox,OA); il se peut qu'elle rajoute/enlève π.
Tandis qu'avec `atan2()`, on aura toujours exactement l'angle (Ox,OA).

---

    int(x + 0.5)

Arrondit le nb décimal positif `x` à l'entier le plus proche.


    $1 > max { max = $1 }
    END      { print max }

Affiche le plus grand nombre de la 1e colonne.


    # ✘
    $ awk '{ print (1.2 == 1.1 + 0.1 ) }' <<<''
    0

    # ✔
    $ awk '{ x = 1.2 - 1.1 - 0.1 ; print (x < 0.001 && x > 0 || x > -0.001 && x < 0) }' <<<''
    1˜

Il se  peut que 2  expressions arithmétiques  diffèrent pour awk  alors qu'elles
devraient être identiques.

Le pb vient du fait que la représentation d'un flottant est parfois inexacte.

Cela peut conduire à des erreurs lors d'une comparaison entre 2 expressions dont
les valeurs sont des flottants.

Ou  encore  lors d'un  calcul  en  plusieurs  étapes,  qui fait  intervenir  des
flottants.
Lorsqu'une erreur,  même petite, se propage  d'une étape à une  autre, elle peut
être amplifiée.
Au final, on peut obtenir un résultat très loin de celui désiré.

Pour un exemple, lire ce lien qui contient un algo approximant π:

<https://www.gnu.org/software/gawk/manual/html_node/Errors-accumulate.html#Errors-accumulate>

Pour une comparaison entre flottants, la solution consiste à ne pas les comparer
directement entre  eux, mais plutôt  leur distance  par rapport à  une précision
arbitraire.

---

    # ✔
    $ awk '1e50 == 1.0e50 { print 1 }' <<<''
    1˜

    # ✘
    $ awk '1e500 == 1.0e500 { print 1 }' <<<''
    1˜

Le problème peut venir de nombres trop grands, pex:

    1e50  == 1.0e50     ✔
    1e500 == 1.0e500    ✘

    1.2 == 1.1 + 0.1 { print }
    ✘ devrait afficher tous les records de l'input mais atm n'affiche rien car la comparaison échoue˜

    { print 1.2 - 1.1 - 0.1 }
    retourne -1.38778e-16, mais devrait retourner 0˜
    D'où vient cette différence non nulle ???

    On a le même problème dans Vim!
    :echo 1.2 - 1.1 - 0.1
    -1.387779e-16˜

    Autre problème:
    :echo 1.3 - 1.1 - 0.1 == 0.1
    0˜

    Bottom line:
    Don't make a float comparison in VimL, nor in awk.

    Read the gawk user's guide, chapter 15 to understand what's going on.

##
# Syntaxe
## Arrays

    array

En  informatique,  une array  est  un  ensemble  d'éléments  indexés par  un  ou
plusieurs indices.

Analogie entre informatique et maths:

    ┌─────────────────────────────────────────┬───────────┐
    │ informatique                            │ maths     │
    ├─────────────────────────────────────────┼───────────┤
    │ array indexée par 0 indice              │ constante │
    │ ≈ scalaire                              │           │
    ├─────────────────────────────────────────┼───────────┤
    │ array indexée par un seul indice        │ vecteur   │
    │                                         │           │
    │ liste ou dictionnaire                   │           │
    │ │        │                              │           │
    │ │        └ les index sont des chaînes   │           │
    │ └ les index sont des nbs                │           │
    ├─────────────────────────────────────────┼───────────┤
    │ array indexée par 2 indices             │ matrice   │
    ├─────────────────────────────────────────┼───────────┤
    │ array indexée par n indices             │ tenseur   │
    └─────────────────────────────────────────┴───────────┘


Dans  awk, une  array  est associative,  i.e.  elle peut  être  indexée par  des
chaînes.

Pk le terme "associative"?
Explication:

Une array associative mémorise des associations.

En  programmation,  les  éléments  d'une  liste sont  indexés  par  des  nombres
consécutifs en partant de 0.
Une  liste n'a  besoin de  mémoriser que  ses éléments,  car elle  peut utiliser
l'ordre dans  lequel ils  sont rangés  pour retrouver  n'importe lequel  via son
index.
Elle n'a pas besoin de mémoriser les associations 'indice élément'.

En revanche, dans une array pouvant être indexée par des chaînes, il n'y a aucun
ordre sur lequel s'appuyer.
Il faut donc que les *associations* 'indice - élément' soient mémorisées, et non
pas simplement les éléments.

---

    array[$1] = $2

Crée une array dont  les indices sont les éléments de la  1e colonne de l'input,
et les valeurs associées sont ceux de la 2e colonne.
Ex:

    foo 1
    bar 2    →    array = { 'foo': 1, 'bar': 2, 'baz':3 }
    baz 3


    i = "A"; j = "B"; k = "C"
    array[i, j, k] = "hello, world\n"

Affecte "hello, world\n" à l'élément de `array` indexé par la chaîne:

    "A\034B034C"

Illustre  qu'awk  supporte  les  arrays multi-dimensionnelles,  et  que  lorsque
l'indice est une liste d'expressions,  ces dernières sont converties en chaînes,
et concaténées  en utilisant le  contenu de  la variable interne  `SUBSEP` comme
séparateur.

---

    if (i in a)
        print a[i]

    if ((i,j) in a)
        print a[i,j]

Teste si `a[i]` / `a[i,j]` existe et si c'est le cas, affiche sa valeur.


`i` et `j` peuvent être des variables,  des chaînes ou des nombres (convertis en
chaînes).


`i in a`  est une expression retournant  `1` si l'array `a`  contient un élément
d'indice `i`, `0` autrement.


Dans une expression utilisant l'opérateur `in`, un indice multi-dimensionnel est
entouré de parenthèses (et non de crochets).

---

    if ("Africa" in pop) ...        ✔
    if (pop["Africa"] != "") ...    ✘

Ces 2 `if` testent si l'indice "Africa" est présent dans l'array `pop`.

Le 2e  `if` ajoute  automatiquement à  `pop` l'élément  d'indice "Africa"  et de
valeur "".
Ce n'est pas le cas du 1er `if`, dont la syntaxe est sans doute à préférer.

---

    delete a
    delete a[42]

Supprime tous les éléments de l'array `a` / l'élément d'indice 42.

---

    for (i in a)
        print a[i]

Affiche tous les éléments de l'array `a`.


Si l'array  est multi-dimensionnelle, et qu'à  l'intérieur de la boucle  on veut
accéder  à  chaque  composant  de  l'indice `i`  séparément,  on  peut  utiliser
`split()` et `SUBSEP`:

    split(i, x, SUBSEP)

... les composants sont stockées dans l'array `x`.


Ne pas confondre la construction awk `for  i in array` avec la construction VimL
`for val in list`.

Une array awk se rapproche davantage d'un dictionnaire Vim.
Toutefois, en VimL et contrairement à awk, on ne peut pas itérer directement sur
les clés d'un dictionnaire, à moins de passer par la fonction `items()`:

    for i in items(mydic)
        echo i[0]
    endfor

Résumé:

    ┌──────┬───────────────────────────────────────────────────────────────────┐
    │ VimL │ for val in list:    `val` itère sur les VALEURS au sein de `list` │
    ├──────┼───────────────────────────────────────────────────────────────────┤
    │ awk  │ for i in array:     `i` itère sur les INDICES de `array`          │
    └──────┴───────────────────────────────────────────────────────────────────┘

##
## Control (flow) statements
### while

    while (e)
        s

    ⇔

    while (e) s

    ⇔

    do
        s
    while (e)

    ⇔

    do s; while (e)

---

    while (e) {
        s1
        s2
    }

    ⇔

    while (e) { s1; s2 }

    ⇔

    do { s1; s2 } while (e)

Si `e` est fausse dès le début, une boucle `while` n'exécutera jamais `s`.
En revanche, une boucle `do` l'exécutera une fois, car `do` vient avant `while`.

### next / exit

    exit
    exit 123

Se rendre directement à la règle `END`.
Idem, en retournant 123 comme code de sortie du programme awk.

Si `exit`  est utilisé au sein  de la règle  `END`, on quitte le  programme awk,
sans terminer de traiter les actions `END`.

---

    next
    nextfile

Arrête  le  traitement du  record  courant,  ignore les  couples  pattern-action
suivants, et passe:

   - au prochain record du fichier courant
   - au 1er      record du prochain fichier de l'input


Qd `nextfile` est utilisé, certaines variables sont mises à jour:

   - `FILENAME`
   - `ARGIND`
   - `FNR`  →  1


`next` provoque une erreur s'il est utilisé dans la règle `BEGIN` ou `END`.
Idem pour `nextfile`.

---

    pattern { statement1; next}
            { statement2 }

Exécute `statement1`  sur les records  où `pattern` matche, et  `statement2` sur
les autres.

Grâce  à  `next`, on  évite  l'exécution  de  `statement2`  sur les  records  où
`pattern` ne matche pas.

##
## Functions
### close

La  fonction `close()`  permet de  fermer des  fichiers et  pipes ouverts  (i.e.
auxquels le processus awk accède en lecture).
Ça peut être  nécessaire entre autres car l'OS possède  une limite concernant le
nb  de fd  (file descriptors)  ouverts  simultanément, ce  qui limite  le nb  de
fichiers / pipes pouvant être ouverts à un instant T.

---

    $ tee /tmp/awk.awk <<'EOF'
    BEGIN {
        "date" | getline var1
        print var1
        system("sleep 3")
        close("date")
        "date" | getline var2
        print var2
    }
    EOF

    $ awk -f /tmp/awk.awk <<<''

Affiche l'heure et la date du jour, dort 3s, puis réaffiche l'heure.

Sans l'instruction `close("date")` qui ferme le précédent pipe `"date" | getline var`,
la  2e commande  shell `date`  n'aurait pas  été exécutée,  et `print`  n'aurait
affiché qu'une seule date.

Illustre qu'il faut  fermer un pipe, si on veut  pouvoir le réutiliser plusieurs
fois.

---

    END {
        for (i in a)
            print a[i] | "sort -nr >/tmp/file"

        close("sort -nr >/tmp/file")

        while ((getline <"/tmp/file") > 0) print
    }

Ce code fait 3 choses:

   1. écrit le contenu de l'array `a` sur l'entrée de la commande shell:

          $ sort -nr >/tmp/file

   2. ferme le pipe

   3. lit et affiche le contenu de `/tmp/file`

Pour que la  1e étape se termine,  et que le fichier `/tmp/file`  soit écrit, la
fermeture du pipe via `close()` dans la 2e étape est nécessaire.
Sans  `close()`,  awk  ne  fermerait  le  pipe  que  lorsque  son  processus  se
terminerait, pas avant.

### getline

`getline` permet, à tout moment, de lire un nouveau record depuis:

   - l'input d'origine (celle passée à awk au moment où on l'a invoqué)
   - un fichier
   - un pipe
   - le clavier

---

Valeurs retournées par `getline`:

    ┌────┬─────────────────────────────────────────────────────────────────────────┐
    │ 1  │ a pu lire un record                                                     │
    ├────┼─────────────────────────────────────────────────────────────────────────┤
    │ 0  │ est arrivée à la fin:                                                   │
    │    │                                                                         │
    │    │     - de l'input d'origine                                              │
    │    │     - du fichier                                                        │
    │    │     - de l'output du pipe                                               │
    ├────┼─────────────────────────────────────────────────────────────────────────┤
    │ -1 │ a rencontré une erreur                                                  │
    └────┴─────────────────────────────────────────────────────────────────────────┘

Le code de sortie  de `getline` est utile pour lire  et opérer sur l'intégralité
d'une source de texte contenant plusieurs records.
Pour  ce faire,  on utilise  la structure  de contrôle  `while`, et  on s'assure
qu'elle est  > 0  (pour éviter  de rester piégé  dans une  boucle infinie  si le
fichier n'est pas lisible).

    ┌───────────────────────────────┬─────────────────────────────────────────────────────────────┐
    │ while (getline > 0)           │ Exécute la déclaration `s`, tant qu'il reste des records    │
    │     s                         │ à traiter dans l'input                                      │
    ├───────────────────────────────┼─────────────────────────────────────────────────────────────┤
    │ while ((getline <expr) > 0)   │ tant qu'il reste des records dans le fichier dont le chemin │
    │     s                         │ est la valeur chaîne de `expr`                              │
    ├───────────────────────────────┼─────────────────────────────────────────────────────────────┤
    │ while (("cmd" | getline) > 0) │ tant qu'il reste des records dans la sortie de "cmd"        │
    │     s                         │                                                             │
    └───────────────────────────────┴─────────────────────────────────────────────────────────────┘

---

`getline` is a command, not a function (source: `man gawk`, gawk user's guide):

    getline()    ✘
    getline      ✔

    var = getline()    ✘
    getline var        ✔

    getline(expr)      ✘
    getline <expr      ✔

Le symbole de redirection `<` est nécessaire pour qu'il n'y ait pas de confusion
avec la syntaxe `getline var`.
On  peut aussi  expliquer  le choix  de  ce  symbole par  le  fait qu'on  change
l'argument  par défaut  de `getline`,  à savoir  l'input d'origine:  on redirige
l'entrée de `getline` vers la valeur d'une expression.

---

How do I access a record read by `getline`?

If you provided the name of a variable as an argument, use this variable.
Otherwise, use `$0`.

Note that when `getline` updates `$0`, it also updates `$i` (fields contents) and `NF`.

---

When does `getline` update `NR` and `FNR`?

Only when you use it to read a record from the input.

If you try to read a record from a new file (`getline <"file"`), or from a shell
command (`"cmd" | getline`), `NR` and `FNR` are *not* udpated.

---

When doesn't `getline` update any built-in variable?

When you  read a record  from outside the input  (shell command, file),  and you
save it in a variable.

    $ tee /tmp/file <<'EOF'
    a
    b c
    d e f
    EOF

    $ tee /tmp/awk.awk <<'EOF'
    /a/ { "whoami" | getline var ; print $0, NF, NR }
    EOF

    $ awk -f /tmp/awk.awk /tmp/file
    a 1 1˜

Here, even though we've invoked `getline`:

   - `$0` was not changed to `b c`
   - `NF` was not changed to `2`
   - `NR` was not changed to `2`

---

`getline` est  pratique qd on a  du mal à décrire  le record sur lequel  on veut
agir, mais qu'on peut facilement décrire celui qui le précède.

---

Tout comme `next`,  `getline` peut provoquer la lecture du  prochain record.  La
différence  vient du  fait que  `next` repositionne  l'exécution au  début du
programme, pas  `getline`.  IOW, une  fois `getline` exécutée, awk  ne compare
pas le nouveau record aux patterns des précédents couples pattern-action qu'il
a déjà traité.

---

    print "Enter your name: "
    getline var <"-"

Demande à l'utilisateur de taper son nom, et stocke la réponse dans `var`.

Illustre que dans les syntaxes:

    getline <expr
    getline var <expr

... `expr` peut être `"-"`; et que `"-"` désigne le clavier.

---

    "whoami" | getline
    print

    "whoami" | getline me
    print me

Affiche `username` (ex: toto), dans les 2 cas.

Mais la sortie de la commande shell  `whoami` peuple `$0` uniquement dans le 1er
exemple.

### built-in

Fonctions arithmétiques:

    ┌────────────┬────────────────────────────────────────────────────────────────────┐
    │ atan2(y,x) │ arg(x + iy) exprimé en radians dans l'intervalle ]-π,π]            │
    ├────────────┼────────────────────────────────────────────────────────────────────┤
    │ cos(x)     │ cosinus de `x`, `x` étant interprété comme une mesure en radians   │
    ├────────────┼────────────────────────────────────────────────────────────────────┤
    │ exp(x)     │ exponentiel de `x`                                                 │
    ├────────────┼────────────────────────────────────────────────────────────────────┤
    │ int(x)     │ partie entière de `x`                                              │
    ├────────────┼────────────────────────────────────────────────────────────────────┤
    │ log(x)     │ logarithme népérien de `x`                                         │
    ├────────────┼────────────────────────────────────────────────────────────────────┤
    │ rand(x)    │ nombre aléatoire choisi dans [0, 1[                                │
    ├────────────┼────────────────────────────────────────────────────────────────────┤
    │ sin(x)     │ sinus de `x`                                                       │
    ├────────────┼────────────────────────────────────────────────────────────────────┤
    │ sqrt(x)    │ racine carrée de `x`                                               │
    ├────────────┼────────────────────────────────────────────────────────────────────┤
    │ srand(x)   │ définit `x` comme nouvelle graine (seed) pour la fonction `rand()` │
    └────────────┴────────────────────────────────────────────────────────────────────┘

---

               print rand()
    srand()  ; print rand()
    srand(42); print rand()

Affiche un nombre aléatoire dans `[0, 1[`, en utilisant comme graine:

   - 1
   - secondes depuis l'epoch ( `$ date +'%s'`)
   - 42


La sortie de  `rand()` est entièrement déterminée par la  graine.  IOW, si on
ne change pas la graine via `srand()`, `rand()` aura toujours la même valeur.

---

Dans un programme awk, initialement, la graine est toujours `1`.  Puis, au cours
de  l'exécution  du  programme,  elle  peut  changer  via  des  invocations  de
`srand()`.

`srand(42)` et `srand()` ont 2 effets:

   - donne à la graine la valeur `42` / epoch
   - retourne la précédente valeur de la graine

### user-defined

    function myfunc(parameter-list) {
        statements
        return expr
    }

Syntaxe générale pour définir une fonction utilisateur.

Les accolades sont toujours obligatoires, même si la fonction ne contient qu'une
seule déclaration.

---

`expr` est facultative, et la déclaration `return expr` aussi.

Si `expr` est présente, ce doit être un scalaire, pas une array.
Pour simuler  un `return  array`, on  pourra peupler  une variable  globale avec
l'array qu'on veut retourner: array = ...

##
## Ligne de commande

    $ awk --lint -f progfile <input>
    $ awk -t    -f  progfile <input>

`--lint`  et `-t`  (`--old-lint`) fournissent  des avertissements  à propos  des
constructions non portables vers la version (unix) d'awk originelle.

`--lint` fournit également des avertissements pour des constructions douteuses.

---

    $ awk -F: 'pgm' <input>
    $ awk -v RS='\t' 'pgm' <input>

Exécute `pgm` sur `<input>` en utilisant:

   - le double-point comme séparateur de champs
   - le tab          comme séparateur de records

La syntaxe  `-v var=val`  permet de configurer  n'importe quelle  variable avant
l'exécution d'un programme awk; `-F<fs>` ne permet de configurer que `FS`.

---

    $ awk -f progfile f1 FS=: f2

Traite le fichier `f1` avec `FS` ayant  sa valeur par défaut (" "), puis traite
`f2` avec `FS` ayant pour valeur `:`.

Plus généralement, on  peut configurer une variable juste  avant le traitement
d'un fichier arbitraire, via la syntaxe:

    $ awk -f progfile f1 var=val f2

---

    $ awk 'pattern { action }'                      file
    $ awk 'pattern { statement1; statement2; ... }' file
    $ awk 'rule1; rule2; ...'                       file

Demande à awk d'exécuter:

   - `action`                            sur les lignes de `file` matchant `pattern`
   - `statement1`, `statement2`, ...       "
   - `rule1`, `rule2`, ...

La partie entre single quotes est un pgm awk complet.

---

Dans un fichier awk, on sépare via un newline:

   - 2 actions consécutives                  devant agir sur un même pattern

   - 2 couples pattern / action consécutifs  devant agir sur l'input

Sur la ligne de commandes, on peut remplacer les newlines par des points-virgules.

---

    $ awk '{ print $1 }; /M/ { print $2 }' /tmp/emp.data
    Beth˜
    Dan˜
    Kathy˜
    Mark˜
    5.00˜
    Mary˜
    5.50˜
    Susie˜

Dans cet  exemple, la  sortie de awk  mélange des prénoms  et des  nombres. À
chaque fois  qu'un record est traité,  son premier champ est  affiché.  Son 2e
champ l'est aussi, mais uniquement si le record contient le caractère M.

Illustre qu'awk n'itère qu'une seule fois  sur les records.  Pour chacun d'eux,
il exécute toutes les règles pattern-action pour lesquelles le pattern matche.

IOW, awk  itère d'abord sur les  records, et seulement ensuite  sur les règles
pattern-action.

---

    $ awk 'rule' file1 file2

Traite les fichiers `file1` et `file2` en exécutant le code contenu dans `rule`;
illustre que l'input n'est pas limité à un fichier.

## Opérateurs

    x % y

Retourne le reste dans la division euclidienne de x par y.

---

    ++i    i++
    --j    j--

Incrémente `i` et décrémente `j`.

Illustre que les opérateurs `++` et `--` peuvent être utilisés en préfixe ou
en suffixe.

---

    expr1 && expr2    expr1 &&
                      expr2

    expr3 || expr4    expr3 ||
                      expr4

`expr2` n'est pas évaluée si `expr1` est fausse.
`expr4` " si `expr3` est vraie.

En effet:

   - `expr1` FAUX ⇒ `expr1 && expr2` FAUX (peu importe la valeur de vérité de `expr2`)
   - `expr3` VRAI ⇒ `expr3 || expr4` VRAI (" `expr4`)


L'évaluation d'une  expression logique se fait  de la gauche vers  la droite, et
s'arrête dès que awk connait sa valeur de vérité.


Toute expression évaluée en:

   - 0                    est considérée comme fausse
   - un nombre non nul    est considérée comme vraie

---

    a[++i]
    a[1]++
    i = ++n
    while (++i < 5)

Incrémente:

   - `i` puis cherche le i-ième élément de `a`
   - l'élément de `a` d'indice 1
   - `n` puis l'affecte à `i`
   - `i` tant qu'il est strictement inférieur à 5 (1 → 4)

Illustre que `++`  et `--` peuvent être utilisés dans  des expressions utilisant
d'autres opérateurs.

---

    ┌──────────────────────────┬───────────┐
    │ déclaration              │ affichage │
    ├──────────────────────────┼───────────┤
    │ a[++i] = 4; print a[1]   │ 4         │
    │ a[i++] = 4; print a[0]   │ 4         │
    ├──────────────────────────┼───────────┤
    │ print ++a[0]; print a[0] │ 1, 1      │
    │ print a[0]++; print a[0] │ 0, 1      │
    ├──────────────────────────┼───────────┤
    │ n = ++i; print n         │ 1         │
    │ n = i++; print n         │ 0         │
    ├──────────────────────────┼───────────┤
    │ while (++i <= 2)         │ 1, 2      │
    │     print i              │           │
    │                          │           │
    │ while (i++ <= 2)         │ 1, 2, 3   │
    │     print i              │           │
    └──────────────────────────┴───────────┘

La position de l'opérateur `++` est importante lorsqu'elle est présente dans une
expression utilisant un autre opérateur ou avec `print`.
Dans ce  tableau, on voit que  l'autre opérateur peut être  une comparaison, une
affectation ou un indexage.

`++` doit être traité:

   - avant l'autre opérateur ou print qd il est en préfixe
   - après "                                       suffixe

Tout ceci est valable pour `--` également.

---

    for (i in a)
        if (a[i] ~ /^...$/)
            b[++n] = a[i]

Calcule la  sous-array de `a`  dont tous  les éléments contiennent  exactement 3
caractères, ainsi que sa taille `n`.
L'array obtenue est `b`.

##
## Variables
### Internes
#### Tableau récapitulatif

    ┌─────────────┬──────────────────────────────────────────────────────────────────────────────────┐
    │ ARGC        │ nb d'arguments sur la ligne de commande + 1                                      │
    │             │                                                                                  │
    │             │ +1 car awk est considéré comme le 1er argument                                   │
    │             │ Si awk ne reçoit aucun argument, ARGC = 1.                                       │
    │             │                                                                                  │
    │             │ Les options ne sont pas des arguments.                                           │
    │             │                                                                                  │
    │             │ Détermine jusqu'où awk lit les éléments de ARGV:                                 │
    │             │                                                                                  │
    │             │     ARGV[0] → ARGV[ARGC-1]                                                       │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ ARGIND      │ index du fichier couramment traité dans ARGV                                     │
    │             │                                                                                  │
    │             │ le 1er fichier a pour index 1                                                    │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ ARGV        │ array contenant les arguments sur la ligne de commande (exclue les options)      │
    │             │                                                                                  │
    │             │ Permet d'accéder aux noms des fichiers de l'input.                               │
    │             │ Les éléments de ARGV sont indexés à partir de 0, et le 1er élément est 'awk'.    │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ ENVIRON     │ array contenant les valeurs des variables d'environnement du shell               │
    │             │                                                                                  │
    │             │ les indices sont les noms de ces dernières:                                      │
    │             │                                                                                  │
    │             │     print ENVIRON["HOME"]="/home/username"                                       │
    │             │                                                                                  │
    │             │ changer une valeur de l'array n'a aucun effet sur les processus shell            │
    │             │ qu'awk peut lancer via `system()` ou une redirection                             │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ FILENAME    │ nom du fichier courant (celui traité actuellement)                               │
    │             │                                                                                  │
    │             │ Mise à jour à chaque fois qu'un nouveau fichier est lu.                          │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ FNR/NR      │ index du record courant au sein du fichier / de l'input                          │
    │             │                                                                                  │
    │             │ Incrémentées avant chaque traitement d'un record du fichier                      │
    │             │ courant / de l'input.                                                            │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ FS/OFS      │ chaîne dont la valeur est utilisée comme un séparateur de champs dans            │
    │             │ l'input / output                                                                 │
    │             │                                                                                  │
    │             │ Valeur par défaut: " "                                                           │
    │             │                                                                                  │
    │             │ Même si la valeur par défaut est un espace, awk considère n'importe quelle       │
    │             │ séquence d'espaces et/ou de TABs et/ou de newlines comme un séparateur entre     │
    │             │ 2 champs.                                                                        │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ RS/ORS      │ chaîne dont la valeur est utilisée comme séparateur de records de                │
    │             │ l'input / output                                                                 │
    │             │                                                                                  │
    │             │ Valeur par défaut: "\n"                                                          │
    │             │                                                                                  │
    │             │ Jamais mises à jour.                                                             │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ IGNORECASE  │ Par défaut, toutes les opérations manipulant des chaînes sont sensibles          │
    │             │ à la casse:                                                                      │
    │             │                                                                                  │
    │             │            - comparaisons de chaînes (==, !=, <, >, <=, >=) et de regex (~, !~)  │
    │             │            - division en champs                                                  │
    │             │            - séparation des champs                                               │
    │             │            - gsub(), index(), match(), split(), ...                              │
    │             │                                                                                  │
    │             │ Mais si on donne une valeur non nulle à cette IGNORECASE, elles deviennent       │
    │             │ insensibles.                                                                     │
    │             │                                                                                  │
    │             │ Exception:                                                                       │
    │             │ les indices d'arrays ne sont pas affectés (sauf avec `asort()` et `asorti()`).   │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ NF          │ nb de champs sur le record courant                                               │
    │             │                                                                                  │
    │             │ Mise à jour avant chaque traitement d'un record,                                 │
    │             │ ET à chaque fois que $0 change OU qu'un nouveau champ est créé.                  │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ OFMT        │ format à respecter qd:                                                           │
    │ CONVFMT     │                                                                                  │
    │             │     - un nb est affiché sans conversion en chaîne:    print 1.23456789           │
    │             │     - un nb est converti en chaîne:                   print 1.23456789 ""        │
    │             │                                                                                  │
    │             │ Valeur par défaut: "%.6g"                                                        │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ RLENGTH     │ longueur d'une sous-chaîne matchée par `match()`                                 │
    │             │                                                                                  │
    │             │ Vaut -1 s'il n'y pas de match.                                                   │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ RSTART      │ index du 1er caractère d'une sous-chaîne matchée par `match()`                   │
    │             │                                                                                  │
    │             │ Vaut 0 s'il n'y pas de match.  Implique que l'index du 1er caractère est 1       │
    │             │ et non 0.                                                                        │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ RT          │ RS peut être un caractère ou une regex.                                          │
    │             │ Si c'est une regex, le texte qu'elle matche peut changer d'un record à un autre. │
    │             │ awk peuple la variable RT (Record Terminator) avec ce match.                     │
    │             │                                                                                  │
    │             │ RT vaut toujours "" sur le dernier record.                                       │
    │             │                                                                                  │
    │             │ RT est mise à jour pour chaque record.                                           │
    ├─────────────┼──────────────────────────────────────────────────────────────────────────────────┤
    │ SUBSEP      │ séparateur à utiliser pour concaténer 2 indices consécutifs d'une array          │
    │             │ multi-dimensionnelle                                                             │
    │             │                                                                                  │
    │             │ Mnémotechnique:    SUBscript SEParator                                           │
    │             │                    ^                                                             │
    │             │                    indice d'une array                                            │
    │             │                                                                                  │
    │             │ Valeur par défaut: "\034"                                                        │
    │             │ Il est peu vraisemblable qu'on trouve ce caractère dans un indice,               │
    │             │ raison pour laquelle il a été choisi.                                            │
    └─────────────┴──────────────────────────────────────────────────────────────────────────────────┘

#### `ARGC`, `ARGV`

          ┌─────────────────────────────┐
          │ BEGIN {                     │
          │     FS      = ":"           │
          │     ARGV[1] = "/etc/passwd" │
          │     ARGC++                  │
          │ }                           │
          │ { print $2, $4, $6 }        │
          └─────────────────────────────┘
               │
               v
    $ awk -f progfile <<<''

Affiche les champs 2, 4 et 6 de `/etc/passwd`.

La déclaration `ARGC++` est nécessaire.
Sans elle, awk n'ajouterait pas `/etc/passwd` à son input.
En effet, il lit les éléments de `ARGV` uniquement jusqu'à l'index `ARGC - 1`.
Or, ici, `ARGC`  = 1, donc `ARGC -  1 = 0` et  awk ne lit que le  1er élément de
`ARGV` ('awk').

Illustre que  pour accroître l'input,  il ne suffit  pas d'ajouter un  élément à
`ARGV`, il faut aussi incrémenter `ARGC`.

---

    BEGIN { ARGV[2] = "" }
      ou
    BEGIN { delete ARGV[2] }

Supprime le 2e fichier de l'input.

Qd awk rencontre une  chaîne vide dans `ARGV`, il passe  au prochain élément, et
continue jusqu'au `(ARGC-1)`ième.

Illustre qu'en  changeant le contenu de  `ARGV` dans une règle  `BEGIN`, on peut
modifier l'input.

---

    awk -f progfile 42
               │
      ┌───────────────────────┐
      │ BEGIN {               │
      │     myvar   = ARGV[1] │
      │     ARGV[1] = "-"     │
      │ }                     │
      └───────────────────────┘

Illustre comment manuellement ajouter l'entrée standard à l'input d'awk.

Dans cet exemple, on veut passer à awk un argument numérique tout en lui faisant
lire son entrée standard.

Malheureusement,  tout argument  suivant  les options  est  interprété comme  un
fichier, et redirige l'input d'awk vers lui.
Pour résoudre  ce problème,  on peut remplacer  `ARGV[1]` qui  initialement vaut
`42` par la valeur spéciale `"-"`.


Si awk ne  reçoit aucun fichier en  argument, dit autrement si  `ARGV` n'a qu'un
seul élément (`ARGC = 1`, `ARGV[0]  = 'awk'`), il lit automatiquement son entrée
standard, qui est connectée soit au clavier soit à un pipe.

#### `FS`, `RS`, `OFS`, `ORS`, `NR`

    ┌─────────────────────────────────┐    ┌─────────────────────────────────┐
    │ BEGIN { FS = "\\."; OFS = "|" } │    │ This.old.house.is.a.great.show. │
    │ {                               │    │ I.like.old.things.              │
    │     $(NF + 1) = ""              │    └─────────────────────────────────┘
    │     print                       │      │
    │ }                               │      │
    └─────────────────────────────────┘      │
                                 │           │
                                 v           v
                       ┌─────────────────────────┐       ┌──────────────────────────────────┐
                       │ awk -f pgm.awk     data │──────>│ This|new|house|is|a|great|show|| │
                       └─────────────────────────┘       │ I|like|new|things||              │
                                                         └──────────────────────────────────┘


Dans  cet exemple,  la valeur  de  `FS` est  interprétée comme  une regex  "\\."
décrivant un point littéral.
Plus généralement, les valeurs de `FS` et `RS` sont interprétées comme des regex
si elles contiennent plusieurs caractères; autrement littéralement:

    FS = "\\."    ⇔    FS = "."
    RS = "\\."    ⇔    RS = "."

Les valeurs de `OFS` et `ORS` sont toujours littérales.

---

    BEGIN { RS = "_"; ORS = "|" }
          { print }

Effectue la transformation suivante:

    I_like_old_things.    →    I|like|old|things.
                               |

Illustre que le remplacement de `RS` par `ORS` est automatique et inconditionnel.


On remarque un pipe sous le `I`, sur une 2e ligne.
awk  considère  qu'il  y  a  un  “record  terminator“  (`RT`)  entre  2  records
consécutifs, mais aussi après le dernier record.

From the gawk user's guide, `4.1.1 Record Splitting with Standard awk`, page 63:

   > Reaching the end of  an input file terminates the current  input record, even if
   > the last character in the file is not the character in RS.

`RT` est décrit par le caractère / la regex contenu(e) dans `RS`.

Sur le dernier record d'un input, `RT = ""` peu importe la valeur de `RS`.
Awk remplace le dernier `RT` (`""`) par `ORS`.

Par contre,  pourquoi awk  semble ajouter  un newline  après le  dernier record,
alors que `ORS` n'en contient pas?

    I|like|old|things.
    |

    vs

    I|like|old|things.|

Car il y  a toujours un newline  à la fin d'un  fichier / ou de  la sortie d'une
commande shell.

    $ echo '' >/tmp/file
    $ xxd -p /tmp/file
    0a˜

    $ echo '' | xxd -p
    0a˜

Donc, sur le dernier  record de l'input ou d'un fichier,  ce newline fait partie
du record, et awk ajoute `ORS` *après*.

---

    ┌────────────────────┐  ┌────────────────┐
    │ BEGIN { FS = ":" } │  │ ::foo:bar:baz: │
    │       { print NF } │  └────────────────┘
    └────────────────────┘       │
                      │          │
                      v          v
            ┌─────────────────────────┐
            │ awk -f pgm.awk    data  │
            └─────────────────────────┘

Affiche 6, car awk considère qu'il y a 6 champs.

    ::foo:bar:baz:

En plus de `foo`, `bar` et `baz`, awk divise le début du record `::` en 2 champs
vides, et la fin `:` en un champ vide.

Plus généralement, qd awk divise un record, il génère un champ vide:

   - s'il rencontre 2 délimiteurs consécutifs
   - si le début du record commence par un délimiteur
   - si la fin du record se termine par un délimiteur


Exception:

Qd `FS = " "`, awk ignore les espaces et tabs au début et à la fin d'un record.
`" "` n'est pas un simple espace, c'est une valeur spéciale pour `FS`.

### Fields

    $ awk '{ print ($1 < $2) }' <<<'31 30'
    0˜

    $ awk '{ print ($1 < $2) }' <<<'31 3z'
    1˜

Ces 2 commandes  illustrent que lorsqu'un champ est numérique,  awk affecte à la
variable correspondante une valeur numérique et une valeur chaîne.

En effet, dans la 1ère commande, le test échoue, ce qui prouve que les valeurs
de `$1` et `$2` étaient des nombres, et pas des chaînes.  Dans la 2e commande,
le test réussit, ce qui prouve que, cette fois, les valeurs sont des chaînes.

Qd l'opérateur de comparaison travaille sur  des opérandes dont au moins une des
valeurs est numérique, il fait une comparaison numérique (commande 1).

Mais,  si  l'un  des  opérandes  n'a aucune  valeur  numérique,  il  fait  une
comparaison de chaînes, quitte à faire une coercition si besoin.  C'est ce qui
se  passe dans  la commande  2, où  le 2e  champ n'a  pas de  valeur numérique
(`3z`).

---

    $2 = ""; print

Affiche les records en effaçant le 2e champ.

Illustre qu'on peut se  servir de la variable `$i` pour  changer le contenu d'un
champ.


Plus  généralement, une  même  expression nous  permet d'accéder  à  la fois  en
lecture et en écriture à certaines variables (`$1`, `NR`, ...).
Certaines, pas toutes; on ne peut pas modifier `FILENAME`.

Pour rappel, on accède à une variable en:

   - écriture qd elle se trouve dans le côté gauche de l'affectation
   - lecture  "                              droit  "

---

    !$1
    ($1)++

Inverse (au sens logique) / Incrémente la valeur du 1er champ.
