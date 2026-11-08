# I have to give my password twice in 2 different screens when I resume a session after suspending the OS!

Google “suspend linux password twice”:

- <https://askubuntu.com/questions/639014/another-password-prompt-when-waking-from-suspend>
- <https://bugs.launchpad.net/bugs/1296270>
- <https://bugs.launchpad.net/bugs/1631715>

For the moment, I tried to fix the issue by running:

    $ light-locker-settings

Then disabling “Lock on suspend”.

---

IMO, this  bug illustrates  the benefits  of using a  custom and  minimalist DE.
When you'll  build your own  DE, you  probably won't install  the `light-locker`
package; maybe just the `xscreensaver` package.

See also: <https://askubuntu.com/questions/1063481/lightlocker-and-xscreensaver-conflicting>

---

Note that `light-locker` seems to have 2 purposes:

   - it can blank the screen after a certain amount of time (screensaver)
   - it can lock the session after a certain amount of time or when you suspend (session-locker)

---

You can configure `xscreensaver` by running `xscreensaver-demo(1)`.

---

We  can configure  `xscreensaver` so  that it  asks for  our password  after the
screen gets blank and a certain amount of additional time has elapsed.
But how  to configure Linux so  that it asks for  our password when we  resume a
session (after suspending it)?
We can  configure `light-locker`  to do  so, but I  don't want  to rely  on this
package because it's tied to an existing DE (XFCE/LXDE), and because it seems to
cause the issue currently discussed (double password).

Edit: I *think* the session is locked on suspend automatically:
<https://wiki.archlinux.org/title/XScreenSaver#Lock_on_suspend>

To lock it manually:

    $ xscreensaver-command --lock

How to lock it when the lid is closed (portable PC)?

See: <https://docs.xfce.org/xfce/xfce4-power-manager/preferences>

# document why `xsel(1x)` is better than `xclip(1)`

`xclip(1)` doesn't close its STDOUT.

This can make tmux unresponsive:

- <https://askubuntu.com/a/898094/867754>
- <https://wiki.archlinux.org/index.php/Tmux#X_clipboard_integration>
- <https://unix.stackexchange.com/questions/15715/getting-tmux-to-copy-a-buffer-to-the-clipboard/15716#comment349384_16405>

The archwiki link suggests to close it manually with `>/dev/null`.
It might be a known issue: <https://github.com/astrand/xclip/issues/20>

---

Closing xclip's STDOUT doesn't fix another issue where the `xclip(1)` process is
automatically terminated when we start it from Vim and quit the latter:
<https://unix.stackexchange.com/q/523255/289772>

# ?

Sync a folder between 2 computers, with a filesystem watcher so that each time a
file is modified, it is immediately replicated.
<https://unix.stackexchange.com/questions/484434/sync-a-folder-between-2-computers-with-a-filesystem-watcher-so-that-each-time-a>

---

<https://notmuchmail.org/>

---

- <https://0x0.st/>
- <https://github.com/lachs0r/0x0>

No-bullshit file hosting and URL shortening service
Read the contents of the first link to understand how to use the command.

Some examples to upload:

    # a local file
    curl -F'file=@yourfile.png' https://0x0.st

    # a remote url
    curl -F'url=http://example.com/image.jpg' https://0x0.st

    # a remote url
    curl -F'shorten=http://example.com/some/long/url' https://0x0.st

    # output of a shell command
    command | curl -F'file=@-' https://0x0.st

We've  implemented a  `:Share` command  in `vim-unix`  which leverages  this web
service.  Select some text, and  execute `:'<,'>Share`, or just execute `:Share`
while in a file.

---

<https://superuser.com/a/602298>

Is  there a  colorizer utility  that  can take  command output  and colorize  it
accordingly to pre-defined scheme?

Also, see this: <https://github.com/garabik/grc>

See also `ccze(1)`:

    $ sudo apt install ccze
    $ ccze -A </var/log/boot.log

---

- <https://beyondgrep.com/feature-comparison/>
- <https://rentes.github.io/unix/utilities/2015/07/27/moreutils-package/>

---

- <https://www.reddit.com/r/linux/comments/21rm3o/what_is_a_useful_linux_tool_that_you_use_that/>
- <https://www.reddit.com/r/linux/comments/mi80x/give_me_that_one_command_you_wish_you_knew_years/>
- <https://www.reddit.com/r/linux/comments/389mnk/what_are_your_favourite_not_well_known_cli/>

---

What is a bitmask and a mask?
<https://stackoverflow.com/a/31576303>

---

<https://www.booleanworld.com/guide-linux-top-command/>
Guide for `top(1)`.

##
# Utilities to check out
## bubblewrap

It seems to be an alternative to  `chroot(8)` (although, it might not be able to
run a privileged process).  For more info:

   - `man bwrap`
   - `/usr/share/doc/bubblewrap/README.md.gz`
   - `/usr/share/doc/bubblewrap/examples/bubblewrap-shell.sh`

I don't know how to run a bash interactive shell with `chroot(8)`.
But I can using the example script (just replace `/bin/sh` with `/bin/bash`).

## character encoding conversion
### `convmv(1)`

Convert file names (!= file contents) from one character encoding to another.

The use of this tool is relatively simple, but you might want do it in two steps
to  avoid surprises.   The  following example  illustrates  a UTF-8  environment
containing directory names encoded in ISO-8859-15, and the use of `convmv(1)` to
rename them:

    $ ls travail/
    Ic?nes  ?l?ments graphiques  Textes

    $ convmv -r -f iso-8859-15 -t utf-8 travail/
    Starting a dry run without changes...
    mv "travail/�l�ments graphiques"        "travail/Éléments graphiques"
    mv "travail/Ic�nes"     "travail/Icônes"
    No changes to your files done. Use --notest to finally rename the files.

    $ convmv -r --notest -f iso-8859-15 -t utf-8 travail/
    mv "travail/�l�ments graphiques"        "travail/Éléments graphiques"
    mv "travail/Ic�nes"     "travail/Icônes"
    Ready!

    $ ls travail/
    Éléments graphiques  Icônes  Textes

### `recode(1)`

Allow automatic  recoding for simple  text files.  For  more info, read  the man
page,  or the  info  page  which is  more  complete.  Alternatively,  `iconv(1)`
supports more character sets, but has less options.

