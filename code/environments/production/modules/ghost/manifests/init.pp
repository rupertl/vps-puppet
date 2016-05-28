# This class manages the package, files and service for the Ghost
# blogging service. This module only includes configs which are not
# stock.

# Parameters:
# dir - directory where Ghost is installed
# user - user to run ghost as

class ghost(String $dir, String $user) {
  require postgres;

  package { ['build-essential', 'nodejs', 'nodejs-legacy', 'npm', 'unzip']:
    ensure => installed,
    notify => Service['ghost'],
  }

  user { $user:
    ensure => present,
    system => true,
    managehome => false,
    notify => Service['ghost'],
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    notify => Service['ghost'],
  }

  file { "/etc/systemd/system/ghost.service":
    ensure  => file,
    content => epp('ghost/ghost.service.epp'),
  }

  service { 'ghost':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
