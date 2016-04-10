# This class manages the package used for notification of new packages.
# It only includes configs which are not stock.

class apticron {
  $config_dir = "/etc/apticron"

  package { 'apticron':
    ensure => installed,
  }

  # No service dependency or files.
}
