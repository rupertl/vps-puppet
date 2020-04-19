# This class manages the package, files and service for NTP services.
# We use openntpd (and turn off systemd-timesyncd)
# This module only includes configs which are not stock.

class ntpd(Array $servers, Boolean $is_server = false) {
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
    ensure  => file,
    content => epp('ntpd/ntpd.conf.epp'),
  }  

  service { 'openntpd':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

  service { 'systemd-timesyncd':
    ensure => stopped,
    enable => false,
  }
}
  
