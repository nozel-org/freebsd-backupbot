# Manual backupbot
`backupbot` is a easy to use tool for creating (automatic) backups on FreeBSD. Simplicity is one of the most important goals of the project and the following features are supported:

* Manual backups of files and/or MySQL databases.
* Automatic daily backups of files and/or MySQL databases.
* Automatic weekly backups of files and/or MySQL databases.
* Optional compression: gzip, bzip2 and xz.
* Optional symmetrical encryption of backups.
* Optional retention (auto delete based on file age) for daily and weekly backups.
* Customizable backup location for both file and MySQL database backups.
* Customizable backup ownership for both file and MySQL database backups.
* Customizable file name prefix.

<hr>

## 1 How to use
When in doubt, you can use `backupbot --help` to help you on your way:
```
root@freebsd:/ # backupbot --help
Usage:
 backupbot [feature/option]...

Features:
 -b, --backup         Backup everything configured in configuration file
 -f, --files          Backup files configured in configuration file
 -m, --mysql          Backup MySQL databases configured in configuration file

Options:
 --cron               Effectuate cron changes from serverbot config
 --help               Display this help and exit
 --version            Display version information and exit
```
With `backupbot --version` you can check which version of `backupbot` you're running:
```
root@freebsd:/ # backupbot --version
backupbot version 1.4.0
Copyright (C) 2019-2022 Nozel.
License CC Attribution-NonCommercial-ShareAlike 4.0 Int.

Written by Sebas Veeke
```
How to use the other features such as `--backup`, `--files` and `--mysql` is explained in chapter 3.

<hr>

