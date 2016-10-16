# This class manages the package, files and service for the multiccy webapp.

# Parameters:
# dir - directory where multiccy is installed
# user - user to run multiccy as

class multiccy(String $dir, String $user) {
  # Unfortunately we need a home directory for npm to work properly
  user { $user:
    ensure => present,
    system => true,
    managehome => true,
    notify => Service['multiccy'],
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    notify => Service['multiccy'],
  }

  file { "/etc/systemd/system/multiccy.service":
    ensure  => file,
    content => epp('multiccy/multiccy.service.epp'),
  }

  service { 'multiccy':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
