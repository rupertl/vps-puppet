# This class manages the cron job entry to run pup-check,
# which will compare the manifest against the system.

class pup_check {
  cron { pup_check:
    command => "/etc/puppetlabs/scripts/pup-check",
    user    => root,
    hour    => 4,
    minute  => 5,
  }
}
