<https://www.youtube.com/watch?v=VXmvM2QtuMU>

# A server can designate a software or a hardware.

For example, the Minecraft game runs a *software* server.
And you can also rent a dedicated *hardware* server from a company like OVH.

# Being a server is not an intrinsic quality.  It describes a purpose/role/behavior.

For example, a gaming console can sometimes  be used as a media server.  In that
sense, the  machine could  be described as  a server *when*  it's used  to serve
media contents to clients on the home network.

The main purpose fulfilled by a machine  determines whether we call it a server;
not its technical specifications.  The same goes for a software.

A server is  just a component that  acts upon request, and responds  to what was
requested.

## This means that you can't always tell whether a software is a client or a server.

It might  depend on  the context and  the layer we're  talking about.   The same
software can sometimes (or  on some layer) act as a server,  and other times (or
on some other layer) as a client.

As an  example, a P2P program  can act as a  server or as a  client depending on
whether it uploads or downloads a file.

## The same goes for other terms.

Just like "client" and "server", the following terms are also used to describe a
certain role/behavior of a system:

   - controller & target
   - master & slave
   - primary & secondary
   - provider & consumer
   ...

And just like "client" and "server", how  those terms are meant to be used might
depend on the context.

##
# A client and server often use sockets to communicate.
## They can be IP sockets:
### install the `flask` module and write a simple web server application

    $ pipx install flask

    $ tee /tmp/server.py <<'EOF'
    #!/usr/bin/env python3

    from flask import Flask

    app = Flask(__name__)

    @app.route('/')
    def hello_world():
        return '<p>Hello, World!</p>'
    EOF

Notice that the  Python code doesn't create sockets; that's  because the `flask`
module will do it automatically for us.

The Python code of the server can be found here:
<https://flask.palletsprojects.com/en/2.2.x/quickstart/#a-minimal-application>

### start the web server and check that IP sockets are indeed created

    $ strace -f --trace=%net flask --app=/tmp/server.py run --host=127.0.0.1 --port=5000

`strace(1)` starts the `flask` process, and at  the same time records all of its
system calls.  It's called with these options:

   - `-f` traces  child processes  which the  flask process might  start (e.g.
     with  `fork(2)`);  useful in  case  the  system calls  we're interested in
     are not executed by the original parent process but by one of its
     descendants

   - `--trace=network` limits the trace to network related  system calls (useful
     to reduce noise in the output)

The `flask` process loads the  `server.py` application (via `--app`), then `run`
a  web server  on the  local host  (`--host=127.0.0.1`) listening  to port  5000
(`--port=5000`).

Notice how the trace includes `socket(2)` system calls, like this one:

    socket(AF_INET, SOCK_STREAM|SOCK_CLOEXEC, IPPROTO_IP) = 3
    ^----^

BTW, you can visit the webpage by clicking on this line:

     * Running on http://127.0.0.1:5000
                  ^-------------------^

##
## Or they can be Unix sockets:
### install and start mozillavpn

    $ sudo add-apt-repository ppa:mozillacorp/mozillavpn
    $ sudo apt update
    $ sudo apt install mozillavpn
    $ mozillavpn

Source: <https://support.mozilla.org/en-US/kb/how-install-mozilla-vpn-linux-computer>

### observe that 2 processes are running, and that a Unix socket has been created

    $ ps -e -f | grep -i 'mozilla.*vpn'
    root ... /usr/bin/mozillavpn linuxdaemon
    user ... mozillavpn

The `mozillavpn` command has actually started 2 processes:

   - an unprivileged one, for the UI (which asks for your credentials)
   - a privileged one (a daemon), to configure the network (which requires root
     privileges) and start a VPN

The UI is a client, and the daemon is a server.
They communicate via a Unix socket:

    $ ls -F /tmp/mozillavpn.ui.sock
    /tmp/mozillavpn.ui.sock=
                           ^
                           indicator for socket file

### clean up

    $ sudo killall mozillavpn
    $ sudo apt purge mozillavpn
    $ sudo ppa-purge ppa:mozillacorp/mozillavpn
    $ sudo apt autoremove
