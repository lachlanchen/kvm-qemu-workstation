# Native UU Remote in the Windows guest

A Windows guest can run the official UU client independently of the Ubuntu
Wine bridge. This supplies a separate UU device and a possible mapping endpoint
without changing the host's desktop, keyboard, dictation, or clipboard patches.
It is still a vendor-session-dependent TCP forward, not a private LAN or a
guaranteed replacement for a persistent SSH tunnel.

## Install without restarting the guest

Use an existing, SSH-accessible Windows guest. Keep its disks, user profile,
running apps, and current SSH/RDP forwards. Obtain the Windows installer from
[NetEase's official release endpoint](https://api.nrd.nie.163.com/api/v1/release/dl/1?channel=gwqd)
linked by the existing UU updater; avoid lookalike download sites.

On 2026-09-07 the endpoint selected **4.39.2.1561**. An existing cached copy
was reused and verified inside Windows:

```text
SHA-256: cf06187be7b1382eab9d53afa129e4dc0dc07b0c7526d1e7a849475e0ca046f5
Size: 90649136 bytes
Authenticode: Valid
Publisher: NetEase (Hangzhou) Network Co., Ltd
```

Run from elevated Windows PowerShell, initially without `-Install`:

```powershell
./install-uu-remote.ps1 -Installer ./UURemote_Setup.exe `
  -Sha256 cf06187be7b1382eab9d53afa129e4dc0dc07b0c7526d1e7a849475e0ca046f5 `
  -Version 4.39.2.1561
```

Add `-Install` for the reviewed installation. The
[script](../windows/tiny11/guest/install-uu-remote.ps1) verifies the hash,
Windows signature, publisher, and version before invoking the native installer
with `/S`. Repeating it after success returns `already-installed`. It refuses
to replace an older live installation: upgrade that separately through the
normal vendor update process. It does not reboot, copy authentication state,
patch Windows input, or kill a slow installer after its bounded wait expires.

The verified installation created `GameViewerService`, running with automatic
startup, and the native server in the existing console user's session. Start
`C:\Program Files\Netease\GameViewer\GameViewer.exe` in that user's interactive
session and complete the ordinary UU QR/SMS login. SSH commands run outside the
interactive desktop; a one-shot scheduled task with `LogonType Interactive`
can open this executable for an already logged-in user. Do not create another
Windows login session or copy an existing UU device's profile.

## Two useful topologies

### Guest as the controller

```text
Ubuntu OpenSSH -- local SSH --> Windows guest's localhost mapping
                                    |
                                    +-- native UU --> remote SSH server
```

The listener is **inside Windows**, not on Ubuntu's `127.0.0.1`. Use SSH
`ProxyJump` through the guest to reach it. No additional QEMU host forward,
bridged network, firewall opening, or background port-proxy loop is necessary.

Example private SSH configuration, assuming the guest and destination host
keys have already been verified and pinned:

```sshconfig
Host uu-vm
    HostName 127.0.0.1
    Port 2290
    User YOUR_WINDOWS_USER
    IdentityFile ~/.ssh/YOUR_EXISTING_GUEST_KEY
    IdentitiesOnly yes
    StrictHostKeyChecking yes
    BatchMode yes

Host uu-lab-via-vm
    HostName 127.0.0.1
    Port 23709
    User YOUR_REMOTE_USER
    ProxyJump uu-vm
    IdentityFile ~/.ssh/YOUR_EXISTING_REMOTE_KEY
    HostKeyAlias YOUR_EXISTING_VERIFIED_REMOTE_HOST_ALIAS
    UserKnownHostsFile ~/.ssh/YOUR_VERIFIED_HOSTS_FILE
    IdentitiesOnly yes
    StrictHostKeyChecking yes
    BatchMode yes
    ForwardAgent no
    ConnectTimeout 8
    ServerAliveInterval 20
    ServerAliveCountMax 3
```

Create the matching rule in the guest's native UU **Port Mapping** panel:
guest loopback `23709` to the remote-side SSH address and port `22`.
Use a distinct port and alias for each destination. A minimal executable helper
named `ssh-uu-lab-via-vm` is just:

```sh
#!/bin/sh
exec /usr/bin/ssh uu-lab-via-vm "$@"
```

It supports an interactive shell or command. File transfer uses the SSH alias:

```bash
ssh-uu-lab-via-vm
ssh-uu-lab-via-vm hostname
scp ./example.txt uu-lab-via-vm:~/
```

The bridge's existing `uu-ssh add ... --via-ssh-host uu-vm --shell-transport ssh`
also generates a jump-host profile; its dedicated key and host-key alias must
be enrolled/pinned before use. Neither method creates a UU vendor mapping.

### Guest as the controlled relay endpoint

With the reference QEMU user network, the guest can reach the Ubuntu host at
`10.0.2.2:22`. A remote UU controller may therefore map a port **to the Windows
guest's device**, targeting `10.0.2.2:22` rather than Windows's own SSH server.
The final SSH identity is Ubuntu's, so keep Ubuntu's host-key pin and user key.
This can isolate mapping ownership from the Ubuntu Wine UU desktop device.
The reference guest reached the host's SSH banner through this address.

Once one direction really works, SSH can carry an explicitly configured
loopback reverse forward for the return direction. That return route shares
the original carrier's lifetime. Alternatively, operate independent dedicated
UU endpoints on both sides. Do not assume that installing one VM makes every
device reachable in both directions without mapping and SSH authorization.

## Availability and control ownership

- Native Windows needs no Ubuntu Wine keyboard, input-broker, terminal proxy,
  or dictation binary patches. Applying them to this guest would be incorrect.
- A dedicated VM isolates its own UU identity from the host desktop. If the
  **remote mapping target** is also a device someone takes over, the vendor can
  still disconnect its mapping. A dedicated target endpoint avoids that shared
  device, but live testing is still needed.
- `uuyc-cli.exe --help` in 4.39.2.1561 exposes terminal and device commands,
  but no public mapping-management command. Do not invent CLI switches, edit
  the private UU database, or trigger takeover from a health checker.
- An auto-starting Windows service does not prove a saved mapping reconnects
  after reboot. The guest, account login, UU controller session, and rule all
  need to be available. Existing host VM startup ownership should be reused.
- Preserve working cloud/LazyTunnel routes under their existing names. Keep
  VM-based candidates explicitly named until actual shell and transfer tests
  pass; do not silently switch an existing alias to an unverified route.

## Acceptance record and remaining step

Verified on 2026-09-07: native installation and repeated no-op installation;
automatic running Windows service; native GUI with a normal QR login; existing
Windows user/apps preserved; strict SSH login to the VM; an SSH jump through
that VM to a LAN Windows peer; and reachability of the host's SSH banner from
the guest. The host's existing UU bridge was not restarted or patched.

The new UU guest was **not logged in** at this checkpoint. Native UU mappings,
remote SSH through those mappings, real takeover coexistence, and reboot
reconnection remain **unverified**. Prepared SSH aliases are not evidence of a
running tunnel. Complete the account login, enable the reviewed rules, then
test hostname, Unicode shell output, file round trip, and ordinary desktop use.

For application desktops moved onto a Windows virtual display, QEMU's physical
console can retain an old frame while the guest's live VNC view is current.
Use the existing live Windows view to log in; do not restart Windows or move
other applications to repair a stale console just for this installation.
