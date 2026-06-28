# Ebooks
## Websites

   - Library Genesis: <https://libgen.fun> (don't miss the "Fiction" section)
   - Unofficial fork of Library Genesis: <https://libgen.rs>
   - Library Genesis reddit wiki: <https://www.reddit.com/r/libgen/wiki/index>

   - Anna's Archive: <https://annas-archive.org> (metasearch engine)

   - Curated list 1: <https://github.com/Shakil-Shahadat/awesome-piracy#ebooks>
   - Curated list 2: <https://www.reddit.com/r/FREEMEDIAHECKYEAH/wiki/reading>
   - Curated list 3: <https://www.reddit.com/r/Piracy/wiki/megathread/reading_material_and_elearning>

##
## IRC
### #ebooks on IRChighway

    /connect irc.irchighway.net
    /join #ebooks

To get a list of results in a zip archive, execute this command in the channel:

    @search your_book_title

Once  downloaded, unzip  the  archive;  in the  extracted  file,  search a  line
containing the book you're looking for.

Finally, copy the bang command, and execute it in the channel.
Example:

    !temerut Nick Cutter - The Troop (epub).rar

For more info, see:

- <https://irchighway.net/help/i-m-new-to-irc>
- <http://ebooks.byethost6.com/index.html>

### #bookz on Undernet

    /connect irc.undernet.org
    /join #bookz

For more info, see:

- <https://www.undernet.org/help.php>
- <https://encyclopediadramatica.online/Bookz>

###
### I can read an ad about an FTP server.  How to look at what it can serve?  How to download from it?

Let's assume the ad prints this:

    @Oatmeal │ @ --Bookstuff is now open via ftp @ ftp://book:stuffing@173.80.4.19/

From a terminal, run `ftp(1)`:

          replace with whatever IP address was given in the message
          v---------v
    $ ftp 173.80.4.19
    ftp> Connected to 173.80.4.19.
    ftp> 220 Welcome

    ftp> Name (173.80.4.19:lgc): book
                                 ^--^
                                 replace with whatever name was given in the message

    ftp> 331 Password required for book
    ftp> Password: stuffing
                   ^------^
                   replace with whatever password was given in the message

    # print the contents of the remote directory
    ftp> ls
    # download a particular file from the previous listing
    ftp> get <filename>

For more info, `man ftp`, or:

    ftp> help
    ftp> help ls
    ftp> help get
    ftp> help ...

##
## Where can I find audio books?

The best site seems to be BTDigg: <https://btdig.com>

---

For a more specialized site (but not better than BTDigg), try AudioBook Bay:
<http://audiobookbay.nl>

Focus the search field  in the top right corner of the page,  and type the title
of your  ebook.  A list of  front covers should  be now displayed; click  on the
relevant one.  In the long table, find the  info hash of the torrent, and use it
to reconstruct the magnet URI:

    magnet:?xt=urn:btih:<infohash>
                        ^--------^
                        copied from the website

Finally, pass the magnet URI to the transmission daemon so that it can start the
download:

    $ transmission-remote --add '<magnet URI>'

