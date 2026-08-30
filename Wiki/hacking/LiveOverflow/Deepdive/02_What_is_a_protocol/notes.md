<https://www.youtube.com/watch?v=d-zn-wv4Di8>

# Read a raw HTTP request

In Firefox:

   - press `C-t` to open a new tab
   - press `C-S-i` to open the Web Developer Tools
   - visit this URL: <http://info.cern.ch/hypertext/WWW/TheProject.html>
   - in the Web Developer Tools, select the "Network" tab
   - select the first request:

         Status | Method | Domain       | File            | Initiator | Type | ...
         200    | GET    | info.cern.ch | TheProject.html | document  | html | ...

   - in the right panel, make sure the "Headers" tab is selected
   - switch on the "Raw" button on the "Request Headers" line at the very bottom

You should read something like this:

    GET /hypertext/WWW/TheProject.html HTTP/1.1
    Host: info.cern.ch
    User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/110.0
    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8
    Accept-Language: en-US,en;q=0.5
    Accept-Encoding: gzip, deflate
    Connection: keep-alive
    Upgrade-Insecure-Requests: 1

This is the raw HTTP request sent by Firefox to the web server when you asked it
a webpage.

The web server has understood the request and sent back an HTTP response:

    HTTP/1.1 200 OK
    Date: Wed, 08 Mar 2023 06:13:17 GMT
    Server: Apache
    Last-Modified: Thu, 03 Dec 1992 08:37:20 GMT
    ETag: "8a9-291e721905000"
    Accept-Ranges: bytes
    Content-Length: 2217
    Connection: close
    Content-Type: text/html

In turn, Firefox has understood the response and displayed a webpage.

## How do the web server and client understand the requests they receive?

They both implement the HTTP protocol (or  at least the part that is relevant to
their role) as specified in [RFC 9112][1].

## Confirm that Firefox correctly implements the HTTP protocol.

The grammar rule for a valid HTTP request is specified [here][2]:

    HTTP-message   = start-line CRLF
                     *( field-line CRLF )
                     CRLF
                     [ message-body ]

The grammar rule for `start-line` is also specified:

    start-line     = request-line / status-line

This means that `start-line` can be one of:

   - `request-line` (for the client when it requests a resource from the server)
   - `status-line` (for the server when it responds)

In  our first  HTTP request,  Firefox asked  for a  webpage, so  `start-line` is
`request-line`.

The grammar rule for `request-line` is specified [here][3]:

    request-line   = method SP request-target SP HTTP-version

Which matches our original request:

           SP                             SP
           v                              v
        GET /hypertext/WWW/TheProject.html HTTP/1.1
        ^^^ ^----------------------------^ ^------^
     method         request-target         HTTP-version

This confirms that Firefox correctly implements the HTTP protocol.

---

BTW, `SP` stands for a SPace, while `CRLF` stands for a newline (Carriage Return
followed by LineFeed; escape sequence `\r\n`; hex value `0D 0A`).

##
# Send a raw HTTP request manually via netcat

    $ nc -C info.cern.ch 80 < <(tee <<'EOF'
    GET /hypertext/WWW/TheProject.html HTTP/1.1
    Host: info.cern.ch

    EOF
    )

The server should send you an answer such as:

    HTTP/1.1 200 OK
    Date: Fri, 10 Mar 2023 04:23:23 GMT
    Server: Apache
    Last-Modified: Thu, 03 Dec 1992 08:37:20 GMT
    ETag: "8a9-291e721905000"
    Accept-Ranges: bytes
    Content-Length: 2217
    Connection: close
    Content-Type: text/html

    <HEADER>
    <TITLE>The World Wide Web project</TITLE>
    <NEXTID N="55">
    </HEADER>
    <BODY>
    <H1>World Wide Web</H1>The WorldWideWeb (W3) is a wide-area<A
    NAME=0 HREF="WhatIs.html">
    hypermedia</A> information retrieval
    initiative aiming to give universal
    access to a large universe of documents.<P>
    ...

---

Inside the request, the trailing empty line is necessary, as specified in RFC 9112:

   > An HTTP/1.1 message  consists of a start-line followed by  a CRLF [...], an
   > **empty  line indicating the  end of the header section**, and  an optional
   > message body.

It's also indicated in the grammar rule for a valid HTTP message:

    HTTP-message   = start-line CRLF
                     *( field-line CRLF )
                     CRLF
                     [ message-body ]

Notice the single `CRLF` on the third line.

Without, the server sends a `408 Request Timeout` error:

    Server timeout waiting for the HTTP request from the client.

That's because the server waits for the  end of the header section which must be
indicated by an empty line.

---

On Linux, you need to pass the  `-C` option to `nc(1)`, so that it automatically
translates newlines encoded as `LF` into `CRLF`.

