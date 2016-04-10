# This type defines a site managed under an nginx configuration
#
# Parameters:
# $name (default $title) is the site and config file name
# $is_enabled (default true) determines if the site should be on or off

define nginx::site ($site_name = $title, $is_enabled = true) {

  include nginx

  $available = "${nginx::config_dir}/sites-available/$site_name"
  $enabled = "${nginx::config_dir}/sites-enabled/$site_name"
  
  File {
    owner => 'root',
    group => 'root',
  }    

  file { "$available":
    ensure => present,
    mode => '644',
    source => "puppet:///modules/nginx/sites/$site_name",
  }

  # Make a symlink in sites-enabled if the site should be turned on
  if $is_enabled {
    file { "$enabled":
      ensure => link,
      target => "$available",
      require => File["$available"]
    }
  }
  else {
    file { "$enabled":
      ensure => absent,
    }
  }
  
}
