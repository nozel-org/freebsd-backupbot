# Manual backupbot
`backupbot` is a easy to use tool for creating (automatic) backups on FreeBSD. Simplicity is one of the most important goals of the project and the following features are supported:

* Manual backups of files and/or MySQL databases.
* Automatic daily backups of files and/or MySQL databases.
* Automatic weekly backups of files and/or MySQL databases.
* Optional compression: gzip, bzip2 and xz.
* Optional symmetrical encryption of backups.
* Optional retention (auto delete based on file age) for daily and weekly backups.
* Customizable backup location for both file and MySQL database backups.
* Customizable file name prefix.

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

## 3 Features
### 3.1 Manual backups
Manual backup files will look like `prefix-files.tar` and `prefix-mysql-db_name.sql`.

Before you can run manual backups, `BACKUP_FILES_ENABLE` and/or `BACKUP_MYSQL_ENABLE` needs to be set to `YES` in `/usr/local/etc/backupbot.conf`. When you're happy with the configuration you can run `backupbot --backup` to start the backup based on your settings (file backup, MySQL backup or both). If you wish to only backup files or only backup MySQL databases without changing the configuration in `/usr/local/etc/backupbot.conf`, you can also run `backupbot --mysql` or `backupbot --files`.

### 3.2 Daily backups
Daily backup files will look like `prefix-daily-files.tar` and `prefix-daily-mysql-db_name.sql`.

When automatic daily backups are configured by setting `AUTOMATIC_BACKUP_DAILY` in `/usr/local/etc/backupbot.conf`, the created cronjob (after running `backupbot --cron`) will run `backupbot` daily at the configured time. When weekly backups are configured as well, the daily backup won't run on the chosen weekly backup day. Example: you have configured the daily backups to run at 3:00 and the weekly backups to run on on sundays, then the daily backup will run from monday to saturday and skip sundays.

### 3.3 Weekly backups
Weekly backup files will look like `prefix-weekly-files.tar` and `prefix-weekly-mysql-db_name.sql`.

When automatic weekly backups are configured by setting `AUTOMATIC_BACKUP_WEEKLY` in `/usr/local/etc/backupbot.conf`, the created cronjob (after running `backupbot --cron`) will run `backupbot` weekly at the configured day (monday-sunday). The daily backup won't run on the chosen weekly backup day.

### 3.4 Compression
Compression can be configured for both file and MySQL database backups by setting the `BACKUP_FILES_COMPRESSION` and `BACKUP_MYSQL_COMPRESSION` parameters in `/usr/local/etc/backupbot.conf` to either `0` for no compression, `1` for compression by `gzip`, `2` for compression by `bzip2` or `3` for compression by `xz`.

Especially databases can often benefit greatly from compression, but in most cases it's also worthwhile to compress files. Out of these three options, `gzip` has the lowest level of compression but is also by far the fastest. `xz` on the contrary has the highest level of compression but is many times slower than `gzip`. `bzip2` is in between `gzip` and `xz` in both level of compression and compression speed. For devices with a slower cpu/processor, `gzip` is recommended.

For a comparison on a relatively slow server cpu, checkout this [Discussion](https://github.com/nozel-org/freebsd-backupbot/discussions/12).

### 3.5 Encryption
Backups can be encrypted automatically by setting `BACKUP_ENCRYPTION_ENABLE` to `YES` and setting a secret in `BACKUP_ENCRYPTION_SECRET` in `/usr/local/etc/backupbot.conf`.

The encryption feature uses `gpg` to encrypt the backups and will check on the availability of `gpg` on the system when the encryption feature is enabled. Note that this encryption feature uses basic symmetrical encryption with a secret, so make sure other people can't extract the secret from `/usr/local/etc/backupbot.conf`. You can make `/usr/local/etc/backupbot.conf` readable only by root by setting `chown root:wheel /usr/local/etc/backupbot.conf` and `chmod 555 /usr/local/etc/backupbot.conf`.

Store your secret in a safe place so you will never lose it by accident. You could save the secret in a password manager or on paper in a safe (make sure it's water and heat resistent).

Decryption can be done with `gpg` and `tar` (for files), for example by running `gpg -d archive.tar.gz.gpg | tar -xvzf -`. Always test decryption before you set and forget the automatic backups by `backupbot`.

### 3.6 Retention
With the `BACKUP_FILES_RETENTION_DAILY` and `BACKUP_MYSQL_RETENTION_DAILY` parameters in `/usr/local/etc/backupbot.conf`, the amount of days that daily backups should be kept can be configured. Likewise with the `BACKUP_FILES_RETENTION_WEEKLY` and `BACKUP_MYSQL_RETENTION_WEEKLY` parameters in `/usr/local/etc/backupbot.conf`, the amount of days that weekly backups should be kept can be configured.

This way it's for example possible to keep weekly backups for a longer period of time than daily backups.

### 3.7 Cron
When the daily and weekly backup features are configured, `backupbot` can automatically generate cronjobs for their respective schedules by using `backupbot --cron`. This will remove the old cronjob and replace it with a new cronjob based on the chosen parameters in `/usr/local/etc/backupbot.conf`.

The cronjob(s) is/are saved in `/etc/cron.d/backupbot`.