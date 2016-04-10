# This class manages the package, files and service for the radicale
# calendar server. It only includes configs which are not stock
# Ubuntu.

class radicale {
  $config_dir = "/etc/radicale"
  $default_dir = "/etc/default"
  
  package { 'radicale':
    ensure => installed,
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['radicale'],
    notify => Service['radicale'],
  }

  file { "$default_dir/radicale":
    ensure => present,
    source => 'puppet:///modules/radicale/default',
  }

  file { "$config_dir/config":
    ensure => present,
    source => 'puppet:///modules/radicale/config',
  }

  file { "$config_dir/logging":
    ensure => present,
    source => 'puppet:///modules/radicale/logging',
  }

  # There is also a 'users' file but this is managed separately.

  service { 'radicale':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
