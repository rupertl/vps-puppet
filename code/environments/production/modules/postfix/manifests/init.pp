# This class manages the package, files and service for the postfix
# email server. It only includes configs which are not stock.

# Parameters
# server_type:
#   "mailhost" for internet facing send/receive servers
#   "satellite" for servers that do not have local delivery and forward
#               all email to a mailhost
# primary_user: who to send aliased email to
# rewrite_from: rewritten from address for emails from satellites
# relayhost: where to route email for satellites
# relayuser: SASL username to use when routing satellite email
# relaypassword: SASL username to use when routing satellite email

class postfix ($server_type, $primary_user, $rewrite_from, $relayhost, $relayuser, $relaypassword) {
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
    notify => Service['postfix'],
  }

  # Postfix main config file
  file { "$config_dir/main.cf":
    ensure  => file,
    content => epp("postfix/${server_type}.main.cf.epp"),
  }

  # Postfix master config file
  file { "$config_dir/master.cf":
    ensure  => file,
    content => epp("postfix/${server_type}.master.cf.epp"),
  }

  # TODO: mailhost
  if ($server_type == "mailhost") {
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

  # TODO: mailhost
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

  # Configure SMTP forwarding to mailhost for satellites
  if ($server_type == "satellite") {
    file { "$config_dir/sasl_passwd":
      ensure  => file,
      mode => '600',
      content => epp("postfix/sasl_passwd.epp"),
      notify => Exec['postmap sasl_passwd'],
    }

    exec { 'postmap sasl_passwd':
      command => "/usr/sbin/postmap hash:${config_dir}/sasl_passwd",
      refreshonly => true,
      notify => Service['postfix'],
    }

    file { "$config_dir/generic":
      ensure  => file,
      content => epp("postfix/generic.epp"),
      notify => Exec['postmap generic'],
    }

    exec { 'postmap generic':
      command => "/usr/sbin/postmap ${config_dir}/generic",
      refreshonly => true,
      notify => Service['postfix'],
    }
  }

  # The virtual and aliases files need to be converted to DB format
  # when changed.

  # TODO: mailhost
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
    ensure  => file,
    content => epp("postfix/${server_type}.aliases.epp"),
    notify => Exec['newaliases'],
  }

  exec { 'newaliases':
    command => "/usr/bin/newaliases",
    refreshonly => true
  }
}
