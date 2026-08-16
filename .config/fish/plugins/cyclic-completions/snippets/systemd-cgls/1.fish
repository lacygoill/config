--unit=user-$UID.slice
    # List all our user processes.
    #
    # Processes  started  by systemd  are  grouped  under the  service  template
    # `user@$UID.service`.  Processes started by other means are grouped under a
    # scope: `session-*.scope`.
    #
    # ---
    #
    # Alternative:
    #
    #     $ ps --user=$USER --forest --format=pid,tty=TTY,stat=STATE,args
