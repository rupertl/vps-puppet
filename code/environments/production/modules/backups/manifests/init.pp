# This class manages backup cron jobs

# Parameters:
# dir - local directory to store backups in
# backup_host - remote host to save duplicity file backups in
# file_backups - an array of file backups to do with these keys:
#  name - logical name of backup
#  from - local directory to backup from
#  full_day - day of month to do full backup on
#  hour - hour of day to do backups
#  minute - minute of day to do backups

# You will also need to set up the following, which are outside of
# Puppet's control for now:
# 1. Add root's public key for source host to backups@backup_host
# 2. Create a file ~root/.duplicity-passphrase with the GPG passphrase
#    to encrypt backups with

class backups(String $dir, String $backup_host, Array $file_backups) {
  package { ['libdatetime-perl', 'duplicity']:
    ensure => installed,
  }

  $postgres_backup_dir = "${dir}/postgres";
  $duplicity_backup_spec_dir = "${dir}/duplicity-spec";

  file { $dir:
    ensure  => directory,
    owner => 'root',
    group => 'root',
    mode => '755',
    notify => File[$postgres_backup_dir, $duplicity_backup_spec_dir],
  }

  file { $postgres_backup_dir:
    ensure  => directory,
    owner => 'postgres',
    group => 'postgres',
    mode => '755',
  }

  file { $duplicity_backup_spec_dir:
    ensure  => directory,
    owner => 'root',
    group => 'root',
    mode => '755',
  }

  # Postgres backups to local file system

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
    command     => "backup-postgres.pl ${postgres_backup_dir} daily",
    user        => postgres,
    hour        => 20,
    minute      => 31,
  }

  cron { backup_postgres_weekly:
    command     => "backup-postgres.pl ${postgres_backup_dir} weekly",
    user        => postgres,
    hour        => 20,
    minute      => 36,
    weekday     => 1,
  }

  # Filesystem backups with duplicity

  file { '/usr/local/bin/backup-duplicity.sh':
    ensure  => file,
    owner => 'root',
    group => 'root',
    mode => '755',
    content => epp('backups/backup-duplicity.sh.epp'),
  }

  $file_backups.each |Hash $file_backup| {

    # Write an environment file in $duplicity_backup_spec_dir
    # describing the backup.
    $name = $file_backup[name];
    $spec_file = "${duplicity_backup_spec_dir}/${name}.spec";
    file { $spec_file:
      ensure  => file,
      content => epp("backups/duplicity-spec.epp", $file_backup),
      require => File[$duplicity_backup_spec_dir],
    }

    # Set up a cron job to run the backup each day
    cron { "backup_${name}":
      environment => ['PATH=/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
                      "SPEC=${spec_file}"],
      command     => "backup-duplicity.sh backup",
      user        => root,
      hour        => $file_backup[hour],
      minute      => $file_backup[minute],
    }
  }
}
