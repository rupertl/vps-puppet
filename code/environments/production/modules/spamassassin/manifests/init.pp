# This class manages the package, files and service for the
# spamassassin spam filtering server and associated milter. It only
# includes configs which are not stock.

class spamassassin () {
  package { ['spamassassin', 'spamc', 'dovecot-antispam', 'spamass-milter']:
    ensure => installed,
    notify => Service['spamassassin', 'spamass-milter'],
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['spamassassin'],
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
    notify => Service['spamassassin'],
  }

  # Spamassassin client config file
  file { "/etc/spamassassin/spamc.conf":
    ensure  => file,
    content => epp("spamassassin/spamc.conf.epp"),
    notify => Service['spamassassin'],
  }

  service { 'spamassassin':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

  # Configure the running environment for the spamassassin milter
  file { "/etc/default/spamass-milter":
    ensure  => file,
    content => epp("spamassassin/spamass-milter.epp"),
    notify => Service['spamass-milter'],
  }

  service { 'spamass-milter':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

}