## Confirm that the `GET` method is case sensitive

Let's use `nc(1)`  to send a raw  HTTP request again, but this  time we'll write
the `GET` method in lowercase:

    get / HTTP/1.1
    ^^^

Let's try:

    $ nc -C info.cern.ch 80 < <(tee <<'EOF'
    get / HTTP/1.1
    Host: info.cern.ch

    EOF
    )

Here's what the server sends us back:

    HTTP/1.1 501 Not Implemented
    Date: Fri, 10 Mar 2023 05:37:26 GMT
    Server: Apache
    Allow: GET,HEAD,POST,OPTIONS
    Content-Length: 201
    Connection: close
    Content-Type: text/html; charset=iso-8859-1

    <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
    <html><head>
    <title>501 Not Implemented</title>
    </head><body>
    <h1>Not Implemented</h1>
    <p>get to /index.html not supported.<br />
    </p>
    </body></html>

We don't get the HTML document for the main page of the website.
Instead, we get a `501 Not Implemented` error.
That's because the request method is case-sensitive as specified in [RFC 9112][4]:

   > The request method is case-sensitive.

##
# Twitter has an API to look up tweets.  Why can it be considered as a protocol?

It [specifies][5] how a client should  communicate with Twitter servers in order
to retrieve a tweet.

## Why can we say that it's built on top of HTTP?

The API documentation specifies that an HTTP  request must be sent to a specific
endpoint.

### How is the URL for this endpoint built?

With  a specific  query string  which  must include  specific field-value  pairs
separated by ampersands:

                endpoint
    v------------------------------v
    https://api.twitter.com/2/tweets?ids=1228393702244134912,1227640996038684673,1199786642791452673&tweet.fields=created_at&expansions=author_id&user.fields=created_at
                                    ^
                                    start of the query string

Inside the query string from this example, we can find 4 field-value pairs:

    ids=1228393702244134912,1227640996038684673,1199786642791452673
    tweet.fields=created_at
    expansions=author_id
    user.fields=created_at
    ^---------^ ^--------^
       field      value

##
# ?

Continue documenting the video starting from:
<https://www.youtube.com/watch?v=d-zn-wv4Di8&t=460>

---

Why can we say that HTTP is built on TCP?

---

Why does Twitter use HTTP to build its own protocol?

Well, a Twitter client must be able to communicate with the Twitter servers over
the internet, and HTTP already solves  that problem reliably in the general case
(communication between any  client and any server).  No reason  to re-invent the
wheel.

---

<https://old.reddit.com/r/explainlikeimfive/comments/5imw65/eli5_what_does_stateless_nature_of_http_imply/>

---

In Wireshark, to view  a given conversation between hosts (the  one to which the
currently selected package belongs), you can open a flow graph window:

   - Statistics
   - Flow Graph (in the middle of the menu)
   - set the "Limit to display filter" checkbox (to remove irrelevant packets)
   - in the "Flow type" dropdown menu, select the relevant flow type; e.g. "TCP
     Flows" (to remove some overwhelming details about each packet)

And to  filter out the  packets irrelevant to  a given HTTP  conversation, press
C-A-S-h  while selecting  a relevant  packet.  This  should also  open a  window
displaying the client request (in red) and server response (in blue).

##
# Pitfalls
## My netcat doesn't support `-C`!

Use `echo(1)` to include CRLF inside the request via the escape sequence `\r\n`:

    $ echo -e 'GET /hypertext/WWW/TheProject.html HTTP/1.1\r\nHost: info.cern.ch\r\n\r\n' \
        | nc info.cern.ch 80

---

Or write the  request inside a file  and convert the latter from  Unix format to
DOS format with the `unix2dos` utility:

    $ tee /tmp/http_request <<'EOF'
    GET /hypertext/WWW/TheProject.html HTTP/1.1
    Host: info.cern.ch

    EOF

    $ sudo apt install dos2unix
    $ unix2dos /tmp/http_request
    $ nc info.cern.ch 80 </tmp/http_request

If you don't have `unix2dos`, use Vim for the conversion:

    $ vim +'write! ++ff=dos | quitall!' /tmp/http_request

## I don't have netcat!

Use `curl(1)`:

    $ echo -e 'GET /hypertext/WWW/TheProject.html HTTP/1.1\r\nHost: info.cern.ch\r\n\r\n' \
        | curl telnet://info.cern.ch:80

##
# Reference

[1]: https://datatracker.ietf.org/doc/html/rfc9112
[2]: https://datatracker.ietf.org/doc/html/rfc9112#section-2.1
[3]: https://datatracker.ietf.org/doc/html/rfc9112#section-3
[4]: https://datatracker.ietf.org/doc/html/rfc9112#section-3.1
[5]: https://developer.twitter.com/en/docs/twitter-api/tweets/lookup/quick-start
