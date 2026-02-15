# Document how to start a job which doesn't stop when we close the shell.

I had this alias in the past:

    alias dropbox_restart='killall dropbox; ( "${HOME}/.dropbox-dist/dropboxd" & )'

The reason  why I started  dropbox from  a subshell was  to avoid the  job being
terminated when we left the shell from which we ran the alias.
When we start a job from a  subshell, it seems that it's immediately re-parented
to the session leader (here it was `upstart`).

May be relevant:

- <https://blog.debiania.in.ua/posts/2013-03-13-fun-with-bash-disown.html>
- <https://thinkiii.blogspot.com/2009/12/double-fork-to-avoid-zombie-process.html>

Make sure it's true.
Check whether  there're other ways to  start a job which  persists after leaving
the shell (`nohup`, `&!`, ...).
Which way is the most reliable?

Study the PGID and the file descriptors of a process in a subshell vs in a script.

Is a subshell interactive?

# Document `$ pkill --euid toto`

Kills all processes whose EUID is toto.

# Document the process state code `I`

It means that the process is *i*dle.

- <https://stackoverflow.com/a/49407039/9780968>
- <https://elixir.bootlin.com/linux/v4.15.12/source/fs/proc/array.c#L135>

# Document how a child process dies

I think it calls `exit(2)` and returns its exit status to the kernel.
Then, the kernel:

   - terminates the child
   - closes all its open file descriptors
   - reparent its possible children to a subreaper or init

At that moment, the child is a  zombie, because it has terminated but the kernel
sill keeps some  info about it; notably,  its PID in the process  table, and its
exit status.

Then, the kernel sends SIGCHLD to the parent process.
The latter should then collect the exit status via wait(2).
Finally, the kernel removes the PID of the zombie from the process table.

See `man 2 exit`:

   > The  function _exit()  terminates the  calling process  "immediately".  Any
   > open file descriptors belonging to the  process are closed; any children of
   > the process are  inherited by process 1, init, and  the process's parent is
   > sent a SIGCHLD signal.

   > The value  status is returned to  the parent process as  the process's exit
   > status, and can be collected using one of the wait(2) family of calls.

# Document the difference between a task, a process and a thread

I  think   a  thread  is  a   lightweight  process  that  you   haven't  started
intentionally.
Instead,  it was  spawned by  another process,  probably to  improve performance
(i.e. by leveraging multi-core cpus to execute several unit of executions).

I think a task is a process  you've started (e.g. firefox), plus all the threads
it has itself spawned.

When you view an image such as:
<https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Multithreaded_process.svg/1024px-Multithreaded_process.svg.png>
I think that the text "process" should be replaced by "task".
From the  kernel point  of view,  there's no (or  little?) difference  between a
process and a thread.
So saying that a process is a group of threads is misleading.
A *task* is a heavy process + a group of lightweight threads.

---

In `htop(1)`, you can view the number of tasks.
You can also hide/show the threads created by:

   - user processes by pressing `H`
   - kernel processes by pressing `K`

What is shown in the column PID of htop is not always a PID.
I think sometimes, it's a TID (Thread ID):

    $ ps -e -f -L | sed '/UID\|cmus/!d' | grep -v sed

Notice how all  the lines show the  same PID, but not the  same LWP (LightWeight
Process id); see `man ps /lwp\s*LWP`.

   > lwp         LWP       light weight process (thread) ID of the
   >                       dispatchable entity (alias spid, tid).  See tid
   >                       for additional information.

However, things are confusing, because it seems that a TID can appear as a PID:

   > tid         TID       the unique number representing a dispatchable
   >                       entity (alias lwp, spid).  This value may also
   >                       appear as: a process ID (pid); a process group ID
   >                       (pgrp); a session ID for the session leader
   >                       (sid); a thread group ID for the thread group
   >                       leader (tgid); and a tty process group ID for the
   >                       process group leader (tpgid).

Difference between PID and TID: <https://stackoverflow.com/a/8787888/9780968>

