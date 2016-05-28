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
#    notify => Service['ghost'],
  }

  # File {
  #   owner => 'root',
  #   group => 'root',
  #   mode => '644',
  #   notify => Service['ghost'],
  # }

  # file { "/etc/systemd/system/ghost.service":
  #   ensure  => file,
  #   content => epp('ghost/ghost.service.epp'),
  # }

  # service { 'ghost':
  #   ensure => running,
  #   enable => true,
  #   hasstatus => true,
  #   hasrestart => true,
  # }
}
