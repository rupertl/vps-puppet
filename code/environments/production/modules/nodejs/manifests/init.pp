# This class manages the package, files and service for node.js services
# It only includes configs which are not stock Ubuntu.

class nodejs {

  # Note on Ubuntu 12.04 we need a PPA to get Node 1.0
  # sudo add-apt-repository ppa:chris-lea/node.js

  package { ["python-software-properties", "python", "g++", "make", "nodejs"]:
    ensure => installed,
  }

  # Some NPM packages require node to be called node; Debian calls it nodejs
  # so create a soft link

  file { '/usr/local/bin/node':
    ensure => 'link',
    target => '/usr/bin/nodejs',
  }

}
