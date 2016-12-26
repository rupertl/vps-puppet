# This class manages the package, files and service for the OpenDKIM
# email signing system. It only includes configs which are not stock.

# TODO: Note this uses a predefined selector 201612 and does not
# generate keys. Use something like
# opendkim-genkey -b 2048 -h rsa-sha256 -r -s 201612 -d example.com -v

# Parameters
# primary_domain: Main email domain we send email for
# secondary_domains: Array of other email domains we send email for

class opendkim ($primary_domain, $secondary_domains) {
  $config_file = "/etc/opendkim.conf"
  $config_dir = "/etc/opendkim"
  $ket_dir = "${config_dir}/keys"

  package { ['opendkim', 'opendkim-tools']:
    ensure => installed,
    notify => Service['opendkim'],
  }

  File {
    owner => 'opendkim',
    group => 'opendkim',
    mode => '644',
    require => Package['opendkim'],
    notify => Service['opendkim'],
  }

  # Create the directory to store OpenDKIM configs
  file { $config_dir:
    ensure => directory,
    mode => '0755',
  }

  # Create the directory to store OpenDKIM keys
  file { $key_dir:
    ensure => directory,
    mode => '0700',
    require => File[$config_dir],
  }

  # Main config file
  file { "$config_file":
    ensure  => file,
    content => epp("opendkim/opendkim.conf.epp"),
  }

  # Domain to key table map
  file { "$config_dir/signing.table":
    ensure  => file,
    content => epp("opendkim/signing.table.epp"),
    require => File[$config_dir],
  }

  # Key table map
  file { "$config_dir/key.table":
    ensure  => file,
    content => epp("opendkim/key.table.epp"),
    require => File[$config_dir],
  }

  # Trusted sending hosts
  file { "$config_dir/trusted.hosts":
    ensure  => file,
    content => epp("opendkim/trusted.hosts.epp"),
    require => File[$config_dir],
  }

  service { 'opendkim':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

}
