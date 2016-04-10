This is the puppet configuration for my VPSs. Although it reflects my requirements for the servers I run, other people may find it useful so I'm putting it up on github.

I'm using Debian Jessie and puppet 4.4 at present.

## Modules

The configuration implements installation of the software below as modules:

* apticron: handle regular system package updates
* backups: use duplicity to backup servers
* etckeeper: store /etc in git
* logrotate: rotate system log files
* logwatch: watch for changes to system logs
* nginx: web server
* nodejs: programming language
* ntpd: synchronise system time
* php: programming language
* postfix: email server
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
