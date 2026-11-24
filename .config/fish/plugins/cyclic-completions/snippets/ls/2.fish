--sort=size --reverse -l --human-readable
    # Sort by size (largest last).
    #
    # ---
    #
    # `sort(1)` alternative:
    #
    #     # ascending order
    #     $ ls -l | sort --key=5bh,5
    #
    #     # descending order
    #     $ ls -l | sort --key=5bhr,5
    #                             ^
