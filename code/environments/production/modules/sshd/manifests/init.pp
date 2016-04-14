# This class manages the package, files and service for ssh services.
# This module only includes configs which are not stock.

class sshd() {
  $config_dir = "/etc/ssh"

  package { 'openssh-server':
    ensure => installed,
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['openssh-server'],
    notify => Service['ssh'],
  }

  file { "$config_dir/sshd_config":
    ensure  => file,
    content => epp('sshd/sshd_config.epp'),
  }

  service { 'ssh':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
