vim9script

# We got this list by parsing the bash man page:
#
#     $ zcat "$(man --where bash)" \
#         | groff -m man -T ascii \
#         | col -b \
#         | sed -n '/^\s*Shell Variables/,/^   \S/p' \
#         | awk '/^       ([A-Z_0-9]*( |$)|[a-z_0-9]*(  |$))/ { print $1 }' \
#         | sort --version-sort
#
# If you want something more programmatic, try this:
#
#     $ env --ignore-environment bash --norc --noprofile -c 'compgen -A variable'
#
# Unfortunately, it's missing many variables.
const special_variables_list: list<string> =<< trim END
    BASH
    BASHOPTS
    BASHPID
    BASH_ALIASES
    BASH_ARGC
    BASH_ARGV
    BASH_ARGV0
    BASH_CMDS
    BASH_COMMAND
    BASH_COMPAT
    BASH_ENV
    BASH_EXECUTION_STRING
    BASH_LINENO
    BASH_LOADABLES_PATH
    BASH_REMATCH
    BASH_SOURCE
    BASH_SUBSHELL
    BASH_VERSINFO
    BASH_VERSION
    BASH_XTRACEFD
    CDPATH
    CHILD_MAX
    COLUMNS
    COMPREPLY
    COMP_CWORD
    COMP_KEY
    COMP_LINE
    COMP_POINT
    COMP_TYPE
    COMP_WORDBREAKS
    COMP_WORDS
    COPROC
    DIRSTACK
    EMACS
    ENV
    EPOCHREALTIME
    EPOCHSECONDS
    EUID
    EXECIGNORE
    FCEDIT
    FIGNORE
    FUNCNAME
    FUNCNEST
    GLOBIGNORE
    GROUPS
    HISTCMD
    HISTCONTROL
    HISTFILE
    HISTFILESIZE
    HISTIGNORE
    HISTSIZE
    HISTTIMEFORMAT
    HOME
    HOSTFILE
    HOSTNAME
    HOSTTYPE
    IFS
    IGNOREEOF
    INPUTRC
    INSIDE_EMACS
    LANG
    LC_ALL
    LC_COLLATE
    LC_CTYPE
    LC_MESSAGES
    LC_NUMERIC
    LC_TIME
    LINENO
    LINES
    MACHTYPE
    MAIL
    MAILCHECK
    MAILPATH
    MAPFILE
    OLDPWD
    OPTARG
    OPTERR
    OPTIND
    OSTYPE
    PATH
    PIPESTATUS
    POSIXLY_CORRECT
    PPID
    PROMPT_COMMAND
    PROMPT_DIRTRIM
    PS0
    PS1
    PS2
    PS3
    PS4
    PWD
    RANDOM
    READLINE_LINE
    READLINE_POINT
    REPLY
    SECONDS
    SHELL
    SHELLOPTS
    SHLVL
    TIMEFORMAT
    TMOUT
    TMPDIR
    UID
    auto_resume
    histchars
END

export const special_variables: string = special_variables_list->join('\|')
