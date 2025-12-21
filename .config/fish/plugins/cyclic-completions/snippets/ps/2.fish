-e --format=pid,start,args --sort=start_time | less +G
    # Most recently started processes last.
    #
    # ---
    #
    # Don't  use  the `f`  output  modifier  (ASCII  art process  hierarchy  aka
    # forest).  In practice, this can  give a confusing output.  That's because,
    # if a  process has multiple threads  (e.g. firefox), they'll all  be sorted
    # according to the  first main thread.  Same  thing if a process  is part of
    # some hierarchy (e.g.  tmux → fish → Vim); the  whole hierarchy will be
    # sorted according to the most ancient ancestor.