### Write a "fix: ..." navi snippet for issues where unexpected characters appear in text

Document the issues in more detail:

If  a French  text appears  normal with  the exception  of accented  letters and
certain symbols  which appear to be  replaced with sequences of  characters like
“Ã©”, “Ã¨”  or “Ã§”, it  is probably  a file encoded  as UTF-8
but  interpreted as  ISO-8859-1  or ISO-8859-15.   This  is a  sign  of a  local
installation that has not yet been migrated to UTF-8.

If, instead,  you see  question marks  instead of accented  letters —  even if
these question marks seem to also  replace a character that should have followed
the  accented  letter  —  it  is likely  that  your  installation  is  already
configured for UTF-8 and  that you have been sent a  document encoded in Western
ISO.

---

Make the snippet recommend tools like `convmv(1)`, `iconv(1)`, `recode(1)`.

---

Not sure  whether `recode(1)`/`iconv(1)` can work  on any file (not  just simple
text).  If the file format includes encoding information, it might be sufficient
to open  the file with the  appropriate software.  Otherwise, you  might need to
specify  the  original  encoding  when opening  the  file  (e.g. ISO-8859-1  aka
“Western”, or ISO-8859-15  aka “Western (Euro)”).  In both  case, try to
re-save the file specifying UTF-8 encoding.

##
## Links

    https://github.com/learnbyexample/Command-line-text-processing

            From finding text to search and replace, from sorting to beautifying text and more


    https://aptitude.alioth.debian.org/doc/en/ch02s04s03.html

            Manuel aptitude.  Intéressant pour apprendre à affiner nos recherches de paquets.


    https://github.com/gotbletu/dotfiles

            Dotfiles de Gotbletu.
            La page README est intéressante car Gotbletu y mentionne les principaux programmes qu'il utilise.
            Elle mentionne aussi comment il restaure la configuration des ses programmes.


    https://www.reddit.com/r/commandline/comments/6hnygr/going_full_command_line_what_are_some_underrated/

            Reddit thread titled:
            Going full command-line.  What are some underrated yet extremely useful Terminal packages?

    https://inconsolation.wordpress.com/index/
    https://inconsolation.wordpress.com/index-l-z/

            Blog reviewing obscure and underrated terminal packages.


    https://kmandla.wordpress.com/software/

            K.Mandla's blog of Linux experiences

## curl

`curl` accept plusieurs arguments.  En voici quelques-uns:

    -f, --fail

            Échoue silencieusement en cas d'erreurs côté serveur.
            Utile pour ne pas dl une page d'erreur expliquant pourquoi le document est inaccessible.
            `curl` retourne alors le code d'erreur 22.
            Ne fonctionne pas tjrs.  En particulier qd l'échec vient d'une erreur d'authentification (401 et 407).


    -L, --location

            Si le serveur répond que la page demandée a changé d'emplacement, `curl` redemandera la page
            à la nouvelle adresse.


    -o, --output <file>

            Écrit dans <file> au lieu de la sortie standard.

            See  also  the  --create-dirs  option  to  create  the  local  directories  dynamically.


    -o </path/to/file> --create-dirs

            Si certains dossiers de `/path/to/file` n'existent pas sur la machine locale,
            `--create-dirs` les créera.


    curl -fLo /path/to/file --create-dirs url

            Télécharge la page présente à l'adresse url, dans le fichier `/path/to/file` en créant
            les dossiers manquant si besoin, silencieusement (-f), et en suivant les changements
            d'emplacement (-L).

## grep

    $ tee file <<-'EOF'
	toto
	root
	video
    EOF

    grep --fixed-strings --file=file /etc/group

            Affiche les lignes de `/etc/group` contenant une des lignes de `file`.
            La comparaison est littérale grâce à `--fixed-strings`.

            `--file=file` a pour effet de générer le pattern:

                    'line1\|line2\|...'

            ... où `line1`, `line2` ... sont les lignes de `file`.

                                               NOTE:

            On a  préfixé le délimiteur EOF  avec `-` pour que  bash supprime
            les leading tabs.  Sans lui,  le pattern généré par `--file=file`
            ne serait pas `toto\|root\|video` mais ` toto\|	root\|	video`.

            `-` ne supprime que des leading tabs, pas d'espaces.

