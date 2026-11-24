# mouse clicks stop working

In a Debian 12 guest, when XFCE starts, if we use the left or right click before
the  desktop icons  appear  (as well  as  the bottom  panel),  that click  stops
working.  Executing  `$ sudo udevadm trigger` fixes  the issue.  What  does that
do?   Is  it  the  right  fix?   Is  it specific  to  a  VM?  (have  a  look  at
`$ udevadm monitor`)

When the left click stops working, try to use the right click; in some cases, it
can function as  a left click.  When  any click stops working,  hover your mouse
over what you want to click, then press Enter.

# "Spice GL requires virtio graphics configured with accel3d." warning

When we open the "virtual details hardware" tab of a VM, and select the "Display
Spice" entry, there is a warning next to the "OpenGL" button:

    Spice GL requires virtio graphics configured with accel3d.

It *might* explain why mpv gives so many errors when we read a video file in a VM:

    libEGL warning: DRI2: failed to authenticate
    [vo/gpu/opengl] Suspected software renderer or indirect context.
    [vo/gpu] VT_GETMODE failed: Inappropriate ioctl for device
    [vo/gpu/opengl] Failed to set up VT switcher. Terminal switching will be unavailable.
    pci id for fd 10: 1b36:0100, driver (null)
    MESA-LOADER: failed to open qxl: /usr/lib/dri/qxl_dri.so: cannot open shared object file: No such file or directory (search paths /usr/lib/x86_64-linux-gnu/dri:\$${ORIGIN}/dri:/usr/lib/dri, suffix _dri)
    failed to load driver: qxl
    pci id for fd 11: 1b36:0100, driver (null)
    kmsro: driver missing
    [vo/gpu] Failed to create GBM surface.
    [vo/gpu] Failed to setup GBM.
    [vo/gpu/libplacebo] Found no suitable device, giving up.
    [vo/gpu/libplacebo] Failed initializing vulkan device
    libEGL warning: DRI2: failed to authenticate
    [vo/gpu-next/opengl] Suspected software renderer or indirect context.
    [vo/gpu-next] Can't handle VT release - signal already used
    [vo/gpu-next/opengl] Failed to set up VT switcher. Terminal switching will be unavailable.
    pci id for fd 14: 1b36:0100, driver (null)
    MESA-LOADER: failed to open qxl: /usr/lib/dri/qxl_dri.so: cannot open shared object file: No such file or directory (search paths /usr/lib/x86_64-linux-gnu/dri:\$${ORIGIN}/dri:/usr/lib/dri, suffix _dri)
    failed to load driver: qxl
    pci id for fd 15: 1b36:0100, driver (null)
    kmsro: driver missing
    [vo/gpu-next] Failed to create GBM surface.
    [vo/gpu-next] Failed to setup GBM.
    [vo/gpu-next/libplacebo] Found no suitable device, giving up.
    [vo/gpu-next/libplacebo] Failed initializing vulkan device
    Failed to open VDPAU backend libvdpau_nvidia.so: cannot open shared object file: No such file or directory
    [vo/vdpau] Error when calling vdp_device_create_x11: 1
    [vo/xv] No Xvideo support found.
    [vo/sdl] Using opengl
    [vo/sdl] Warning: this legacy VO has bad performance. Consider fixing your graphics drivers, or not forcing the sdl VO.
    [interSubs] Starting interSubs ...
    [W][01460.634462] pw.conf      | [          conf.c:  939 try_load_conf()] can't load config client.conf: No such file or directory
    [E][01460.635152] pw.conf      | [          conf.c:  963 pw_conf_load_conf_for_context()] can't load default config client.conf: No such file or directory

If we tick the "OpenGL" button, the VM can no longer be started:

    Error starting domain:
    internal error:
    process exited while connecting to monitor:
    2023-07-10T22:29:23.191966Z qemu-system-x86_64:
    SPICE GL support is local-only for now and incompatible with -spice port/tls-port

    Traceback (most recent call last):
      File "/usr/share/virt-manager/virtManager/asyncjob.py", line 75, in cb_wrapper
        callback(asyncjob, *args, **kwargs)
      File "/usr/share/virt-manager/virtManager/asyncjob.py", line 111, in tmpcb
        callback(*args, **kwargs)
      File "/usr/share/virt-manager/virtManager/object/libvirtobject.py", line 66, in newfn
        ret = fn(self, *args, **kwargs)
      File "/usr/share/virt-manager/virtManager/object/domain.py", line 1279, in startup
        self._backend.create()
      File "/usr/lib/python3/dist-packages/libvirt.py", line 1234, in create
        if ret == -1: raise libvirtError ('virDomainCreate() failed', dom=self)
    libvirt.libvirtError:
    internal error:
    process exited while connecting to monitor:
    2023-07-10T22:29:23.191966Z qemu-system-x86_64:
    SPICE GL support is local-only for now and incompatible with -spice port/tls-port

Edit: Setting "Listen type"  to "None" *might* fix the issue,  according to this
link: <https://bbs.archlinux.org/viewtopic.php?pid=2075621#p2075621>

I tested  this setting; the  VM starts, but the  warning remains, and  mpv still
gives errors.
