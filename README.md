# backupbot
`backupbot` is a easy to use tool for creating (automated) backups on FreeBSD. Currently files and mysql databases are supported, but more features can be added in the future.

## Features
* **Easy to use**: get started in just a couple of minutes.
* **Backup files and mysql databases**: with optional encryption.
* **Configurable settings**: customize your backups, retention and schedule.
* **Made for FreeBSD**: compatible with basic shell.

## How to use
It's quite easy! Adjust the settings of `backupbot.conf` to taste and just run `backupbot --backup` to start the backup process. The `--backup` argument makes sure all enabled backup features in `backupbot.conf` will be activated. If instead only one of the enabled backup features should be activated manually, just use the corresponding argument like `backupbot --files` or `backupbot --mysql`. To effectuate the chosen schedule for automatic backup, use `backupbot --cron` and `backupbot` will take care of it.

If both `mysql` and `files` features have been enabled, the output of the backup will look something like this:
```
root@server:~ # ls -all -h /data/backup/
drwxr-xr-x  2 root  wheel   512B Jul  1 15:36 .
drwxr-xr-x  4 root  wheel   1.0K Jun 29 23:52 ..
-rw-r--r--  1 root  wheel   162K Jul  1 03:00 200701T0300-casusdag.sql.xz
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
wget https://raw.githubusercontent.com/nozel-org/freebsd-backupbot/master/backupbot.sh -O /usr/bin/backupbot
chown root:wheel /usr/bin/backupbot
chmod 555 /usr/bin/backupbot
wget https://raw.githubusercontent.com/nozel-org/freebsd-backupbot/master/backupbot.conf -O /usr/local/etc/backupbot.conf
backupbot --cron
```

## Support
If you have questions, suggestion or find bugs, please let us know via the issue tracker.

## Changelog
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
