# This class manages the package and files used for log rotation.
# It only includes configs which are not stock Ubuntu.

class logrotate {
  $config_dir = "/etc/logrotate.d"
  
  package { 'logrotate':
    ensure => installed,
  }

  file { "$config_dir/nginx":
    ensure => present,
    source => 'puppet:///modules/logrotate/nginx',
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['logrotate'],
  }

  file { "$config_dir/spamassassin":
    ensure => present,
    source => 'puppet:///modules/logrotate/spamassassin',
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['logrotate'],
  }

  # No service dependency as we don't need to run log rotation after
  # the config has changed - can wait until the next scheduled run.
}
