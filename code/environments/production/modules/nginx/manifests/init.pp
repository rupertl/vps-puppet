# This class manages the package, files and service for the nginx
# webserver and any associated website. It only includes configs which
# are not stock Ubuntu.

class nginx(Array $sites) {
  require letsencrypt

  $config_dir = "/etc/nginx"

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

  file { "$config_dir/nginx.conf":
    ensure  => file,
    content => epp("nginx/nginx.conf.epp"),
  }

  # file { "$config_dir/conf.d/php-socket.conf":
  #   ensure  => file,
  #   content => epp("nginx/php-socket.conf.epp"),
  # }

  # file { "$config_dir/fastcgi_params":
  #   ensure  => file,
  #   content => epp("nginx/fastcgi_params.epp"),
  # }

  # Deploy each site
  $sites.each |String $site| {
    $http_available = "${config_dir}/sites-available/http.${site}"
    $http_enabled = "${config_dir}/sites-enabled/http.${site}"
    $https_available = "${config_dir}/sites-available/https.${site}"
    $https_enabled = "${config_dir}/sites-enabled/https.${site}"

    # Write a basic http conf that serves up letsencrypt challenges
    # and redirects everything else to https
    file { "$http_available":
      ensure  => file,
      content => epp("nginx/sites/http-stub.epp", {site => $site}),
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
      content => epp("nginx/sites/${site}.epp"),
    }

    # Don't enable it yet
    # # Make a symlink in sites-enabled
    # file { "$https_enabled":
    #   ensure => link,
    #   target => "$https_available",
    #   require => File["$https_available"]
    # }
  }

  service { 'nginx':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
