# I want to start a process as a Vim job.  The process doesn't do anything!

A job object is automatically deleted as soon as there are no references to it.
In turn, this causes the process I/O to be closed, which may cause the job to fail.

Make sure to either:

   - close the I/O before the job is started
   - save the job in a variable

If  you want  to close  the I/O,  set the  `in_io`, `out_io`,  `err_io` keys  to
`'null'` in the job's options:

    job_start('...', {
        in_io: 'null',
        out_io: 'null',
        err_io: 'null'
    })

If you want to save the job in a variable, don't use a function-local one.
It would be deleted as soon as the function ends which might be too soon.
Save it in a "public" variable, or in a script-local one.
Anything which can persist some time.

See `:help job_start()`:

   > Note that the job object will be deleted if there are no
   > references to it.  This closes the stdin and stderr, which may
   > cause the job to fail with an error.  To avoid this keep a
   > reference to the job.  Thus instead of:
   >     call job_start('my-command')
   > use:
   >     let myjob = job_start('my-command')
   > and unlet "myjob" once the job is not needed or is past the
   > point where it would fail (e.g. when it prints a message on
   > startup).  Keep in mind that variables local to a function
   > will cease to exist if the function returns.  Use a
   > script-local variable if needed:
   >     let s:myjob = job_start('my-command')

# I want to start a second Vim process as a Vim job.  It doesn't quit even if I make it run `:quitall!`!

It might be that  this second Vim has encountered an error,  causing it to abort
the execution of your Ex commands, before it can reach `:quitall!`.

Solution: Make sure to close its I/O:

    job_start('vim ...', {in_io: 'null', out_io: 'null', err_io: 'null'})
                          ^-----------^  ^------------^  ^------------^

If its I/O is closed, Vim will quit.

##
# How to send `a b` as an argument to an external process started from Vim?  (2)

Use `system()` and quote `a b`:

    :silent call system('tmux command-prompt -I "a b"')
    :a b˜

More generally, if your argument might contain any kind of quotes, use `shellescape()`:

    :let arg = "a'b\"c"
    :silent call system('tmux command-prompt -I ' .. shellescape(arg))
    a'b"c˜

---

Alternatively, you could use `job_start()`:

    :call job_start(['tmux', 'command-prompt', '-I', 'a b'])

# Why should I avoid passing a string to `job_start()`?

