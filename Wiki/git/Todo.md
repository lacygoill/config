# demistify `git reset` and `git checkout`

<https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified>

Git as a system manages and manipulates three trees in its normal operation:

    ┌───────────────────┬───────────────────────────────────┐
    │ tree              │ Role                              │
    ├───────────────────┼───────────────────────────────────┤
    │ HEAD              │ Last commit snapshot, next parent │
    ├───────────────────┼───────────────────────────────────┤
    │ Index             │ Proposed next commit snapshot     │
    │ aka staging area  │                                   │
    ├───────────────────┼───────────────────────────────────┤
    │ Working Directory │ Sandbox                           │
    │ aka working tree  │                                   │
    └───────────────────┴───────────────────────────────────┘

HEAD is the snapshot of your last commit on the current branch.
Technically, it's the pointer to the  current branch reference, which in turn is
a pointer to the last commit made on that branch.

Here is an  example of getting the actual directory  listing and SHA-1 checksums
for each file in the HEAD snapshot:

    $ git cat-file -p HEAD
                   ^^
                   pretty-print the contents of <object> based on its type

    $ git ls-tree -r HEAD
                  ^^
                  recurse into sub-trees

Git populates  the index with  a list  of all the  file contents that  were last
checked out into your working directory and what they looked like when they were
originally checked out.  You then replace  some of those files with new versions
of them, and git commit converts that into the tree for a new commit.

Here is a command to see the contents of the index:

    $ git ls-files -s
                   ^^
                   --staged

                   show staged contents' mode bits,
                   object name and stage number in the output

Finally,  you have  your working  directory.  The  other two  trees store  their
content  in  an  *efficient*  but  *inconvenient*  manner;  inside  the  `.git/`
directory.  The working directory unpacks them into actual files, which makes it
much easier for you to edit them.   Think of the working directory as a sandbox,
where  you can  try changes  out  before committing  them to  your staging  area
(index) and then to history.

---

<https://medium.com/@tommasi.v/git-enhanced-with-tig-9eb07fc30168>
<https://opensource.com/article/19/6/what-tig>

#
# Document
## `$ vim +'Gedit :'`

<https://twitter.com/jesseleite85/status/1179437557035220993>

   > That'll open a vim instance with a fullscreen `:Gstatus` buffer.
   > From there, `g?` to see available mappings,  and `:q` to quit, as you would from
   > a commit buffer.

## How to recover a stash cleared by accident.

<https://stackoverflow.com/a/57095939/9780968>

    $ git fsck --unreachable \
        | awk -v ORS='\0' '/commit/ { print $3 }' \
        | xargs --null git log --merges --no-walk --

    $ git update-ref --create-reflog refs/stash 4b3fc45... -m 'My recover stash'
                                                ^--------^
                                                commit hash copied from the output of the previous command

    $ git stash apply 'stash@{0}'

## `:DiffOrig` but smarter

<https://gist.github.com/romainl/7198a63faffdadd741e4ae81ae6dd9e6>

#
# study scripts under `/usr/share/doc/git/contrib/`

Note that some of them might source a script named `git-sh-setup`.
In case they don't find it, it's here:

    /usr/lib/git-core/git-sh-setup

# ?

This todo item is stale.  We no longer have any binary file in our config.  That
said, we keep it  for now because it contains interesting  commands that we need
to study.

---

Find a way to remove all the binary/big files we've committed by accident in our config repo.

To find them, clone the repo in a temporary directory, then run:

    $ git rev-list --objects --all \
    | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
    | awk '/^blob/ { print substr($0,6) }' \
    | sort --key=2bn,2 \
    | cut --characters=13-40 --complement \
    | numfmt --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest

The big files are at the end of the output.

You can remove one by running:

    $ git filter-branch --index-filter 'git rm --cached --ignore-unmatch my/big/file' HEAD
                                                                         ^---------^
                                                                         replace with the path to the file
                                                                         you want to remove

Make sure that you don't have any non-committed change.
Source: <https://stackoverflow.com/a/46615578/9780968>

Issue: If you do that, you'll get a message (I think in the output of `$ config status`),
telling you that your local branch has diverged from origin/master.

I don't know how to fix this issue.

To undo the removal of the big file, run:

    $ git reset --hard origin/master

##
# Study Vim plugin `tig-explorer.vim`

<https://github.com/iberianpig/tig-explorer.vim>

##
# ?

