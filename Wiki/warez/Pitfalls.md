# I can't access a website!

Maybe  it's  blocked  by your  ISP,  or  maybe  it  has blacklisted  your  IP/AS
(Autonomous System).

If so, check its status on a website such as:
<https://downforeveryoneorjustme.com>

Also, try to access it using the TOR browser:
<https://tb-manual.torproject.org/installation>

    $ cd ~/.local/bin/

    # download TOR browser, and extract the `tor-browser_en-US/` directory here
    $ cd tor-browser_en-US/

    $ ./start-tor-browser.desktop --register-app
    # now you can start the TOR browser from the XFCE application menu
