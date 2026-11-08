# Benefits over Docker

   - can run containers in separate user namespaces
   - can run multiple containers within the same pod
   - can launch containers and pods based on Kubernetes YAML files
   - can generate Kubernetes-compliant YAML files from running containers
   - can be upgraded without stopping all containers (since the Docker daemon is
     monitoring containers, by default, when it stops, all containers stop)

## rootless containers

Podman does not require root access  to run containers.  It runs in unprivileged
mode.

This means that  if a hacker breaks  out of a container, they  only have control
over unprivileged processes; they can't do more damage than a regular user.
Besides, all actions  on the system are  recorded in the audit  logs, even after
removing the container.

---

To  achieve something  similar in  Docker,  you need  to  add your  user to  the
`docker` group, but you  can still gain full root access on  the host by running
the following command:

    $ docker run --interactive --tty --name=hacker \
        --privileged --volume=/:/host ubi8 chroot /host

This mounts  the entire  host operating  system (`/`)  on the  `/host` directory
within  the container.  `--privileged` turns  off all  container security.   And
`$ chroot /host` chroots to `/host`.

From there,  you are in a  root shell at the  root of the host  filesystem, with
full root privileges, meaning you can do whatever you want.

When you are done, you can remove the container and all records of what you did:

    $ docker rm hacker

All  records  of you  launching  the  container  are  erased (unless  Docker  is
configured with non-default file logging).

BTW, this is worse than using `sudo(8)`; at least, the latter is logged.

---

Actually, Docker can run rootless, but almost no one runs it that way.  Starting
up multiple  services in your home  directory just to launch  a single container
has not caught on.

### But doesn't `--privileged` give root access in Podman too?

No, it only turns off the security  features that isolate the container from the
host, like:

   - dropped capabilities
   - read-only mount points
   - Apparmor/SELinux separation
   - seccomp filters

That doesn't give  root privileges to the container process,  because the latter
is a descendant of Podman which runs as your regular user.

In contrast, in Docker, the container process  is not a descendant of the Docker
client  from which  it was  run;  it's a  descendant of  `containerd` (a  Docker
daemon) which runs as root.

##
## daemonless

Podman runs like a traditional command-line tool.

Docker requires multiple root-running daemons.

The Docker  client communicates with  the Docker engine  (a daemon) over  a Unix
socket.   In turn,  the Docker  engine communicates  with `containerd`  (another
daemon),  which  fork/execs a  runtime  container,  which finally  fork/execs  a
container.

In contrast,  Podman simply  fork/execs a runtime  container which  fork/execs a
container.  There is no equivalent for  the Docker client, nor for `containerd`.
The equivalent of the Podman process is the Docker engine daemon; the difference
between them is that Podman does not run as a root daemon.

---

The  client-server  architecture  used  by  Docker is  quite  complex  and  adds
overhead.  Besides, a failure  in one of the daemons can  lead to all containers
shutting  down; when  that  happens,  it might  be  difficult  to diagnose  what
happened.

## systemd integration

Podman can run systemd inside a container, which lets you run a service within a
container via a regular unit file.

Besides, systemd can  manage the life cycle  of a Podman container  as a service
specified in a unit file.  In particular,  a container can be started or stopped
at boot time.

Also, Podman  can generate a  systemd unit  file (following best  practices) for
running a container within a systemd service.

---

In contrast,  Docker does not support  running systemd inside a  container.  And
only the  Docker daemon  can manage the  life cycle of  a Docker  container, but
since systemd has more features in that domain, Docker misses:

   - startup ordering
   - socket activation
   - service ready notifications
   ...

## pods

Podman can manage groups of containers together in a pod.

## more customizable

Podman lets you  configure the namespaces and capabilities  which containers run
with, whether or not SELinux is enabled, registries for unqualified image names,
etc.

With  Docker, most  of these  values  are hard-coded  and cannot  be changed  by
default.

---

For  example,  an  unqualified  image  name is  hard-coded  to  be  pulled  from
`docker.io`.  So this fails:

    $ docker pull ubi8/httpd-24
    Using default tag: latest
    Error response from daemon: pull access denied for ubi8/httpd-24,
    repository does not exist or may require 'docker login': denied: requested
    access to the resource is denied

Because the image  is not on `docker.io`;  it's on `registry.access.redhat.com`.
You need to fully qualify the image name by adding the domain name:

    $ docker pull registry.access.redhat.com/ubi8/httpd-24
                  ^-------------------------^

    The Docker engine gives docker.io an advantage over other container registries as the

