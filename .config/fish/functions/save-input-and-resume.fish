# Resume last job or temporarily discard the current command line.
function save-input-and-resume
    set --global _saved_input $(commandline --current-buffer | string collect)

    # Don't run `fg(1)` directly from this  function; the shell prompt would not
    # be properly redrawn.  Instead, make fish type the command.
    commandline --replace 'fg'
    commandline --function execute
end

function _restore_input --on-event=fish_postexec
    if test -n "$_saved_input"
        commandline --replace -- $_saved_input
        set --erase --global _saved_input
    end
end
