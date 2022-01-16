# backupbot
`backupbot` is a easy to use tool for creating (automatic) backups on FreeBSD. Currently files and mysql databases are supported, but more features can be added in the future.

## Features
* **Easy to use**: get started in just a couple of minutes.
* **Backup files and mysql databases**: daily and weekly backups with optional compression and encryption.
* **Configurable settings**: customize your backups, retention and schedule.
* **Made for FreeBSD**: compatible with basic shell.

## How to use
It's quite easy! Adjust the settings of `/usr/local/etc/backupbot.conf` to taste and run `backupbot --backup` to start the backup process. To effectuate the chosen schedule for automatic backups, use `backupbot --cron` and `backupbot` will take care of the rest.

If both `mysql` and `files` features have been enabled, the output of the backup will look something like this:
```
root@server:~ # ls -all -h /data/backup/
drwxr-xr-x  2 root  wheel   512B Jul  1 15:36 .
drwxr-xr-x  4 root  wheel   1.0K Jun 29 23:52 ..
-rw-r--r--  1 root  wheel   162K Jul  1 03:00 200701T0300-blog.sql.xz
-rw-r--r--  1 root  wheel   896M Jul  1 03:00 200701T0300-files.tar.xz
-rw-r--r--  1 root  wheel    66K Jul  1 03:00 200701T0300-cloud_test.sql.xz
-rw-r--r--  1 root  wheel    16M Jul  1 03:00 200701T0300-wp.sql.xz
```

## How to install
1. Copy `backupbot` to `/usr/bin/backupbot` (owner=`root`, group=`wheel`, permissions=`555` (read & execute).
2. Copy `backupbot.conf` to `/usr/local/etc/backupbot.conf` and adjust the settings to taste.
3. Optionally add the chosen schedule to a automatic cronjob with `backupbot --cron`.

This will look something like:
```
# install backupbot
wget https://raw.githubusercontent.com/nozel-org/freebsd-backupbot/master/backupbot -O /usr/bin/backupbot
chown root:wheel /usr/bin/backupbot
chmod 555 /usr/bin/backupbot
wget https://raw.githubusercontent.com/nozel-org/freebsd-backupbot/master/backupbot.conf -O /usr/local/etc/backupbot.conf
nano /usr/local/etc/backupbot.conf
backupbot --cron
```

## Support
The [manual](https://github.com/nozel-org/freebsd-backupbot/blob/master/manual.md) provides some more insight in to backupbot. If you have questions, suggestion or find bugs, please let us know via Issues and Discussions.

## Changelog
### 1.4.0-RELEASE (16-01-2022)
- Added daily backup and weekly backup cycles.
- Extended automatic cron generation to include daily and weekly backup cycles.
- Extended retention to include daily and weekly backup cycles.
- Changed backup file names to reflect whether its a daily, weekly or manual backup.
- Changed the order of backup file name components to be more easy to read.
- Made default configuration file more compact and easy to read.
- Made some variable names more consistent.

### 1.3.0-RELEASE (15-01-2022)
- Added more compression alternatives: no compression, gzip, bzip2 and xz.

### 1.2.2-RELEASE (14-01-2022)
- Fixed a bug in retention feature.
- Switched from STABLE to RELEASE tag for releases.

### 1.2.1-STABLE (11-01-2022)
- Refactored retention feature to keep working when user switches from encrypted to unencrypted backups and vice versa.

### 1.2.0-STABLE (16-10-2021)
- Added support for automatic removal of old backups/retention.

### 1.1.0-STABLE (19-01-2021)
- Added support for symmetrical encryption of backups.

### 1.0.0-STABLE (01-07-2020)
- First stable release.
- Added support for backing up files.
- Added support for backing up mysql databases.
- Added support for automatic backup based on cron.
- Added creation of cronjob based on backupbot.conf.
- Added configurable settings for backup features and cron in backupbot.conf.
