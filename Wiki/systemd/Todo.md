# `man 7 bootup` is *very* interesting (and short); read it

In particular, its `SYSTEM MANAGER BOOTUP` and `USER MANAGER STARTUP` sections.

---

   > When systemd starts up the system, it will activate all units that are
   > dependencies of default.target (as well as recursively all dependencies
   > of these dependencies). Usually, default.target is simply an alias of
   > graphical.target or multi-user.target, depending on whether the system
   > is configured for a graphical UI or only for a text console. To enforce
   > minimal ordering between the units pulled in, a number of well-known
   > target units are available, as listed on systemd.special(7).
   >
   > The following chart is a structural overview of these well-known units
   > and their position in the boot-up logic. The arrows describe which
   > units are pulled in and ordered before which other units. Units near
   > the top are started before units nearer to the bottom of the chart.

---

Graph for the *user* manager startup:

    (various           (various         (various
     timers...)         paths...)        sockets...)
         |                  |                 |
         v                  v                 v
    timers.target      paths.target     sockets.target
         |                  |                 |
         \______________   _|_________________/
                        \ /
                         v
                   basic.target
                         |
              __________/ \_______
             /                    \
             |                    |
             |                    v
             v            graphical-session-pre.target
    (various user services)       |
             |                    v
             |        (services for the graphical session)
             |                    |
             v                    v
      default.target      graphical-session.target


I think systemd  builds this chart from  the *bottom*, by first  looking for the
`default.target` (which  in practice is often  `graphical-session.target`), then
looking for its dependencies (recursively).  But once built, it activates/starts
the units from the *top* (as  documented).  Targets are started in sequence, but
units within a given target are started in parallel.

---

For  more  info  about the  boot  process,  the  systemd  book might  help.   In
particular, these chapters:

   - Chapter 6: Understanding systemd Targets
   - Chapter 8: Understanding the systemd Boot Process

And this command might help too:

    $ systemctl --user list-units --type=target

##
# understand what `enabled-runtime`, `indirect`, and `transient` mean

Found here:

    $ systemctl list-unit-files --plain --no-legend | awk '{ print $2 }' | sort --unique
    disabled
    enabled
    enabled-runtime
    generated
    indirect
    masked
    static
    transient

# in systemd's glossary, define what priority, level, severity, and facility are

What we *think* so far:

In    syslog,    the    priority    is    formed    by    ORing    together    a
facility   value   (`man syslog /Values for facility`)   and   a   level   value
(`man syslog /Values for level`).

In systemd, the "priority" is what syslog calls "log level".

See `man syslog`, `man rsyslog.conf`, and `man journalctl`.