We've installed tig from the sources:

    $ git clone https://github.com/jonas/tig

    $ make prefix=/usr/local
    $ sudo make install prefix=/usr/local

    $ make install-doc
       [...]
       INSTALL  doc/tig.1 -> /home/user/share/man/man1
       INSTALL  doc/tigrc.5 -> /home/user/share/man/man5
       INSTALL  doc/tigmanual.7 -> /home/user/share/man/man7
       [...]
       INSTALL  doc/tig.1.html -> /home/user/share/doc/tig
       INSTALL  doc/tigrc.5.html -> /home/user/share/doc/tig
       INSTALL  doc/manual.html -> /home/user/share/doc/tig
       INSTALL  README.html -> /home/user/share/doc/tig
       INSTALL  INSTALL.html -> /home/user/share/doc/tig
       INSTALL  NEWS.html -> /home/user/share/doc/tig

Read this: <https://github.com/jonas/tig/blob/master/INSTALL.adoc>

---

Read this glossary: <https://gitirc.eu/gitglossary.html>
This comes from a site associated to the `#git` irc channel on libera.
Check out the site for other possible interesting links.

Also, atm, the channel has a public logfile for each day:
<https://colabti.org/irclogger/irclogger_logs/git>
So, if you get disconnected, and want to check what you missed when you come back, visit:
<https://gitirc.eu/log>

---

Learn  how  to use  `git-jump`,  which  is a  bash  script  from the  `contrib/`
directory of the `git(1)` repo (and finish assimilating the script).

Read `~/.local/bin/README.md`, and read this to populate a qfl with the output:
- <https://vi.stackexchange.com/q/13433/17449>
- <https://gist.github.com/romainl/a3ddb1d08764b93183260f8cdf0f524f>

BTW, are there other interesting scripts in the `contrib/` directory of the repo
for `git(1)`? <https://github.com/git/git/tree/master/contrib/>

---

- <https://github.com/so-fancy/diff-so-fancy>
- <https://www.reddit.com/r/vim/comments/bkz81t/vimdiff_nor_nvim_d_are_working_as_an_external/emlntpu/>
- <https://www.reddit.com/r/vim/comments/bkz81t/vimdiff_nor_nvim_d_are_working_as_an_external/emkges3/>

---

Read: <https://chris.beams.io/posts/git-commit/>

---

Read:

    $ git help <guide>

Where `<guide>` is any guide given in the output of:

    $ git help -g

---

How to create automatically a repository-local `.gitignore` file when starting a
new project?

Maybe we  should use vim-projectionist  to automatically create them,  using the
relevant file from here as a template: <https://github.com/github/gitignore>

In particular, it would be interesting to copy the LaTeX and python files.

---

Learn to use the buffer-local commands/mappings installed by:

    $VIMRUNTIME/ftplugin/gitcommit.vim
    $VIMRUNTIME/ftplugin/gitrebase.vim

See also `:help ft-gitcommit-plugin`.

---

Document the option `rerere.autoUpdate` (see `man git-config`).
We've found it on page 28 (statusline) in the Pro Git book.
Do  it once  you've studied  the “rerere”  feature (REuse  REcorded REsolution),
which the book talks about.

---

- <https://try.gitea.io/>
- <https://www.reddit.com/r/linux/comments/8oziba/gitea_is_a_very_lightweight_github_clone_but_i/e07r34f/>
- <https://docs.gitea.io/en-us/config-cheat-sheet/>

---

Read:

- <https://gist.github.com/CristinaSolana/1885435>
- <https://github.com/edx/edx-platform/wiki/How-to-Rebase-a-Pull-Request>
- <https://help.github.com/articles/checking-out-pull-requests-locally/>
- <https://vimways.org/2018/vim-and-git/>

---

<https://github.com/github/hub/releases>

hub est un wrapper en cli autour de git qui ajoute à ce dernier des commandes et
des fonctionnalités, pour faciliter le travail avec GitHub.

On peut l'installer en téléchargeant  la dernière release, puis en décompressant
l'archive et en exécutant le script d'installation:

    $ sudo ./install

Ça devrait aussi installer les pages man du pgm.  Les lire:

    man hub

---

- <https://stackoverflow.com/a/9784089>
- <https://stackoverflow.com/a/8498197>

Merging without whitespace conflicts
Commit without whitespace changes on github

---

Read: <http://michaelwales.com/articles/make-gitconfig-work-for-you/>

---

Read: <https://github.blog/2020-02-12-supercharge-your-command-line-experience-github-cli-is-now-in-beta/>

---

Learn how to generate tags with a Git hook:

   - <https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration>
   - <https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks>
   - <https://git-scm.com/docs/githooks>

   - <https://tbaggery.com/2011/08/08/effortless-ctags-with-git.html>
   - <https://github.com/tpope/tpope/tree/master/.git_template>
   - <https://github.com/tpope/tpope/blob/master/.gitconfig>

Problem: Your tags will be generated only in git projects.
Not in projects using other VCS systems (`.hg/`, `.bzr/`, ...).
