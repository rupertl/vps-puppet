# This class manages the package, files and service for the Radicale
# calendar.contacts service.

# This has been updated for radicale 2.1. As Debian Stretch is still
# on an old version, we create a venv and install locally.

# Parameters:
# install_dir - root directory for radicale install
# date_dir - directory where radicale should store files
# user - user to run radicale update service as

class radicale(String $install_dir, String $data_dir, String $user) {

  $venv_dir = "${install_dir}/venv";
  $install_script = "${install_dir}/install.sh";
  $run_script = "${install_dir}/run.sh";

  $config_dir = "/etc/radicale";
  $config_file = "${config_dir}/config";

  # Set up required packages
  package { ['python3-pip', 'python-virtualenv',]:
    ensure => installed,
    notify => File[$install_script],
  }

  # Create a user to run radicale
  user { $user:
    ensure => present,
    system => true,
    # managehome was false in previous versions of vps-puppet. Changed
    # to true so we can store temp files etc while installing
    # radicale. To migrate, need to manually create a home dir with
    #     usermod -d ${install_dir} radicale
    # as puppet won't make this change
    # (https://tickets.puppetlabs.com/browse/PUP-1439)
    managehome => true,
    notify => File[$install_script, $run_script],
  }

  # Copy in the installation script
  file { $install_script:
    ensure  => file,
    owner => $user,
    mode => '744',
    content => epp("radicale/install.sh.epp", {'venv_dir' => $venv_dir}),
    notify => Exec["install venv"],
  }

  # Create a python3 venv and install radicale there
  exec {"install venv":
    creates => $venv_dir,
    command => $install_script,
    user => $user,
    cwd => $install_dir,
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
    notify => Service['radicale'],
  }

  # Directory to store calendar data
  file { $data_dir:
    ensure  => directory,
    owner => $user,
    group => $user,
    mode => '755',
    notify => Service['radicale'],
  }

  # Config directory
  file { $config_dir:
    ensure  => directory,
    owner => $user,
    group => $user,
    mode => '755',
    require => User[$user],
    notify => File[$config_file],
  }

  # Radicale main config file
  file { $config_file:
    ensure  => file,
    owner => 'root',
    group => 'root',
    mode => '644',
    content => epp("radicale/config.epp"),
    notify => Service['radicale'],
  }

  # Copy in the run script
  file { $run_script:
    ensure  => file,
    owner => $user,
    mode => '744',
    content => epp("radicale/run.sh.epp", {'venv_dir' => $venv_dir}),
    notify => Service['radicale'],
  }

  # Systemd service
  file { "/etc/systemd/system/radicale.service":
    ensure  => file,
    content => epp('radicale/radicale.service.epp'),
    notify => Service['radicale'],
  }

  service { 'radicale':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
