# How to take good notes?
## the time you need to find any given info should be short

This implies  that you should  choose the name  of your wikis,  files, sections,
subsections, ... very carefully.

## use an FAQ format

This lets you test your memory when reviewing your notes.
When you can't remember an info, it may be because the question or the answer is
not properly written; you can then rephrase it, which in turn improves your notes.

This also associates a short question to each – possibly long – info.
You can view a question as the key to retrieve an info.

## avoid repetition (DRY, DIE)

A repetition means that you need to (in no particular order):

   1. remove sth

   2. restructure your notes
      merge two sections, break down a too big section ...

   3. rephrase an idea which you've documented several aspects of

`1.` and `2.`  have the benefit of  resp. removing noise and  should making your
notes more logical; this makes it easier to find an info in your notes.

`3.` has the  benefit of giving a better understanding,  by making links between
different  (but similar)  ideas, and  synthesizing  them into  shorter and  more
powerful ideas.

## your notes should contain as much practical info as possible

Theoretical info is harder to understand and remember than practical info.
Try to limit it to definitions in a glossary.

If you  need to  define some concept  outside a glossary,  be consistent  in the
location where you do it; ATM, I try to do it at the start of a section.
When  you  have difficulty  understanding  a  practical  info, because  of  some
concept, you'll find its  definition quicker if you know in  advance where it is
defined.

## the structure of a section should be consistent

One example of  simple structure would be  to place the theoretical  info at the
top, and the practical one at the bottom.

No matter  the structure  you choose, and  no matter how  complicated it  is, be
consistent; that is, you should use the same one all the time.

## an info should be easy to understand

This implies that you should:

   - move the most important idea to the front of the text
   - break down long sentences into shorter ones
   - shorten the text by using new and richer words of vocabulary

---

If you're not able  to reduce an info into a few lines,  it means you're missing
some  intermediary concepts;  wait until  you've understood  and documented  the
latter in other questions/answers or in a glossary.

##
# Where to find documentation for a program?

   - `man pgm`

   - amazon book

   - wiki (github, gitlab, ...)

   - FAQ (often included in the github wiki)

   - configuration files

           $ git clone <url> && cd <dir> && find -name '*.conf' -type f

       e.g. `mpv`, `ranger`, ...

   - official website

       e.g. https://weechat.org/doc/

# How to write good documentation?

<https://writing.stackexchange.com/a/34138/30109>

##
# Résoudre un problème

Qd  on émet  une hypothèse  pour expliquer  l'origine d'un  problème, dès  qu'on
trouve une contradiction, en chercher une nouvelle.

On perd souvent du temps en s'entêtant  à essayer de prouver la 1e hypothèse qui
nous est venue à l'esprit.
En effet, cette dernière bénéficie sans doute d'un effet de primauté.
C'est la plus évidente, donc on rejette l'idée même qu'elle puisse être fausse.

Ceci est un piège.
Contradiction = tout de suite chercher une autre hypothèse.
Ne pas approfondir une hypothèse avant d'en avoir exploré un maximum:

    “breadth before depth”

---

Qd  on rencontre  un  problème difficile,  ne  pas s'obstiner  à  chercher à  le
résoudre.
Un tel problème vient rarement seul.
Il est souvent accompagné par/décomposable en plusieurs autres problèmes.

Les noter TOUS explicitement, et le plus clairement possible, au fur et à mesure
qu'on en rencontre au cours de notre tentative de résolution.

Passer  régulièrement de  l'un à  l'autre  dès qu'on  n'arrive plus  à faire  de
progrès.
Il  se peut  que l'un  d'eux soit  plus  facile que  les autres,  et qu'il  nous
permette de résoudre facilement les autres.

Il faut  voir un problème  difficile comme un PUZZLE,  pas comme un  roman qu'on
doit lire du début à la fin.

---

Qd on rencontre un bug, il ne faut pas chercher à le réparer immédiatement.
Au préalable, il faut chercher à le simplifier un maximum.
En    effet,   on    ne    sait    pas   à    l'avance    combien   de    cycles
"hypothèse-tentative-échec" il faudra réaliser avant de trouver la solution.
Si ce  nombre est  grand, on a  tout intérêt  à réduire la  durée d'un  cycle au
maximum.
Autrement le déboguage sera long et décourageant.

