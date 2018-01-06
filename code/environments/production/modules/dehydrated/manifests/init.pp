# This class installs the dehydrated client from git.

# Client from https://github.com/lukas2511/dehydrated
# (was formerly https://github.com/lukas2511/letsencrypt.sh)
# Method based on http://blog.thesparktree.com/post/138452017979/automating-ssl-certificates-using-nginx

# Parameters
# install_dir: Where to clone the software
# root_dir: Base directory for data files
# domains_txt: File containing domain names to generate certificates for
# challenge_dir: Directory to serve ACME challenges to get certificates
# certs_dir: Directory to store generated certificates

class dehydrated(String $install_dir, String $root_dir, String $domains_txt, String $challenge_dir, String $certs_dir) {
  # The script from the repo
  $script = "${install_dir}/dehydrated"
  # Source repository
  $repo = 'https://github.com/lukas2511/dehydrated.git'
  # Generated config file
  $config_dir = '/etc/dehydrated'
  $config_file = "${config_dir}/config"

  # Clone the repository
  exec {"git clone":
    creates => $install_dir,
    command => "git clone ${repo} ${install_dir}",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    notify => File[$script],
  }

  # Ensure the script is executable
  file { $script:
    ensure => file,
    mode => '0744',
  }

  # Create the root directory for working files
  file { $root_dir:
    ensure => directory,
    mode => '0755',
    notify => File[$domains_txt, $challenge_dir, $certs_dir],
  }

  # Create the file to store domains in
  file { $domains_txt:
    ensure => present,
    mode => '0644',
  }

  # Create the directory to store challenges
  file { $challenge_dir:
    ensure => directory,
    mode => '0755',
  }

  # Create the directory to store certificates
  file { $certs_dir:
    ensure => directory,
    mode => '0700',
  }

  # Dehydrated main config file
  file { $config_dir:
    ensure => directory,
    mode => '0755',
    notify => File[$config_file],
  }

  file { $config_file:
    ensure  => file,
    mode => '0644',
    content => epp("dehydrated/config.epp"),
  }

  # Create a cron job to renew any certs
  cron { renew_letsencrypt_certs:
    command     => "${script} --cron && /bin/systemctl reload nginx",
    environment => "PATH=/usr/sbin:/usr/bin:/sbin:/bin",
    user        => root,
    hour        => 12,
    minute      => 24,
    weekday     => 6,
    require     => File[$script],
  }
}
