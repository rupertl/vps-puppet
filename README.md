This is the puppet configuration for my VPSs and also any scratch VMs I spin up at home. Although it reflects my requirements for the servers I run, other people may find it useful so I'm putting it up on github.

This does not use a puppet master as I'm only managing a small number of nodes. Configs can be installed with `puppet apply` on each node instead.

I'm using Debian Jessie and Puppet 4.4 at present. Some Puppet 4 features such as EPP templates are used. Most site specific data is managed via Hiera (plus the encrypted YAML module for sensitive data). I don't generally use modules as I only need Debian support and don't want the overhead of managing modules on each server.

## Modules

The configuration implements installation of the software below as modules:

* apticron: handle regular system package updates
* essential: install general utility packages
* etckeeper: store /etc in git
* ntpd: synchronise system time
* postfix: email server
* ssh_public: install ssh authorized keys
* sudo: controlled root access

These need to be updated

* backups: use duplicity to backup servers
* logrotate: rotate system log files
* nginx: web server
* nodejs: programming language
* php: programming language
* postfix: email server [for mailhosts]
* pup_check: custom script to check puppet config
* radicale: calendar server

## Manifests

Each VPS has its own manifest of what to install.

## Bootstrap

Do a basic install of Debian, selecting ssh-server as the only extra task.

Once logged in, update the system and set up sudo and git:

```
$ su -c 'apt-get update; apt-get upgrade; apt-get install git sudo; adduser rupert sudo'
```

Log out and back in to pick up the group change then run the below to install puppet 4.4

```
$ sudo sh -c 'cd /tmp && wget http://apt.puppetlabs.com/puppetlabs-release-pc1-jessie.deb && dpkg -i puppetlabs-release-pc1-jessie.deb && apt-get update && apt-get install puppet-agent'
```

## Use

Clone this git repo to `/etc/puppetlabs` and then run

```
$ puppet apply /etc/puppetlabs/code/environments/production/manifests/`hostname`.pp
```

## License

License: 3-clause new BSD; see LICENSE file.
