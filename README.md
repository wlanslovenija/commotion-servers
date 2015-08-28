# Commotion nodewatcher installation

This repository contains the necessary Salt files to deploy a nodewatcher instance for
Commotion Wireless.

An example Salt configuration, which may be used with `salt-ssh` follows.

```
pki_dir: /home/commotion/salt/config/pki
cachedir: /tmp/salt-cache
jinja_trim_blocks: True
jinja_lstrip_blocks: True
file_roots:
  base:
    - /home/commotion/servers/states
    - /home/commotion/tozd
pillar_roots:
  base:
    - /home/commotion/servers/pillars
```

In this example, the `servers` directory contains a checkout of this repository, while
the `tozd` directory is a checkout of the [`tozd/salt` repository](https://github.com/tozd/salt),
containing commonly used Salt states.