## 2 How to install
`backupbot` consists of two files: `/usr/bin/backupbot` and `/usr/local/etc/backuptbot.conf`. These files can be downloaded from the [project's repository on GitHub](https://github.com/nozel-org/freebsd-backupbot). That being said, never trust some random stranger on the internet and always be cautious when installing new software from a random git repo. In this case `backupbot` is open source, so you can verify for yourself whether this software should be trusted or not.

### 2.1 backupbot
The program can be installed by running `wget https://raw.githubusercontent.com/nozel-org/freebsd-backupbot/master/backupbot -O /usr/bin/backupbot`. Owner and group should be set to `root` and `wheel` while read/execute permissions `555` should suffice. This can be done with `chown root:wheel /usr/bin/backupbot` and `chmod 555 /usr/bin/backupbot`.

### 2.2 backupbot.conf
The configuration file can be installed by running `wget https://raw.githubusercontent.com/nozel-org/freebsd-backupbot/master/backupbot.conf -O /usr/local/etc/backupbot.conf`. Owner and group should be set to `root` and `wheel` while read/write permissions for `root` should suffice. This can be done with `chown root:wheel /usr/local/etc/backupbot.conf` and `chmod 600 /usr/local/etc/backupbot.conf`.

### 2.3 Full installation
```
wget https://raw.githubusercontent.com/nozel-org/freebsd-backupbot/master/backupbot -O /usr/bin/backupbot
chown root:wheel /usr/bin/backupbot
chmod 555 /usr/bin/backupbot
wget https://raw.githubusercontent.com/nozel-org/freebsd-backupbot/master/backupbot.conf -O /usr/local/etc/backupbot.conf
chown root:wheel /usr/local/etc/backupbot.conf
chmod 600 /usr/local/etc/backupbot.conf
```

<hr>

## 3 Configuration
`backupbot` needs a configuration file to work and this configuration file must be present in `/usr/local/etc/backupbot.conf`. The [default configuration file](https://github.com/nozel-org/freebsd-backupbot/blob/master/backupbot.conf) is commented for a fast and easy configuration, but below the available options are explained in more detail.

### 3.1 General settings
`backupbot` logs its actions to a log file. This log file can be configured with the `BACKUPBOT_LOG='/directory/file.log` configuration option. If no log file is set, `/var/log/backupbot.log` will be used.

### 3.2 Automatic backup
Automatic backups can be configured to run either daily or both daily and weekly. By setting `AUTOMATIC_BACKUP_ENABLE='YES'`, automatic daily backups will run daily at `00:00`. To change the daily backup time, set `AUTOMATIC_BACKUP_DAILY=''` to a number between `0` (00:00) and `23` (23:00). 

To enable automatic weekly backups, set `AUTOMATIC_BACKUP_WEEKLY=''` to a number between `1` (monday) and `7` (sunday). Setting it to `0` will disable automatic weekly backups. When enabled, the weekly backup will run at the same time as the configured daily backup time.

When both daily and weekly backups are configured, the daily backup won't run on the chosen weekly backup day. Example: you have configured the daily backups to run at 3:00 and the weekly backups to run on on sundays, then the daily backup will run from monday to saturday and skip sundays.

Run `backupbot --cron` to effectuate any changes made to the automatic backups configuration. This will create relevant `cron` jobs in the system.

| Automatic backup | Configuration |
| ---------------- | ------------- |
| `AUTOMATIC_BACKUP_ENABLE=''` | Set to `YES` to enable automatic backups. Set to `NO` to disable automatic backups. |
| `AUTOMATIC_BACKUP_DAILY=''` | Set to a number between `0` (00:00) and `23` (23:00) to configure the daily backup process wil start. |
| `AUTOMATIC_BACKUP_WEEKLY=''` | Set to a number between `1` (monday) and `7` (sunday) to configure the weekly backup day. Set to `0` to disable automatic weekly backups. |
| `RANDOM_DELAY=''` | Set to 'YES' to add a random delay between 0 and 3600 seconds (1 hour) before the automated backup process starts. Set to `NO` to disable the random delay. |

### 3.3 File backup
#### 3.3.1 Activate file backup
File backups can be activated by setting `BACKUP_FILES_ENABLE='YES'`.

#### 3.3.2 Set files to be backupped and backup destination
The files that are part of the backup can be configured by setting folder(s) and/or file(s) in `BACKUP_FILES=''`. For example `'/etc'`, `'/usr/local/etc /usr/local/www /var/log'` and `'/usr/local/etc/apache24 /etc/rc.conf'` are all valid entries.

The file backup destination can be configured by setting a folder in `BACKUP_FILES_DESTINATION=''`. For example `'/home/backup'` and `'/mnt/storage/backup'` are valid entries.

Note that all entries should be seperated from each other with a space and that there should be no trailing `/` at the end of the folder names. If the list with file and folder locations in `BACKUP_FILES` is quite long, you can also make a list on multiple lines by using backslash newlines.

#### 3.3.3 Retention
When automatic daily backups are configured (see 4.1), the retention of automatic daily backups can be configured by setting `BACKUP_FILES_RETENTION_DAILY=''` to the amount of days you want daily backups to be kept.

Likewise, when automatic weekly backups are configured (see 4.1), the retention of automatic weekly backups can be configured by setting `BACKUP_FILES_RETENTION_WEEKLY=''` to the amount of days you want weekly backups to be kept. This way it's for example possible to keep weekly backups for a longer period of time than daily backups.

For both daily and weekly backup retention, setting the retention to `0` will keep backups indefinitely.

#### 3.3.4 Compression
Backups can be compressed automatically with gzip, bzip2 or xz by setting  `BACKUP_FILES_COMPRESSION=''` to `1` for gzip, to `2` for bzip2 and to `3` for xz. Compression can be disabled by setting `BACKUP_FILES_COMPRESSION=''` to `0`.

Especially databases can often benefit greatly from compression, but in most cases it's also worthwhile to compress files. Out of these three options, gzip has the lowest level of compression but is also by far the fastest. xz on the contrary has the highest level of compression but is many times slower than gzip. bzip2 is in between gzip and xz in both level of compression and compression speed. For devices with a slower cpu/processor, gzip is recommended.

For a comparison on a relatively slow server cpu, checkout this [Discussion](https://github.com/nozel-org/freebsd-backupbot/discussions/12).

#### 3.3.5 Encryption
Backups can be encrypted automatically with gpg by setting `BACKUP_FILES_ENCRYPTION=''` to a secret/passphrase of your choosing. Encryption can be disabled by setting `BACKUP_FILE_ENCRYPTION='NO'`.

The program will check on the availability of gpg on the system when the encryption feature is enabled. Note that this encryption feature uses basic symmetrical encryption with a secret, so make sure other people can't extract the secret from `/usr/local/etc/backupbot.conf`. You can make `/usr/local/etc/backupbot.conf` readable only by root by setting `chown root:wheel /usr/local/etc/backupbot.conf` and `chmod 555 /usr/local/etc/backupbot.conf`.

Store your secret in a safe place so you will never lose it by accident. You could save the secret in a password manager or on paper in a safe (make sure it's water and heat resistent).

Decryption can be done with gpg, for example by running `gpg --output archive.tar.gz --decrypt archive.tar.gz.gpg`. Always test decryption before you set and forget the automatic backups by `backupbot`.

#### 3.3.6 Ownership
File backup ownership can be configured by setting the `BACKUP_FILES_OWNER='owner'` en `BACKUP_FILES_GROUP='group'` configuration options. If no owner or group is set, `BACKUP_FILES_OWNER='root'` and `BACKUP_FILES_GROUP='wheel'` will be used.

#### 3.3.7 Custom file names
The first part of the backup file name can be configured by setting `BACKUP_FILES_PREFIX=''`. The default option is `'$(date +%y%m%dT%H%M%S)'` which translates to the `YYMMDDThhmmss` format. In practise this could look like `220115T041145`, which would mean that the backup was created on 15 january 2022 at 4 hours 11 minutes and 45 seconds in the morning.

#### 3.3.8 Overview
| File backup | Configuration |
| ---------------- | ------------- |
| `BACKUP_FILES_ENABLE=''` | Set to `YES` to enable file backup. Set to `NO` to disable file backup. |
| `BACKUP_FILES=''` | Set to folder(s) and/or file(s) separated by a space. No trailing / at the end of folder and/or file names. |
| `BACKUP_FILES_DESTINATION=''` | Set to a folder without a trailing / at the end of the folder name. |
| `BACKUP_FILES_RETENTION_DAILY=''` | Set to `0` to keep backups indefinitely. Set to a number (amount of days) of `1` or higher to automatically remove older backups. |
| `BACKUP_FILES_RETENTION_WEEKLY=''` | Set to `0` to keep backups indefinitely. Set to a number (amount of days) of `1` or higher to automatically remove older backups. |
| `BACKUP_FILES_COMPRESSION=''` | Set to `1` (gzip), `2` (bzip2) or `3` (xz) to enable compression. Set to `0` to disable compression. |
| `BACKUP_FILES_ENCRYPTION=''` | Set to secret/passphrase to enable encryption. Set to `NO` to disable encryption. |
| `BACKUP_FILES_PREFIX=''` | "$(date +%y%m%dT%H%M%S)" |

### 3.4 Mysql database backup
#### 3.4.1 Activate mysql database backup
Mysql database backups can be activated by setting `BACKUP_MYSQL_ENABLE='YES'`.

For this backup feature to work, MySQL needs to be able to authenticate unattended. You can make this possible by creating a *.cnf file in `/usr/local/etc/mysql` with the following content:

```
[client]
user='root'
password='password'
```

#### 3.4.2 Set backup destination
The file backup destination can be configured by setting a folder in `BACKUP_FILES_DESTINATION=''`. For example `'/home/backup'` and `'/mnt/storage/backup'` are valid entries. Note that there should be no trailing `/` at the end of the folder name.

#### 3.4.3 Retention
When automatic daily backups are configured (see 4.1), the retention of automatic daily backups can be configured by setting `BACKUP_MYSQL_RETENTION_DAILY=''` to the amount of days you want daily backups to be kept.

Likewise, when automatic weekly backups are configured (see 4.1), the retention of automatic weekly backups can be configured by setting `BACKUP_MYSQL_RETENTION_WEEKLY=''` to the amount of days you want weekly backups to be kept. This way it's for example possible to keep weekly backups for a longer period of time than daily backups.

For both daily and weekly backup retention, setting the retention to `0` will keep backups indefinitely.

#### 3.4.4 Compression
Backups can be compressed automatically with gzip, bzip2 or xz by setting  `BACKUP_MYSQL_COMPRESSION=''` to `1` for gzip, to `2` for bzip2 and to `3` for xz. Compression can be disabled by setting `BACKUP_MYSQL_COMPRESSION=''` to `0`.

Especially databases can often benefit greatly from compression. Out of these three options, gzip has the lowest level of compression but is also by far the fastest. xz on the contrary has the highest level of compression but is many times slower than gzip. bzip2 is in between gzip and xz in both level of compression and compression speed. For devices with a slower cpu/processor, gzip is recommended.

For a comparison on a relatively slow server cpu, checkout this [Discussion](https://github.com/nozel-org/freebsd-backupbot/discussions/12).

#### 3.4.5 Encryption
Backups can be encrypted automatically with gpg by setting `BACKUP_MYSQL_ENCRYPTION=''` to a secret/passphrase of your choosing. Encryption can be disabled by setting `BACKUP_MYSQL_ENCRYPTION='NO'`.

The program will check on the availability of gpg on the system when the encryption feature is enabled. Note that this encryption feature uses basic symmetrical encryption with a secret, so make sure other people can't extract the secret from `/usr/local/etc/backupbot.conf`. You can make `/usr/local/etc/backupbot.conf` readable only by root by setting `chown root:wheel /usr/local/etc/backupbot.conf` and `chmod 555 /usr/local/etc/backupbot.conf`.

Store your secret in a safe place so you will never lose it by accident. You could save the secret in a password manager or on paper in a safe (make sure it's water and heat resistent).

Decryption can be done with gpg, for example by running `gpg --output backup.sql.gz --decrypt backup.sql.gz.gpg`. Always test decryption before you set and forget the automatic backups by `backupbot`.

#### 3.4.6 Ownership
MySQL backup ownership can be configured by setting the `BACKUP_MYSQL_OWNER='owner'` en `BACKUP_MYSQL_GROUP='group'` configuration options. If no owner or group is set, `BACKUP_MYSQL_OWNER='root'` and `BACKUP_MYSQL_GROUP='wheel'` will be used.

#### 3.4.7 Custom file names
The first part of the backup file name can be configured by setting `BACKUP_MYSQL_PREFIX=''`. The default option is `'$(date +%y%m%dT%H%M%S)'` which translates to the `YYMMDDThhmmss` format. In practise this could look like `220115T041145`, which would mean that the backup was created on 15 january 2022 at 4 hours 11 minutes and 45 seconds in the morning.

#### 3.4.8 Overview
| File backup | Configuration |
| ---------------- | ------------- |
| `BACKUP_MYSQL_ENABLE=''` | Set to `YES` to enable mysql backup. Set to `NO` to disable mysql backup. |
| `BACKUP_MYSQL_DESTINATION=''` | Set to a folder without a trailing / at the end of the folder name. |
| `BACKUP_MYSQL_RETENTION_DAILY=''` | Set to `0` to keep backups indefinitely. Set to a number (amount of days) of `1` or higher to automatically remove older backups. |
| `BACKUP_MYSQL_RETENTION_WEEKLY=''` | Set to `0` to keep backups indefinitely. Set to a number (amount of days) of `1` or higher to automatically remove older backups. |
| `BACKUP_MYSQL_COMPRESSION=''` | Set to `1` (gzip), `2` (bzip2) or `3` (xz) to enable compression. Set to `0` to disable compression. |
| `BACKUP_MYSQL_ENCRYPTION=''` | Set to secret/passphrase to enable encryption. Set to `NO` to disable encryption. |
| `BACKUP_MYSQL_PREFIX=''` | "$(date +%y%m%dT%H%M%S)" |

<hr>

## 4 Recovery
The method for recovering your data inside backupbot's backup files depends on used compression and encryption options. Below all combinations will be explained in both the full and short commands.

### 4.1 File backups
#### 4.1.1 Decompress
| Type | Decompress | 
| ---- | ---------- |
| default | tar --extract --verbose --file backup.tar --directory /path/to/destination<br>tar -xvf files.tar -C /path/to/destination |
| gzip | tar --extract --gzip --verbose --file backup.tar.gz --directory /path/to/destination<br>tar -xzvf files.tar.gz -C /path/to/destination |
| bzip2 | tar --extract --bzip2 --verbose --file backup.tar.bzip2 --directory /path/to/destination<br>tar -xjvf files.tar.bzip2 -C /path/to/destination |
| xz | tar --extract --xz --verbose --file backup.tar.xz --directory /path/to/destination<br>tar -xJvf files.tar.xz -C /path/to/destination |

#### 4.1.2 Decrypt
| Type | Decrypt | 
| ---- | ------- |
| default | gpg --output /path/to/destination/backup.tar --decrypt backup.tar.gpg<br>gpg -o /path/to/destination/backup.tar -d backup.tar.gpg |
| gzip | gpg --output /path/to/destination/backup.tar.gz --decrypt backup.tar.gz.gpg<br>gpg -o /path/to/destination/backup.tar.gz -d backup.tar.gz.gpg |
| bzip2 | gpg --output /path/to/destination/backup.tar.bzip2 --decrypt backup.tar.bzip2.gpg<br>gpg -o /path/to/destination/backup.tar.bzip2 -d backup.tar.bzip2.gpg |
| xz | gpg --output /path/to/destination/backup.tar.xz --decrypt backup.tar.xz.gpg<br>gpg -o /path/to/destination/backup.tar.xz -d backup.tar.xz.gpg |

### 4.2 MySQL backups
#### 4.2.1 Decompress
Note that these commands decompress the existing sql file, without creating a copy.
| Type | Decompress | 
| ---- | ---------- |
| gzip | gzip --decompress --verbose backup.sql.gz<br>gzip -dv backup.sql.gz
| bzip2 | bzip2 --decompress --verbose backup.sql.bzip2<br>bzip2 -dv backup.sql.bzip2
| xz | xz --decompress --verbose backup.sql.xz<br>gzip -dv backup.sql.gz

#### 4.2.2 Decrypt
| Type | Decrypt | 
| ---- | ------- |
| default | gpg --output /path/to/destination/backup.sql --decrypt backup.sql.gpg<br>gpg -o /path/to/destination/backup.sql -d backup.sql.gpg
| gzip | gpg --output /path/to/destination/backup.sql.gz --decrypt backup.sql.gz.gpg<br>gpg -o /path/to/destination/backup.sql.gz -d backup.sql.gz.gpg
| bzip2 | gpg --output /path/to/destination/backup.sql.bzip2 --decrypt backup.sql.bzip2.gpg<br>gpg -o /path/to/destination/backup.sql.bzip2 -d backup.sql.bzip2.gpg
| xz | gpg --output /path/to/destination/backup.sql.xz --decrypt backup.sql.xz.gpg<br>gpg -o /path/to/destination/backup.sql.xz -d backup.sql.xz.gpg

<hr>

## 5 FAQ
### 5.1 How do file names look?
The configurable prefix (see 3.3.7 and 3.4.7) is the only part of the file name that is not static. Assuming the default prefix, file backups have the following naming schemes:

| Type | Default name | Compression | Encryption | Comp + Crypt |
| ----- | ------- | ----------- | ---------- | ---- |
| Files (manual) | `YYMMDDThhmmss-files.tar` | `YYMMDDThhmmss-files.tar.gz`<br>`YYMMDDThhmmss-files.tar.bz2`<br>`YYMMDDThhmmss-files.tar.xz` | `YYMMDDThhmmss-files.tar.gpg` | `YYMMDDThhmmss-files.tar.gz.gpg`<br>`YYMMDDThhmmss-files.tar.bz2.gpg`<br>`YYMMDDThhmmss-files.tar.xz.gpg` |
| Files (daily) | `YYMMDDThhmmss-daily-files.tar` | `YYMMDDThhmmss-daily-files.tar.gz`<br>`YYMMDDThhmmss-daily-files.tar.bz2`<br>`YYMMDDThhmmss-daily-files.tar.xz` | `YYMMDDThhmmss-daily-files.tar.gpg` | `YYMMDDThhmmss-daily-files.tar.gz.gpg`<br>`YYMMDDThhmmss-daily-files.tar.bz2.gpg`<br>`YYMMDDThhmmss-daily-files.tar.xz.gpg` |
| Files (weekly) | `YYMMDDThhmmss-weekly-files.tar` | `YYMMDDThhmmss-weekly-files.tar.gz`<br>`YYMMDDThhmmss-weekly-files.tar.bz2`<br>`YYMMDDThhmmss-weekly-files.tar.xz` | `YYMMDDThhmmss-weekly-files.tar.gpg` | `YYMMDDThhmmss-weekly-files.tar.gz.gpg`<br>`YYMMDDThhmmss-weekly-files.tar.bz2.gpg`<br>`YYMMDDThhmmss-weekly-files.tar.xz.gpg` |
| MySQL (manual) | `YYMMDDThhmmss-mysql-db.sql` | `YYMMDDThhmmss-mysql-db.sql.gz`<br>`YYMMDDThhmmss-mysql-db.sql.bz2`<br>`YYMMDDThhmmss-mysql-db.sql.xz` | `YYMMDDThhmmss-mysql-db.sql` | `YYMMDDThhmmss-mysql-db.sql.gz.gpg`<br>`YYMMDDThhmmss-mysql-db.sql.bz2.gpg`<br>`YYMMDDThhmmss-mysql-db.sql.xz.gpg` |
| MySQL (daily) | `YYMMDDThhmmss-daily-mysql-db.sql` | `YYMMDDThhmmss-daily-mysql-db.sql.gz`<br>`YYMMDDThhmmss-daily-mysql-db.sql.bz2`<br>`YYMMDDThhmmss-daily-mysql-db.sql.xz` | `YYMMDDThhmmss-daily-mysql-db.sql` | `YYMMDDThhmmss-daily-mysql-db.sql.gz.gpg`<br>`YYMMDDThhmmss-daily-mysql-db.sql.bz2.gpg`<br>`YYMMDDThhmmss-daily-mysql-db.sql.xz.gpg` |
| MySQL (weekly) | `YYMMDDThhmmss-weekly-mysql-db.sql` | `YYMMDDThhmmss-weekly-mysql-db.sql.gz`<br>`YYMMDDThhmmss-weekly-mysql-db.sql.bz2`<br>`YYMMDDThhmmss-weekly-mysql-db.sql.xz` | `YYMMDDThhmmss-weekly-mysql-db.sql` | `YYMMDDThhmmss-weekly-mysql-db.sql.gz.gpg`<br>`YYMMDDThhmmss-weekly-mysql-db.sql.bz2.gpg`<br>`YYMMDDThhmmss-weekly-mysql-db.sql.xz.gpg` |

<hr>