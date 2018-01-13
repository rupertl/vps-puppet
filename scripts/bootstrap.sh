%#!/bin/bash

# Bootstraps a new server by installing Puppet and some essential
# modules then cloning the vps-puppet repo.

echo "## Updating package list"
apt-get -y update

echo "## Upgrading packages"
apt-get -y upgrade

echo "## Installing git"
apt-get -y install git

echo "## Getting Puppet PC1"
cd /tmp
wget -q https://apt.puppetlabs.com/puppetlabs-release-pc1-stretch.deb

echo "## Installing Puppet PC1"
dpkg -i /tmp/puppetlabs-release-pc1-stretch.deb
rm -f /tmp/puppetlabs-release-pc1-stretch.deb

echo "## Updating package list again"
apt-get -y update

echo "## Installing puppet"
apt-get -y install puppet-agent

echo "## Moving away the old /etc/puppetlabs"
mv /etc/puppetlabs /tmp/old-etc-puppetlabs

echo "## Cloning the vps-puppet repo"
git clone https://github.com/rupertl/vps-puppet.git /etc/puppetlabs

echo "## Installing the EYAML gem"
/opt/puppetlabs/puppet/bin/gem install hiera-eyaml
ln -s /opt/puppetlabs/puppet/bin/eyaml /opt/puppetlabs/bin/

echo "## All done."
echo "## Remember to install EYAML keys to"
echo "## /etc/puppetlabs/secure/eyaml/keys/"
echo "## Then run the following command to apply puppet config"
echo "## puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp"