## ls

     ┌─────────────────────┬─────────────────────────────────────────────────────────┐
     │ ls -1               │ une seule entrée par ligne                              │
     ├─────────────────────┼─────────────────────────────────────────────────────────┤
     │ ls -A               │ n'affiche pas les entrées `.` et `..`                   │
     │                     │                                                         │
     │                     │ -A = --almost-all                                       │
     ├─────────────────────┼─────────────────────────────────────────────────────────┤
     │ ls -b               │ affiche une séquence d'échappement pour représenter     │
     │                     │ un caractère non graphique                              │
     ├─────────────────────┼─────────────────────────────────────────────────────────┤
     │ ls -C | less        │ liste les entrées par colonnes et pipe la sortie        │
     │                     │ de `ls` vers `less`                                     │
     │                     │                                                         │
     │                     │ par défaut, qd on redirige la sortie de `ls` vers       │
     │                     │ `less`, `ls` affiche les entrées par lignes (`-1`)      │
     │                     │ `-C` l'oblige à afficher par colonnes                   │
     ├─────────────────────┼─────────────────────────────────────────────────────────┤
     │ ls -F               │ ajoute un indicateur à la fin de chaque entrée          │
     │                     │ correspondant à son type                                │
     │                     │                                                         │
     │                     │         @ = lien symbolique                             │
     │                     │         / = dossier                                     │
     │                     │         * = exécutable                                  │
     │                     │                                                         │
     │                     │ -F = --classify                                         │
     ├─────────────────────┼─────────────────────────────────────────────────────────┤
     │ ls -Gg              │ long listing (comme `-l`), mais sans le nom du          │
     │                     │ proprio ni celui du groupe                              │
     ├─────────────────────┼─────────────────────────────────────────────────────────┤
     │ ls -p               │ ajoute un slash après les noms des dossiers             │
     ├─────────────────────┼─────────────────────────────────────────────────────────┤
     │ ls -lt              │ long listing, en triant par date (`-t`)                 │
     ├─────────────────────┼─────────────────────────────────────────────────────────┤
     │ ls -X               │ tri par extension                                       │
     │                     │                                                         │
     │                     │    les .avi avant les .mp4                              │
     │                     │ et les .mp4 avant les .txt                              │
     ├─────────────────────┼─────────────────────────────────────────────────────────┤
     │                     │ trie en fonction de la date de:                         │
     │                     │                                                         │
     │ ls -lt --time=mtime │     dernière modification du contenu                    │
     │ ls -lt --time=ctime │                           du contenu ou des métadonnées │
     │ ls -lt --time=atime │     dernier accès en lecture                            │
     ├─────────────────────┼─────────────────────────────────────────────────────────┤
     │ ls *                │ liste tout: fichiers, dossiers, et leurs contenus       │
     ├─────────────────────┼─────────────────────────────────────────────────────────┤
     │ ls */               │ liste les dossiers et leurs contenus                    │
     │                     │                                                         │
     │                     │ le slash empêche le scan des fichiers à la RACINE       │
     │                     │ du dossier courant, mais il n'empêche pas               │
     │                     │ l'affichage des fichiers des sous-dossiers              │
     ├─────────────────────┼─────────────────────────────────────────────────────────┤
     │ ls -d */            │ liste les dossiers mais pas leurs contenus              │
     │                     │                                                         │
     │                     │ `-d` empêche le scan du contenu des dossiers            │
     └─────────────────────┴─────────────────────────────────────────────────────────┘

                                               NOTE:

            touch $'foo\nbar'; ls       →    foo?bar
                               ls -b    →    foo\nbar    # `-b` permet de représenter un caractère non graphique

            touch foo\ bar; ls          →    foo bar
                            ls -b       →    foo\ bar    # les espaces sont également échappés par `-b`


                                               NOTE:

            La plupart du temps, les dossiers n'ont  pas d'extension, `ls -X` est donc pratique pour
            séparer rapidement les  dossiers des fichiers.  Attention, un dossier  peut malgré tout
            avoir une extension (`ls -X /etc`), comme par exemple `folder.d` ou `folder.conf`.

## node

    gcc and g++ 4.9.4 or newer
    Python 2.6 or 2.7
    GNU Make 3.81 or newer

            Dépendances pour pouvoir compiler `node` sous Linux.


    https://github.com/nodejs/LTS/

            Page listant les différentes version du programme.
            Chercher la version LTS active la plus récente.  ATM, c'est `6.11.0`.
            On va se servir de ce n° de version dans une commande `git checkout`.


    https://github.com/nodejs/node/blob/master/BUILDING.md#building-nodejs-on-supported-platforms

            Description de la procédure de compilation.


                                               NOTE:

            On peut télécharger un binaire précompilé, ici:

                    https://nodejs.org/en/download/

            Toutefois, je n'ai pas réussi à l'utiliser / installer correctement.
            Si on utilise cette méthode d'installation, penser à vérifier la signature du binaire.

            Au passage, on peut utiliser ce lien pour confirmer le n° de version de la LTS la plus récente.


                                               NOTE:

            Il semble qu'on puisse aussi installer le programme via `apt`:

                    https://nodejs.org/en/download/package-manager/

                    curl -sL https://deb.nodesource.com/setup_6.x | sudo --preserv-env bash -
                    sudo apt install -y nodejs

            À utiliser éventuellement, si la compilation échoue ou prend trop de temps.


    $ git clone https://github.com/nodejs/node/
    $ cd node
    $ git checkout v6.11.0
    $ ./configure
    $ make
    $ make test
    $ make doc
    $ man doc/node.1 (test)
    $ ./node -e "console.log('Hello from Node.js ' + process.version)"
    Hello from Node.js v6.11.0   (test)˜
    $ sudo make install

            Procédure d'installation.


                                               NOTE:

            `node` est un très gros projet:

                    % du -sh ~/VCS/node
                    751M    /home/user/VCS/node

            La compilation peut prendre beaucoup de temps, et consommer pas mal de ressources (mémoire et cpu).

            Pour accélérer la compilation on peut passer le flag `-j` à `make`, pour lui demander d'exécuter
            plusieurs jobs simultanément:

                    make -j4
                           │
                           └ 4 jobs

            Toutefois, ça augmente la consommation de ressources de manière drastique. À éviter sur une machine
            peu puissante.  Voici ce que rapporte la commande `make -j4` sur ma machine atm:

                    make -j4  2160.75s user 97.62s system 363% cpu 10:21.56 total
                                                                   ├────────────┘
                                                                   └ temps pris par la compilation

            On constate qu'elle a augmenté la charge cpu à 363%, et pris 10 minutes et 21 secondes.
            Si on avait réduit le nombre de jobs, la compilation aurait sans doute pris
            beaucoup plus de temps, mais consommé beaucoup moins de ressources.

            Conseil: bite the bullet, et n'utiliser qu'un seul job (`make` sans `-j`).

