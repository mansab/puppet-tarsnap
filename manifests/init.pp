# Class: puppet_tarsnap
# AUTHOR Mansab Uppal
# Official site: http://mansab.upp.al
# Official git repository: https://github.com/mansab/puppet-tarsnap
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
# See README.md for more information.
#
class puppet_tarsnap(
  $ensure = present,
  $tarsnap_write_key = undef,
  $backups_enabled = false,
  $backups = {},
  $version = '1.0.35-0'
){

  file { "tarsnap":
    path   => "/tmp/tarsnap-$version.x86_64.rpm",
    source => "puppet:///modules/${module_name}/rpms/tarsnap-$version.x86_64.rpm"
  }

  package { "tarsnap":
    ensure   => $ensure,
    provider => 'rpm',
    source   => "/tmp/tarsnap-$version.x86_64.rpm",
    require  => File["tarsnap"]
  }

  file { "/etc/tarsnap":
    ensure => 'directory'
  }

  file { "/var/log/tarsnap":
    ensure => 'directory'
  }

  if $tarsnap_write_key {
    file { "tarsnap_key":
      path    => "/etc/tarsnap/tarsnap-write-key",
      ensure  => $ensure,
      content => template("${module_name}/key.erb"),
      mode    => 0600,
      require => File["/etc/tarsnap"]
    }
  }

  file { "/etc/tarsnap/tarsnap.conf":
    source => "puppet:///modules/${module_name}/etc/tarsnap/tarsnap.conf",
    ensure => $ensure,
    require => [ Package["tarsnap"], File["/etc/tarsnap"] ]
  }

  if $backups_enabled {
    create_resources('puppet_tarsnap::resource::backups', $backups)
  }
}
