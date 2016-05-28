# This class manages backup cron jobs

class backups(String $backup_dir) {
  $postgres_backup_dir = "${backup_dir}/postgres";

  package { 'libdatetime-perl':
    ensure => installed,
  }

  file { $backup_dir:
    ensure  => directory,
    owner => 'root',
    group => 'root',
    mode => '755',
    notify => File[$postgres_backup_dir],
  }

  file { $postgres_backup_dir:
    ensure  => directory,
    owner => 'postgres',
    group => 'postgres',
    mode => '755',
  }

  file { '/usr/local/bin/backup-postgres.pl':
    ensure  => file,
    owner => 'root',
    group => 'root',
    mode => '755',
    content => epp('backups/backup-postgres.pl.epp'),
    notify => Cron['backup_postgres_daily', 'backup_postgres_weekly'],
  }

  Cron {
    environment => 'PATH=/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  cron { backup_postgres_daily:
    command     => "backup-postgres.pl ${backup_dir} daily",
    user        => postgres,
    hour        => 20,
    minute      => 31,
  }

  cron { backup_postgres_weekly:
    command     => "backup-postgres.pl ${backup_dir} weekly",
    user        => postgres,
    hour        => 20,
    minute      => 36,
    weekday     => 1,
  }
}