Il s'agit de trouver un MRE.
Toutefois, un MRE ne signifie pas nécessairement un minimium de texte.
En effet, si un MRE ne permet pas  de mieux comprendre le problème, il peut être
judicieux de rajouter un peu de texte, afin d'expliciter l'implicite.
Pour rappel, il  nous est arrivé de  perdre du temps à comprendre  une regex qui
nous donnait  l'impression que le  moteur de Vim  n'utilisait pas la  1e branche
matchant  du  texte,  mais  celle  matchant  le plus  long  texte,  ce  qui  est
inhabituel.
En réalité, il y avait plusieurs matchs qu'on confondait en un seul.
La confusion a été levé en explicitant l'ancre `^` au début de la 2e branche:

    .*pat\|^.*
           ^

---

Il y a un thème récurrent qui se dégage jusqu'ici:

Qd qch attire notre attention (solution, problème, bug), on a souvent tendance à
ne plus rien voir autour, ce qui nous fait perdre parfois beaucoup de temps.
Il  faut s'habituer  à prendre  du  recul dès  que  qch devient  pénible, et  se
demander s'il  n'y a pas qch  d'autre qui mérite davantage  notre attention dans
l'immédiat.

---

If:

   - you have an issue which you fully understand

   - you think you have a solution, but for some reason it doesn't work

   - after spending quite some time, you still can't find anything wrong with
     the solution

ask yourself these questions:

   1. What am I trying to do?
   2. What makes me think it's possible?
   3. What could explain that my belief is wrong?

Example of answers:

   1. I'm trying to find a condition to prevent my autocmd to install a match
      (trailing whitespace) in a fzf buffer

   2. when my autocmd is fired, I can detect the filetype of the buffer

   3. the filetype has not been set yet

## weird is relative

When you find sth new which seems weird, and you suspect there's a bug, consider
the possibility that  this new thing is not  weird; it may be the  old thing, to
which you're comparing it, that is weird.

---

For example, when we  tried the st terminal, we were surprised  by the fact that
we couldn't paste a text yanked from  Vim into the clipboard (`""yiw`) back into
the terminal (`C-S-v`), after quitting Vim.

It turns out that this behavior is perfectly normal.
We thought it  was not normal, because  we were used to a  perl script (`pasta`)
which has the  side effect of allowing us  to paste the clipboard  in urxvt even
after quitting Vim.

What was weird was urxvt, not st.

If you had considered the possibility that maybe urxvt was weird, you would have
tried to test  other terminals, and you  would have come to  the conclusion that
urxvt was indeed weird.
Then, you  would have tested  urxvt without  config, which would  have confirmed
your conclusion.
Finally, you would have applied a binary search to your `~/.Xresources` in order
to find the minimum amount of code to reproduce the weird behavior.

##
# Modularisation

Réduire le temps d'accès.

    Cartes répétition espacée

    Notes wiki personnel

    Shell snippets

    Cheatkeys

    Fichier de conf commentés

# Cartes mentales

Structue un gd nb de sources d'infos variées:
capture d'écran ; liens vers pages, vidéo, documents...

Les cartes mentales sont sans doute très utiles pour s'organiser avant d'agir.
Mais pas pour prendre des notes et comprendre qch.
Pour prendre des notes, un wiki et des diagrammes sont plus adéquates.

# Cognitif vs métacognitif

Les stratégies cognitives sont les procédures, les techniques qu'on utilise pour
réussir une tâche.

Les stratégies  métacognitives consistent  à réfléchir sur  sa façon  de penser,
d'agir et d'apprendre pour en évaluer l'efficacité et pour l'améliorer.

Pour  rendre sa  manière d'apprendre  plus efficace,  on doit  s'interroger pour
savoir comment on apprend.

# Top-Down vs Bottom-Up

    Top-Down

Technique d'apprentissage dans  laquelle on commence par  comprendre le contexte
général avant de passer aux détails.

    Bottom-Up

Dans le  cadre du  bottom-up il  est important de  constituer des  “chunks”, des
ensembles  neuronaux très  serrés que  notre cerveau  sera capable  de manipuler
comme des blocs.

