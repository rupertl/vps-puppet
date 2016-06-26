# This class manages the package, files and service for the Radicale
# calendar.contacts service.

# Parameters:
# date_dir - directory where radicale should store files
# user - user to run radicale update service as

# Runs radicale as a daemon through systemd allowing connections from
# localhost. Authentication and HTTPS encryption should be controlled
# through nginx - see
# https://www.blogobramje.nl/posts/How_to_run_radicale_behind_nginx/

# As Debian Jessie has an old version of radicale we need to use the
# version from git; however note that the current dev version (as of
# 26 June 2016) does not seem to work with CalDAVSync on Android so
# you should check out the latest stable version 1.1.1

# From the unpacked git repo, run sudo python3 ./setup.py install
# there to get the correct python dependencies and install it to
# /usr/local/bin

class radicale(String $data_dir, String $user) {

  $config_dir = "/etc/radicale";
  $config_file = "${config_dir}/config";

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

  # Config directory
  file { $config_dir:
    ensure  => directory,
    owner => $user,
    group => $user,
    mode => '755',
    require => User[$user],
    notify => File[$config_file],
  }

  # Radicale main config file
  file { $config_file:
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
