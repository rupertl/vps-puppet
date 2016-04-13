# This class manages the package and files for etckeeper, which keeps
# the contents of /etc in a local git repo for easy analysis of
# changes. It will init the repo on first run.

class etckeeper {
  $config_dir = "/etc/etckeeper"

  # Ensures git is installed
  require essential

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
    ensure => file,
    content => epp('etckeeper/etckeeper.conf.epp'),
  }

  exec { 'etckeeper-init':
    command => 'etckeeper init',
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    cwd     => '/etc',
    creates => '/etc/.git',
    require => Package['etckeeper'],
  }
}
