vim9script

if exists('b:current_syntax')
    finish
endif

# For more info about the format of an `authorized_keys` file:
# `man 8 sshd /AUTHORIZED_KEYS FILE FORMAT`

#     $ ssh -Q PubkeyAcceptedKeyTypes | sort
var KEY_TYPES: any =<< trim END
    ecdsa-sha2-nistp256
    ecdsa-sha2-nistp256-cert-v01@openssh.com
    ecdsa-sha2-nistp384
    ecdsa-sha2-nistp384-cert-v01@openssh.com
    ecdsa-sha2-nistp521
    ecdsa-sha2-nistp521-cert-v01@openssh.com
    rsa-sha2-256
    rsa-sha2-256-cert-v01@openssh.com
    rsa-sha2-512
    rsa-sha2-512-cert-v01@openssh.com
    sk-ecdsa-sha2-nistp256-cert-v01@openssh.com
    sk-ecdsa-sha2-nistp256@openssh.com
    sk-ssh-ed25519-cert-v01@openssh.com
    sk-ssh-ed25519@openssh.com
    ssh-dss
    ssh-dss-cert-v01@openssh.com
    ssh-ed25519
    ssh-ed25519-cert-v01@openssh.com
    ssh-rsa
    ssh-rsa-cert-v01@openssh.com
END
KEY_TYPES = KEY_TYPES->join()

# For the key types to be matched  as keywords, we need to add some characters
# to `iskeyword`.
syntax iskeyword @,48-57,_,192-255,45,46,@-@
#                                  ^-------^
#                                  hyphen, dot and at characters

var OPTIONS: any =<< trim END
    X11-forwarding
    agent-forwarding
    cert-authority
    command
    environment
    expiry-time
    from
    no-X11-forwarding
    no-agent-forwarding
    no-port-forwarding
    no-pty
    no-touch-required
    no-user-rc
    permitlisten
    permitopen
    port-forwarding
    principals
    pty
    restrict
    touch-required
    tunnel
    user-rc
END
OPTIONS = OPTIONS->join()

syntax match authorizedkeysSOL /^/ nextgroup=authorizedkeysOptions,authorizedkeysKeyType,authorizedkeysLineComment

execute 'syntax keyword authorizedkeysOptions'
    .. ' ' .. OPTIONS
    .. ' contained'
    .. ' nextgroup=authorizedkeysOptionsComma,authorizedkeysOptionsEqual,authorizedkeysKeyType'
    .. ' skipwhite'
syntax match authorizedkeysOptionsComma /,/ contained nextgroup=authorizedkeysOptions

#     command="command"
#     environment="NAME=value"
#     expiry-time="timespec"
#     from="pattern-list"
#     permitlisten="[host:]port"
#     permitopen="host:port"
#     principals="principals"
#     tunnel="n"
syntax match authorizedkeysOptionsEqual /=/ contained nextgroup=authorizedkeysOptionsValue
execute 'syntax region authorizedkeysOptionsValue'
    .. ' start=/"/'
    .. ' skip=/\\"/'
    .. ' end=/"/'
    .. ' contained'
    .. ' nextgroup=authorizedkeysOptionsComma,authorizedkeysOptions,authorizedkeysKeyType'
    .. ' skipwhite'

execute 'syntax keyword authorizedkeysKeyType ' .. KEY_TYPES
    .. ' contained'
    .. ' nextgroup=authorizedkeysPublicKey'
    .. ' skipwhite'

syntax match authorizedkeysPublicKey /\S\+/ contained nextgroup=authorizedkeysKeyComment skipwhite
#    > The comment field is not used for anything (but may be convenient for the
#    > user to identify the key).
syntax match authorizedkeysKeyComment /\S.*/ contained

 #    > empty lines and lines starting with a ‘#’ are ignored as comments
syntax match authorizedkeysLineComment /#.*/ contained

highlight default link authorizedkeysKeyComment Comment
highlight default link authorizedkeysKeyType Type
highlight default link authorizedkeysKeyTypeInvalid Error
highlight default link authorizedkeysLineComment Comment
highlight default link authorizedkeysOptions PreProc
highlight default link authorizedkeysOptionsEqual Identifier
highlight default link authorizedkeysOptionsValue String
highlight default link authorizedkeysPublicKey String

b:current_syntax = 'authorizedkeys'
