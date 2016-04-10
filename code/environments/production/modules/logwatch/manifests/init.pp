# This class manages the package and files used for the daily logwatch system.
# It only includes configs which are not stock Ubuntu.

class logwatch {
  $config_dir = "/usr/share/logwatch/default.conf"
  
  package { 'logwatch':
    ensure => installed,
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['logwatch'],
  }    

  file { "$config_dir/logwatch.conf":
    ensure => present,
    source => 'puppet:///modules/logwatch/logwatch.conf',
  }

  file { "$config_dir/logfiles/spamassassin.conf":
    ensure => present,
    source => 'puppet:///modules/logwatch/logfiles/spamassassin.conf',
  }

  # No service dependency as this will be run by cron daily.
}