Inutile de lire et de relire un texte indéfiniment pour être sûr d'avoir compris
et maîtrisé un sujet.
En  fait, il  est  beaucoup plus  malin  de se  répéter ce  qu'on  a appris,  de
reformuler le contenu  de la leçon jusqu'à  être capable de le  réexpliquer à sa
façon.

Cette technique est plus efficace que  d'autres méthodes plus élaborées comme la
création de schémas conceptuels.

En effet on essaie  trop souvent de bâtir des relations  entre des concepts sans
avoir  auparavant maîtrisé  les clusters  correspondant  à ces  concepts ce  qui
équivaut à apprendre des stratégies avancées  du jeu d'Échecs sans connaître les
règles de base.

# Concentration

Principe de Pareto:
<https://fr.wikipedia.org/wiki/Principe_de_Pareto>

Mode concentré vs mode diffus:
<http://www.internetactu.net/2015/09/08/apprendre-a-apprendre-14-deux-modes-dapprentissage/>

# Astuces

    Structurer l'info

Plus  facile d'intégrer  une grande  quantité d'infos  quand elle  nous apparaît
comme cohérente.

Structurer l'info  signifie la transformer sous  une forme qui nous  paraît plus
accessible.
Moins on a besoin de faire d'efforts de compréhension mieux c'est.

Rendre l'info + accessible fait partie d'un processus d'assimilation.

Cette page est une excellent illustration du principe:
<https://noahfrederick.com/log/a-list-of-vims-lists/>

Plusieurs notions complexes sont regroupées et comparées.
On constate qu'elles sont proches les unes des autres, on peut les manipuler via
des commandes similaires, et emplissent un objectif similaire.

    Définir objectif clair et motivant

La clarté est nécessaire  pour pouvoir faire le tri entre  les sources qu'il est
utile d'analyser et celles qui ne sont pas intéressantes.

La motivation est nécessaire pour s'investir bcp.

    Dialogue entre théorie et pratique

    Partir de ce qui marche

Quand on  a plusieurs  sources pour  accomplir un objectif  donné, et  que l'une
d'elles fournit des infos qui semblent  erronées, il faut commencer à travailler
à partir d'une  autre source pour lesquelles les infos  fonctionnent puis tenter
d'intégrer un maximum d'infos de la source problématique.

Ne pas perdre son temps à chercher à comprendre tout de suite pourquoi des infos
ne  fonctionnent pas,  car le  pb peut  se résoudre  en lisant  d'autres sources
d'infos.

    Relire ses notes avec un esprit critique

