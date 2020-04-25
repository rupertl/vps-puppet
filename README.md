This is the puppet configuration for my VPSs, home file server and also any scratch VMs I spin up at home. Although it reflects my requirements for the servers I run, other people may find it useful so I'm putting it up on github.

This does not use a puppet master as I'm only managing a small number of nodes. Configs can be installed with `puppet apply` on each node instead.

This works with Debian Buster and the version of puppet 5.5 included by Debian. Previous versions used the version of puppet packaged by Puppetlabs. See the section at the end of this file on how to upgrade.

Most site specific data is managed via Hiera (plus the encrypted YAML module for sensitive data). I don't generally use modules as I only need Debian support and don't want the overhead of managing modules on each server.

## Modules

The configuration implements installation of the software below as modules:

* apticron: handle regular system package updates
* backups: scheduled database backups
* dovecot: IMAP mailbox server
* essential: install general utility packages
* etckeeper: store /etc in git
* dehydrated: generate SSL certificates
* nfs_server: local network NFS server
* nginx: web server
* ntpd: synchronise system time
* opendkim: email signing service
* php: programming language for web applications
* pflogsumm: Postfix reporting
* postfix: email, both for main relay host and satellites
* postgres: database engine
* pup_check: custom script to check puppet config
* radicale: CalDAV/CardDAV calendar/contacts service
* spamassassin: email filtering service
* sshd: ssh server
* ssh_public: install ssh authorized keys
* sudo: controlled root access
* ttrss: Tiny Tiny RSS web application

## Bootstrap

Do a basic install of Debian, selecting ssh-server as the only extra task.

Run the bootstrap script to install Puppet PC1 and clone this repo.

```
wget -qO - https://raw.githubusercontent.com/rupertl/vps-puppet/master/scripts/bootstrap.sh | bash
```

This will also install the [encrypted YAML](https://github.com/TomPoulton/hiera-eyaml) gem.

Finally, copy the EYAML keys to `/etc/puppet/secure/eyaml/keys/` and encrypted YAML files under `hieradata`. Obviously if you are not me you won't have these, so you'll need to regenerate any encrypted Hiera files.

## Use

```
$ puppet apply /etc/puppet/code/environments/production/manifests/site.pp
```

## Upgrading from Puppetlans Puppet 4 to Debian Puppet 5

As of the move to Debian Buster I've switched from using the version of Puppet 4 provided by Puppetlabs to the stock Puppet 5 provided by Debian. Historically the version of Puppet provided by Debian lagged behind, but it is modern enough now. Having to deal with one less foreign apt repository is a plus.

The main differnce between the two packages is that Debian Puppet expects its config files to be in `/etc/puppet` rather than `/etc/puppetlabe`. Some subdirectories have also moved, eg `hieradata` is now called `data`. As a result, I recommend something like the following set of steps to upgrade:

```
$ apt-get remove puppet-agent puppetlabs-release-pc1
$ apt-get purge puppet-agent puppetlabs-release-pc1
$ apt-get update && apt-get dist-upgrade
$ mv /etc/puppetlabs /etc/OLD.puppetlabs
$ apt-get install puppet hiera-eyaml
$ mv /etc/puppet /etc/OLD.puppet
$ git clone https://github.com/rupertl/vps-puppet.git /etc/puppet
```

Copy over any EYAML files and keys from `/etc/OLD.puppetlabs`, test it works with the usual puppet apply command and then remove `/etc/OLD.puppet*`.

## License

License: 3-clause new BSD; see LICENSE file.
