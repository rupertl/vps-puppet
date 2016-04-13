# This class manages the package and files for sudo services.
# sudo allows controlled root access to selected users.

# Parameters:
# users - array of users who can use sudo

class sudo(Array $users) {
  $config_dir = "/etc"

  package { 'sudo':
    ensure => installed,
  }

  File {
    owner => 'root',
    group => 'root',
    mode => '440',
    require => Package['sudo'],
  }

  file { "$config_dir/sudoers":
    ensure  => file,
    content => epp('sudo/sudoers.epp'),
  }

  # Add each user to the sudo group if not already a member
  $users.each |String $user| {
    exec {"sudo group ${user}":
      unless => "/usr/bin/getent group sudo | /usr/bin/cut -d: -f4 | /bin/grep -q ${user}",
      command => "/usr/sbin/usermod -a -G sudo ${user}",
      require => Package['sudo'],
    }
  }
}