Quand on relit  ses notes, shell snippets,  rester attentif à ce  qui ne marche
pas  (pex. une  info qu'on  met  trop de  temps  à trouver  ou à  comprendre),
apporter  les  modifications  nécessaires  et en  tirer  un  enseignement  pour
améliorer les notes futures.

    Laisser reposer (agilité mentale)

Quand on a noté bcp d'infos sur un sujet donné et qu'on sent qu'on a du mal à en
assimiler plus :

   1. passer à un autre sujet

   2. revenir sur le sujet précédent le lendemain, en relisant ses notes à haute
      voix pour vérifier qu'on comprend bien et si besoin les éditer / modifier
      pour les rendre plus claires

         Condenser

Qd on  prend ses  notes, il faut  aller à l'essentiel  et toujours  chercher une
formulation qui prend un minimum de caractères.

Si  on  n'arrive  pas  à  condenser  une  information  en  suffisamment  peu  de
caractères, ça signifie probablement qu'il  faut la décomposer en plusieurs sous
informations, pas forcément au même endroit.
C'est peut-être aussi dû au fait que l'information est encore trop complexe pour
être assimilé, il nous manque des notions importantes.

Condenser l'information  est utile  pour retrouver plus  rapidement ce  qui nous
intéresse (temps d'accès),  et aussi pour créer des cartes  Anki (qui ont besoin
de questions / réponses courtes).

# J'apprends si ...

Je suis concerné par ce que j'apprends.
J'y trouve un intérêt, un sens.
J'ai confiance en mes capacités.
Je m'appuie sur mes connaissances.
Je fais des liens entre les connaissances acquises.
Je m'appuie sur mes stratégies privilégiées.
Je prends conscience du savoir que j'ai acquis.
Je me confronte aux autres.

# Comment aborder un sujet confus

   1. Trouver et dumper les info liées au sujet qui semble confus.

   2. Réduire l'info en:

       - supprimant le "bruit", càd des infos:

       * redondantes
       * pas ou peu intéressantes
       * expliquées par des règles déduites dans l'étape 3

       - factorisant le + possible

   3. Déduire des règles.  Puis revenir à l'étape 2.  Répéter jusqu'à ce qu'il n'y
      ait plus qu'un minimum d'infos et un max de règles.

---

Notes can be confusing because of its terminology.
A good example is the man page for `update-alternatives`.
It refers to 3 related concepts with different words:

   - generic name, alternative link
   - alternative name
   - alternative, alternative path

`generic name` is confusing because it's completely different than all the other words.
`alternative` is confusing  because whenever you read it, you  wonder whether it
means “alternative path”, or an alternative as a whole (link, name, path).

If the documentation uses different terminologies, edit it to make it more consistent.
Always use the same word to refer to the same concept.
Choose the word which is used the most often in the official documentation.

Exception:

If the most  used word is confusing  in itself (e.g. generic  name), the subject
you're studying has a very limited area  of application, and you're not going to
study it for a long time, then it's  ok to use another word, provided it's still
used somewhere in the documentation.

So,  in the  previous example,  it's  ok to  use “alternative  link” instead  of
“generic name”.

---

If the documentation is still confusing, that's probably because it lacks some info.

How to gain more info?
Use  the info  you have  noted  to do  sth  practical; for  anything related  to
computer science, it means running commands.

This implies that you should remove any note which can't be used in practice.
After using the info, study the effects of what you did to gather more info.

For example, in computer science, running commands is useful because you can see
whether  files were  created,  how many,  where,  ... or  you  can run  commands
verbosely and read a logfile...

However, you'll likely need to re-run  the same commands many times, with slight
changes, to get a better understanding of the documentation.
This implies two things:

   1. For every group of commands you run, you need to find the opposite
      commands which will undo all their effects.  You need it so that the second
      time you run your commands, their effects won't be affected by the
      previous run.

      Example: the opposite of `update-alternatives --install ...` is
      `update-alternatives --remove all ...`.

   2. You need to write a temporary script to avoid having to run the same long
      commands over and over.  With it,  all you'll have to  do is edit a  script
      to add your  change and re-run it.  It's much quicker to change a word in
      a command, then to retype several long commands just for one little
      change.

# Design

When  you  encounter  the  same   problem  regularly,  but  it's  insufficiently
specified, you need to develop a design.

The purpose of the design is to  answer all the implicit questions not mentioned
in the original problem.

Example:

    Problem:
    write some code to show the snippets available in the current buffer.

Implicit questions:

   - Where should I display the info (horizontal/vertical split, tabpage)?
   - Should I use syntax highlighting?
   - If so, how to implement it (syntax plugin vs `matchadd()`) and which colors should I use?
   - Should I use a preview window?
   - Which buffer-local options should I set?
   - Which buffer-local mappings should I install?
   ...


Without a design, you'll:

   - lose time answering those questions over and over again

   - forget to answer some of them

   - create an inconsistent environment
     (because every time, you'll solve the problem in a slightly different way)

   - have a hard time to refactor and improve your solutions
     (because they'll all be slightly different)

##
# I'm too confused by a command!
## Try the hydra method.

The hydra method is only useful if the reason why you're confused is because you
feel overwhelmed by too many variations of the same command.

Here's how it goes:

   1. Identify the parameters which can vary in the command.
   2. Enumerate all commands by using all possible combinations of parameter values.
   3. Put a comment above each command, describing its effect.
   4. Group the commands according to their effect.
   5. In each group, identify the parameter values which don't change.
   6. From those parameter values, infer some rules predicting the effect of any command.

The rules inferred in step 6 should help you gain a better understanding of the command.
You should now see  that the commands can only have a few  effects, and that you
can predict the effect  of any given command according to a  short set of simple
rules.
