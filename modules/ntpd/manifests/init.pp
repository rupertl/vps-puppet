# This class manages the package, files and service for NTP services.
# We use openntpd across Ubuntu and Debian
# This module only includes configs which are not stock.

class ntpd {
  $config_dir = "/etc/openntpd"
  
  package { 'openntpd':
    ensure => installed,
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['openntpd'],
    notify => Service['openntpd'],
  }    

  file { "$config_dir/ntpd.conf":
    ensure => present,
    source => 'puppet:///modules/ntpd/ntpd.conf',
  }

  service { 'openntpd':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
