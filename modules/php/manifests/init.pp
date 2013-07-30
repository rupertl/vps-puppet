# This class manages the package, files and service for the php-fpm
# server. It only includes configs which are not stock Ubuntu.

class php {
  $config_dir = "/etc/php5"

  package { 'php5-fpm':
    ensure => installed,
  }

  $php_extras = ["php5-cli", "php5-curl", "php5-gd", "php5-mcrypt",
                 "php5-pgsql", "php5-suhosin" ]
  package { $php_extras:
    ensure => "installed"
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['php5-fpm'],
    notify => Service['php5-fpm'],
  }

  file { "$config_dir/fpm/pool.d/www.conf":
    ensure => present,
    source => 'puppet:///modules/php/fpm-pool-www.conf',
  }

  service { 'php5-fpm':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
