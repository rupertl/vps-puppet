# This class manages the package, files and service for the dovecot
# IMAP server. It only includes configs which are not stock.

# Parameters

class dovecot () {
  $config_root_dir = "/etc/dovecot"
  $config_dir = "${config_root_dir}/conf.d"

  package { ['dovecot-core', 'dovecot-imapd', 'dovecot-sieve', 'dovecot-managesieved']:
    ensure => installed,
    notify => Service['dovecot'],
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['dovecot-core'],
    notify => Service['dovecot'],
  }

  # Dovecot main config file
  file { "$config_root_dir/dovecot.conf":
    ensure  => file,
    content => epp("dovecot/dovecot.conf.epp"),
  }

  # Other config files
  file { "$config_dir/10-auth.conf":
    ensure => file,
    content => epp("dovecot/10-auth.conf.epp"),
  }

  file { "$config_dir/auth-system.conf.ext":
    ensure => file,
    content => epp("dovecot/auth-system.conf.ext.epp"),
  }

  file { "$config_dir/10-logging.conf":
    ensure => file,
    content => epp("dovecot/10-logging.conf.epp"),
  }

  file { "$config_dir/10-mail.conf":
    ensure => file,
    content => epp("dovecot/10-mail.conf.epp"),
  }

  file { "$config_dir/10-master.conf":
    ensure => file,
    content => epp("dovecot/10-master.conf.epp"),
  }

  file { "$config_dir/10-ssl.conf":
    ensure => file,
    content => epp("dovecot/10-ssl.conf.epp"),
  }

  file { "$config_dir/15-lda.conf":
    ensure => file,
    content => epp("dovecot/15-lda.conf.epp"),
  }

  file { "$config_dir/15-mailboxes.conf":
    ensure => file,
    content => epp("dovecot/15-mailboxes.conf.epp"),
  }

  file { "$config_dir/20-imap.conf":
    ensure => file,
    content => epp("dovecot/20-imap.conf.epp"),
  }

  file { "$config_dir/20-managesieve.conf":
    ensure => file,
    content => epp("dovecot/20-managesieve.conf.epp"),
  }

  file { "$config_dir/90-sieve.conf":
    ensure => file,
    content => epp("dovecot/90-sieve.conf.epp"),
  }

  service { 'dovecot':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

}
