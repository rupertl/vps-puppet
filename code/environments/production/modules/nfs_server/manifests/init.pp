# This class manages the package, files and service for a local
# network NFS server. This module only includes configs which are not
# stock.
#
# Parameters:
# exports: Array of strings, each containing a directory and export
# options separated by whitespace

class nfs_server(Array $exports) {
  package { 'nfs-kernel-server':
    ensure => installed,
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['nfs-kernel-server'],
    notify => Service['nfs-kernel-server'],
  }

  file { "/etc/exports":
    ensure  => file,
    content => epp('nfs_server/exports.epp'),
  }

  service { 'nfs-kernel-server':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
