# Management
## How to install `newsboat`?

    # https://github.com/newsboat/newsboat#dependencies
    $ api asciidoc libcurl4-gnutls-dev libjson-c-dev libsqlite3-dev libstfl-dev

    $ git clone https://github.com/newsboat/newsboat

    $ cd newsboat

    $ make
    $ sudo make install

    $ mkdir -p ~/.local/share/newsboat

    $ vim ~/.config/newsboat/urls
            # write the urls of your feeds; ex:

            https://github.com/vim/vim/commits/master.atom

    $ vim ~/.config/newsboat/config

    $ vim ~/.shrc

            alias nb='newsboat'

## How to remove `newsboat`?

        $ sudo dpkg -r newsboat

## Which files does `newsboat` read for its config and data?

   - `$HOME/.config/newsboat/config`
   - `$HOME/.config/newsboat/urls`
   - `$HOME/.local/share/newsboat/cache.db`
   - `$HOME/.local/share/newsboat/history.cmdline`
   - `$HOME/.local/share/newsboat/history.search`
   - `$HOME/.local/share/newsboat/queue`

#
# First steps

After you’ve  installed newsboat, you  can run it for  the first time  by typing
newsboat on your command prompt.
This will bring you the following message:

    Error: no URLs configured.
    Please fill the file /home/ak/.newsboat/urls with RSS feed URLs or import an
    OPML file.

    newsboat 2.10
    usage: ./newsboat [-i <file>|-e] [-u <urlfile>] [-c <cachefile>] [-x <command> ...] [-h]
            -e, --export-to-opml            export OPML feed to stdout
            -r, --refresh-on-start          refresh feeds on start
            -i, --import-from-opml=<file>   import OPML file
            -u, --url-file=<urlfile>        read RSS feed URLs from <urlfile>
            -c, --cache-file=<cachefile>    use <cachefile> as cache file
            -C, --config-file=<configfile>  read configuration from <configfile>
            -X, --vacuum                    compact the cache
            -x, --execute=<command>...      execute list of commands
            -q, --quiet                     quiet startup
            -v, --version                   get version information
            -l, --log-level=<loglevel>      write a log with a certain loglevel (valid values: 1 to 6)
            -d, --log-file=<logfile>        use <logfile> as output log file
            -E, --export-to-file=<file>     export list of read articles to <file>
            -I, --import-from-file=<file>   import list of read articles from <file>
            -h, --help                      this help

This means that newsboat can’t start without any configured feeds.
To add  feeds to  newsboat, you can  either add URLs  to the  configuration file
$HOME/.newsboat/urls  or you  can import  an OPML  file by  running newsboat  -i
blogroll.opml.
To manually add URLs,  open the file with your favorite text  editor and add the
URLs, one per line:

    http://rss.cnn.com/rss/cnn_topstories.rss
    http://newsrss.bbc.co.uk/rss/newsonline_world_edition/front_page/rss.xml

If  you need  to add  URLs that  have restricted  access via  username/password,
simply provide the username/password in the following way:

    http://username:password@hostname.domain.tld/feed.rss

In order to  protect username and password, make  sure that $HOME/.newsboat/urls
is only readable by you and, optionally, your group:

    $ chmod u=rw,g=r,o= ~/.newsboat/urls

Newsboat  also  makes sure  that  usernames  and  passwords within  URLs  aren’t
displayed in its user interface.
In case there  is a @ in  the username, you need  to write it as  %40 instead so
that it  can be distinguished  from the  @ that separates  the username/password
part from the hostname part.

You can also  configure local files as  feeds, by prefixing the  local path with
file:// and adding it to the $HOME/.newsboat/urls file:

    file:///var/log/rss_eventlog.xml

Now you can run newsboat again, and it will present you with a controllable list
of the URLs that you configured previously.
You can now start downloading the feeds,  either by pressing "R" to download all
feeds, or by pressing "r" to download the currently selected feed.
You can then select a feed you want to read, and by pressing "Enter", you can go
to the article list for this feed.
This works even while the downloading is still in progress.

