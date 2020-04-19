#!/bin/bash

# Bootstraps a new server by installing Puppet and some essential
# modules then cloning the vps-puppet repo.
#
# This now uses the stock puppet 5.5 available through Debian rather
# then using the package released by puppet.com. The root directory
# has changed as a result from /etc/puppetlabs to /etc/puppet

echo "## Updating package list"
apt-get -y update

echo "## Upgrading packages"
apt-get -y upgrade

echo "## Installing git"
apt-get -y install git

echo "## Getting Puppet and modules"
apt-get -y install puppet hiera-eyaml

echo "## Moving away the old /etc/puppet"
mv /etc/puppet /tmp/old-etc-puppet

echo "## Cloning the vps-puppet repo"
git clone https://github.com/rupertl/vps-puppet.git /etc/puppet

echo "## All done."
echo "## Remember to install EYAML keys to"
echo "## /etc/puppet/secure/eyaml/keys/"
echo "## Then run the following command to apply puppet config"
echo "## puppet apply /etc/puppet/code/environments/production/manifests/site.pp"

