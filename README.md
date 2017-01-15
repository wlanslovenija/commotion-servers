# Commotion nodewatcher installation

This repository contains [Salt](http://docs.saltstack.com/en/latest/) files to deploy a nodewatcher instance for
Commotion Wireless.
Expected to be used with Ubuntu Server 14.04, but it might work with other
distributions as well.

An example Salt configuration, which may be used with `salt-ssh` follows.

```
pki_dir: /home/commotion/servers/config/pki
cachedir: /tmp/salt-cache
jinja_trim_blocks: True
jinja_lstrip_blocks: True
ssh_use_home_key: True
ssh_minion_opts:
  gpg_keydir: /home/commotion/.gnupg
log_file: /home/commotion/servers/log/master
ssh_log_file: /home/commotion/servers/log/ssh
file_roots:
  base:
    - /home/commotion/servers/states
    - /home/commotion/tozd
pillar_roots:
  base:
    - /home/commotion/servers/pillars
```

You can put it into the `config/master` file under this repository.

In this example, the `servers` directory contains a checkout of this repository, while
the `tozd` directory is a checkout of the [`tozd/salt` repository](https://github.com/tozd/salt),
containing commonly used Salt states.

You should also create a `config/roster` file with something like:

```
nodewatcher:
  host: nodewatcher.commotionwireless.net
  port: 22
  user: <username>
  sudo: True
```

Secrets in this example are encrypted with a GPG keypair to demonstrate how secrets can be protected.
Both private and public keys are stored in the the `gpgkeys` directory of this repository.
**This keypair is for demonstration purposes only.**
You should generate your own keypair, encrypt secrets yourself, and make sure to keep the private key secret.

Keypair was generated without any password on the keychain using:

```
gpg --homedir /home/commotion/servers/gpgkeys --gen-key
```

Secrets can be encrypted using:

```
echo -n "supersecret" | gpg --homedir /home/commotion/servers/gpgkeys --armor --encrypt -r C84CC9E2
```

[See Salt GPG renderer documentation for more information](https://docs.saltstack.com/en/latest/ref/renderers/all/salt.renderers.gpg.html).
