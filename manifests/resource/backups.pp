# Resource: puppet_tarsnap::resource::backups
# AUTHOR Mansab Uppal
# Official site: http://mansab.upp.al
# Official git repository: https://github.com/mansab/puppet-tarsnap
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
# See README.md for more information.
#
define puppet_tarsnap::resource::backups(
  $ensure               = present,
  $archive_name         = $name, # This will be the pre-fix for the kind for backups taken on this machine. The Tarsnap cronjob and bash script will be named after it.
  $rm_after_upload      = undef, # Set this to 'yes-remove-I-know-what-I-am-doing' if you want to remove the specified files and folders once uploaded to Tarsnap (Use with CAUTION, as it will do a 'rm -rf')
  $machine_name         = undef, # If you want to tag your machine specifically on tarsnap then define it here. Otherwise the default 'hostname' will be used.
  $send_alerts_to       = undef, # Use a vaild 'To' address ('Firstname Lastname <firstname.lastname@example.com>') for receiving notifications in case of errors during Tarsnap backup process.
  $default_machine_name = "${fqdn}",
  $directories          = [],
  $files                = [],
  $ensure_cron_job      = 'present',
  $cron_hour            = '12',
  $cron_minute          = '0')
  {
    $use_machine_name = $machine_name ? {
      default => $machine_name,
      undef   => $default_machine_name,
    }

    $backup_script = "/usr/local/bin/tarsnap-backup-$use_machine_name-$archive_name"

    file { $backup_script:
      ensure => $ensure,
      content => template("puppet_tarsnap/bin/tarsnap-backup.sh.erb"),
      mode => 0777,
    }

    cron { "tarsnap-backup-cron-$use_machine_name-$archive_name":
      ensure  => $ensure_cron_job,
      command => $backup_script,
      hour    => $cron_hour,
      minute  => $cron_minute,
      require => File["$backup_script"]
    }
  }