But this works:

    $ podman pull ubi8/httpd-24
    ? Please select an image:
      ▸ docker.io/ubi8/httpd-24:latest
        quay.io/ubi8/httpd-24:latest

Note that the prompt is temporary.   Once you make your decision, Podman records
the short-name alias and no longer  prompts you; it uses the previously selected
registry.

## multiple transports

   - `container-storage://`
   - `dir://`
   - `docker://`
   - `docker-archive://`
   - `docker-daemon://`
   - `oci://`
   - `oci-archive://`

## user-namespace support

Podman is  fully integrated  with the user  namespace, which  provides isolation
between users on a system.  All containers of a given rootless user are launched
inside the  same user namespace (otherwise,  sharing content and other  types of
namespaces would be impossible).

---

In theory, Docker  can run containers in separate namespaces,  but almost nobody
uses that feature.  Probably because:

   - it's not enabled by default
   - it requires some complex configuration
     (https://docs.docker.com/engine/security/userns-remap/)
   - it can cause compatibility issues with certain applications or system
     configurations

This means that in practice, Docker runs  all containers of all users within the
same user  namespace.  Root  in one  container is  the same  as root  in another
container,  which means  containers  attack  each other  from  a user  namespace
perspective.

##
# WIP
## `podman-search(1)`

TODO: Write a shell snippet for this command:

    $ podman image search --filter='is-official,stars=100' --format='table {{.Index}} {{.Name}} {{.Stars}}' ubuntu

Issue: It *seems* we can use a regex:

    $ podman image search --format='table {{.Name}}' '.*ubuntu.*'
                                                      ^--------^

But then, we lose matches from `docker.io`.  Why?

Also, only matches  from `docker.io` are reported to have  stars.  And yet, when
we visit `quay.io` from Firefox, images do have stars.  What gives?

Also, note that the `is-official` filter  seems to remove all images which don't
come from `docker.io`.

##
## Working with containers

Building a containerized application involves 4 steps:

   1. launch a container
   2. modify its contents
   3. create an image
   4. ship it to a registry

This can be automated to maintain the security of the image.

### Exploring containers
#### run your first container

    $ podman run --interactive --tty --rm registry.access.redhat.com/ubi8/httpd-24 bash

This command reaches out to the `registry.access.redhat.com` container registry,
pulls down an image, and store it in your local container storage.

By default `podman-run(1)` executes the  containerized command in the foreground
until the container  exits.  Here, you end  up at a Bash prompt.   When you exit
Bash, Podman stops the container.

---

Experiment inside the container:

    $ pwd
    /opt/app-root/src

    $ whoami
    default

    $ ps -e | wc -l
    2

###
### Running the containerized application
#### run a containerized web server

    $ podman run --detach --publish=8080:8080 --name=myapp registry.access.redhat.com/ubi8/httpd-24
    444b7958f052303de1ded6140eecf2c1aa467b7838e40bd50327bb5c94c7a80a
    ^--------------------------------------------------------------^
                                  UUID

#### communicate with the web server from a web browser on the host

    $ browse http://localhost:8080

###
### Starting containers
#### `podman-start(1)`

Start one or more containers.

One common use case for `podman-start(1)` is starting a container after a reboot
to start all of the containers that were stopped during shutdown.

Some useful options are:

   - `--all`: start all of the stopped containers in container storage
   - `--attach`: attach terminal to output of container
   - `--interactive`: attach terminal input to container

##
### exec-ing into a container

`podman-exec(1)` is useful to execute a given command within a running container to:

   - debug or examine what is going on
   - modify some of the content the container is using

#### modify web page given by web server

    $ podman container exec --interactive myapp tee /var/www/html/index.html <<EOF
    <html>
      <head>
      </head>
      <body>
        <h1>Hello World</h1>
      </body>
    </html>
    EOF

Here,  we've  executed   a  `tee(1)`  command  into  the   container  to  create
`/var/www/html/index.html`, which just contains a "Hello World" header.

---

`--interactive` is necessary for `tee(1)` to be fed the contents of the heredoc.
Otherwise, its STDIN would be closed.

---

If  you  stopped   the  `myapp`  container,  you  need  to   restart  it,  since
`podman-exec(1)` only works on running containers.

#### check web page has been modified

    $ podman container exec myapp cat /var/www/html/index.html
    $ browse http://localhost:8080

###
### Creating an image from a container

TODO: Page 39 of PDF.
