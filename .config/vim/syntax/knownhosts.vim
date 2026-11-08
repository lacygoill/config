vim9script

# For more info about the format of a `known_hosts` file: `man 8 sshd /SSH_KNOWN_HOSTS FILE FORMAT`{{{
#
# Which states in particular:
#
#    > Each line in these files contains the following fields: markers (op‐
#    > tional), hostnames, keytype, base64-encoded key, comment.  The fields are
#    > separated by spaces.
#}}}

if exists('b:current_syntax')
    finish
endif

#     $ ssh -Q HostbasedAcceptedKeyTypes | sort
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

# For the  key types  to be  matched as keywords,  we need  to add  the hyphen
# character to `iskeyword`.
syntax iskeyword @,48-57,_,192-255,45
#                                  ^^
#                                  hyphen character

syntax match knownhostsSOL /^/
    \ nextgroup=knownhostsHostName,knownhostsRevokedMarker,knownhostsCAMarker,knownhostsLineComment
syntax match knownhostsHostName /@\@!\S\+/ contained nextgroup=knownhostsKeyType skipwhite

syntax match knownhostsRevokedMarker /@revoked/ contained nextgroup=knownhostsHostName skipwhite
syntax match knownhostsCAMarker /@cert-authority/ contained nextgroup=knownhostsHostName skipwhite

#    > Lines starting with ‘#’ and empty lines are ignored as comments.
syntax match knownhostsLineComment /#.*/ contained

execute 'syntax keyword knownhostsKeyType ' .. KEY_TYPES
    .. ' contained'
    .. ' nextgroup=knownhostsPublicKey'
    .. ' skipwhite'

syntax match knownhostsPublicKey /\S\+/ contained nextgroup=knownhostsKeyComment skipwhite
#    > The optional comment field continues to the end of the line, and is not used.
syntax match knownhostsKeyComment /\S.*/ contained

highlight default link knownhostsCAMarker Special
highlight default link knownhostsKeyComment Comment
highlight default link knownhostsKeyType Type
highlight default link knownhostsLineComment Comment
highlight default link knownhostsPublicKey String
highlight default link knownhostsRevokedMarker ErrorMsg

b:current_syntax = 'knownhosts'
