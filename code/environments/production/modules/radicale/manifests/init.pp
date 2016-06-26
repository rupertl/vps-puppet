# This class manages the package, files and service for the Radicale
# calendar.contacts service.

# Runs radicale as a daemon through systemd allowing connections from
# localhost. Access and HTTPS should be controlled through nginx - see
# https://www.blogobramje.nl/posts/How_to_run_radicale_behind_nginx/

# Parameters:
# src_dir - directory where radicale is installed
# date_dir - directory where radicale should store files
# user - user to run radicale update service as

class radicale(String $src_dir, String $data_dir, String $user) {
  user { $user:
    ensure => present,
    system => true,
    managehome => false,
    notify => Service['radicale'],
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    notify => Service['radicale'],
  }

  # Directory to store calendar data
  file { $data_dir:
    ensure  => directory,
    owner => $user,
    group => $user,
    mode => '755',
    require => User[$user],
  }

  # Radicale main config file
  file { "/etc/radicale/config":
    ensure  => file,
    content => epp("radicale/config.epp"),
  }

  # Systemd service
  file { "/etc/systemd/system/radicale.service":
    ensure  => file,
    content => epp('radicale/radicale.service.epp'),
  }

  service { 'radicale':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