## parallel  xargs

    https://www.youtube.com/watch?v=OpaiGYxkSuQ
    https://www.gnu.org/software/parallel/parallel_tutorial.html


    cd /var/cache/apt/archives/
    sudo apt download parallel
             ^------^
             dl le `.deb` dans le répertoire courant

    sudo dpkg --force-conflicts --install parallel Tab (*)
              ^---------------^
              [!] conflicts    Allow installation of conflicting packages
              description trouvée via `dpkg --force-help`

    sudo /var/lib/dpkg/status
      chercher `package: moreutils`, et supprimer la ligne `conflicts: moreutils` qui suit


            Procédure d'installation du paquet `parallel`, si `moreutils` est déjà présent sur le système.

            Il y a un conflit entre la version du binaire `parallel` présent dans `moreutils`, et
            celle fournie par le paquet `parallel`.

            (*) Tab pour compléter le nom du paquet.  Ex:

                    parallel  →  parallel_20141022+ds1-1_all.deb

            Messages importants pendant l'installation de `parallel`:

                    dpkg: warning: ignoring conflict, may proceed anyway!
                    ...
                    Adding 'diversion of /usr/bin/parallel to /usr/bin/parallel.moreutils by parallel'
                    Adding 'diversion of /usr/share/man/man1/parallel.1.gz to
                                         /usr/share/man/man1/parallel.moreutils.1.gz by parallel'

            Une diversion consiste à déplacer un fichier qd il est en conflit avec un autre lors d'une
            installation.  Elle est réalisée par `dpkg-divert`.
            On peut lister toutes les diversions ayant été réalisées sur le système, et par quels programmes:

                    dpkg-divert --list

            Une fois qu'on a installé une diversion pour un fichier donné, tout paquet le fournissant
            l'installera dans un nouvel endroit, avec un autre nom si désiré.
            Il ne s'agit donc pas d'un simple déplacement, car on informe tout le système que ce déplacement
            doit être répété à chaque installation / mise à jour d'un paquet fournissant le fichier.


            J'ai trouvé toute cette procédure ici:
                    https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=749355;msg=110


            La dernière édition est nécessaire pour empêcher `apt-get` et `aptitude` de se plaindre
            qd on fait une màj:

                    $ sudo aptitude upgrade
                    Unable to resolve dependencies for the upgrade: no solution found.˜
                    Unable to safely resolve dependencies, try running with --full-resolver.˜

                    $ sudo apt-get upgrade
                    You might want to run 'apt-get -f install' to correct these.˜
                    The following packages have unmet dependencies:˜
                    parallel: Conflicts: moreutils but 0.57-1 is installed˜
                    E: Unmet dependencies.  Try using -f.˜


            Il semble que bientôt (?) la procédure ne sera plus utile, car tout ceci sera fait automatiquement
            par le système:

                    https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=749355#133