Edit: I think I get it.
When you start a heavy process, its PID and TID are equal.
But then,  if it spawns threads,  their TIDs are  different from the PID  of the
heavy process.
You can check  this by looking at the  first line in the output  of the previous
`ps(1)` command: the first cmus process has a  PID equal to its TID, but not the
other threads.

---

In case  you wonder  why `htop(1)`  considers that  you have  *multiple* firefox
tasks, maybe it's because one task is created per tab you've opened and visited.
Or maybe viewing an embedded video on a webpage starts another task.
Or maybe downloading a file from a webpage starts another task.
...
You get the idea: the browser rarely performs only one task.

---

Note that not all programs are multi-threaded.
For example, WeeChat doesn't seem to be.
Press `\  weechat Enter`  in htop,  then `H` to  show the  user threads:  no new
process is displayed.

OTOH, cmus is multi-threaded.
Press `\ cmus Enter` in htop, then `H`  to show the user threads: a bunch of new
processes are displayed.

---

<https://en.wikipedia.org/wiki/Thread_(computing)>
Difference Between Process and Thread: <https://www.youtube.com/watch?v=O3EyzlZxx3g>
Intro to Processes & Threads: <https://www.youtube.com/watch?v=exbKr6fnoUw>
Process Management (Processes and Threads): <https://www.youtube.com/watch?v=OrM7nZcxXZU>

# Define what a system call (or syscall) is

<https://en.wikipedia.org/wiki/System_call>

##
# ?

<http://www.linusakesson.net/programming/tty/>

# ?

Understand the output of `free --human`:

                   total       used        free      shared  buff/cache   available
    Mem:           3,6G        1,8G        408M        262M        1,4G        1,2G
    Swap:          3,8G         50M        3,8G

`Shared` is an obsolete concept and `total` is easy to understand:

                   used        free    buff/cache   available
    Mem:           1,8G        408M          1,4G        1,2G
    Swap:           50M        3,8G

# ?

<https://unix.stackexchange.com/questions/138463/do-parentheses-really-put-the-command-in-a-subshell/138498#comment772229_138498>

Why does the manual say "The order of expansions is:

... parameter and  variable expansion, ..., and command substitution  (done in a
left-to-right fashion); word splitting; and filename expansion." Isn't this kind
of misleading?
I had interpreted the manual to mean $x would be expanded first as it has higher
precedence than command substitution.
But apparently this is not the case, as you correctly point out.

    x=1
    echo $(x=2; echo $x)

Which has the priority: variable expansion or command substitution?

# ?

When  we execute  a job  in a  subshell, it's  automatically re-parented  to the
session leader (upstart atm).

I think it's because, even though there's only one command, the subshell doesn't
`exec()` to start the job (i.e. no optimization).
Instead, it `fork()`, then `execve()`.
Once the job has been started in the sub-sub-shell, the sub-shell dies (why?).
So, the job becomes orphan and is re-parented to the session leader.

MRE:

    $ (sleep 100 &)
    $ pstree --long --show-parents --show-pids $(pidof -s sleep)
    systemd(1)───lightdm(980)───lightdm(1086)───upstart(1096)───sleep(8274)˜
                                                ^-------------------------^

---

How to start a job as a daemon?

Solution 1:

    $ (cmd &)

Solution 2:

    $ cmd &
    $ disown %

I think the first solution is more powerful.
Because the second one doesn't work if the job takes time to be started.

If the job contains several commands:

    $ ({ cmd1; cmd2 ;} &)
    $ pstree --long --show-parents --show-pids $(pidof -s sleep)
    systemd(1)───lightdm(980)───lightdm(1086)───upstart(1096)───bash(11880)───sleep(11881)˜
                                                                ^---------^
                                                                this time, the subshell doesn't die˜

---