You can now see the list of available articles by their title.
A "N" on the left indicates that an article wasn’t read yet.
Pressing "Enter" brings you to the content of the article.
You can scroll through this text, and also run a browser (default: lynx) to view
the complete  article if the  content is  empty or just  an abstract or  a short
description.
Each URL in the article has a number next to it; to open it, type # and then the
number, then press "Enter".
For single-digit links, like 3, you can just press that number on the keyboard.

Pressing "q" brings you back to the  article list, and pressing "q" again brings
you back to the feed list.
Pressing "q" a third time then closes newsboat.

Newsboat caches the article that it downloads.
This  means that  when you  start  newsboat again  and  reload a  feed, the  old
articles can still be read even if they aren’t in the current RSS feeds anymore.
Optionally you  can configure how  many articles shall  be preserved by  feed so
that the article backlog doesn’t grow endlessly (see max-items below).

Newsboat  also  uses a  number  of  measures to  preserve  the  users' and  feed
providers' bandwidth, by trying to  avoid unnecessary feed downloads through the
use of conditional HTTP downloading.
It  saves every  feed’s "Last-Modified"  and "ETag"  response header  values (if
present) and advises  the feed’s HTTP server  to only send data if  the feed has
been updated by modification date/time or "ETag" header.
This doesn’t only make feed downloads for  RSS feeds with no new updates faster,
it also reduces the amount of transferred data per request.
Conditional HTTP  downloading can be optionally  disabled per feed by  using the
always-download configuration command.

Several aspects  of newsboat’s behaviour  can be configured via  a configuration
file, by default $HOME/.newsboat/config.
This configuration file contains lines in the form <config-command> <arg1> ....
The  configuration file  can  also  contain comments,  which  start  with the  #
character and go as far as the end of line.
If you need  to enter a configuration argument that  contains spaces, use quotes
(") around the whole argument.
It’s  even possible  to  integrate  the output  of  external  commands into  the
configuration.
The text between two backticks (`) is evaluated as shell command, and its output
is put on its place instead.
This works like  backtick evaluation in Bourne-compatible shells  and lets users
use external information from the system within the configuration.
Backticks  can be  escaped  with a  backslash  (\`); in  that  case, they’ll  be
replaced by a literal backtick in the configuration.

Searching for articles is possible in newsboat, too.
Just press the "/"  key, enter your search phrase, and the  title and content of
all articles are searched for it.
When you do a  search from the list of feeds, all articles  of all feeds will be
searched.
When you do a  search from the article list of a feed,  only the articles of the
currently viewed feed are searched.
When  opening an  article from  a  search result  dialog, the  search phrase  is
highlighted.

The   history  of   all  your   searches  is   saved  to   the  filesystem,   to
~/.newsboat/history.search.
By default,  the last  100 search phrases  are stored, but  this limited  can be
influenced through the history-limit configuration variable.
To disable search history saving, simply set the history-limit to 0.

#
# Configuration

    bind-key (parameters: <key> <operation> [<dialog>]; default value: n/a)

        Bind key <key> to <operation>.
        This means that whenever <key>  is pressed, then <operation> is executed
        (if applicable in the current dialog).
        A list of available operations can be found below.
        Optionally, you can specify a dialog.
        If you specify one, the key binding  will only be added to the specified
        dialog.
        Available dialogs are:

                - 'all' (default  if none is specified),
                - 'article'
                - 'articlelist'
                - 'feedlist'
                - 'filebrowser'
                - 'filterselection'
                - 'help'
                - 'podbeuter'
                - 'tagselection'
                - 'urlview'

Example:

        bind-key ^R reload-all

#
# Misc
## Why not newsbeuter?

It's not maintained anymore.
From [the repo][1]:

   > ABANDONED! An actively maintained fork is available in newsboat repo

##
# Reference

[1]: https://github.com/akrennmair/newsbeuter
