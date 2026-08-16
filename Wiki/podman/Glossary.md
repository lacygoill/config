# b
## base image

Lowest layer of  an image, which provides the foundation  for subsequent layers.
It  typically  includes the  operating  system  and  libraries required  for  an
application to run.

---

There exist several base images, such as ubi8.
Each of them come with its own advantages and disadvantages.
The  choice depends  on the  specific requirements  of the  application and  the
preferences of the developer.

##
# c
## Linux capabilities

A  way to  divide the  privileges traditionally  associated with  superuser into
distinct units,  known as capabilities,  which can be independently  enabled and
disabled.

For more info: `man 7 capabilities`.

##
## cgroup

Linux kernel  feature which allows  processes to be organized  into hierarchical
groups, whose  usage of various  types of  resources (CPU, memory,  network) can
then be limited and monitored.

A cgroup is  intended to prevent one group of  processes from dominating certain
system  resources in  such a  way  that another  group of  processes can't  make
progress on the system.

See `man 7 cgroups`.

---

Actually, "cgroup" is a polyseme.
It can also refer to a collection  of processes subject to resource usage limits
and monitoring, set with the previously mentioned kernel feature.

##
## container
### container engine

Podman and  Docker are  container engines  intended to  develop, manage  and run
containerized applications.  Their job is to:

   - pull an image to the host, and unpack its contents

   - build a container runtime JSON file which describes how to run the
     containerized application

   - launch a container runtime (e.g. `crun(1)`), which reads the JSON file,
     sets up kernel cgroups, security constraints, namespaces, and finally
     launches the primary process (PID1) of the container

Buildah is another container engine, but it is only used for building images.

CRI-O and  containerd are also  container engines, but they're  purpose-built to
run  orchestrated Kubernetes  containers.   They  are not  intended  to be  used
directly by a user.

---

The container  runtime JSON file is  obtained by by merging  the image manifest,
its built-in defaults, and the user's input.  It can be read after the container
has been created with `$ podman inspect CONTAINER`.

---

A container engine can be launched:

   - directly by a user
   - out of a systemd unit file at boot
   - by a container orchestrator like Kubernetes

### container image

Consists of three components:

   - a directory tree containing all the software required to run an application

   - the manifest (a JSON file) that describes the contents of the directory
     tree (aka rootfs, aka root filesystem); the files are laid out as if their
     top level directory was the root (`/`) of a Linux system

   - the manifest list (another JSON file) which lets Podman pull the correct
     image for the architecture of the  machine it's running on, or for the
     desired architecture as specified by `--arch=`

The image manifest might also define:

   - the author of the image (`Author`)
   - the architecture for the image (`Architecture`)
   - the command to be run when the container starts (`Config.Cmd` field)
   - the environment variables to be set within the container (`Config.Env`)
   - the working directory (`Config.WorkingDir`)
   - the date the image was created (`Created`)
   - free-form labels to be used to search and describe the contents of the
     image (`Labels`)
   - the OS for the image (`Os`)
   ...

### container orchestrator

Software which orchestrates containers onto multiple different machines.
It communicates with a container engine to run the containers.

The primary container orchestrator is Kubernetes.
Docker Swarm is another example of a container orchestrator.

### container registry

Web server where images are stored (e.g. `docker.io` and `quay.io`).

### container runtime

Software which configures different parts of the Linux kernel and then, finally,
launches the containerized application.

The two  most commonly used  container runtimes  are `runc` and  `crun(1)`.  The
former is the default in Docker; it's a  big binary written in Go, which is slow
to start/stop a lot of containers.  The  latter is the default in Podman; it's a
small binary written in C, optimized to start/stop a lot of containers.

##
### Linux container

A way to run an application inside an isolated environment.

Applications running natively on a system share the same:

   - binaries
   - libraries
   - kernel
   - filesystem
   - network
   - users

This can cause issues when an  application is updated, especially with regard to
conflicting libraries or unsatisfied dependencies.

A  container image  solves this  dependency management  problem by  bundling all
the  software needed  to  run  an application  into  a  single unit  (libraries,
executables, and configuration files).  The developers and customers all run the
exact same containerized environment along with the application; this guarantees
consistency and limits the number of bugs caused by misconfiguration.

Also, a poorly-designed process can  dominate system resources, preventing other
processes from doing their job.  And a malicious process might steal data.

