# This class manages the package, files and service for the nginx
# webserver. It only includes configs which are not stock Ubuntu.

class nginx {
  $config_dir = "/etc/nginx"
  
  package { 'nginx':
    ensure => installed,
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['nginx'],
    notify => Service['nginx'],
  }    

  file { "$config_dir/nginx.conf":
    ensure => present,
    source => 'puppet:///modules/nginx/nginx.conf',
  }

  service { 'nginx':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
