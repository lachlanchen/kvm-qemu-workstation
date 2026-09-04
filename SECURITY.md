# Security policy

This repository intentionally contains no VM image, installer, licence key,
credential, private SSH key, OpenCore identity, writable firmware state, TPM
state, or browser profile.

Default display and guest-service forwards are loopback-only. Reach them from
another computer through an authenticated SSH tunnel rather than changing the
bind address. Report accidental secret publication privately to the repository
owner and rotate the affected identity before opening a public issue.
