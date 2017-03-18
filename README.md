# Commotion nodewatcher installation

This repository contains [Salt](http://docs.saltstack.com/en/latest/) files to deploy a nodewatcher instance for
Commotion Wireless.
Expected to be used with Ubuntu Server 14.04 and 16.04, but it might work with other distributions
as well.

You should create a `config/roster` file with something like:

```
nodewatcher:
  host: nodewatcher.commotionwireless.net
  port: 22
  user: <username>
  sudo: True
```

Your user on the target server should have sudo permissions without needing to provide a password.
You can configure that in `/etc/sudoers` on the target server with such line (you can replace existing
one without `NOPASSWD`):

```
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL) NOPASSWD: ALL
```

Then you can sync the state of a server by doing:

```
$ salt-ssh '<servername>' state.highstate
```

Secrets in this example are encrypted with a GPG keypair to demonstrate how secrets can be protected.
Both private and public keys are stored in the the `gpgkeys` directory of this repository.
**This keypair is for demonstration purposes only.**
You should generate your own keypair, encrypt secrets yourself, and make sure to keep the private key secret.

Keypair was generated without any password on the keychain using:

```
gpg --homedir ./gpgkeys --gen-key
```

Future secrets can be encrypted using:

```
echo -n "supersecret" | gpg --homedir ./gpgkeys --armor --encrypt -r C84CC9E2
```

[See Salt GPG renderer documentation for more information](https://docs.saltstack.com/en/latest/ref/renderers/all/salt.renderers.gpg.html).
