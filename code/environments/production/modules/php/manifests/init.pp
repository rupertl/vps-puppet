# This class manages the package, files and service for the php-fpm
# server. It only includes configs which are not stock.

class php {
  $config_dir = "/etc/php5"

  package { 'php5-fpm':
    ensure => installed,
  }

  $php_extras = ["php-apc", "php5-cli", "php5-curl", "php5-gd", "php5-mcrypt",
                 "php5-pgsql", "php5-intl" ]
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

  file { "$config_dir/fpm/php-fpm.conf":
    ensure => file,
    content => epp('php/php-fpm.conf.epp'),
  }

  file { "$config_dir/fpm/pool.d/www.conf":
    ensure => file,
    source => epp('php/fpm-pool-www.conf.epp',
  }

  service { 'php5-fpm':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
