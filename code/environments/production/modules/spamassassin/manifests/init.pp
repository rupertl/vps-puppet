# This class manages the package, files and service for the spamassassin
# spam filtering server. It only includes configs which are not stock.

class spamassassin () {
  package { ['spamassassin', 'spamc', 'dovecot-antispam']:
    ensure => installed,
    notify => Service['spamassassin'],
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['spamassassin'],
    notify => Service['spamassassin'],
  }

  # Configure the running environment for spamassassin
  file { "/etc/default/spamassassin":
    ensure  => file,
    content => epp("spamassassin/spamassassin.epp"),
    notify => Service['spamassassin'],
  }

  # Spamassassin main config file
  file { "/etc/spamassassin/local.cf":
    ensure  => file,
    content => epp("spamassassin/local.cf.epp"),
  }

  # Spamassassin client config file
  file { "/etc/spamassassin/spamc.conf":
    ensure  => file,
    content => epp("spamassassin/spamc.conf.epp"),
  }

  service { 'spamassassin':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

}
