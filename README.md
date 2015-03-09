# puppet_tarsnap

This is a Puppet module for managing Tarsnap backups.

Author: Mansab Uppal

Official site: http://mansab.upp.al

Official git repository: https://github.com/mansab/puppet-tarsnap

##Overview

This module installs and manage Tarsnap (http://tarsnap.com/)

##Module description

The puppet_tarsnap module will install Tarsnap client and can manage tarsnap key, backup scripts and cron jobs.

This module has been tested against Tarsnap - 1.0.35 and CentOS 6,7

##Setup

###The module manages the following

* Tarsnap package as an RPM.
* Tarsnap configuration file.
* Cron Job for Tarsnap backups.
* Write key for uploading Tarsnap archives.

### Tarsnap RPM

Tarsnap RPM has been provided as a part of this Puppet module under 'puppet_tarsnap/files/rpms'
The RPM has been built using the Tarsnap source provided here: https://www.tarsnap.com/download.html

## Quick Start

### Requirements

* Puppet-2.7.0 or later
* Ruby-1.9.3 or later (Support for Ruby-1.8.7 is not guaranteed. YMMV).

### Install Tarsnap client

```puppet
class { 'puppet_tarsnap': }
```

### Configure Tarsnap key for creating new archives 
 - This key should have write previleges to Tarsnap servers - https://www.tarsnap.com/man-tarsnap-keymgmt.1.html
 - The key will be installed at: /etc/tarsnap/tarsnap-write-key

```puppet
class { 'puppet_tarsnap': 
  tarsnap_write_key  => '
  ----- BEGIN TARSNAP SAMPLE KEY -----
  hE/F8hT2OH6wtYwzFQ/NVb/cBhGBfwseejYoEN5yVrEBiL94qhsN9kYghwIDAQAB
  AoGAD87W3x0/BMmCCNmInPWLgcJHZtudfialnPPj1D1eMamDYdl79Tx9qkdVFJkR
  5XhwMsb3mXly/2Npg7gOYw55ABdqWCxpPo80fiEOv3VMYWiT2ERpoOCarMVZZR6B
  v34z/Fiqri+6qyVwEpFsYMA5BylDRgJe4r+7VgZf/4fLH6ECQQDZHNNvkm6PG6lQ
  vwIjoXBeiYxYIauU0cfb00vOH6a5mA30O6KQobF9aeiF7tavr/onCz7bDm4Sg8BE
  ---- END TARSNAP SAMPLE KEY -----'
}
```

### Enable & Configure Tarsnap backups

```puppet
class { 'puppet_tarsnap':
  backups_enabled => true
}

puppet_tarsnap::resource::backups { 'webserver-node01':
  directories => ['/var/www/html', '/srv/www'],
  files       => ['/etc/nginx/sites-available/www.example.com', '/etc/nginx/.htpasswd'],
  cron_hour   => '*/1',
  cron_minute => '30',
  send_alerts_to: 'Firstname Lastname <firstname.lastname@example.com>'
}
```

### Hiera Support

Defining Tarsnap resources in Hiera.

```yaml
puppet_tarsnap::backups_enabled: 'true'

puppet_tarsnap::backups:
  'webserver-node01':
    directories:
      - '/var/www/html'
      - '/srv/www'
    files:
      - '/etc/nginx/sites-available/www.example.com'
      - '/etc/nginx/.htpasswd'
    cron_hour: '*/1'
    cron_minute: '30'
    send_alerts_to: 'Firstname Lastname <firstname.lastname@example.com>'
```

### Resource parameter description
 - puppet_tarsnap::resource::backups

* $archive_name    = $name, # This will be the pre-fix for the kind for backups taken on this machine. The Tarsnap cronjob and bash script will be named after it.
* $rm_after_upload = undef, # Set this to 'yes-remove-I-know-what-I-am-doing' if you want to remove the specified files and folders once uploaded to Tarsnap (Use with CAUTION, as it will do a 'rm -rf')
* $machine_name    = undef, # If you want to tag your machine specifically on tarsnap then define it here. Otherwise the default 'hostname' will be used.
* $send_alerts_to  = undef, # Use a vaild 'To' address ('Firstname Lastname <firstname.lastname@example.com>') for receiving notifications in case of errors during Tarsnap backup process.