In contrast, a process running inside  a container (aka a containerized process)
doesn't suffer from  any of these issues, because it's  mostly isolated from the
host (it still interacts with the host kernel) via:

   - Linux namespaces
   - cgroups
   - security tools like:

      * dropped Linux capabilities (which limit the power of root)
      * read-only access to kernel filesystems (mounted on `/sys`, `/proc`, `/dev`, ...)
      * SELinux (which controls access to the filesystem)
      * seccomp (which limits the system calls available in the kernel)
      * user namespace (which allows access to limited root environments;
        limited in that it doesn't give root access to the host system)

#### What's the difference with a VM?

A VM needs  to manage an entire operating system  (kernel, init system, logging,
security  updates, backups,  ...) as  well  as the  isolated application,  which
creates overhead for the host.

In contrast, a container only runs  a containerized application (and its runtime
dependencies); there is no overhead and no additional OS management.

###
### rootless container

A container  which doesn't require  root access to be  run, because it's  run in
unprivileged mode (i.e. as a regular user).

###
# k
## Kubernetes (aka K8s)

Tool  to orchestrate  (deploy, scale,  manage) large  clusters of  containerized
microservices, which run on multiple machines at the same time.

It's a higher-level tool than Podman.

---

Podman   integrates   with   Kubernetes  via   `$ podman generate kube`,   which
generates  a  Kubernete  YAML  file  from  a  running  container/pod,  and  with
`$ podman  play kube`,  which  plays  a   Kubernetes  YAML  file  and  generates
pods/containers on your host.

##
# l
## layer

Images are divided into layers, that can be viewed as filesystems stacked on top
of  each other  (a  layer inherits  files from  the  layer below),  representing
changes that have been made to  the container's filesystem, such as installing a
package or modifying a file.

---

When a  container is  started, all of  the layers are  combined to  create a
single, unified view of the filesystem.

This approach  provides several benefits:

   - efficient use of disk space
   - fast container startup times
   - the ability to share common layers between multiple containers

##
# m
## microservice

A type of software architecture where  an application is broken down into small,
independent  services that  work together  to provide  functionality, in  a more
manageable, scalable and resilient way.

For example,  instead of designing  a monolithic application which  integrates a
web frontend,  a load balancer,  and a database,  you can build  three different
container images and make them  communicate with each other through well-defined
APIs or protocols; in effect, those are microservices.

Compared to a monolithic application, a microservice is easier to change, share,
reuse, and more resilient  (if it fails, it does not  necessarily bring down the
entire application).

### Why is a microservice more scalable than a monolithic application?

A monolithic  application is composed of  several services.  To handle  a bigger
load, you might  need to run several  instances of *one* of  those services (aka
"replicate").  But replicating  a whole monolithic application leads  to a waste
of resources, because there is no reason  to assume that *all* the services need
to be replicated in the same way.

Or  you  might  want  to  upgrade  your servers.   But  upgrading  for  a  whole
application  might  force you  to  upgrade  certain  computer parts  which  your
application  doesn't rely  on  as much,  and  which you  wouldn't  need to  with
microservices.

##
# n
## Linux namespace

A kernel feature which is necessary to enable Linux containers.
It exposes alternative  and isolated system resources  (e.g. network, filesystem
mounts, users, ...) to an isolated process.

There are eight kinds of namespaces:

   - PID (Process ID) namespace
   - User namespace
   - UTS (UNIX Time-Sharing) namespace
   - network namespace
   - IPC (InterProcess Communication) namespace
   - cgroup namespace
   - mount namespace
   - time namespace

### PID namespace

Processes  in different  PID  namespaces can  have the  same  PID.  This  allows
processes inside a  container to keep their PIDs after  suspending then resuming
the container, or after migrating it to a new host.

For more info, see: `man 7 pid_namespaces`.

### user namespace

Inside a user namespace, Podman can map:

   - the privileged UID `0` to your non-privileged UID on the host (necessary
     because most container images assume they start with root)

   - other UIDs  to some of your subordinate UIDs on the host, as specified in
     `/etc/subuid` (necessary because  the kernel disallows a non-privileged
     account to use several UIDs on the host)

For more info, see: `man 7 user_namespaces`.

---

UIDs and GIDs are assigned to processes, as well as stored on filesystem objects
(in  addition to  permissions).  Linux  controls  the processes'  access to  the
filesystem based  on these UIDs  and GIDs;  this access is  called Discretionary
Access Control.

---

`/etc/subuid` might contain something like:

    john:100000:65536

This specifies that inside the user namespace of `john`:

   - UID `1` is mapped to UID `100000` on the host
   - UID `2` is mapped to UID `100001` on the host
   ...
   - UID `65536` is mapped to UID `165535` on the host

As an example:

    # clear out all storage to get fresh environment
    $ podman rmi --all --force

    # launch a container with the `quay.io/rhatdan/myimage` image
    $ podman run --detach --publish=8080:8080 --name=myapp quay.io/rhatdan/myimage

    # `--user=root` for `find(1)` to be able to examine *all* files
    $ podman run --user=root --rm quay.io/rhatdan/myimage -- \
        bash -c 'find / -xdev -printf "%U=%u\n" | sort --numeric-sort --unique'
    0=root
    48=apache
    1001=default
    65534=nobody

According to the previous `/etc/subuid`, inside the container, the UIDs `48` and
`1001` are mapped to the UIDs `100047` and `101000` on the host.

### ?

    - A UTS namespace allows the isolation of the hostname.

    - A network namespace allows isolation of networking system resources, such
      as network devices, IPv4 and IPv6 protocol stacks, routing tables,
      firewall rules, port numbers, and so on.  Users can create virtual network
      devices called veth pairs to build tunnels between network namespaces.

    - An IPC namespace isolates IPC resources such as System V IPC objects and
      POSIX message queues.  Objects created in an IPC namespace can be accessed
      only by the processes that are members of the namespace.  Processes use
      IPC to exchange data, events, and messages in a client-server mechanism.

    - A cgroup namespace isolates cgroup directories, providing a virtualized
      view of the process's cgroups.

    - A mount namespace provides isolation of the mount point list that is seen
      by the processes in the namespace.

    - A time namespace provides an isolated view of system time, letting
      processes in the namespace run with a time offset against the host time.

---

    - it  has a separated filesystem view, and  its program is executed from the
      isolated filesystem itself

    - it's run under an independent process ID (PID)

    - it has its own user and group IDs (UID/GID)

    - it has its own network resources (network devices, IPv4 and IPv6 stacks,
      routing tables, firewall rules, ...)

    - ...

##
## nobody

Inside a user namespace, `nobody` is the owner of a file whose UID is not mapped
into that namespace (i.e. absent from `/proc/PID/uid_map`).  For example:

    $ podman unshare ls -ld /
    drwxr-xr-x ... nobody nogroup ... /
                   ^----^

On the  host, `/` is  owned by  root, but from  inside the user  namespace, it's
reported as owned  by `nobody`.  That's because  the UID `0` is  not mapped into
the user namespace.

---

Processes within  a user namespace only  have access to `nobody`  files based on
the world permissions:

    $ podman unshare bash -c "id --user; ls -l /etc/passwd; grep $USER /etc/passwd; touch /etc/passwd"
    0
    -rw-r--r-- 1 nobody nogroup 2952 Jun 10 08:25 /etc/passwd
    lgc:x:1000:1000:Lacygoill,,,:/home/lgc:/usr/bin/bash
    touch: cannot touch '/etc/passwd': Permission denied

In the output of this command:

   - `id(1)` tells us that we're root inside the user namespace
   - `ls(1)` tells us that `/etc/passwd` is owned by `nobody`

   - `grep(1)` tells us that we can read `/etc/passwd` (because it's world
     readable)

   - `touch(1)` fails because  even root is not  allowed to modify a  file not
     mapped into the user namespace (rightfully so, root is mapped to your user
     on the host, which is not allowed to modify a root file)

##
# o
## OCI

The Open Container Initiative is an  open governance structure which has written
standards for:

   - a container image and its manifest (aka the OCI Image Format Specification)

   - a container runtime (aka the OCI Runtime Specification)

   - APIs used by a container runtime to fetch container images and run them
     (aka the OCI Distribution Specification)

These  standards let  any container  engine work  with any  image stored  at any
container registry, and always in the exact same way.

For more information: <https://opencontainers.org>

##
# p
## pod

A group of one or more  containers with shared storage/network resources, shared
resources constraints (via  namespaces/cgroups), and a specification  for how to
run them.   A pod  lets you group  multiple services together  to form  a larger
service managed as a single entity.

## podman

Short for Pod Manager.

It's the Red Hat replacement for Docker, which is meant to run containers.
It comes with greatly enhanced security, and features that aren't in Docker.

It can run individual containers as well as pods.

##
# s
## scaling

Increasing the capacity of a web application to handle more workload or traffic.

### horizontal scaling

Adding more servers or instances of a service to distribute the workload.

Scaling out horizontally can be more cost-effective than scaling up vertically.

Microservices are often designed with horizontal scaling in mind, as they can be
deployed independently of each other.

### vertical scaling

Adding more resources (such as CPU, memory, or storage) to a single server.

##
## seccomp

Linux kernel mechanism that limits the set of syscalls a group of processes can call.

For more info: `man 2 seccomp`.

## SELinux

Security-Enhanced Linux  is a Linux  kernel mechanism that labels  every process
and every  filesystem object on the  system.  A SELinux policy  defines rules on
how labeled  processes interact with  label objects.  The Linux  kernel enforces
the rules.

##
# t
## transport

A couple image format + location.

Podman supports these transports:

### container-storage://

References an image located in a local storage.
This is the defaults for a local image.

### dir://

References an image compliant with the Docker image layout, similar to `oci://`,
but storing the files using the legacy docker format.

### docker://

References  an  image  stored  in  a  registry  website  (e.g.  `docker.io`  and
`quay.io`).

### docker-archive://

References an image in a Docker image layout that is packed into a TAR archive.

### docker-daemon://

References an image stored in the Docker daemon's internal storage.

### oci://

References an image compliant with  OCI layout specifications.  The manifest and
layer tarballs are located in the following local directory as individual files.

### oci-archive://

References an image compliant with OCI layout specifications that is packed into
a TAR archive.

##
# u
## ubi8

Base image maintained by Red Hat.
"ubi" stands for "Universal Base Image".
