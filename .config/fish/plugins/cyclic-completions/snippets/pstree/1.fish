-C age --ascii --hide-threads --long --show-parents --show-pids $(pidof -s ⌖)
    # `-C age`: color processes by age (green or  yellow if they started less than 1
    # minute/1 hour ago, red otherwise)
    # `--ascii`: `-C age` doesn't play nicely with some unicode characters
    # `--hide-threads`: threads make the output sometimes too verbose and confusing
