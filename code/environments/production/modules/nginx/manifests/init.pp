# This class manages the package, files and service for the nginx
# webserver and any associated website. It only includes configs which
# are not stock Ubuntu.

class nginx(Array $sites) {
  require letsencrypt

  $config_dir = "/etc/nginx"
  $le_domains = '/opt/letsencrypt/domains.txt'

  package { 'nginx':
    ensure => installed,
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '644',
    require => Package['nginx'],
    notify => Service['nginx'],
  }

  file { "/usr/local/bin/finalise-letsencrypt.sh":
    ensure  => file,
    mode => '744',
    content => epp("nginx/finalise-letsencrypt.sh.epp"),
  }

  file { "$config_dir/nginx.conf":
    ensure  => file,
    content => epp("nginx/nginx.conf.epp"),
  }

  # Remove default configs
  file { "$config_dir/sites-available/default":
    ensure  => absent,
  }
  file { "$config_dir/sites-enabled/default":
    ensure  => absent,
  }

  # Generate better Diffie-Hellman parameters
  $dhparams = '/etc/ssl/certs/dhparam.pem'
  exec {"generate dhparams":
    creates => $dhparams,
    command => "openssl dhparam -out ${dhparams} 2048",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    require => Package['nginx'],
    notify => Service['nginx'],
  }

  file { "$config_dir/conf.d/php-socket.conf":
    ensure  => file,
    content => epp("nginx/php-socket.conf.epp"),
  }

  # Deploy each site
  $sites.each |Hash $site_hash| {
    $website = $site_hash[website]
    $http_available = "${config_dir}/sites-available/http.${website}"
    $http_enabled = "${config_dir}/sites-enabled/http.${website}"
    $https_available = "${config_dir}/sites-available/https.${website}"
    $https_enabled = "${config_dir}/sites-enabled/https.${website}"

    exec {"add ${website} to letsencrypt domains.txt":
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      unless  => "grep -q ${website} ${le_domains}",
      command => "sh -c 'echo ${website} ${site_hash[secondary]} >> ${le_domains}'",
      require => Package['nginx'],
    }

    # Write a basic http conf that serves up letsencrypt challenges
    # and redirects everything else to https
    file { "$http_available":
      ensure  => file,
      content => epp("nginx/sites/http-stub.epp", $site_hash),
    }

    # Make a symlink in sites-enabled
    file { "$http_enabled":
      ensure => link,
      target => "$http_available",
      require => File["$http_available"]
    }

    # Write the main https config
    file { "$https_available":
      ensure  => file,
      content => epp("nginx/sites/${website}.epp", $site_hash),
    }

    # The https config is enabled later, after certs are generated.
  }

  service { 'nginx':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

  # Generate any missing certs and enable https sites
  exec {"finalise letsencrypt":
    command => "/usr/local/bin/finalise-letsencrypt.sh",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    require => Service['nginx'],
    refreshonly => true,
  }
}
