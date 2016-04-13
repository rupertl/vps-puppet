# This class installs a set of essential utility packages which do not
# need further configuration.

# Parameters:
# packages - array of packages to install

class essential(Array $packages) {
  package { $packages: ensure => 'installed' }
}
