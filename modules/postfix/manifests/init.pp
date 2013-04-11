# This class manages the package, files and service for the postfix
# email server. It only includes configs which are not stock Ubuntu.

class postfix {
  $config_dir = "/etc/postfix"
  
  package { 'postfix':
    ensure => installed,
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['postfix'],
  }

  # The main and master config files need the service to be reloaded
  # when changed.
  file { "$config_dir/main.cf":
    ensure => present,
    source => 'puppet:///modules/postfix/main.cf',
    notify => Service['postfix'],
  }

  file { "$config_dir/master.cf":
    ensure => present,
    source => 'puppet:///modules/postfix/master.cf',
    notify => Service['postfix'],
  }

  service { 'postfix':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

  # The virtual and aliases files need to be converted to DB format
  # when changed.
  file { "$config_dir/virtual":
    ensure => present,
    source => 'puppet:///modules/postfix/virtual',
    notify => Exec['postmap virtual'],
  }

  exec { 'postmap virtual':
    command => "/usr/sbin/postmap $config_dir/virtual",
    refreshonly => true
  }
  
  file { "/etc/aliases":
    ensure => present,
    source => 'puppet:///modules/postfix/aliases',
    notify => Exec['postmap aliases'],
  }

  exec { 'postmap aliases':
    command => "/usr/sbin/postmap /etc/aliases",
    refreshonly => true
  }
  
}
