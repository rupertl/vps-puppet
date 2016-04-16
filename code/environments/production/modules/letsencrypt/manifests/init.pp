# This class installs the letsencrypt.sh client from git.

# Client from https://github.com/lukas2511/letsencrypt.sh
# Method based on http://blog.thesparktree.com/post/138452017979/automating-ssl-certificates-using-nginx

class letsencrypt() {
  # Where to clone the repo
  $install_dir = '/opt/letsencrypt'
  # The script from the repo
  $script = "${install_dir}/letsencrypt.sh"
  # Where to store challenges when running letsencrypt.sh
  $challenge_dir = "${install_dir}/.acme-challenges"
  # Source repository
  $repo = 'https://github.com/lukas2511/letsencrypt.sh.git'

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
    notify => File[$challenge_dir],
  }

  # Create the directory to store challenges
  file { $challenge_dir:
    ensure => directory,
    mode => '0755',
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