Because Vim  will split the arguments  at any whitespace outside  double quotes,
which might seem unexpected:

    :call job_start('tmux command-prompt -I "foo bar"')
    :foo bar˜

    :call job_start("tmux command-prompt -I 'foo bar'")
    (bar') foo'˜

In the last command, tmux receives this:

    subcmd = command-prompt
    arg1   = -I
    arg2   = 'foo
    arg3   = bar'

---

Besides, a string works best on Windows, not on Unix.
From `:help job_start()`:

   > {command} can be  a **String**.  This works  best on **MS-Windows**.  On  Unix it is
   > split up  in white-separated parts to  be passed to execvp().   Arguments in
   > **double quotes** can contain white space.
   > ...
   > {command}  can be  a **List**,  where  the first  item is  the executable  and
   > further items  are the arguments.   All items  are converted to  String.  This
   > works best on **Unix**.

##
# Updating a quickfix/location list asynchronously without interfering with another plugin

<https://gist.github.com/yegappan/3b50ec9ea86ad4511d3a213ee39f1ee0>

Updating a  quickfix or  location list asynchronously  opens up  the possibility
that  two or  more plugins  might  try to  update  the same  quickfix list  with
different output.
Also when a plugin is updating a quickfix list in the background, the user might
issue a command that creates or updates a quickfix list.
The plugin might then incorrectly use this new list to add the entries.

The various Vim commands that create or modify a qfl (like `:make`, `:grep`, and
`:cfile`) operate only on the current one.
A  plugin using  these commands  to update  the qfl  can interfere  with another
plugin.

To avoid these issues, `getqflist()` and `setqflist()` can be used to operate on
a specific list in the stack, using its unique id which can be obtained with:

    let qfid = getqflist({'id': 0}).id

When adding new entries, the plugin can use `setqflist()` with this id:

    call setqflist([], 'a', {'id': qfid, 'items': newitems})

To parse the output of a command and add the quickfix entries, the plugin can use:

    call setqflist([], 'a', {'id': qfid, 'lines': cmdoutput})

Note that in the  previous command, the current `'efm'` option  is used to parse
the command output.
This setting might have been changed either  by the user or by some other plugin
to some other value.
To parse the command output using a specific `'efm'`, the plugin can use:

    call setqflist([], 'a', {'id': qfid, 'lines': cmdoutput, 'efm': myefm})

If more than  10 quickfix lists are added  to the stack, then the  oldest qfl is
removed.
When a plugin  is using a qfl, if another  plugin or user adds a new  qfl to the
stack, then there is  a possibility that the qfl that is in  use is removed from
the stack.
So the plugin should check whether the qfl it is using is still valid:

    if getqflist({'id': qfid}).id == qfid
        " List is still valid
    endif

In summary,  a plugin can  use the following  steps to asynchronously  process a
command output and update a qfl:

   1. Create an empty quickfix list:

         call setqflist([], ' ', {'title': 'Output from command abc'})

   2. Save the newly created quickfix list identifier:

         let qfid = getqflist({'id': 0}).id

   3. Start a command in the background using `job_start()`

   4. In the job callback function, check if the quickfix list is still present:

         if getqflist({'id': qfid}).id == qfid
             " Still present
             " Update the list
         else
             " List is removed.  Stop the background job.
             call job_stop(....)
         endif

   5. Process the command output and update the quickfix list using one of the
      following calls:

         call setqflist([], 'a', {'id': qfid, 'lines': cmdoutput, 'efm': myefm})
         ^
         should we add `noautocmd`? (same question for the command below)

      or

         call setqflist([], 'a', {'id': qfid, 'items': newitems})

##
# async

<https://github.com/prabirshrestha/async.vim> 299 sloc

# asyncmake

Plugin for asynchronously running make

<https://github.com/yegappan/asyncmake> 125 sloc

To start make in the background, run the following command:

    :AsyncMake

This invokes the program set in the 'makeprg' option in the background.
The results are processed and added to a quickfix list.
Only one instance of the make command can be run in the background at a time.
Arguments passed to  the ":AsyncMake" command will be passed  on to the external
make command:

    :AsyncMake -f SomeMake.mak

To display the  status of the currently running make  command, use the following
command:

    :AsyncMakeShow

To cancel the currently running make command, use the following command:

    :AsyncMakeStop

When a make is running in the background, if you quit Vim, then the make process
will be terminated.

The output from the make command is added to a quickfix list.
You can use the quickfix commands to browse the output.
If  the make  command exits  with an  error code,  then the  quickfix window  is
automatically opened.

# autoread

Use `$ tail -f` on a buffer and append new content.

This plugin uses Vim 8 async jobs to append new buffer content.

Internally, it  works by running `$  tail -f` on a  file and the output  will be
appended to the buffer, which displays this buffer.

<https://github.com/chrisbra/vim-autoread> 173 sloc

# makejob

This is a plugin  for folks who think that Vim's quickfix  feature is great, but
who don't like how calls to :make and :grep freeze the editor.
MakeJob implements  asynchronous versions of  the builtin commands in  just over
150 lines of Vimscript.

<https://github.com/foxik/vim-makejob>

197 sloc

##
# Todo
## document how to get more info about the job which has started the process of ID 1234

    vim9 echo job_info()
        ->mapnew((_, v: job): dict<any> => job_info(v))
        ->filter((_, v: dict<any>): bool => v.process == 1234)

## make `vim-fex` async
