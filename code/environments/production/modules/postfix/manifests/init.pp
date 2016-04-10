# This class manages the package, files and service for the postfix
# email server. It only includes configs which are not stock.

# Parameter server_type can be
# "mailhost" for internet facing send/receive servers
# "satellite" for servers that do not have local delivery and forward
# all email to a mailhost

class postfix ($server_type) {
  $config_dir = "/etc/postfix"

  if ($server_type != "mailhost" and $server_type != "satellite") {
    fail("server_type must be 'mailhost' or 'satellite'")
  }

  package { 'postfix':
    ensure => installed,
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['postfix'],
  }

  # The config files need the service to be reloaded when changed.

  file { "$config_dir/main.cf":
    ensure => present,
    source => "puppet:///modules/postfix/${server_type}.main.cf",
    notify => Service['postfix'],
  }

  if ($server_type == "mailhost") {
    file { "$config_dir/master.cf":
      ensure => present,
      source => 'puppet:///modules/postfix/master.cf',
      notify => Service['postfix'],
    }

    file { "$config_dir/sasl/smtpd.conf":
      ensure => present,
      source => 'puppet:///modules/postfix/smtpd.conf',
      notify => Service['postfix'],
    }
  }

  service { 'postfix':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

  if ($server_type == "mailhost") {
    # Postfix on mailhosts relies on saslauthd for authentication so
    # this is defined here also. Note that SSL certificate generation
    # is not covered.

    package { 'sasl2-bin':
      ensure => installed,
    }

    file { '/etc/default/saslauthd':
      ensure => present,
      source => 'puppet:///modules/postfix/saslauthd',
      require => Package['sasl2-bin'],
      notify => Service['saslauthd'],
    }

    service { 'saslauthd':
      ensure => running,
      enable => true,
      hasstatus => true,
      hasrestart => true,
    }
  }

  # Configure SMTP forwarding to mailhost for satellities
  # As this involves passwords this is not included here
  if ($server_type == "satellite") {

    file { "$config_dir/sasl_passwd":
      replace => "no",
      ensure  => "present",
      content => "# This file needs to be set up\n",
      mode    => 600,
    }

    file { "$config_dir/generic":
      replace => "no",
      ensure  => "present",
      content => "# This file needs to be set up\n",
    }
  }

  # The virtual and aliases files need to be converted to DB format
  # when changed.

  if ($server_type == "mailhost") {
    file { "$config_dir/virtual":
      ensure => present,
      source => 'puppet:///modules/postfix/virtual',
      notify => Exec['postmap virtual'],
    }

    exec { 'postmap virtual':
      command => "/usr/sbin/postmap $config_dir/virtual",
      refreshonly => true
    }
  }

  file { "/etc/aliases":
    ensure => present,
    source => "puppet:///modules/postfix/${server_type}.aliases",
    notify => Exec['newaliases'],
  }

  exec { 'newaliases':
    command => "/usr/bin/newaliases",
    refreshonly => true
  }

}
