vim9script

export const cached_parameters: string = $'{expand('<sfile>:h:h')}/tools/parameters'

# Some parameters are meant to be used only for system services.{{{
#
# Not for services running in a per-user instance of the service manager:
#
#    > This option is only available for system services and is not
#    > supported for services running in per-user instances of the service
#    > manager.
#
# We'll need  this information at runtime  to not suggest those  parameters when
# writing a unit file under a directory containing the `/user/` path component.
#}}}
export const system_only: list<string> =<< trim END
    AmbientCapabilities
    AppArmorProfile
    BindPaths
    BindReadOnlyPaths
    CapabilityBoundingSet
    DynamicUser
    Group
    InaccessiblePaths
    MountAPIVFS
    MountFlags
    NetworkNamespacePath
    PAMName
    PrivateDevices
    PrivateMounts
    PrivateNetwork
    PrivateTmp
    ProtectClock
    ProtectControlGroups
    ProtectHome
    ProtectHostname
    ProtectKernelLogs
    ProtectKernelModules
    ProtectKernelTunables
    ReadOnlyPaths
    ReadWritePaths
    RemoveIPC
    RootDirectory
    RootImage
    SELinuxContext
    SmackProcessLabel
    SupplementaryGroups
    TemporaryFileSystem
    User
    WakeSystem
END