Edit: Answer from phind.com:

    The three terms `enabled-runtime`, `indirect`, and `transient` are related to
    the state of systemd unit files. Let's dive into each of them:

    ### enabled-runtime

    `enabled-runtime`  means  that the  unit  is  enabled  only for  the  current
    runtime, and  it will not persist  across reboots. This is achieved  by using
    the `--runtime` option with the `systemctl enable` command, which creates the
    necessary symlinks in  the `/run` directory instead  of `/etc`. These changes
    are  lost on  the  next reboot  since  the `/run`  directory  is a  temporary
    filesystem [Source 0](https://man.archlinux.org/man/systemctl.1.en).

    Example:
    ```sh
    systemctl enable --runtime example.service
    ```

    ### indirect

    `indirect`  refers   to  a  unit  that   is  not  enabled  directly   but  is
    activated  as   a  dependency   of  other   enabled  units. Such   units  are
    not  directly  enabled   via  `systemctl  enable`  but   are  instead  pulled
    in  by  other  units  that  depend  on  them. This  is  useful  when  a  unit
    should   only   be   started   when  another   unit   requires   it   [Source
    3](https://manpages.ubuntu.com/manpages/focal/en/man1/systemctl.1.html).

    For   example,  let's   say  we   have  two   units  `example1.service`   and
    `example2.service`. If  `example1.service` has  a `Requires=example2.service`
    directive  in   its  `[Unit]`   section,  enabling   `example1.service`  will
    indirectly enable `example2.service`.

    ### transient

    A  `transient`   unit  is   a  unit   that  is   created  dynamically   by  a
    running  system   and  not   backed  by  a   unit  file   on  disk. Transient
    units  are  useful  for   managing  on-the-fly  configurations  or  temporary
    services  without  having  to  create  and  manage  unit  files. These  units
    are   created   using  the   `systemctl   start`   command  with   additional
    options  to   specify  the  unit  properties. Transient   units  are  removed
    when   they    are   stopped    or   the    system   is    rebooted   [Source
    3](https://manpages.ubuntu.com/manpages/focal/en/man1/systemctl.1.html).

    For example, to create a transient service unit that executes a simple command:

    ```sh
    systemctl start --property=ExecStart='/bin/echo "Hello, World!"' transient-example.service
    ```

    In summary, `enabled-runtime` units are  enabled only for the current runtime
    and  do not  persist across  reboots, `indirect`  units are  activated as  a
    dependency of other enabled units, and `transient` units are created
    dynamically by the running system without a unit file on disk.

##
# review which `systemctl(1)` subcommands are interesting

    $ systemctl --help

# study tool to convert crontab into equivalent .timer and .service units

<https://github.com/systemd-cron/systemd-cron>

# study `man systemd-nspawn`

    systemd-nspawn - Spawn a command or OS in a light-weight container
    [...]
    systemd-nspawn may be used to run a command or OS in a light-weight
    namespace container. In many ways it is similar to chroot(1), but more
    powerful since it fully virtualizes the file system hierarchy, as well
    as the process tree, the various IPC subsystems and the host and domain
    name.

Check out the `EXAMPLES` section of the man page.
Also, find some guides.  At the moment, the first page of google gives these:

- <https://wiki.debian.org/nspawn>
- <https://medium.com/@huljar/setting-up-containers-with-systemd-nspawn-b719cff0fb8d>
- <https://clinta.github.io/getting-started-with-systemd-nspawnd/>
- <https://blog.selectel.com/systemd-containers-introduction-systemd-nspawn/>

Edit: Is it worth learning this?  It doesn't seem very popular.
Shouldn't we focus on podman instead?

# understand "No protocol specified" error

At some point, we had this error:

    $ sudo systemctl edit --full display-manager.service
    # quit editor
    No protocol specified

We fixed it like this:

    $ sudo --login --user=$USER sh -c "unset XAUTHORITY; xauth add $(xauth list)"

Found here: <https://unix.stackexchange.com/a/209750>

What did our command do exactly?
What was the cause of the issue?
Why can't we reproduce it anymore?

Edit: Now that I've rebooted the machine, I can reproduce again.
Although, the message has changed:

    Invalid MIT-MAGIC-COOKIE-1 key

And this time the previous command no longer helps.

Edit: I've logged out and logged back in.  No issue anymore.

##
# replace `--no-legend` with `--legend=no` everywhere once you upgrade systemd (version >=248)

   > * For most tools the --no-legend= switch has been replaced by
   >   --legend=no and --legend=yes, to force whether tables are shown with
   >   headers/legends.

Source: <https://raw.githubusercontent.com/systemd/systemd/main/NEWS>

Also, `--legend=no` does not suppress bullet points.
If  you parse  the output  of `systemctl list-units`,  and you  need them  to be
removed, use `--plain` (in addition to `--legend=no`).

# write a systemd service to periodically and automatically lint all our config files

At least  those for  which we  have files under  `~/Wiki/linter/`; or  maybe all
filetypes for which we have a Vim compiler plugin.

Starting point in Vim9 script:

    vim9script
    import autoload 'myfuncs.vim'
    # TODO: Bail out if json file does not exist, or create it.
    for file in readfile($'{$HOME}/.cache/vim/config_filetypes.json')
            ->get(0, '')
            ->json_decode()
            ->get('python', [])
            # Too many false positives in our courses.
            # For example, we might purposefully write wrong code to illustrate some pitfall.
            ->filter((_, file: string): bool => file !~ '.*/Wiki/.*/course/.*')
        execute $'edit {file}'
        myfuncs.RunCompiler()
        # TODO: Don't break.  Instead, make `RunCompiler()` *append* new errors.
        if getloclist(0) != []
            break
        endif
    endfor

Make sure to limit the amount of hardware resources that the service can consume
(`CPUQuota`, `MemoryMax`, `IOReadBandwidthMax`).

Issue: What if we  have multiple linters for the same  filetype (e.g. pylint and
mypy for Python)?  How to run all of them?

Issue: If we run  all known compilers for  a given filetype, how  to only filter
out non-linters (e.g. black for Python is a formatter)?

Issue: The awk compiler  assumes the existence of input files  which in practice
often don't exist.

# write a systemd service to start/stop an aria2c daemon

Start from this shell script:
<https://github.com/baskerville/diana/blob/master/dad>

Once you have an `aria2c(1)` daemon, you will  be able to get a TUI frontend for
all of your downloads started with the `aria2c(1)` command.
For that, you'll need to install `aria2p`:

    $ pipx install aria2p

For more info, watch this video:
<https://www.youtube.com/watch?v=bc5thl-Dngs>

# sometimes, when we shut down the system, it takes a long time (forever?)

Edit: we no  longer have this issue.   However, we keep this  section because it
might contain valuable information.

---

Read:

   - `/usr/share/doc/systemd/README.Debian.gz`
     (press `za` to get custom folding; read section "Debugging boot/shutdown problems")
   - <https://bugs.launchpad.net/ubuntu/+source/systemd/+bug/1464917>
   - <https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=788303>
   - <https://freedesktop.org/wiki/Software/systemd/Debugging/>

---

Try to enable a debug shell before shutting down the system:

    $ sudo systemctl start debug-shell

Then, when the shutdown hangs, press Ctrl+Alt+F9.

You should get a debug shell.
In it, run this to see the hanging jobs:

    $ systemctl list-jobs

If you see any hanging job/error, run `dmesg(1)`.
Run also `$ journalctl -xe`.

You  could  also  try  to include  `debug`  in  `GRUB_CMDLINE_LINUX_DEFAULT`  in
`/etc/default/grub`, to increase the verbosity of the messages.

---

Try to shut down the system by running `$ systemctl poweroff` (don't use `shutdown(8)`).
Or if you need to reboot: `$ systemctl reboot`.

---

Try to disable all swap partitions: `$ sudo swapoff -a`.
You can do this before shutting down the system, or after, in a debug shell.

---

Try to add the `-proposed` archive to your list of sources:
<https://wiki.ubuntu.com/Testing/EnableProposed>

And update systemd.

---

ATM, here's the output of `$ systemctl list-jobs`:

    JOB UNIT                                                          TYPE  STATE
    1529 dev-sda5.swap                                                 stop  running
    1528 dev-disk-by\x2did-wwn\x2d0x55cd2e404bd8ae31\x2dpart5.swap     stop  running
    1385 systemd-poweroff.service                                      start waiting
    1524 umount.target                                                 start waiting
    1525 dev-disk-by\x2dpath-...0000:00:1f.2\x2data\x2d5\x2dpart5.swap stop  running
    1384 poweroff.target                                               start waiting
    1526 dev-disk-by\x2duuid-...2\x2d4f56\x2da70d\x2d99203e934142.swap stop  running
    1527 dev-disk-by\x2did-at...120A3_CVCV434202BE120BGN\x2dpart5.swap stop  running
    1533 final.target                                                  start waiting

    9 jobs listed.

You can  see that there are  5 jobs running; they  are all related to  the swap.
And there  are 4 jobs  waiting; they are  probably waiting for  the swap-related
jobs to be  finished.  In conclusion, it  seems our hanging issue  is related to
the swap.

---

Document how to start a debug shell during the boot process.

I think you need to edit `/etc/default/grub`, and append the item
`systemd.debug-shell` in the value assigned to `GRUB_CMDLINE_LINUX` (see
`/usr/share/doc/systemd/README.Debian.gz`), then run `$ sudo update-grub`.

For more info about the difference between `GRUB_CMDLINE_LINUX` and
`GRUB_CMDLINE_LINUX_DEFAULT`, see `info '(grub)Simple configuration'`.

# install command(s) to measure system startup time

<https://serverfault.com/a/617864>

    $ systemd-analyze critical-chain

    $ systemd-analyze plot > plot.svg
    $ display plot.svg

    $ systemd-analyze dot 'avahi-daemon.*' | dot -Tsvg > avahi.svg
    $ display avahi.svg

# install service to automatically sanitize filenames under `~/Downloads/`

A downloaded file might contain weird characters:

   - `|`
   - `[`
   - `]`
   - `(`
   - `)`
   - `,`
   ...

Those characters  can make  a path hard  to read, and  even break  some programs
(e.g.  frec  won't  log a  filename  in  its  DB  if the  latter  contains  such
characters).

Use a service starting a file watcher which automatically renames such files.
Make it replace weird characters with underscores.
You might want to run something like:

                  only characters which we preserve
                  v-----------v
    $ sed 'h; s,[^-_./[:alnum:]],_,g; s/_\+/_/g; G; s/\(.*\)\n\(.*\)/mv --no-clobber -- "\2" "\1"/' <<<"$file" \
        | sh

You might  also want to run  `echo "$HOME/Downloads" | entr -d ...`.  With `-d`,
`entr(1)` will be run  once when a new file is added in  the directory (and quit
immediately, so  you might want  to run  `entr(1)` inside a  `while sleep` loop;
have a look at `~/bin/entr-watch`).

Pitfall: This could break torrents while the files are being downloaded.
To avoid  this issue, create  `~/Download/torrents/`, and make sure  your script
ignores files underneath.

Edit: Instead of a `sed(1)` command, what about `detox(1)`:
<https://github.com/dharple/detox>

Edit: Instead of `entr(1)`, what about a systemd unit path?

Edit: Are there directories other than `~/Downloads/` where we should do the same?

##
# Documentation to read/watch
## videos

- <https://www.youtube.com/watch?v=S9YmaNuvw5U>
- <https://www.youtube.com/watch?v=tY9GYsoxeLg>
- <https://www.youtube.com/watch?v=V0xoCA_qO58>

## texts

- <https://systemd-by-example.com/>
- <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd>
- <https://www.freedesktop.org/wiki/Software/systemd/>
- <https://wiki.archlinux.org/index.php/Systemd>
- <https://wiki.archlinux.org/index.php/Systemd/User>
- <https://wiki.archlinux.org/index.php/Systemd_FAQ>
- <https://wiki.archlinux.org/index.php/Systemd/Timers>

---

systemd units and unit files:
<https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files>

systemd socket units:
<https://www.linux.com/training-tutorials/end-road-systemds-socket-units/>

The difference between `ListenStream=` and `ListenDatagram`:
<https://unix.stackexchange.com/questions/517240/systemd-socket-listendatagram-vs-listenstream>

Monitoring paths and directories:
<https://www.linux.com/topic/desktop/systemd-services-monitoring-files-and-directories/>

How to manage systemd services:
<https://www.howtogeek.com/216454/how-to-manage-systemd-services-on-a-linux-system/>

How to create systemd service files:
<https://linuxconfig.org/how-to-create-systemd-service-unit-in-linux>

Securing and sandboxing applications and services:
<https://www.redhat.com/sysadmin/mastering-systemd>

Managing containers in podman with systemd unit files:
<https://www.youtube.com/watch?v=AGkM2jGT61Y>

##
# Documentation to write
## how to find overridden configuration files

    $ man systemd-delta

## how to create a su(1)-like privileged session

I.e. a session which is fully isolated from the original session:

    $ sudo machinectl shell

Source:

- <https://github.com/systemd/systemd/pull/1022>
- <https://github.com/systemd/systemd/issues/825#issuecomment-127957710>
- <https://github.com/systemd/systemd/issues/825#issuecomment-127917622>

You might need to install the `systemd-container` package.

## purpose of TOR daemon which might be running on the machine

    tor --defaults-torrc /usr/share/tor/tor-service-defaults-torrc -f /etc/tor/torrc --RunAsDaemon 0

It can help to torify a shell command such as `$ python3 -m pip install`, when a
package can't be installed because of a network issue (e.g. AS blacklisted).

    $ . torsocks on
    $ python3 -m pip install requests

<https://tor.stackexchange.com/questions/12588/debian-tor-user-running-tor-in-the-background-from-startup#comment13069_12588>

If it's not running, you need to start the service manually:

    $ . torsocks on
    $ sudo systemctl start tor.service
    $ python3 -m pip install requests

torsocks - Access The Tor Network - Linux CLI: <https://www.youtube.com/watch?v=0uXFffq-UPU>

## maybe we should always use `--no-block` to start a service from a script

To not block the script.

Unless the  rest of  the script needs  the guarantee that  the service  has been
fully started.

##
# Understand cron/systemd timers
## `~/Ebooks/txt/How_Linux_Works.txt`
### Scheduling Recurring Tasks with `cron(8)` and Timer Units

There  are two  ways to  run programs  on a  repeating schedule:  `cron(8)`, and
systemd timer  units.  This  ability is vital  to automating  system maintenance
tasks.  One example is logfile rotation utilities to ensure that your hard drive
doesn't fill up with old logfiles.  The  cron service has long been the de facto
standard for doing  this.  However, systemd's timer units are  an alternative to
`cron(8)` with advantages in certain cases.

You can run any program with `cron(8)`  at whatever times suit you.  The program
running through `cron(8)` is  called a cron job.  To install  a cron job, you'll
create an entry line in your crontab file, usually by running `crontab(1)`.  For
example, the following crontab file entry schedules the `/home/juser/bin/spmake`
command daily at 9:15 AM (in the local time zone):

    15 09 * * * /home/juser/bin/spmake

The five fields at the beginning  of this line, delimited by whitespace, specify
the scheduled time.  The fields are as follows, in order:

   - Minute (0 through 59).  This cron job is set for minute 15.
   - Hour (0 through 23).  This job is set for the ninth hour.
   - Day of month (1 through 31).
   - Month (1 through 12).
   - Day of week (0 through 7).  The numbers 0 and 7 are Sunday.
   - Command.

`*`  in any  field  means to  match  every value.   The  preceding example  runs
`spmake` daily because the  day of month, month, and day of  week fields are all
filled with stars, which `cron(8)` reads as  “run this job every day, of every
month, of  every day of the  week.”  To run `spmake`  only on the 14th  day of
each month, you would use this crontab line:

    15 09 14 * * /home/juser/bin/spmake

You can  select more  than one  time for each  field.  For  example, to  run the
program on the 5th and the 14th day of each month, you could enter `5,14` in the
third field:

    15 09 5,14 * * /home/juser/bin/spmake

NOTE: If the cron job generates standard output or an error or exits abnormally,
`cron(8)` should email this information to  the owner of the cron job.  Redirect
the output to `/dev/null` or some other logfile if you find the email annoying.

`crontab(5)` provides complete information on the crontab format.

### Installing Crontab Files

Each user can have  their own crontab file, which means  that every system might
have multiple crontabs, usually found in `/var/spool/cron/crontabs/`.

Normal users can't write to this directory; `crontab(1)` installs, lists, edits,
and removes a  user's crontab.  The easiest  way to install a crontab  is to put
your crontab entries  into a file and  then use crontab file to  install file as
your current crontab. `crontab(1)` checks the  file format to make sure that you
haven't made  any mistakes.   To list  your cron  jobs, run  `$ crontab -l`.  To
remove  the crontab,  use  `$ crontab -r`.  After  you've  created your  initial
crontab, it  can be a bit  messy to use  temporary files to make  further edits.
Instead, you can edit and install  your crontab in one step with `$ crontab -e`.
If you make a mistake, `crontab(1)` should tell you where the mistake is and ask
if you want to try editing again.

### System Crontab Files

Many  common cron-activated  system tasks  are run  as the  superuser.  However,
rather than  editing and  maintaining a superuser's  crontab to  schedule these,
Linux  distributions  normally  have  an  `/etc/crontab`  file  for  the  entire
system.  You won't use crontab to edit this file, and in any case, it's slightly
different in  format: before  the command  to run,  there's an  additional field
specifying the user that should run the job.  (This gives you the opportunity to
group system tasks together  even if they aren't all run  by the same user.) For
example,  this  cron job  defined  in  `/etc/crontab` runs  at  6:42  AM as  the
superuser (root 1):

    42 6 * * * root1 /usr/local/bin/cleansystem >/dev/null 2>&1

NOTE: Some   distributions   store   additional    system   crontab   files   in
`/etc/cron.d/`.   These files  might  have  any name,  but  they  have the  same
format  as  `/etc/crontab`.   There  might  also be  some  directories  such  as
`/etc/cron.daily/`, but  the files here  are usually  scripts run by  a specific
cron job in `/etc/crontab` or `/etc/cron.d/`.   It can sometimes be confusing to
track down where the jobs are and when they run.

### Timer Units

An alternative to creating a cron job for  a periodic task is to build a systemd
timer unit.  For an  entirely new task, you must create two  units: a timer unit
and a  service unit.   The reason  for two units  is that  a timer  unit doesn't
contain  any specifics  about  the  task to  perform;  it's  just an  activation
mechanism to run a service unit (or  conceptually, another kind of unit, but the
most common usage is for service units).

Let's look at  a typical timer/service unit pair, starting  with the timer unit.
Let's call this loggertest.timer; as with  other custom unit files, we'll put it
in `/etc/systemd/system`.

    [Unit]
    Description=Example timer unit

    [Timer]
    OnCalendar=*-*-* *:00,20,40
    Unit=loggertest.service

    [Install]
    WantedBy=timers.target

This timer  runs every 20 minutes,  with the `OnCalendar` option  resembling the
cron syntax.  In this  example, it's at the top of each hour,  as well as 20 and
40 minutes past each hour.

The `OnCalendar` time format  is `year-month-day hour:minute:second`.  The field
for  seconds  is optional.   As  with  `cron(8)`, a  `*`  represents  a sort  of
wildcard, and commas allow for multiple values.  The periodic `/` syntax is also
valid; in  the preceding example,  you could change  the `*:00,20,40 to *:00/20`
(every 20 minutes) for the same effect.

NOTE: The syntax  for times  in the  `OnCalendar` field  has many  shortcuts and
variations.  See `man systemd.time(7) /CALENDAR EVENTS`.

The associated service unit is  named `loggertest.service`.  We explicitly named
it  in the  timer with  the  `Unit` option,  but this  isn't strictly  necessary
because systemd looks for a `.service` file with the same base name as the timer
unit file.  This service unit also goes in `/etc/systemd/system`.

    [Unit]
    Description=Example Test Service

    [Service]
    Type=oneshot
    ExecStart=/usr/bin/logger -p local3.debug I\'m a logger

The meat of this is the `ExecStart`  line, which is the command that the service
runs when activated.  This particular example sends a message to the system log.

Note the use  of `oneshot` as the  service type, indicating that  the service is
expected to  run and exit, and  that systemd won't consider  the service started
until the command specified by `ExecStart` completes.  This has a few advantages
for timers:

   - You can specify multiple `ExecStart` commands in the unit file.  The other
     service unit styles that we saw in Chapter 6 do not allow this.

   - It's easier to control strict dependency order when activating other units
     using `Wants` and `Before` dependency directives.

   - You have better records of start and end times of the unit in the journal.

NOTE: In this unit  example, we're using `logger(1)` to send  an entry to syslog
and the  journal.  You  read earlier  that you  can view  log messages  by unit.
However, the unit  could finish up before  journald has a chance  to receive the
message.  This is a race condition, and  in the case that the unit completes too
quickly, journald won't be  able to look up the unit  associated with the syslog
message (this is done by process ID).

Consequently,   the   message  that   gets   written   in  the   journal   might
not   include  a   unit   field,   rendering  a   filtering   command  such   as
`$ journalctl --follow --unit=loggertest.service`   incapable  of   showing  the
syslog message.  This isn't normally a problem in longer-running services.

### `cron(8)` vs Timer Units

`cron(8)` is one  of the oldest components  of a Linux system;  it's been around
for  decades  (predating Linux  itself),  and  its configuration  format  hasn't
changed much  for many years.   When something gets to  be this old,  it becomes
fodder for replacement.

The systemd timer units that you just saw might seem like a logical replacement,
and indeed, many distributions have  now moved system-level periodic maintenance
tasks to timer units.  But it turns out that `cron(8)` has some advantages:

   - Simpler configuration
   - Compatibility with many third-party services
   - Easier for users to install their own tasks

Timer units offer these advantages:

   - Superior tracking of processes associated with tasks/units with cgroups
   - Excellent tracking of diagnostic information in the journal
   - Additional options for activation times and frequencies
   - Ability to use systemd dependencies and activation mechanisms

Perhaps someday there  will be a compatibility  layer for cron jobs  in much the
same manner as mount units and  `/etc/fstab`.  However, configuration alone is a
reason why it's  unlikely that the cron  format will go away any  time soon.  As
you'll see in  the next section, `systemd-run(1)` does allow  for creating timer
units and  associated services without  creating unit files, but  the management
and implementation differ enough that many users would likely prefer `cron(8)`.

###
## `~/Ebooks/txt/linux_admin_handbook.txt`
### Periodic processes

It's  often useful  to  have a  script  or command  executed  without any  human
intervention.  Common use cases  include scheduled backups, database maintenance
activities, or the  execution of nightly batch jobs.  There's  more than one way
to achieve this goal.

### `cron(8)`: schedule commands

The cron daemon is the traditional  tool for running commands on a predetermined
schedule.  It  starts when the system  boots and runs  as long as the  system is
up.   There  are multiple  implementations  of  `cron(8)`, but  fortunately  for
administrators, the syntax  and functionality of the various  versions is nearly
identical.

`cron(8)` reads configuration files containing  lists of command lines and times
at which they are to be invoked.   The command lines are executed by `sh(1)`, so
almost anything you  can do by hand from  the shell can also be  done with cron.
If you prefer, you can even configure `cron(8)` to use a different shell.

A cron configuration file is called a “crontab”, short for “cron table”.

Crontabs for individual  users are stored under `/var/spool/cron`.   There is at
most one crontab file  per user.  Crontab files are plain  text files named with
the login names of the users to whom they belong. `cron(8)` uses these filenames
(and  the file  ownership) to  figure  out which  UID  to use  when running  the
commands contained  in each  file. `crontab(1)` transfers  crontab files  to and
from this directory.

`cron(8)` tries to minimize the time it spends reparsing configuration files and
making time calculations. `crontab(1)`  helps maintain `cron(8)`'s efficiency by
notifying it when crontab files change.   Ergo, you shouldn't edit crontab files
directly,  because this  approach might  result in  `cron(8)` not  noticing your
changes.

If you  do get into  a situation where `cron(8)`  doesn't seem to  acknowledge a
modified crontab, a HUP  signal sent to the cron process forces  it to reload on
most systems. `cron(8)`  normally does its work silently, but  most versions can
keep a  log file  (usually `/var/log/cron`)  that lists  the commands  that were
executed and the times at which they ran.  Glance at the cron log file if you're
having problems with a cron job and can't figure out why.

### The format of crontab files

All  the  crontab files  on  a  system share  a  similar  format.  Comments  are
introduced start with `#` in the first  column of a line.  Each non-comment line
contains six fields and represents one command:

    minute hour dom month weekday command

The first five fields tell `cron(8)` when to run the command.  They're separated
by whitespace, but  within the command field, whitespace is  passed along to the
shell.  The fields in the time specification are interpreted as:

    Field        Description          Range
    minute       Minute of the hour   0 to 59
    hour         Hour of the day      0 to 23
    dom          Day of the month     1 to 31
    month        Month of the year    1 to 12
    weekday      Day of the week      0 to 6 (0 = Sunday)

An entry in a crontab is colloquially known as a “cron job”.

Each of the time-related fields can contain:

   - A star, which matches everything
   - A single integer, which matches exactly
   - Two integers separated by a dash, matching a range of values
   - A range followed by a slash and a step value, e.g., 1-10/2
   - A comma-separated list of integers or ranges, matching any value

For example, the time specification:

    45 10 * * 1-5

means “10:45 a.m., Monday through Friday”.
A hint:  never use stars in  every field unless you  want the command to  be run
every minute, which is useful only in testing scenarios.

One minute  is the finest  granularity available to  cron jobs.  Time  ranges in
crontabs can include  a step value.  For example,  the series `0,3,6,9,12,15,18`
can be written  more concisely as `0-18/3`.  You can  also use three-letter text
mnemonics for the names of months and  days, but not in combination with ranges.
As far  as we  know, this  feature works only  with English  names.  There  is a
potential ambiguity to watch out for with the weekday and dom fields.  Every day
is both a day of  the week and a day of the month.  If  both weekday and dom are
specified, a day need satisfy only one of the two conditions to be selected.

For example:

    0,30 * 13 * 5

means: “every half-hour on Friday, and every half-hour on the 13th of the month,”
not: “every half-hour on Friday the 13th”.

The command  is the `sh(1)`  command-line to be executed.   It can be  any valid
shell command and should not be quoted.   It's considered to continue to the end
of the line and can contain blanks or tabs.

`%` indicates a newline within the command field.  Only the text up to the first
`%` is  included in the  actual command.  The remaining  lines are given  to the
command as standard input.  Use `\` as an escape character in commands that have
a meaningful `%`, for example, `date +\%s`.

Although  `sh(1)` is  involved  in executing  the command,  the  shell does  not
act  as  a login  shell  and  does not  read  the  contents of  `~/.profile`  or
`~/.bash_profile`.  As  a result, the  command's environment variables  might be
set up somewhat  differently from what you  expect.  If a command  seems to work
fine when executed from the shell but fails when introduced into a crontab file,
the environment  is the likely  culprit.  If need be,  you can always  wrap your
command with a script that sets up the appropriate environment variables.

We also suggest using the fully qualified path to the command, ensuring that the
job will work properly even if the  `PATH` is not set as expected.  For example,
the following  command logs the  date and  uptime to a  file in the  user's home
directory every minute:

    * * * * * echo $(/bin/date) - $(/usr/bin/uptime) >> ~/uptime.log

Alternatively, you can set environment variables explicitly at the top of the crontab:

    PATH=/bin:/usr/bin
    * * * * * echo $(date) - $(uptime) >> ~/uptime.log

Here are a few more examples of valid crontab entries:

    */10 * * * 1,3,5 echo ruok | /usr/bin/nc localhost 2181 |
        mail -s "TCP port 2181 status" ben@admin.com

This line  emails the  results of  a connectivity  check on  port 2181  every 10
minutes on Mondays,  Wednesdays, and Fridays.  Since  `cron(8)` executes command
by way of `sh(1)`, special shell characters like pipes and redirects function as
expected.

    0 4 * * Sun (/usr/bin/mysqlcheck -u maintenance --optimize
      --all-databases)

This  entry runs  the mysqlcheck  maintenance program  on Sundays  at 4:00  a.m.
Since the  output is  not saved  to a file  or otherwise  discarded, it  will be
emailed to the owner of the crontab.

    20 1 * * *        find /tmp -mtime +7 -type f -exec rm -f {  } ';'

This command runs at 1:20 each morning.  It removes all files under `/tmp/` that
have not been modified in 7 days.

`cron(8)` does  not try  to compensate  for commands that  are missed  while the
system is down.  However, it is smart about time adjustments such as shifts into
and out of daylight saving time.

If your cron job  is a script, be sure to make it  executable or `cron(8)` won't
be able to execute  it.  Alternatively, set `cron(8)` to invoke  a shell on your
script directly (e.g. `$ bash -c ~/bin/myscript.sh`).

### Crontab management

`$ crontab filename` installs `filename` as your crontab, replacing any previous version.

`$ crontab -e` checks out a copy of your  crontab, invokes your editor on it (as
specified by `$EDITOR`), and then resubmits it to the crontab directory.

`$ crontab -l` lists the contents of your crontab to standard output.
`$ crontab -r` removes it, leaving you with no crontab file at all.

Root  can supply  a username  argument to  edit or  view other  users' crontabs.
For  example, `$ crontab -r jsmith`  erases the  crontab belonging  to the  user
`jsmith`, and `$ crontab -e jsmith` edits it.

Linux  allows   both  a   username  and   a  filename   argument  in   the  same
command,  so the  username  must be  prefixed with  `-u`  to disambiguate  (e.g.
`$ crontab -u jsmith crontab.new`).

Without  command-line arguments,  most versions  of `crontab(1)`  try to  read a
crontab from  standard input. If you enter  this mode by accident,  don't try to
exit with `C-d`; doing so erases your entire crontab.  Use `C-c` instead.

Many sites  have experienced  subtle but recurrent  network glitches  that occur
because  administrators have  configured `cron(8)`  to run  the same  command on
hundreds of machines at exactly the same time, causing delays or excessive load.
Clock synchronization with  NTP exacerbates the problem.  This issue  is easy to
fix with a random delay script.

cron logs  its activities through  syslog using  the facility `cron`,  with most
messages  submitted at  level `info`.   Default syslog  configurations generally
send cron log data to its own file.

### Other crontabs

In addition to  looking for user-specific crontabs, `cron(8)`  also obeys system
crontab entries found in `/etc/crontab` and in `/etc/cron.d/`.  These files have
a slightly different format from the per-user crontab files: they allow commands
to be run as an arbitrary user.

An extra username field comes before the command name.

The username  field is not present  in garden-variety crontab files  because the
crontab's filename supplies this same information.

In general,  `/etc/crontab` is a file  for system administrators to  maintain by
hand, whereas `/etc/cron.d/` is a sort of depot into which software packages can
install any crontab entries they might need.

Files in `/etc/cron.d/` are by convention  named after the packages that install
them, but `cron(8)` doesn't care about or enforce this convention.

Linux distributions also  pre-install crontab entries that run the  scripts in a
set  of  well-known directories,  thereby  providing  another way  for  software
packages to  install periodic jobs without  any editing of a  crontab file.  For
example, scripts  in `/etc/cron.{hourly,daily,weekly}/`  are run  hourly, daily,
and weekly, respectively.

### cron access control

`/etc/cron.{allow,deny}`  specify which  users can  submit crontab  files.  Many
security standards require  that crontabs be available only  to service accounts
or  to users  with a  legitimate business  need.  The  `allow` and  `deny` files
facilitate compliance with these requirements.

If `cron.allow`  exists, then it  contains a list of  all users that  can submit
crontabs,  one  per line.   No  unlisted  person  can invoke  `crontab(1)`.   If
`cron.allow` doesn't  exist, then `cron.deny`  is checked.   It, too, is  just a
list of users, but the meaning is  reversed: everyone except the listed users is
allowed access.

If neither `cron.allow`  nor `cron.deny` exists, systems  default (apparently at
random, there  being no  dominant convention)  either to  allowing all  users to
submit crontabs or to limiting crontab access to root.

In practice,  a starter configuration  is typically  included in the  default OS
installation, so the question of  how crontab might behave without configuration
files is moot.  Most default configurations  allow all users to access `cron(8)`
by default.

On  most  systems,  access  control  is  implemented  by  `crontab(1)`,  not  by
`cron(8)`.    If  a   user  is   able  to   sneak  a   crontab  file   into  the
appropriate  directory  by  other  means, `cron(8)`  will  blindly  execute  the
commands  it contains.   Therefore it  is vital  to maintain  root ownership  of
`/var/spool/cron`.   OS distributions  always set  the permissions  correctly by
default.

###
### systemd timers

In accordance  with its mission  to duplicate the  functions of all  other Linux
subsystems,  systemd includes  the concept  of  timers, which  activate a  given
systemd service on a predefined schedule.  Timers are more powerful than crontab
entries, but they  are also more complicated  to set up and  manage.  Some Linux
distributions  (e.g. CoreOS)  have  abandoned  `cron(8)` entirely  in  favor  of
systemd timers, but our example systems all continue to include `cron(8)` and to
run it by default.

We have no useful advice regarding the choice between systemd timers and crontab
entries.  Use  whichever you prefer for  any given task.  Unfortunately,  you do
not really have  the option to standardize  on one system or  the other, because
software packages add their jobs to a random system of their own choice.  You'll
always  have to  check both  systems when  you are  trying to  figure out  how a
particular job gets run.

### Structure of systemd timers

A systemd timer comprises two files:

   - A timer unit that describes the schedule and the unit to activate.
   - A service unit that specifies the details of what to run.

In contrast to crontab entries, systemd timers can be described both in absolute
calendar terms (“Wednesdays  at 10:00 a.m.”) and in terms  that are relative
to other  events (“30 seconds after  system boot”).  The options  combine to
allow powerful expressions that don't suffer the same constraints as cron jobs:

    Type                    Time basis
    OnActiveSec             Relative to the time at which the timer itself is activated
    OnBootSec               Relative to system boot time
    OnStartupSec            Relative to the time at which systemd was started
    OnUnitActiveSec         Relative to the time the specified unit was last active
    OnUnitInactiveSec       Relative to the time the specified unit was last inactive
    OnCalendar              A specific day and time

As their  names suggest, values  for these timer  options are given  in seconds.
For  example, `OnActiveSec=30`  is 30  seconds after  the timer  activates.  The
value can actually be any valid systemd time expression.

### systemd timer example

Red Hat  and CentOS  include a  preconfigured systemd timer  that cleans  up the
system's temporary files once a day.  Below,  we take a more detailed look at an
example.  First, we  enumerate all the defined timers  with `systemctl(1)`.  (We
rotated  the output  table  below to  make it  readable.   Normally, each  timer
produces one long line of output.)

    $ systemctl list-timers
    NEXT         Sun 2017-06-18 10:24:33 UTC
    LEFT         18h left
    LAST         Sat 2017-06-17 00:45:29 UTC
    PASSED       15h ago
    UNIT         systemd-tmpfiles-clean.timer
    ACTIVATES    systemd-tmpfiles-clean.service

The output  lists both the name  of the timer unit  and the name of  the service
unit it activates.  Since this is a default system timer, the unit file lives in
the  standard systemd  unit directory,  `/usr/lib/systemd/system/`.  Here's  the
timer unit file:

    $ cat /usr/lib/systemd/system/systemd-tmpfiles-clean.timer
    [Unit]
    Description=Daily Cleanup of Temporary Directories

    [Timer]
    OnBootSec=15min
    OnUnitActiveSec=1d

The  timer first  activates 15  minutes after  boot and  then fires  once a  day
thereafter.  Note  that some kind of  trigger for the initial  activation (here,
`OnBootSec`)  is  always  necessary.   There is  no  single  specification  that
achieves an “every X minutes” effect on its own.

Astute observers will notice that the timer does not actually specify which unit
to run.  By default, systemd looks for a  service unit that has the same name as
the timer.  You can specify a target unit explicitly with the `Unit` option.  In
this case, the associated service unit holds no surprises:

    $ cat /usr/lib/systemd/system/systemd-tmpfiles-clean.service
    [Unit]
    Description=Cleanup of Temporary Directories
    DefaultDependencies=no
    Conflicts=shutdown.target
    After=systemd-readahead-collect.service systemd-readahead-replay.service
        local-fs.target time-sync.target
    Before=shutdown.target

    [Service]
    Type=simple
    ExecStart=/usr/bin/systemd-tmpfiles --clean
    IOSchedulingClass=idle

You can  run the target service  directly (that is, independently  of the timer)
with  `$ systemctl start systemd-tmpfiles-clean`, just  like any  other service.
This fact greatly  facilitates the debugging of scheduled tasks,  which can be a
source of much administrative anguish when you are using `cron(8)`.

To   create  your   own   timer,   drop  `.timer`   and   `.service`  files   in
`/etc/systemd/system/`.  If you want the timer to run at boot, add:

    [Install]
    WantedBy=multi-user.target

to the end of  the timer's unit file.  Don't forget to enable  the timer at boot
time with `$ systemctl enable`.  (You can  also start the timer immediately with
`$ systemctl start`.)

A timer's `AccuracySec` option delays its  activation by a random amount of time
within the specified time window.  This feature  is handy when a timer runs on a
large group of  networked machines and you  want to avoid having  all the timers
fire at exactly the same moment. (Recall that  with `cron(8)`, you need to use a
random delay script to achieve this feat.)

`AccuracySec` defaults  to 60  seconds.  If  you want your  timer to  execute at
exactly  the scheduled  time, use  `AccuracySec=1ns`. (A nanosecond  is probably
close enough.  Note that you won't actually obtain nanosecond accuracy.)

### systemd time expressions

Timers  allow  for  flexible  specification  of  dates,  times,  and  intervals.
`systemd.time(7)` is the authoritative reference for the specification grammar.

You can use interval-valued expressions  instead of seconds for relative timings
such as those used as the values of `OnActiveSec` and `OnBootSec`.

For example, the following forms are all valid:

    OnBootSec=2h 1m
    OnStartupSec=1week 2days 3hours
    OnActiveSec=1hr20m30sec10msec

Spaces  are   optional  in  time   expressions.   The  minimum   granularity  is
nanoseconds, but  if your timer fires  too frequently (more than  once every two
seconds) systemd temporarily disables it.

In addition  to triggering  at periodic  intervals, timers  can be  scheduled to
activate at specific  times by including the `OnCalendar`  option.  This feature
offers the closest match to the syntax of a traditional cron job, but its syntax
is more expressive and flexible.

Here are some examples of time specifications that could be used as the value of
`OnCalendar`:

    Time specification               Meaning
    2017-07-04                       July 4th, 2017 at 00:00:00 (midnight)
    Fri-Mon *-7-4                    July 4th each year, but only if it falls on Fri–Mon
    Mon-Wed *-*-* 12:00:00           Mondays, Tuesdays, and Wednesdays at noon
    Mon 17:00:00                     Mondays at 5:00 p.m.
    weekly                           Mondays at 00:00:00 (midnight)
    monthly                          The 1st day of the month at 00:00:00 (midnight)
    *:0/10                           Every 10 minutes, starting at the 0th minute
    *-*-* 11/12:10:0                 At 11:10 and 23:10 every day


In time expressions, `*` is a  placeholder that matches any plausible value.  As
in crontab files, `/` introduces an increment  value.  The exact syntax is a bit
different from  that used  in crontabs, however:  crontabs want  the incremented
object to  be a range (e.g. `9-17/2`,  “every two hours between  9:00 a.m. and
5:00 p.m.”), but systemd time expressions take only a start value (e.g. `9/2`,
“every two hours starting at 9:00 a.m.”).

### Transient timers

You can use `systemd-run(1)` to schedule the execution of a command according to
any of the normal systemd timer  types, but without creating task-specific timer
and service unit files.

For example, to pull a Git repository every ten minutes:

    $ systemd-run --on-calendar '*:0/10' /bin/sh -c "cd /app && git pull"
    Running timer as unit run-8823.timer.
    Will run service as unit run-8823.service.

systemd  returns   a  transient   unit  identifier  that   you  can   list  with
`systemctl(1)`. (Once again, we futzed with the output format below...)

    $ systemctl list-timers run-8823.timer
    NEXT        Sat 2017-06-17 20:40:07 UTC
    LEFT        9min left
    LAST        Sat 2017-06-17 20:30:07 UTC
    PASSED      18s ago

    $ systemctl list-units run-8823.timer
    UNIT        run-8823.timer
    LOAD        loaded
    ACTIVE      active
    SUB         waiting
    DESCRIPTION /bin/sh -c "cd /app && git pull"

To   cancel  and   remove  a   transient  timer,   just  stop   it  by   running
`$ systemctl stop`:

    $ sudo systemctl stop run-8823.timer

`systemd-run(1)`  functions  by  creating  timer  and  unit  files  for  you  in
subdirectories  of `/run/systemd/system/`.   However,  transient  timers do  not
persist  after a  reboot.  To  make them  permanent, you  can fish  them out  of
`/run`, tweak them as necessary, and install them in `/etc/systemd/system/`.  Be
sure  to stop  the transient  timer before  starting or  enabling the  permanent
version.

###
### Common uses for scheduled tasks

In this section, we  look at a couple of common chores  that are often automated
through `cron(8)` or systemd.

#### Sending mail

The following crontab entry implements a  simple email reminder.  You can use an
entry like  this to  automatically email  the output  of a  daily report  or the
results of  a command  execution. (Lines have  been folded  to fit  the page. In
reality, this is one long line.)

    30 4 25 * * /usr/bin/mail -s "Time to do the TPS reports"
       ben@admin.com%TPS reports are due at the end of the month! Get
       busy!%%Sincerely,%cron%

Note the use of `%` both to separate the command from the input text and to mark
line endings within the input.  This entry  sends email at 4:30 a.m. on the 25th
day of each month.

#### Cleaning up a filesystem

When  a program  crashes,  the kernel  might  write out  a  file (usually  named
`core.PID`, `core`, or  `PROGRAM.core`) that contains an image  of the program's
address space.   Core files  are useful for  developers, but  for administrators
they are usually a waste of space.   Users often don't know about core files, so
they tend not  to disable their creation  or delete them on their  own.  You can
use a  cron job to clean  up these core files  or other vestiges left  behind by
misbehaving and crashed processes.

#### Rotating a log file

Systems vary in the  quality of their default log file  management, and you will
probably need  to adjust  the defaults  to conform to  your local  policies.  To
“rotate” a  log file means to  divide it into  segments by size or  by date,
keeping several  older versions of  the log available  at all times.   Since log
rotation is a recurrent and regularly occurring  event, it's an ideal task to be
scheduled.

#### Running batch jobs

Some  long-running  calculations are  best  run  as  batch jobs.   For  example,
messages can  accumulate in  a queue  or database.  You  can use  a cron  job to
process all the queued messages at once as an ETL (extract, transform, and load)
to another location, such as a data warehouse.

Some databases benefit  from routine maintenance.  For example,  the open source
distributed database Cassandra  has a repair function that keeps  the nodes in a
cluster  in sync.   These maintenance  tasks are  good candidates  for execution
through `cron(8)` or systemd.

#### Backing up and mirroring

You can use  a scheduled task to  automatically back up a directory  to a remote
system.   We  suggest running  a  full  backup  once  a week,  with  incremental
differences each night.  Run  backups late at night when the  load on the system
is  likely to  be  low.   Mirrors are  byte-for-byte  copies  of filesystems  or
directories that are  hosted on another system.   They can be used as  a form of
backup or as a way to make files available at more than one location.  Web sites
and software repositories  are often mirrored to offer better  redundancy and to
offer faster access for users that are physically distant from the primary site.
Use periodic execution of the rsync command to maintain mirrors and keep them up
to date.
