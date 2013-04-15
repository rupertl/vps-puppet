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

  # The config files need the service to be reloaded when changed.
  
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

  file { "$config_dir/sasl/smtpd.conf":
    ensure => present,
    source => 'puppet:///modules/postfix/smtpd.conf',
    notify => Service['postfix'],
  }

  service { 'postfix':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

  # Postfix relies on saslauthd for authentication so this is defined
  # here also. Note that SSL certificate generation is not covered.
  
  package { 'sasl2-bin':
    ensure => installed,
  }
  
  file { '/etc/default/saslauthd':
    ensure => present,
    source => 'puppet:///modules/postfix/saslauthd',
    require => Package['sasl2-bin'],
    notify => Service['saslauthd'],
  }

  service { 'saslauthd':
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
    notify => Exec['newaliases'],
  }

  exec { 'newaliases':
    command => "/usr/bin/newaliases",
    refreshonly => true
  }
  
}