## renommage

    touch image{1..9}.png
    for f in *.png; do mv "$f" "${f#image}"; done

            Renomme toutes les images du dossier courant:

                    image1.png  →  1.png
                    ...
                    image9.png  →  9.png

            Illustre  la syntaxe  `${parameter#word}`  décrite  dans `man  bash`
            (’parameter expansion’).
            Cette dernière permet de supprimer  un préfixe dans le développement
            d'un paramètre.
            Ici, `parameter = f` et `word = image`.


                                               NOTE:

            `word` est développé avant `parameter` pour produire un pattern.
            Il existe d'autres syntaxes similaires:

                    ┌───────────┬────────────────────────────────────────────────┐
                    │ ${f#p}    │ supprime le plus court préfixe matchant `p`    │
                    ├───────────┼────────────────────────────────────────────────┤
                    │ ${f##p}   │ supprime le plus long préfixe matchant `p`     │
                    ├───────────┼────────────────────────────────────────────────┤
                    │ ${f%p}    │ supprime le plus court suffixe matchant `p`    │
                    ├───────────┼────────────────────────────────────────────────┤
                    │ ${f%%p}   │ supprime le plus long suffixe matchant `p`     │
                    └───────────┴────────────────────────────────────────────────┘

                    ┌───────────┬────────────────────────────────────────────────┐
                    │ ${f/p/r}  │ remplace la 1e occurrence de `p` par `r`       │
                    ├───────────┼────────────────────────────────────────────────┤
                    │ ${f//p/r} │ remplace toutes les occurrences de `p` par `r` │
                    ├───────────┼────────────────────────────────────────────────┤
                    │ ${f/#p/r} │ remplace le préfixe matchant `p` par `r`       │
                    ├───────────┼────────────────────────────────────────────────┤
                    │ ${f/%p/r} │ remplace le suffixe matchant `p` par `r`       │
                    └───────────┴────────────────────────────────────────────────┘

            `f`, `p` et  `r` désignent resp. un paramètre (ex:  nom de fichier),
            un pattern et une chaîne de remplacement.

            Mnémotechnique:
            `#` sert à commenter une ligne, et se place donc au début (préfixe).
            `%` est utilisé à la fin du prompt par défaut de zsh (suffixe).


    touch file{1..9}.bak
    for f in *.bak; do mv "$f" "${f%.bak}"; done

            Renomme tous les fichiers backup en supprimant leur extension.

            Illustre la syntaxe `${parameter%word}`  qui supprime la plus courte
            chaîne matchée par le pattern `word`.
            `${parameter%%word}` supprime la plus longue chaîne.


    for f in .*; do mv "$f" "${f/./}"; done

            Renomme tous  les fichiers cachés  du dossier courant  en supprimant
            leur dot.
            On pourrait remplacer "${f/./}" par "${f#.}".


                                     TODO:
À terminer ...


    rename -v  'y/A-Z/a-z/'  *


    mv -i foo bar

            Renomme `foo` en `bar`.
            Si `bar` existe déjà, le flag `-i` nous demandera une confirmation avant de l'écraser.


    qmv

            Renommer toutes les entrées (fichiers/dossiers) à la racine du dossier de travail.

            Un buffer s'ouvre à l'intérieur duquel des noms d'entrées sont affichés dans 2 colonnes.
            Pour changer le nom d'une entrée, il suffit d'en éditer un dans la colonne de droite.

                    colonne de gauche = anciens noms des entrées
                    colonne de droite = nouveaux noms désirés


                                               NOTE:

            Cette commande est fournie par le paquet `renameutils`.
            Il fournit également:

                    - deurlname
                    - icp
                    - imv
                    - qcp
                    - qmv


    qmv -f do *.jpeg

            Renomme toutes les images du dossier de travail, en utilisant qu'une seule colonne (-f do).

            D'habitude, `qmv` utilise 2 colonnes, une pour afficher l'ancien nom des entrées, l'autre
            pour afficher les noms modifiés.
            Ça peut être ennuyeux qd on veut faire un renommage multiple via une substitution (:%s///g).
            En effet, dans ce cas, on risque de modifier les noms d'origine (colonne 1) ce qui empêchera
            `qmv` de reconnaître les entrées qu'on souhaite renommer: donc aucun renommage.

            `-f do` = `--format destination-only` résoud ce pb.


    qmv -R /tmp/

            Renommer toutes les entrées à l'intérieur de /tmp/.

            L'option -R permet d'explorer les sous-dossiers.


    qmv --help

            Affiche les options supportées par qmv.
            La plupart sont identiques à celles de ls.  qmv s'appuie sur ls et lui passe ces options.

                    -A    affiche toutes les entrées, mêmes cachées
                          mais n'affiche pas les entrées implicites . et .. (contrairement à -a)


    qmv --dummy

            Simule un renommage des entrées du dossier de travail.


    qcp    icp

            Semblables à qmv et imv à ceci près que leur but n'est pas de changer le nom d'entrées
            mais de faire des copies.
            Les nouveaux noms ne sont donc pas utilisés pour changer les anciens mais pour nommer des copies.


    deurlname 'foo%20bar%20baz'    →    'foo bar baz'

            `deurlname` permet de nettoyer un nom de fichier contenant des caractères encodés pour passer
            dans une url (ex: %20 pour espace, %41 pour A ...).

            Certains pgms comme w3m conservent ces caractères indésirables qd on sauvegarde des fichiers
            depuis le web.

## sort

    sort file -o file

            Trie le contenu de `file` in-place.

            Ne surtout pas faire:

                    sort file >file    ✘

            ...  car le  shell  vide  le contenu  de  `file`  lorsqu'il crée  la
            redirection `>file`.
            Il n'y  aurait donc  rien à  trier, et on  finirait avec  un fichier
            vide.


    sort -t$'\t'     -k2,2 file
    sort -t:      -b -k2,2 file

            Trie le contenu de `file` en fonction  du 2e champ des lignes, et en
            considérant le caractère tab comme le séparateur entre 2 champs.

            Idem, mais en  considérant un `:` comme séparateur de  champs, et on
            omettant d'éventuels leading whitespace au sein des champs.


                                               NOTE:

            `-b` est indispensable qd la largeur d'un des champs précédents est variable.

            Il  est  probable que,  par  défaut,  `sort`  n'utilise que  le  1er
            whitespace qu'il rencontre.
            Donc, si  2 champs sont  séparés par plusieurs whitespace,  tous ces
            derniers à l'exception  du 1er sont considérés  comme faisant partie
            du champ.

            Ex:
                    vim <(setopt ksh_option_print; unsetopt)

                    vip
                    !sort    -k2
                    ✘

                    vip
                    !sort -b -k2
                    ✔
                    trie les `off` avant les `on`


                                               NOTE:

            Par défaut, `sort`  utilise les whitespace comme  délimiteurs, et il
            ignore les leading/trailing whitespace de chaque ligne.
            Par  contre,  dès qu'on  utilise  `-t`  pour choisir  un  délimiteur
            arbitraire, `sort` n'ignore plus les leading/trailing whitespace.


                                               NOTE:

            Pk `2,2` et pas `k2` ?

            `-k2` trie  en fonction du  texte commençant  depuis le début  du 2e
            champ jusqu'à la fin de la ligne.
            `-k2,2` trie en  fonction du texte commençant depuis le  début du 2e
            champ jusqu'à la fin du 2e champ.


                                               NOTE:

            L'ordre de tri est influencé par la locale courante.
            Pour ne  pas avoir de  surprise, et si le  texte ne contient  pas de
            caractères spéciaux/accentués, utiliser la locale C:

                    LC_ALL=C sort ...

##
## sudo
### configuration

    sudo visudo -f /etc/sudoers.d/my_modifications

            Édite un fichier dans `/etc/sudoers.d/`.

            Il est conseillé d'utiliser ce dernier pour modifier le comportement de `sudo`,
            plutôt que `/etc/sudoers`.  Probablement car ce dernier est reset à chaque mise à jour
            du paquet `sudo`.

            `visudo` crée un fichier temporaire, et une fois qu'on quitte l'éditeur, il vérifie la validité
            de la syntaxe du contenu ajouté.


                                               NOTE:

            En cas de conflit entre 2 lignes, c'est celle qui arrive en dernier dans le fichier qui
            a la priorité.


                                               NOTE:

            Les droits, proprio, groupe du dossier et de ses fichiers doivent respecter certaines
            valeurs.  Atm, sous Ubuntu:

                    drwxr-xr-x  root  root  /etc/sudoers.d
                    -r--r-----  root  root  my_modifications


    Defaults    pwfeedback
    Defaults    timestamp_timeout=30

            Active l'option `pwfeedback` pour qu'un astérisque s'affiche à chaque caractère saisi
            qd `sudo` nous demande notre mdp.

            Augmente la durée pendant laquelle notre identification est mise en cache, en la faisant
            passer à 30 minutes.  Par défaut, c'est 15.

            On peut vider ce cache via `sudo -k`, ou au contraire le réinitialiser via `sudo -v`.


     ┌─ Qui ?
     │     ┌─ Où ?
     │     │    ┌─ En tant que qui ?
     │     │    │
    %admin ALL=(ALL)NOPASSWD:/usr/bin/apt update
                    │        │
                    │        └─ Quoi ?
                    └─ Comment ?

            Tous les utilisateurs du groupe admin, sur n'importe quelle machine peuvent lancer
            la commande `apt update` en tant que n'importe quel autre utilisateur sans donner de mdp.


                                               NOTE:

            Au sein de la commande, tout caractère `:`, `\`, `=` doit être échappé.


    %admin ubuntu=(ALL)NOPASSWD:/usr/bin/apt
    %admin ubuntu=(root)NOPASSWD:/usr/bin/apt

            Idem mais uniquement sur la machine dont le nom d'hôte est `ubuntu` (`hostname`).
            Idem mais uniquement en tant que root.


                                                    ┌─ pas d'espace après la virgule
                                                    │
    %admin ubuntu=(root)NOPASSWD:/usr/bin/apt update,/usr/bin/apt upgrade

            Idem mais uniquement pour les commandes `apt update` et `apt upgrade`.


    %admin ubuntu=(root)NOPASSWD:/usr/bin/apt install *

            Idem mais pour toutes les commandes suivant le pattern `apt install <paquet>`.


    %admin ubuntu=(root)NOPASSWD:/*/sbin/*

            Idem mais pour toutes les commandes suivant le pattern `/*/sbin/*` comme  p.ex.
            `/usr/sbin`, `/usr/local/sbin/` ou `/home/user/sbin`.


    %admin ubuntu=(root)NOEXEC:/usr/bin/vim

            `NOEXEC` empêche d'utiliser Vim pour lancer des commandes shell, il ne pourra servir
            qu'à éditer du texte.

            Attention `NOEXEC` peut empêcher le bon fonctionnement de certaines commandes.
            Pex, `apt` peut avoir besoin de lancer un shell pour y exécuter `dpkg`.


    user ALL=(ALL) ALL

            `user` peut lancer sur n'importe qelle machine, en tant que n'importe quel utilisateur,
            n'importe quelle commande.

### utilisation

    su --login

            Se connecter en tant que root. `-l` permet de restaurer l'environnement qu'on aurait
            eu si on s'était connecté directement sans passer par le shell courant.

            Il faut fournir le mdp du compte root.

            Plus généralement, `su` permet de se connecter en tant que n'importe quel utilisateur,
            à condition de lui fournir son nom en argument.


    sudo --login

            Lance le shell de root en mode login, et en restaurant l'environnement qu'on aurait eu
            si on s'était connecté directement.

            Il faut fournir le mdp du compte courant.


                                               NOTE:

            Plus généralement, `--login` permet de:

                    - lancer le shell d'un utilisateur cible (via `--user=<user>`)

                      En son absence root est utilisé.

                    - exécuter une commande arbitraire (elle est passée au shell via `-c`; ex: `bash -c 'cmd'`)

                      En son absence, un shell interactif est lancé, avec pour répertoire de travail
                      le home de l'utilisateur cible.


    sudo --list
    sudo --list --list

            Affiche la politique de sécurité définie dans `/etc/sudoers` relative à l'utilisateur courant.
            `--list --list` utilise un format d'affichage plus long.


                        home de l'utilisateur `www`
                        v--v
    sudo --user=www vim ~www/htdocs/index.html

            Éditer `index.html` comme si on était l'utilisateur `www`.


    sudo --group=adm vim /var/log/syslog

            Lire les logs système comme si on étant membre du groupe `adm` (admin).


    sudo --user=jim --group=audio vim ~jim/sound.txt

            Éditer `sound.txt` comme si on était `jim` et membre du groupe `audio`.


    $ sudo    bash -c 'echo $HOME'
    /home/user˜
    $ sudo --set-home bash -c 'echo $HOME'
    /root˜

            `--set-home` demande à  `sudo` de donner pour valeur  à `$HOME` le
            home de l'utilisateur cible.


                                               NOTE:

            Si on avait simplement exécuté:

                    $ sudo    echo $HOME
                    /home/user˜
                    $ sudo --set-home echo $HOME
                    /home/user˜

            ... on aurait constaté aucune différence, car `$HOME` aurait été développé avant d'exécuter
            la commande.


    sudo bash -c "cd /home ; du -sh * | sort -rn >USAGE"

            Calculer l'espace occupé par les homes des utilisateurs du système, et écrire le résultat
            dans `/home/USAGE`.

            `/home` est possédé par `root`, et les droits ne permettent pas à un autre utilisateur
            d'y créer un fichier:

                    ls -ld /home
                    drwxr-xr-x 3 root root 4096 Jan 18 18:04 /home˜
                            │˜
                            └ pas le droit de modification˜

            Il faut donc élever nos privilèges via `sudo`.


                                               NOTE:

            Pk `bash -c` ? Pour 2 raisons:

            1. `sudo` ne peut exécuter que des programmes externes au shell, et `cd` n'en est pas un.

            2. La redirection `>USAGE` est effectuée par le shell courant, dont l'EUID est le simple
               utilisateur courant (car c'est nous qui l'avons lancé).
               Donc, si on n'a pas les droits suffisants pour écrire dans `/home`, le shell courant non plus.


                                               NOTE:

            EUID vs RUID

            Qd on lance  une commande via `sudo`, le processus  qui en résulte a
            un RUID et un EUID différents.
            Le RUID  (Real User ID)  est l'utilisateur  qui a lancé  la commande
            (ex: toto).
            Le EUID (Effective User ID) est l'utilisateur cible (ex: root).


    export FOO=bar; sudo    bash -c 'echo $FOO'
    ∅˜
    export FOO=bar; sudo --preserv-env bash -c 'echo $FOO'
    bar˜

            Par défaut, `sudo` ne préserve pas les variables d'environnement.
            Si on veut les conserver, il faut utiliser l'option `--preserv-env`.
            La réussite de la conservation dépend de la politique de sécurité définie dans `/etc/sudoers`.

            `--preserv-env` désactive temporairement l'option `env_reset`. Équivaut à:

                    Defaults    !env_reset


                                               NOTE:

            On pourrait aussi inclure `FOO` dans l'option `env_keep`:

                    Defaults    env_keep += "FOO"

            Et si on voulait en préserver plusieurs:

                    Defaults    env_keep += "VAR1 VAR2"


    $ sudo --preserv-env bash -c 'echo $PATH'
    root's path

    $ sudo PATH=$PATH bash -c 'echo $PATH'
    current user path

            Ni `--preserv-env`, ni `env_keep` ne préservent pas `PATH`, il faut
            donc la passer manuellement.

### déboguage

    /var/log/auth.log

            Chaque utilisation de `sudo` ajoute une ligne dans ce fichier.
            À consulter en cas de pb.

##
## tee

    echo 'hello' | tee --append *

            Écrit `hello` à la fin de tous les fichiers du répertoire courant.

            `tee` permet d'ajouter le support des wildcards à des commandes ne l'ayant pas par défaut.


    cmd | tee file1 file2 file3

            `tee` permet d'écrire la sortie d'une commande dans plusieurs fichiers.


    cmd1 | tee file | cmd2

            `tee` écrit la sortie de `cmd1` dans `file` ET la refile au pipe qui suit,
            qui la refile à `cmd2`.

            En effet, même qd on demande à `tee` de rediriger sa sortie dans un fichier,
            il continue de l'afficher à l'écran (double sortie).

            On peut le vérifier simplement:

                    ls | tee file

            La sortie de `ls` est bien écrite dans `file` ET affichée à l'écran.


               cmd >root_file    ✘
          sudo cmd >root_file    ✘

    cmd | sudo tee  root_file    ✔

            `tee` permet d'écrire la sortie d'une commande dans un fichier pour lequel on n'a pas
            les droits suffisants.

            La 2e commande échoue car ce n'est pas `cmd` qui écrit dans le fichier, mais le shell
            (qui effectue la redirection).
            Il faut donc élever les droits du shell, ou d'une commande écrivant dans le fichier.

##
## Futur

### cylon-deb

    TUI menu driven bash shell script to maintain a Debian-based Linux distro.

    https://github.com/gavinlyonsrepo/cylon-deb

                                              469 sloc

    Pourrait être utile pour automatiser une maintenance plus rigoureuse d'une distro basée sur debian.

### dasht

    Search API docs offline, in terminal or browser.

    https://github.com/sunaku/dasht

    dasht-docsets-install

            lister toutes les documentations installables:

                    ActionScript
                    Akka
                    Android
                    Angular
                    Angular.dart
                    AngularJS
                    AngularTS
                    Ansible
                    Apache_HTTP_Server
                    Appcelerator_Titanium
                    Apple_Guides_and_Sample_Code
                    AppleScript
                    Arduino
                    AWS_JavaScript
                    BackboneJS
                    Bash
                    Boost
                    Bootstrap_2
                    Bootstrap_3
                    Bootstrap_4
                    Bourbon
                    C
                    C++
                    CakePHP
                    Cappuccino
                    Chai
                    Chef
                    Clojure
                    CMake
                    Cocos2D
                    Cocos2D-X
                    Cocos3D
                    CodeIgniter
                    CoffeeScript
                    ColdFusion
                    Common_Lisp
                    Compass
                    Cordova
                    Corona
                    CouchDB
                    Craft
                    CSS
                    D3JS
                    Dart
                    Django
                    Docker
                    Doctrine_ORM
                    Dojo
                    Drupal_7
                    Drupal_8
                    ElasticSearch
                    Elixir
                    Emacs_Lisp
                    EmberJS
                    Erlang
                    Express
                    ExpressionEngine
                    ExtJS
                    Flask
                    Font_Awesome
                    Foundation
                    GLib
                    Go
                    Gradle_DSL
                    Gradle_Groovy_API
                    Gradle_Java_API
                    Gradle_User_Guide
                    Grails
                    Groovy
                    Groovy_JDK
                    Grunt
                    Gulp
                    Haml
                    Handlebars
                    Haskell
                    HTML
                    Ionic
                    Jade
                    Jasmine
                    Java_EE6
                    Java_EE7
                    Java_EE8
                    JavaFX
                    JavaScript
                    Java_SE6
                    Java_SE7
                    Java_SE8
                    Java_SE9
                    Jekyll
                    Jinja
                    Joomla
                    jQuery
                    jQuery_Mobile
                    jQuery_UI
                    Julia
                    KnockoutJS
                    Kobold2D
                    Laravel
                    LaTeX
                    Less
                    Lo-Dash
                    Lua_5.1
                    Lua_5.2
                    Lua_5.3
                    Man_Pages
                    MarionetteJS
                    Markdown
                    MATLAB
                    Matplotlib
                    Meteor
                    Mocha
                    MomentJS
                    MongoDB
                    Mongoose
                    Mono
                    MooTools
                    MySQL
                    Neat
                    NET_Framework
                    Nginx
                    NodeJS
                    NumPy
                    OCaml
                    OpenCV
                    OpenCV_C
                    OpenCV_C++
                    OpenCV_Java
                    OpenCV_Python
                    OpenGL_2
                    OpenGL_3
                    OpenGL_4
                    Pandas
                    Perl
                    Phalcon
                    PhoneGap
                    PHP
                    PHPUnit
                    Play_Java
                    Play_Scala
                    Polymer.dart
                    PostgreSQL
                    Processing
                    PrototypeJS
                    Pug
                    Puppet
                    Python_2
                    Python_3
                    Qt_4
                    Qt_5
                    R
                    Racket
                    React
                    Redis
                    RequireJS
                    Ruby
                    Ruby_2
                    Ruby_Installed_Gems
                    RubyMotion
                    Ruby_on_Rails_3
                    Ruby_on_Rails_4
                    Ruby_on_Rails_5
                    Rust
                    SailsJS
                    SaltStack
                    Sass
                    Scala
                    SciPy
                    Semantic_UI
                    Sencha_Touch
                    Sinon
                    Smarty
                    Sparrow
                    Spring_Framework
                    SQLAlchemy
                    SQLite
                    Statamic
                    Stylus
                    Susy
                    SVG
                    Swift
                    Symfony
                    Tcl
                    Tornado
                    Twig
                    Twisted
                    TypeScript
                    TYPO3
                    UnderscoreJS
                    Unity_3D
                    Vagrant
                    Vim
                    VMware_vSphere
                    VueJS
                    WordPress
                    Xamarin
                    Xojo
                    XSLT
                    XUL
                    Yii
                    YUI
                    Zend_Framework_1
                    Zend_Framework_2
                    Zend_Framework_3
                    ZeptoJS

    dasht-docsets-install bash

            Installe la documentation bash.

    dasht 'c - x'

            Chercher dans la documentation tous les sujets contenant 'c - x'.

### dfc

    TODO: lire `man dfc`
    dfc - display file system space usage using graphs and colors
    (df mais en plus lisible)

### diana-mui

- <https://www.youtube.com/watch?v=y59JwlYsrAE>
- <https://github.com/baskerville/diana>

### direnv

- <https://github.com/direnv/direnv>
- <https://github.com/direnv/direnv.vim>

direnv is an environment switcher for the shell.
It knows  how to hook  into bash, zsh,  tcsh, fish shell  and elvish to  load or
unload environment variables depending on the current directory.
This  allows  project-specific  environment  variables  without  cluttering  the
~/.profile file.

Before each prompt,  direnv checks for the  existence of a ".envrc"  file in the
current and parent directories.
If the file exists  (and is authorized), it is loaded into  a bash sub-shell and
all exported  variables are then captured  by direnv and then  made available to
the current shell.

Because direnv is compiled into a single static executable, it is fast enough to
be unnoticeable on each prompt.
It  is also  language-agnostic and  can be  used to  build solutions  similar to
rbenv, pyenv and phpenv.

### grep-typos

    https://github.com/ss18/grep-typos

            Quickly check your project for typos

### inotifywait

    https://github.com/rvoicilas/inotify-tools/wiki
    https://superuser.com/a/181543/747860

            File watcher.

            Alternatives:

                    http://entrproject.org/  ✔✔✔ à tester, peut-être meilleur que `inotify`
                    https://github.com/cortesi/modd
                    https://github.com/mattgreen/watchexec
                    https://github.com/stylemistake/runner
                    https://github.com/shanzi/wu

            À propos de `entr`:
            https://news.ycombinator.com/item?id=13856623

---

Old comment extracted from `~/.config/systemd/user/cfg-reload-xterm.service`:

    # We could use `inotifywait(1)` instead of `entr(1)`, but it's trickier.
    #
    # Here is a starting point:
    #
    #     $ inotifywait --monitor --event modify,move_self "$HOME/.Xresources"
    #
    # But, I'm not sure the events are correct.
    # In particular, I think the `modify` event is not always fired.
    # It might  depend on  how the  file is modified  (Vim, nano,  shell redirection
    # overwrite, shell redirection append, ...). To get the fired events, use this:
    #
    #     $ inotifywait --quiet --monitor --format '%T: %w: %e' --timefmt '%H:%M:%S' ~/.Xresources
    #
    # Also, I think  you would need a `while true`  loop, otherwise `inotifywait(1)`
    # would probably terminate as soon as it detects a file change.

### lnav

Log file navigator http://lnav.org

- <https://github.com/tstack/lnav>
- <https://www.youtube.com/watch?v=D9Tox1ysPXE>


                                               NOTE:

        Procédure d'installation:

                git clone https://github.com/tstack/lnav
                cd lnav
                ./autogen.sh
                ./configure
                make
                sudo make install

        OU

                sudo apt install lnav


                                     FIXME:

        Actuellement, la couleur de fond est noire.
        `lnav` utilise probablement  la couleur noire définie par  la palette du
        terminal.
        On  pourrait  peut-être  la  faire  passer en  blanc,  en  la  modifiant
        temporairement, le temps d'une invocation de `lnav`?
        (je doute mais bon...)

        Un bug report existe sur le sujet:

                https://github.com/tstack/lnav/issues/270

        Une PR est en préparation.  Elle pourrait résoudre le pb:

                https://github.com/tstack/lnav/pull/468

### noti

    https://github.com/variadico/noti

            Trigger notifications when a process completes.

### pass

    https://www.passwordstore.org/

            the standard unix password manager

            À comparer à keepasscli.

### progress

    https://github.com/Xfennec/progress

            Linux tool to show progress for cp, mv, dd, ... (formerly known as cv)

            sudo api progress

            Ne semble pas génial pour améliorer `cp`, car il n'affiche pas d'information concernant
            la progression globale d'une copie de plusieurs fichiers (progression par fichier uniquement).
            Et ne permet sans doute pas de reprendre la copie en cas d'interruption.
            Lui préférer `rsync`.

            En revanche, pour d'autres commandes (ex: `dd`) ...

### rat

    Compose shell commands to build interactive terminal applications

    Rat  was developed  as part  of  an effort  to build  a  tig-like application  with very  little
    opinionated UI logic, delegating instead to the capabilities of shell commands like git log with
    its --pretty and --graph options.

    Shell commands  are executed and  the output is  captured and displayed  in pagers.  Configurable
    annotators parse  through the output,  adding annotations  that can be  acted upon to  run other
    shell commands.

    https://github.com/ericfreese/rat

### rclone

    "rsync for cloud  storage" - Google Drive,  Amazon Drive, S3, Dropbox, Backblaze  B2, One Drive,
    Swift, Hubic, Cloudfiles, Google Cloud Storage, Yandex Files https://rclone.org

    https://github.com/ncw/rclone

### pv

    TODO: lire `man pv`
    pv - monitor the progress of data through a pipe

### sdcv

    https://askubuntu.com/questions/191125/is-there-an-offline-command-line-dictionary

    sudo apt install sdcv

### socat

    http://freecode.com/projects/socat
    https://unix.stackexchange.com/search?tab=votes&q=socat

            Alternative plus puissante à `netcat`.

            man socat

### streamlink

        https://github.com/streamlink/streamlink

        https://streamlink.github.io/

        https://www.youtube.com/watch?v=QtzB6ZqpfLc

CLI  for extracting  streams from  various websites  to a  video player  of your
choosing.

### TMSU

    https://github.com/oniony/TMSU

            TMSU lets you  tags your files and then access  them through a nifty
            virtual filesystem from any other application.

            Comment from a redditor:

            People need  to understand the power  of tagging it is  the superior
            way of categorising.
            The subconsciousness usually comes up with  the same set of words as
            you used  to tag  it with  in the  first place  (when you  query and
            search your collection).
            I have thousands of bookmarks:

                    http://pinboard.in/u:dza

            I have  logs of work-related  solutions and avoid googling  the same
            results over and over again.
            I retain much more of what I learn.
            Tagging  and  bookmarking this  way  is  the  best thing  that  ever
            happened to  me to retain  the neverending flow of  information that
            developers get exposed to.
            I would recommend anyone doing it  and I would hope schools teach it
            some day.

### translate-shell

    https://github.com/soimort/translate-shell/

            Command-line translator using Google Translate, Bing Translator, Yandex.Translate, etc.

            Cette page est très intéressante pour adopter un bon style qd on écrit du code awk:
            https://github.com/soimort/translate-shell/wiki/AWK-Style-Guide

            Cette page produit des traductions de grande qualité:
            https://demo-pnmt.systran.net/production#/translation


    git clone https://github.com/soimort/translate-shell/
    cd translate-shell
    git checkout Tab    (ATM, la release la plus récente est 0.9.6.4)
    make
    sudo make install

            Procédure d'installation.


    trans -shell
    hello

            Affiche la prononciation, la définition, des synonymes et des exemples d'utilisation du mot “hello“.
            `-shell` lance `translate-shell` en mode interactif (REPL).

            Taper `:q` pour quitter.


    trans 'Un jour je me lèverai, et il fera beau!'
    trans -brief 'Un jour je me lèverai, et il fera beau!'

            Traduit une phrase en français vers l'anglais (langue système).
            Idem mais en moins verbeux.

### visidata

A terminal interface for exploring and arranging tabular data.

<https://github.com/saulpw/visidata>
<https://www.visidata.org/docs/>