Explain why none of these work:

    alias dropbox_restart='killall dropbox; ( "${HOME}/.dropbox-dist/dropboxd" ) &'
    alias dropbox_restart='killall dropbox; { "${HOME}/.dropbox-dist/dropboxd" & ;}'
    alias dropbox_restart='killall dropbox; { "${HOME}/.dropbox-dist/dropboxd" ;} &'

Note that according to [Gilles](https://unix.stackexchange.com/a/88235/289772):

   > Parentheses  create a  subshell whereas  braces  don't, but  this is  irrelevant
   > (except as a micro-optimization in some  shells) since a backgrounded command is
   > in a subshell anyway.

# ?

    $ cat /tmp/sh.sh
        #!/bin/bash -
        /tmp/sh1.sh

    $ cat /tmp/sh1.sh
        #!/bin/bash -
        sleep

    $ /tmp/sh.sh &

    $ pstree --long --show-parents --show-pids $(pidof -s sleep)
    systemd(1)───lightdm(980)───lightdm(1086)───upstart(1096)───tmux: server(2784)───bash(29746)───sh.sh(32569)───sh1.sh(32+˜

If you kill `sh.sh`, you get this new process tree:

    systemd(1)───lightdm(980)───lightdm(1086)───upstart(1096)───sh1.sh(32570)───sleep(32571)

This shows  that when  a process  dies, its child  is re-parented  to init  or a
subreaper (here the session leader upstart).

If you kill `sh1.sh`, you get this new process tree:

    systemd(1)───lightdm(980)───lightdm(1086)───upstart(1096)───sleep(32571)

Again, the orphan (`sleep`) is re-apparented to the session leader.

---

However, if you kill the shell from which the script was started, then `sleep` is killed too.

    $ pstree --long --show-parents --show-pids $(pidof -s sleep)
    systemd(1)───lightdm(980)───lightdm(1086)───upstart(1096)───tmux: server(2784)───bash(29746)───sh.sh(32569)───sh1.sh(32+
                                                                                     ^--^
    $ kill -1 29746
            ^
            TERM is not enough

This shows that when you exit a shell, the latter sends SIGHUP to all its children.

---

    systemd(1)---lightdm(980)---lightdm(1086)---upstart(1096)---sh(6583)---run-or-raise(6584)---firefox(6586)...
                                                                │          │
                                                                │          └ /bin/bash ~/bin/run-or-raise firefox
                                                                │
                                                                └ sh -c ~/bin/run-or-raise firefox

    systemd(1)---lightdm(980)---lightdm(1086)---upstart(1096)---sh(2426)---run-or-raise(2427)---urxvt(2429)-+-urxvt(2430)
                                                                │          │
                                                                │          └ /bin/bash /home/user/bin/run-or-raise urxvt
                                                                │
                                                                └ sh -c ${HOME}/bin/run-or-raise urxvt

---

    $ cat /tmp/sh.sh
        mousepad [&]

    $ /tmp/sh.sh

        systemd(1)---lightdm(980)---lightdm(1086)---upstart(1096)---mousepad(30648)-+-{dconf worker}(30649)
                                                                                    |-{gdbus}(30651)
                                                                                    `-{gmain}(30650)

# Orphan process

A  process can  be orphaned  unintentionally, such  as when  the parent  process
terminates or crashes.
The  process group  mechanism can  be used  to help  protect against  accidental
orphaning, where in coordination with the user's shell will try to terminate all
the child processes with the "hangup"  signal (SIGHUP), rather than letting them
continue to run as orphans.
More precisely, as part of job control,  when the shell exits, because it is the
"session  leader" (its  session id  equals  its process  id), the  corresponding
login  session ends,  and  the shell  sends  SIGHUP to  all  its jobs  (internal
representation of process groups).

It is sometimes desirable to intentionally  orphan a process, usually to allow a
long-running job  to complete  without further  user attention,  or to  start an
indefinitely running service or agent.
Such  processes   (without  an  associated   session)  are  known   as  daemons,
particularly if they are indefinitely running.
A  low-level approach  is to  fork  twice, running  the desired  process in  the
grandchild, and immediately terminating the child.
The grandchild process  is now orphaned, and is not  adopted by its grandparent,
but rather by init.
In any event, the session id (process  id of the session leader, the shell) does
not change,  and the process id  of the session that  has ended is still  in use
until all orphaned processes either terminate  or change session id (by starting
a new session via setsid(2)).

To  simplify system  administration,  it is  often desirable  to  use a  service
wrapper so that processes not designed  to be used as services respond correctly
to system signals.
An alternative  to keep  processes running  without orphaning them  is to  use a
terminal multiplexer and  run the processes in a detached  session (or a session
that becomes detached), so the session is  not terminated and the process is not
orphaned.

A server process is also said to  be orphaned when the client that initiated the
request unexpectedly crashes  after making the request while  leaving the server
process running.

These  orphaned processes  waste server  resources and  can potentially  leave a
server starved for resources.
However, there are several solutions to the orphan process problem:

   - Extermination is the  most commonly used technique; in this  case the
     orphan is killed.

   - Reincarnation is  a technique in  which machines periodically try  to
     locate the parents  of any remote  computations; at which point  orphaned
     processes are killed.

   - Expiration is a technique where each process is allotted a certain amount
     of time to finish before being killed.  If need be a  process may "ask" for
     more time to  finish before the allotted time expires.

# Zombie process

A zombie  process or defunct process  is a process that  has completed execution
(via the exit system call) but still has  an entry in the process table: it is a
process in the "Terminated state".
This occurs for  child processes, where the  entry is still needed  to allow the
parent process to read its child's exit status: once the exit status is read via
the wait system call,  the zombie's entry is removed from  the process table and
it is said to be "reaped".
A child  process always  first becomes  a zombie before  being removed  from the
resource table.
In most cases,  under normal system operation zombies are  immediately waited on
by their parent and then reaped by  the system – processes that stay zombies for
a long time are generally an error and cause a resource leak.

The term zombie process derives from the common definition of zombie — an undead
person.
In  the term's  metaphor, the  child process  has "died"  but has  not yet  been
"reaped".
Also,  unlike normal  processes, the  kill  command has  no effect  on a  zombie
process.

Zombie processes should not be confused with orphan processes: an orphan process
is a process that is still executing, but whose parent has died.
These do not remain as zombie  processes; instead, (like all orphaned processes)
they are adopted by init (process ID 1), which waits on its children.
The result is that a process that is  both a zombie and an orphan will be reaped
automatically.

When a process ends via exit, all of the memory and resources associated with it
are deallocated so they can be used by other processes.
However, the process's entry in the process table remains.
The parent can read  the child's exit status by executing  the wait system call,
whereupon the zombie is removed.
The wait call may be executed in sequential code, but it is commonly executed in
a handler for the SIGCHLD signal, which the parent receives whenever a child has
died.

After  the zombie  is removed,  its process  identifier (PID)  and entry  in the
process table can then be reused.
However, if a parent fails to call wait,  the zombie will be left in the process
table, causing a resource leak.
In some situations this may be desirable – the parent process wishes to continue
holding this resource – for example  if the parent creates another child process
it ensures that it will not be allocated the same PID.

Zombies can be identified in the output from the Unix ps command by the presence
of a "Z" in the "STAT" column.
Zombies that exist for more than a short period of time typically indicate a bug
in the parent  program, or just an  uncommon decision to not  reap children (see
example).
If the parent program is no  longer running, zombie processes typically indicate
a bug in the operating system.
As with other resource leaks, the presence  of a few zombies is not worrisome in
itself, but may indicate a problem that would grow serious under heavier loads.
Since there is no memory allocated to  zombie processes – the only system memory
usage is  for the  process table entry  itself – the  primary concern  with many
zombies is not  running out of memory,  but rather running out  of process table
entries, concretely process ID numbers (`$ cat /proc/sys/kernel/pid_max`).

To remove zombies  from a system, the  SIGCHLD signal can be sent  to the parent
manually, using the kill command.
If the parent process still refuses to reap  the zombie, and if it would be fine
to terminate  the parent  process, the  next step  can be  to remove  the parent
process.
When a process loses its parent, init becomes its new parent.
init periodically executes the wait system call to reap any zombies with init as
parent.

---

<https://unix.stackexchange.com/a/5648/289772>

You may sometimes see entries marked Z in the ps or top output.
These  are technically  not  processes,  they are  zombie  processes, which  are
nothing more than an entry in the  process table, kept around so that the parent
process can be notified of the death of its child.
They will go away when the parent process pays attention via wait(2) (or dies).

---

How to reap a zombie?

    $ gdb -p PPID
    (gdb) call waitpid(PID, 0, 0)
    (gdb) quit

PID is the PID of the zombie, and PPID is the PID of its parent.

<https://serverfault.com/a/101525>

You can test this solution like so:

    $ tee /tmp/zombie.c <<'EOF'
    // https://vitux.com/how-to-create-a-dummy-zombie-process-in-ubuntu/
    #include <stdlib.h>
    #include <sys/types.h>
    #include <unistd.h>
    int main ()
    {
    pid_t child_pid;child_pid = fork ();
    if (child_pid > 0) {
    // replace 3600 with the time in seconds during which the zombie should run
    sleep (3600);
    }
    else {
    exit (0);
    }
    return 0;
    }
    EOF

    $ cc /tmp/zombie.c -o /tmp/zombie
    $ /tmp/zombie &!
    $ ps -e --format=pid,ppid,stat,args | grep [d]efunct
    22511 22510 ZN   [zombie] <defunct>˜

    $ gdb -p 22510
    (gdb) call waitpid(22511, 0, 0)
    (gdb) quit
    $ ps -e --format=pid,ppid,stat,args | grep [d]efunct
    ''˜

    $ killall zombie

Document that there are at least two other ways:

   - kill the parent (should always work: the zombie is adopted by a subreaper, then reaped)
   - send SIGCHLD to the parent (may not work if the parent doesn't wait(2) – I think)

---

From `man 2 wait`:

   > A child that terminates, but has not been waited for becomes a "zombie".
   > The kernel maintains a minimal set of information about the zombie process (PID,
   > termination status, resource usage information) in  order to allow the parent to
   > later perform a wait to obtain information about the child.
   > As long as a zombie is not removed from the system via a wait, it will consume a
   > slot  in the  kernel process  table, and  if this  table fills,  it will  not be
   > possible to create further processes.
   > If a parent process terminates, then  its "zombie" children (if any) are adopted
   > by init(1), which automatically performs a wait to remove the zombies.

---

   > processes that stay zombies for a long time are generally an error and cause a **resource leak**.
<https://en.wikipedia.org/wiki/Zombie_process>

   > In  computer  science,  a  resource  leak  is  a  particular  type  of  resource
   > consumption by a  computer program where the program does  not release resources
   > it has acquired.
   > This condition is normally the result of a bug in a program.

   > Examples  of resources  available in  limited  numbers to  the operating  system
   > include  internet sockets,  file  handles, **process  table  entries, and  process**
   > **identifiers (PIDs)**.
   > Resource leaks  are often a  minor problem, causing  at most minor  slowdown and
   > being recovered from after processes terminate.
   > In  other  cases  resource  leaks  can be  a  major  problem,  causing  resource
   > starvation  and severe  system  slowdown or  instability,  crashing the  leaking
   > process, other processes, or even the system.
   > Resource leaks often go unnoticed under light load and short runtimes, and these
   > problems only manifest themselves under heavy system load or systems that remain
   > running for long periods of time.

<https://en.wikipedia.org/wiki/Resource_leak>

   > In computing,  a (system)  resource is  any physical  or virtual  component of
   > limited availability within a computer system.
   > Every device connected to a computer system is a resource.
   > Every internal system component is a resource.
   > Virtual  system  resources  include  files (concretely  file  handles),  network
   > connections (concretely network sockets), and memory areas.

<https://en.wikipedia.org/wiki/System_resource>

---

Document that `~/bin/signals-disposition`  is useful to check  whether a process
is blocking `CHLD`, which can explain why it has zombies.
And that  more generally, `/proc/PID/status` contains  a lot of useful  info for
debugging an issue.

I think that when a process blocks a signal, it tells the OS never to send it.
OTOH, when a process ignores a signal, the OS can still send it, but the process
doesn't react to it.

# Daemon

A daemon is a program that runs as a background process, rather than being under
the direct control of an interactive user.
Traditionally,  the  process names  of  a  daemon end  with  the  letter d,  for
clarification that  the process  is in  fact a  daemon, and  for differentiation
between a daemon and a normal computer program.
For example, syslogd is the daemon  that implements the system logging facility,
and sshd is a daemon that serves incoming SSH connections.

The parent process of a daemon is often, but not always, the init process.
A daemon is usually either created by a process forking a child process and then
immediately exiting,  thus causing init  to adopt the  child process, or  by the
init process directly launching the daemon.
In addition,  a daemon launched  by forking  and exiting typically  must perform
other operations, such as dissociating the process from any controlling terminal
(TTY).  Such  procedures are often  implemented in various  convenience routines
such as `daemon(3)`.

Systems often start daemons at boot time which will respond to network requests,
hardware activity, or other programs by performing some task.
Daemons such as cron may also perform defined tasks at scheduled times.

The term  is inspired from  Maxwell's demon, an  imaginary being from  a thought
experiment that constantly works in the background, sorting molecules.
Unix systems inherited this terminology.
Maxwell's Demon is consistent with  Greek mythology's interpretation of a daemon
as  a supernatural  being working  in the  background, with  no particular  bias
towars good or evil.

After  the  term  was  adopted  for  computer use,  it  was  rationalized  as  a
"backronym" for Disk And Execution MONitor.

Daemons which connect to a computer network are examples of network services.

In a strictly technical sense, a process is a daemon when:

   - its parent process terminates
   - it's assigned the init process as its parent process
   - it has no controlling terminal

However, more generally a daemon may  be any background process, whether a child
of the init process or not.

The common method for a process to  become a daemon, when the process is started
from the  command-line  or from a  startup script  such as an  init script  or a
SystemStarter script, involves:

   - Optionally removing unnecessary variables from environment.

   - Executing as a background task by  forking and exiting (in the parent
     "half" of the fork).  This  allows daemon's  parent (shell  or  startup
     process)  to receive  exit notification and continue its normal execution.

   - Dissociating from  the controlling TTY

   - Creating a new session  and becoming the session leader of that session.

   - Becoming a process group leader.
     These  three  steps  are  usually  accomplished  by  a  single  operation,
     setsid().

   - If  the daemon  wants  to  ensure that  it  won't  acquire a  new
     controlling  TTY even  by  accident  (which happens  when  a session
     leader without a controlling TTY opens a free TTY), it may fork and exit
     again.  This means  that it is no  longer a session  leader in the new
     session, and can't acquire a controlling TTY.

   - Setting the root directory (/) as  the current working directory so that
     the process does  not keep any directory  in use that  might be on
     a  mounted filesystem (allowing it to be unmounted).

   - Changing the umask to 0 to allow open(), creat(), and other operating
     system calls to provide their  own permission masks and not to  depend on
     the umask of the caller

   - Closing all inherited files  at the time of execution that are left open
     by the  parent process, including file descriptors 0,  1 and 2 for the
     standard streams (stdin, stdout and stderr).  Required files will be opened
     later.

   - Using a logfile, the console, or /dev/null as stdin, stdout, and stderr

If the process is  started by a super-server daemon, such  as inetd, launchd, or
systemd, the  super-server daemon will  perform those functions for  the process
(except for old-style  daemons not converted to run under  systemd and specified
as Type=forking and "multi-threaded" datagram servers under inetd).
