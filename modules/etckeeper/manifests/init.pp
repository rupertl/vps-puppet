# This class manages the package and files for etckeeper. It will init
# the repo on first run. The class assumes stock Debian/Ubuntu and
# that git was installed as part of base setup.

class etckeeper {
  $config_dir = "/etc/etckeeper"

  package { 'etckeeper':
    ensure => installed,
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['etckeeper'],
  }

  file { "$config_dir/etckeeper.conf":
    ensure => present,
    source => 'puppet:///modules/etckeeper/etckeeper.conf',
  }

  exec { 'etckeeper-init':
    command => 'etckeeper init',
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    cwd     => '/etc',
    creates => '/etc/.git',
    require => Package['etckeeper'],
  }
}
