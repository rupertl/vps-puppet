This is the puppet configuration for my VPSs and also any scratch VMs I spin up at home. Although it reflects my requirements for the servers I run, other people may find it useful so I'm putting it up on github.

This does not use a puppet master as I'm only managing a small number of nodes. Configs can be installed with `puppet apply` on each node instead.

I'm using Debian Jessie and Puppet 4.4 at present. Some Puppet 4 features such as EPP templates are used. Most site specific data is managed via Hiera (plus the encrypted YAML module for sensitive data). I don't generally use modules as I only need Debian support and don't want the overhead of managing modules on each server.

## Modules

The configuration implements installation of the software below as modules:

* apticron: handle regular system package updates
* essential: install general utility packages
* etckeeper: store /etc in git
* ghost: blogging system written in node.js
* letsencrypt: generate SSL certificates
* nginx: web server
* ntpd: synchronise system time
* postfix: email server
* sshd: ssh server
* ssh_public: install ssh authorized keys
* sudo: controlled root access

These need to be updated

* backups: use duplicity to backup servers
* php: programming language
* postfix: email server [for mailhosts]
* pup_check: custom script to check puppet config

## Bootstrap

Do a basic install of Debian, selecting ssh-server as the only extra task.

Run the bootstrap script to install Puppet PC1 and clone this repo.

```
wget -qO - https://raw.githubusercontent.com/rupertl/vps-puppet/puppet4/scripts/bootstrap.sh | bash
```

This will also install the [encrypted YAML](https://github.com/TomPoulton/hiera-eyaml) gem. 

Finally,  copy the EYAML keys to `/etc/puppetlabs/secure/eyaml/keys/`. Obviously if you are not me you won't have these, so you'll need to regenerate any encrypted sections of Hiera files.

## Use

```
$ puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp
```

## License

License: 3-clause new BSD; see LICENSE file.
