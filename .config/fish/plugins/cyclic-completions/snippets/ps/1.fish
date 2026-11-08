--user=$USER --forest --format=pid,tty=TTY,stat=STATE,args | less
    # Only our processes and with minimum of noise.
    #
    # ---
    #
    # For some reason, the last character of the `TTY` and `STATE` column headers is
    # omitted, so we set those two column headers explicitly.
