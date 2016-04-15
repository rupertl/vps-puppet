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

  Exec {
    require => Package['openssh-server'],
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    notify => Service['ssh'],
  }

  # Generate the ed25519 key if not present
  exec {"generate ed25519 key":
    creates => '/etc/ssh/ssh_host_ed25519_key',
    command => 'ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""',
  }

  service { 'ssh':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
