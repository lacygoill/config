# ?

Press `vis"` while the cursor is where the bar is:

    " foo
    b|ar
    " baz

It should select the sandwich.  It doesn't.
Same issue with `vis'` and:

    ' foo
    b|ar
    ' baz

# ?

Read this (taken from vim-surround note), and try to reimplement it:

    Au moment d'encadrer un text-object, on peut également interroger
    l'utilisateur via un prompt pour lui permettre d'insérer une chaîne de
    caractères arbitraire:

            let g:surround_108 = "\1Enter sth: \1 \r \1\1"

    `\r` permet de se référer au texte à remplacer (un peu comme & dans une
    substitution).
    Le prompt sera peuplé avec ’Enter sth: ’, et la chaîne saisie sera insérée
    entre chaque paire consécutive de `\1 … \1`.
    On ne peut pas se référer plusieurs fois au texte d'origine.
    IOW, on ne peut pas utiliser plusieurs fois `\r`.
    Le 1er sera bien remplacé par le text-object d'origine.  Mais les autres
    seront traduits en CR littéraux.
    Il est nécessaire d'utiliser des doubles quotes.
    On peut utiliser jusqu'à 7 input différents:

            let g:surround_108 = "\1Enter sth: \1 \r \2And sth else: \2"

    Ajouter des exemples …
    https://stackoverflow.com/a/47401509/8243465



    Furthermore, one can specify a regular expression substitution to apply.

          let g:surround_108 = "\\begin{\1environment: \1}\r\\end{\1\r}.*\r\1}"
          let g:surround_108 = "\1Enter sth: \1 \r \1\r}.*\r\1"

    This will remove anything after the first } in the input when the text is
    placed within the \end{} slot.  The first \r marks where the pattern begins,
    and the second where the replacement text begins.

    Les 2 derniers `\r` sont équivalents à `\zs` et `\ze`.
    Tout ce qui se situe entre eux est supprimé.

    Here's a second  example for creating an HTML <div>.  The substitution prompts
    for an id, but only adds id="" if it is non-blank.

          let g:surround_{char2nr("d")} = "<div\1id: \r..*\r id=\"&\"\1>\r</div>"

# ?

                   ↣ sdf ↢

    func(arg)    ---->    arg


                                ↣ sdf ↢
    func1(func2(func3(arg)))  ---->   func1(func2(arg))
                 ^              ↣ 2sdf, sdF ↢
                              ---->   func1(func3(arg))
                                ↣ 3sdf, 2sdF ↢
                              ---->   func2(func3(arg))


    vis_
    vas_

            Permet de cibler  un sandwich entouré par des  underscores (exclus /
            inclus).
            Fonctionne avec  n'importe quelle  autre caractère  entourant, entre
            autres:

                    _ - . : , ; | / \ * + # %

            Y compris qd le sandwich est multi-lignes.


               ↣ saio( ↢

    a                 (a)
    bb       ---->    (bb)
    ccc               (ccc)
