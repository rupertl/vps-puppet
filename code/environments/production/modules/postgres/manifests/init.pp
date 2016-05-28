# This class manages the package, files and service for the Postgresql
# database engine.. This module only includes configs which are not
# stock.

class postgres() {
  package { ['postgresql', 'postgresql-client']:
    ensure => installed,
  }
}
