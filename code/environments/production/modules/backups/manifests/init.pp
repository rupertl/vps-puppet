# This class manages backup cron jobs

class backups {
  $std_env = "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

  if $hostname == "udon" {
    cron { backup_duplicity:
      command     => "/usr/local/bin/backup-duplicity.sh backup",
      environment => $std_env,
      user        => root,
      hour        => 5,
      minute      => 4,
    }

    cron { backup_postgres_daily:
      command     => "/usr/local/bin/backup-postgres.pl daily",
      environment => $std_env,
      user        => postgres,
      hour        => 5,
      minute      => 31,
    }

    cron { backup_postgres_weekly:
      command     => "/usr/local/bin/backup-postgres.pl weekly",
      environment => $std_env,
      user        => postgres,
      hour        => 5,
      minute      => 36,
      weekday     => 1,
    }
  }
}
