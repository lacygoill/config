# what we want to build (name of the target that you can pass to `make(1)`)
# |
# |   what's required to build it
# v   v------v
kilo: step_1.c
	$(CC) step_1.c -o kilo -Wall -Wextra -pedantic -std=c99
# -----^^-----------------------------------------------------^
#    |  how to build it; $(CC) is a variable that `make(1)` expands into `cc` by default
#    |
# literal tab (Makefiles must be indented with tabs; not spaces)
