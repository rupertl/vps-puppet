# This class manages the package, files and service for the pflogsumm
# Postfix reporting system. It only includes configs which are not stock.

class pflogsumm () {
  package { 'pflogsumm':
    ensure => installed,
    notify => Cron['pflogsumm_daily_report'],
  }

  cron { pflogsumm_daily_report:
    environment => 'PATH=/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    command     => "/usr/sbin/pflogsumm --problems-first -d yesterday /var/log/mail
log 2>&1 | /usr/bin/mailx -s \"`uname -n` daily mail report\" postmaster",
    user        => root,
    hour        => 02,
    minute      => 47,
  }

}
