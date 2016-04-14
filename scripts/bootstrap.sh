#!/bin/bash

# Bootstraps a new server by installing Puppet and some essential
# modules then cloning the vps-puppet repo.

echo "## Updating package list"
apt-get update

echo "## Upgrading packages"
apt-get upgrade

echo "## Installing git"
apt-get install git sudo

echo "## Getting Puppet PC1"
cd /tmp
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-jessie.deb

echo "## Installing Puppet PC1"
dpkg -i /tmp/puppetlabs-release-pc1-jessie.deb
rm -f /tmp/puppetlabs-release-pc1-jessie.deb

echo "## Updating package list again"
apt-get update

echo "## Installing puppet"
apt-get install puppet-agent

echo "## Cloning the vps-puppet repo"
cd /etc/puppetlabs
git clone https://github.com/rupertl/vps-puppet.git

echo "## All done."
echo "## Remember to install EYAML keys to"
echo "## /etc/puppetlabs/secure/eyaml/keys/"
echo "## Then run the following command to apply puppet config"
echo "## puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp"
