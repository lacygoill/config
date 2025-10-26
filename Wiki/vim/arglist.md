When you need to do some tests while editing this file, use this code:

    nnoremap cd <cmd>call <sid>study_arglist()<cr>
    function s:study_arglist() abort
        split
        args /etc/*.conf
        let g:my_stl_list_position = 2
    endfunction

---

You can switch from the local arglist to the global one with `:argg`.
How to do the reverse?
`:argl` doesn't work because it creates a new copy of the global one.
That's not what I want.  I want to get back to the old local one.

Maybe it's lost after `:argg`.
In that  case, we  might need  a mapping/command which  saves the  local arglist
before activating the global one (for a future possible restoration).

# Info
## Is the arglist a set of files?   Of buffers?

No and no.

It's a set of filepaths.

    $ vim -Nu NONE /tmp/file
    :split
    :bwipeout
    :args
    [/tmp/file]˜

In this experiment,  even after wiping the buffer `/tmp/file`,  which was stored
in the arglist, it still persists in the arglist.

##
## How to get
### the length of the currently used arglist?

    :echo argc()

### the list of entries in the currently used arglist?

    :echo argv()
             │
             └ mnemonics: vector

### the i-th entry in the currently used arglist?

    :echo argv(i)

### the id of the currently used arglist?

    :echo arglistid()

### the id of the currently used arglist in the second window?

    :echo arglistid(2)

### the id of the currently used arglist in the second window in the third tabpage?

    :echo arglistid(2,3)

##
## How to detect whether the currently used arglist is global?

The global id of a global arglist is `0`.
The global id of a local arglist is a positive integer.
So:

    if arglistid()
        " do sth with the local arglist
    else
        " do sth with the global arglist
    endif

## What can I do with the id of a local arglist?

Atm, nothing.

`arglistid()` has  no other  purpose than detecting  whether the  currently used
arglist is global.

Maybe it will change in the future:

<https://github.com/coot/vim_patches#arglistspatch>

#
# Action
## How to populate the arglist with the output of a shell command?

    :silent args `=systemlist('shell cmd')`

## How to populate the arglist with all the files in `~/.vim/after/ftplugin`?

    :args `=glob('~/.vim/after/ftplugin/*')`

#
# Issues
## Why does `:args fname` sometimes fail?

`fname` might contain some characters which are special on Vim's command-line.
To prevent their interpretations, use `fnameescape()`:

    :execute 'args ' .. fnameescape(fname)

## Why does ``:silent args `=systemlist('ls ~/.vim/after/ftplugin')` `` fail?

Because `ls(1)` returns filenames, but `:args` needs complete filepaths.

So, when `:args`  receives a filename, it completes its  path with Vim's working
directory, which  will probably lead  to a buffer  NOT associated with  any real
file.

## Why using ``:args `shell cmd` `` to populate the arglist is a bad idea?

It might not work and give an error:

    E79: Cannot expand wildcards

MRE:

    $ find /etc -name 'debconf.conf' 2>/dev/null
    /etc/debconf.conf

    :args `find /etc -name 'debconf.conf' 2>/dev/null`
    E79

Besides, if the shell command contains a  pipe, a quote, or some other character
which has a special meaning on Vim's command-line, you'll have to escape it.

You don't need to escape anything with:

    :args `=...`

#
# ?

Les commandes  qui affichent ou manipulent  le contenu de l'arglist  opèrent sur
l'arglist locale à la fenêtre qd elle existe, autrement sur l'arglist globale.

Edit: Not sure.  I think that they rather operate on the currently USED arglist.
It's different.  Because the local arglist could exist, while the commands still
operate on the global one.

Edit: In fact, maybe it was right.  Because maybe we can't get back to the local
arglist after switching to the global one.


    :args **/*.[ch]

            Peupler l'arglist avec  tous les fichiers .c ou .h  présents dans le
            dossier de travail ou l'un de ses sous-dossiers.


    :next /usr/inc**/*.h

            Peupler l'arglist avec  tous les fichiers portant  l'extension .h et
            dont le chemin commence par /usr/inc.


    :wnext

            Écrire le buffer courant de l'arglist et afficher le suivant.


    vim [--remote] $(cmd)

            Ouvrir [dans un serveur] tous les fichiers affichés par la sortie de cmd.

            Exemples de commandes shell:  $ find, $ grep

            L'ancienne arglist est remplacée par ces fichiers.

            On  peut  alors,  pex,  enregistrer une  macro  utilisant  :wn  pour
            réaliser une même tâche sur tous les fichiers de l'arglist.

            Pour ce faire, typiquement:

                    1. on débute l'enregistrement de la macro sur le 1er fichier
                       de l'arglist

                    2. on réalise une suite d'éditions sur ce dernier, on
                       enregistre avec :wn pour automatiquement passer au
                       fichier suivant

                    3. on termine l'enregistrement avant de rejouer la macro
                       autant de fois que nécessaire pour affecter tous les
                       fichiers de l'arglist


    Afficher/charger:

    ┌─────────────────────┬──────────────────────────────────────────────────────────────────────┐
    │ :args               │ les chemins stockés dans l'arglist                                   │
    ├─────────────────────┼──────────────────────────────────────────────────────────────────────┤
    │ :argument           │ l'argument courant de l'arglist                                      │
    │                     │                                                                      │
    │                     │ utile pour y revenir rapidement après avoir sauté de tag en tag pour │
    │                     │ se renseigner sur un de ses passages                                 │
    ├─────────────────────┼──────────────────────────────────────────────────────────────────────┤
    │ :3argument          │ l'argument 3 de l'arglist                                            │
    ├─────────────────────┼──────────────────────────────────────────────────────────────────────┤
    │ :next      previous │ le buffer suivant / précédent de l'arglist                           │
    │ [a         ]a       │                                                                      │
    ├─────────────────────┼──────────────────────────────────────────────────────────────────────┤
    │ :first    :last     │ le 1er / dernier buffer de l'arglist                                 │
    │ [A        ]A        │                                                                      │
    └─────────────────────┴──────────────────────────────────────────────────────────────────────┘


    :argadd %
    :$argadd %

            Ajoute le buffer courant à la fin de l'arglist.

                    - après l'argument courant

                            Ex:  si  on  a  5 buffers  dans  l'arglist,  et  que
                            l'argument courant est le 3e, le buffer courant sera
                            ajouté en 4e position

                    - à la fin de l'arglist


                                               NOTE:

            On ne change  pas de position dans l'arglist,  l'argument courant de
            l'arglist reste inchangé.

            Si  on veut  ajouter  le  buffer courant  à  l'arglist  ET en  faire
            l'argument courant, il faut exécuter:

                    :argadd % | next
                OU
                    :argedit %


    :args ## foo

            Ajoute le buffer foo à l'arglist, et trie cette dernière (:h :argadd).


    :argedit foo

            Ajouter le  fichier foo dans  l'arglist après l'argument  courant et
            l'éditer.

            Équivaut à:    :argadd foo | edit foo


    :42argadd foo

            Ajoute le fichier foo après le 42e fichier de l'arglist.


    :argadd **/*.conf

            Ajoute à l'arglist tous les  fichiers `.conf` du dossier de travail,
            et de ses sous-dossiers.


    :arglocal dir/{foo,bar,baz}.conf
    :argdo write

            Crée 3 fichiers au sein d'un même dossier, avec la même extension.

            Utile pour créer  un mapping ou commande générant  une hiérarchie de
            fichiers typique dans un nouveau projet.


    :% argdelete
    :argdelete *

            Supprimer tous les chemins de l'arglist.


    :. argdelete

            Supprimer l'argument courant de l'arglist.


    :argadd foo bar
    :argdelete foo bar

            Ajouter / supprimer les fichiers foo et bar de l'arglist.


    :% argd            → supprime l'arglist
    :bufdo argadd %    → ajoute tous les chemins des buffers dans l'arglist
    :1,999 bdelete     → décharge tous les buffers
    :argdo edit        → recharge les fichiers dont les chemins ont été sauvegardés dans l'arglist

            Renuméroter  tous  les buffers,  de  sorte  que d'éventuels  “trous“
            disparaissent.

            Ceci illustre que l'arglist n'est pas un ensemble de buffers mais un
            ensemble de chemins.

            Si  l'arglist  était un  ensemble  de  buffers,  alors quand  on  en
            supprimerait un (`:bdelete`), il disparaîtrait aussi de l'arglist, ce
            qui n'est pas le cas.


    :argdo edit!
    :argdo update
    :argdo bdelete

            Annuler toutes  les modification apportées aux  buffers de l'arglist
            depuis leur dernière sauvegarde.

            Écrire  sur  le disque  les  buffers  de  l'arglist ayant  subi  une
            modification.

            Décharger tous les buffers de l'arglist.


    :argdo :% substitute/foo/bar/ge | update

            Remplacer  toutes les  occurrences  de  foo par  bar  dans tous  les
            buffers de l'arglist  en sauvegardant à chaque fois si  une modif' a
            eu lieue.

            Équivaut à :first | :% substitute/foo/bar/ge | next | :% substitute/... | next ...

            On ajoute le flag e à la commande de substitution pour éviter qu'une
            erreur n'interrompt le processus.

            Qd on fait un refactoring sur un gd  nb de fichiers, qu'il y a un gd
            nb de buffers dans l'arglist, et  que bcp finissent par être modifié
            après  un :argdo,  il  vaut mieux  intégrer un  :update  au sein  de
            l'argdo plutôt que de finir par un :wall ou :xall (:wqall).

            En effet, l'update  est plus rapide car Vim n'a  pas besoin d'écrire
            des buffers non modifiés.


    Définir l'arglist globale/locale comme étant:

    ┌────────────────────┬─────────────────────────────────┐
    │ :argglobal %       │ le buffer courant               │
    │ :arglocal %        │                                 │
    ├────────────────────┼─────────────────────────────────┤
    │ :argglobal foo bar │ la liste de fichiers [foo, bar] │
    │ :arglocal foo bar  │                                 │
    ├────────────────────┼─────────────────────────────────┤
    │ :arglocal          │ une copie de l'arglist globale  │
    └────────────────────┴─────────────────────────────────┘

            Ceci a pour effet de recharger le buffer courant.

            Si  des  modifications n'ont  pas  été  sauvegardées, ces  commandes
            échouent sans le bang.

            Avec  le  bang,  elles  réussissent  quoi  qu'il  arrive,  mais  les
            modifications du buffer courant sont perdues.

            Elles acceptent en argument n'importe quelle liste de fichiers.


                                               NOTE:

            Quelle différence entre `argglobal file` et `args file`?

            Il  semble que  `:args` peuple  l'arglist actuellement  utilisée (la
            locale  ou  la globale),  tandis  que  `:argglobal` peuple  toujours
            l'arglist globale.

            On peut  vérifier que `:args`  peuple la locale, ssi  cette dernière
            est celle actuellement utilisée, comme ceci:

                    :split
                    :arglocal
                    :args /etc/*.conf

                    " Don't execute `:arglocal` to ask  to use the arglist, it would
                    " make a  local copy of  the global argument list,  which is
                    " empty.  In effect, it would remove the local arglist we've
                    " just populated.
                    :args
                    some filepaths˜
                    :echo arglistid()
                    7 or some other non-zero number,˜
                    and according to `:help arglistid()`:˜

                            “Zero is used for the global argument list.”˜

                    So, it means we're currently using the local arglist.˜


                    :argglobal " use the global arglist
                    :args /etc/*.conf
                    :args
                    no filepaths˜
                    :echo arglistid()
                    0˜


    argidx()

            N°  de l'argument  courant au  sein  de l'arglist  (en commençant  à
            compter à partir de 0).
            Ce n° est local à la fenêtre (sure? I think it should depend on which
            arglist is currently used: the global one or the local one).

# Todo

It would be  nice if the arglist  indicator in the status line  (`%a`) showed us
which arglist  is currently  used in each  window (the global  one or  the local
one).

---

Integrate here anything related to the arglist (`:all`, dirvish `x_x`, ...):

    noautocmd vimgrep /arglist/gj ## | cwindow

BTW, `:sall` and `:vert sall` are really  nice when your arglist doesn't contain
too many files.

---

Play with:

   - `argc()` + `argv()`
     They can now access the global arglist and the local arglist of another window:

         https://github.com/vim/vim/releases/tag/v8.1.0493

   - `getcompletion('*', 'arglist')`
     +
     `command -complete=arglist ...`


---

See our fixme in `~/.vim/pack/mine/opt/brackets/plugin/brackets.vim`.
It's about  `]a` which behaves unexpectedly  when we try to  visit an unreadable
argument (this  is due  to `:next`  – and probably  `:previous` too  – which
behaves differently inside a `try` conditional).
