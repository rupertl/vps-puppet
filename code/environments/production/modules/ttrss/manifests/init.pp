# This class manages the package, files and service for the Tiny Tiny
# RSS web service.

# Parameters:
# dir - directory where TTRSS is installed
# user - user to run TTRSS update service as

class ttrss(String $dir, String $user) {
  require postgres;
  require php;

  user { $user:
    ensure => present,
    system => true,
    managehome => false,
    notify => Service['ttrss'],
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    notify => Service['ttrss'],
  }

  file { "/etc/systemd/system/ttrss.service":
    ensure  => file,
    content => epp('ttrss/ttrss.service.epp'),
  }

  service { 'ttrss':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
