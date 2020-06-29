#!/bin/sh

#############################################################################
# Version 0.1.0-UNSTABLE (29-06-2020)
#############################################################################

#############################################################################
# Copyright 2019-2020 Nozel/Sebas Veeke. Licenced under a Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# See https://creativecommons.org/licenses/by-nc-sa/4.0/
#
# Contact:
# > e-mail      mail@nozel.org
# > GitHub      onnozel
#############################################################################

#############################################################################
# VARIABLES
#############################################################################

# serverbot version
BACKUPBOT_VERSION='0.1.0'

# backupbot parameters can be configured in /usr/local/etc/backupbot.conf
# if the backupbot configuration file exists, it gets sourced by backupbot
if [ -f /usr/local/etc/backupbot.conf ]; then
    # populate all usable variables for checking validity later on
    AUTOMATIC_BACKUP_ENABLE='0'
    AUTOMATIC_BACKUP_CRON='0'
    BACKUP_FILES_ENABLE='0'
    BACKUP_FILES_PREFIX='0'
    BACKUP_FILES_RETENTION='0'
    BACKUP_FILES_DESTINATION='0'
    BACKUP_FILES='0'
    BACKUP_MYSQL_ENABLE='0'
    BACKUP_MYSQL_PREFIX='0'
    BACKUP_MYSQL_RETENTION='0'
    BACKUP_MYSQL_DESTINATION='0'

    # and source backupbot.conf
    . /usr/local/etc/backupbot.conf

    # and finally use default values for unconfigured parameters
    if [ "${BACKUP_FILES_PREFIX}" = '0' ]; then
        BACKUP_FILES_PREFIX="$(date +%Y%m%d)-files"
    fi
    if [ "${BACKUP_MYSQL_PREFIX}" = '0' ]; then
        BACKUP_MYSQL_PREFIX="$(date +%Y%m%d)"
    fi
    XZ_COMPRESSION_RATE='-1'
else
    # if backupbot.conf does not exist, return this error 
    echo 'backupbot: error: /usr/local/etc/backupbot.conf is required but cannot be found'
fi

#############################################################################
# ARGUMENTS
#############################################################################

# enable arguments to backupbot
while test -n "$1"; do
    case "$1" in
        # options
        --version)
            ARGUMENT_VERSION='1'
            shift
            ;;

        --help|-help|help|--h|-h)
            ARGUMENT_HELP='1'
            shift
            ;;

        --cron)
            ARGUMENT_CRON='1'
            shift
            ;;

        # features
        --backup|backup|-b)
            ARGUMENT_BACKUP='1'
            shift
            ;;

        --files|files|-f)
            ARGUMENT_FILES='1'
            shift
            ;;

        --mysql|mysql|-m)
            ARGUMENT_MYSQL='1'
            shift
            ;;

        # other
        *)
            ARGUMENT_NONE='1'
            shift
            ;;
    esac
done

#############################################################################
# ERROR FUNCTIONS
#############################################################################

error_invalid_argument() {
    echo 'backupbot: error: used argument is invalid, use "backuptbot --help" for proper usage'
    exit 1
}    
error_destination_not_configured() {
    echo 'backupbot: error: backup destination is not configured properly in /usr/local/etc/backupbot.conf'
    exit 1
}

error_source_not_configured() {
    echo 'backupbot: error: backup source is not configured properly in /usr/local/etc/backupbot.conf'
    exit 1
}

error_cron_not_configured() {
    echo 'backupbot: error: cron is not configured properly in /usr/local/etc/backupbot.conf'
    exit 1
}

error_no_feature_configured() {
    echo 'backupbot: error: no backup feature is enabled in /usr/local/etc/backupbot.conf'
    exit 1
}

error_retention_not_integer() {
    echo 'backupbot: error: retention should be a positive number in /usr/local/etc/backupbot.conf'
    exit 1
}

error_feature_not_configured() {
    echo 'backupbot: error: one of the invoked features is not configured in /usr/local/etc/backupbot.conf'
    exit 1
}

#############################################################################
# REQUIREMENT FUNCTIONS
#############################################################################

requirement_argument_validity() {
    # enabled backup features must have file destinations
    if [ "${BACKUP_FILES_ENABLE}" = 'YES' ] && [ "${BACKUP_FILES_DESTINATION}" = '0' ]; then
        error_destination_not_configured
    fi
    if [ "${BACKUP_MYSQL_ENABLE}" = 'YES' ] && [ "${BACKUP_MYSQL_DESTINATION}" = '0' ]; then
        error_destination_not_configured
    fi
    # enabled backup features must have configured file sources
    if [ "${BACKUP_FILES_ENABLE}" = 'YES' ] && [ "${BACKUP_FILES}" = '0' ]; then
        error_source_not_configured
    fi
    # enabled automatic backup must have a configured cron parameter
    if [ "${AUTOMATIC_BACKUP_ENABLE}" = 'YES' ] && [ "${AUTOMATIC_BACKUP_CRON}" = '0' ]; then
        error_cron_not_configured
    fi
    # at least one backup feature must be enabled
    if [ "${BACKUP_FILES_ENABLE}" = '0' ] && [ "${BACKUP_MYSQL_ENABLE}" = '0' ]; then
        error_no_feature_configured
    fi
    # backup feature retention must be a integer
    if ! [ "${BACKUP_FILES_RETENTION}" -eq "${BACKUP_FILES_RETENTION}" ] 2> /dev/null; then
        error_retention_not_integer
    fi
    if ! [ "${BACKUP_MYSQL_RETENTION}" -eq "${BACKUP_MYSQL_RETENTION}" ] 2> /dev/null; then
        error_retention_not_integer
    fi
}

requirement_root() {
    echo 'placeholder requirement root'
}

requirement_os() {
    echo 'placeholder requirement os'
}

#############################################################################
# OPTION FUNCTIONS
#############################################################################

option_version() {
    echo "Backupbot ${BACKUPBOT_VERSION}"
    echo "Copyright (C) 2016-2020 Nozel."
    echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
    echo
    echo "Written by Sebas Veeke"
}

option_help() {
    echo "Usage:"
    echo " backupbot [feature/option]..."
    echo
    echo "Features:"
    echo " -b, --backup         Backup everything configured in configuration file"
    echo " -f, --files          Backup files configured in configuration file"
    echo " -m, --mysql          Backup MySQL databases configured in configuration file"
    echo
    echo "Options:"
    echo " --cron               Effectuate cron changes from serverbot config"
    echo " --help               Display this help and exit"
    echo " --version            Display version information and exit"
}

option_cron() {
    echo 'Removing old backupbot cronjobs'
    rm -f /etc/cron.d/backupbot
    if [ "${AUTOMATIC_BACKUP_ENABLE}" = 'YES' ]; then
        echo 'Updating cronjob for backupbot'
        echo '# This cronjob activates backupbot on the chosen schedule' > /etc/cron.d/backupbot
        echo "${AUTOMATIC_BACKUP_CRON} root /usr/bin/backupbot --backup" >> /etc/cron.d/backupbot
    else
        echo 'Automatic backup is disabled, skipping creation of cronjob'
    fi
    echo 'Done!'
}

#############################################################################
# FEATURE FUNCTIONS
#############################################################################

feature_files() {
    if [ "${BACKUP_FILES_ENABLE}" = 'YES' ]; then
        # backupbot uses tar for archiving data and xz for compressing data
        # the below xz compression rate is less hard hitting on slower systems
        XZ_OPT=${XZ_COMPRESSION_RATE}
        # the following arguments are used for tar:
        # --create               (-c) create new archive containing the specified items
        # --xz                   (-J) compress the resulting archive with xz
        # --preserve-permissions (-p) preserve file permissions
        # --file                 (-f) write the archive to the specified file
        # --verbose              (-v) produce verbose output (disabled by default)
        tar --create --preserve-permissions --xz --file "${BACKUP_FILES_DESTINATION}/${BACKUP_FILES_PREFIX}.tar.xz" ${BACKUP_FILES}
    fi
}

feature_mysql() {
    if [ "${BACKUP_MYSQL_ENABLE}" = 'YES' ]; then
        for DB in $(mysql -e 'show databases' -s --skip-column-names); do
            mysqldump --single-transaction ${DB} | xz ${XZ_COMPRESSION_RATE} > ${BACKUP_MYSQL_DESTINATION}/${BACKUP_MYSQL_PREFIX}-${DB}.sql.xz
        done
    fi
}

#############################################################################
# MAIN FUNCTION
#############################################################################

backupbot_main() {
    # check whether requirements are met
    requirement_argument_validity

    # call option based on arguments
    if [ "${ARGUMENT_VERSION}" = '1' ]; then
        option_version
        exit 0
    elif [ "${ARGUMENT_HELP}" = '1' ]; then
        option_help
        exit 0
    elif [ "${ARGUMENT_CRON}" = '1' ]; then
        requirement_root
        requirement_os
        option_cron
        exit 0
    # call feature based on arguments
    elif [ "${ARGUMENT_BACKUP}" = '1' ]; then
        requirement_root
        requirement_os
        feature_files
        feature_mysql
        exit 0
    elif [ "${ARGUMENT_FILES}" = '1' ]; then
        requirement_root
        requirement_os
        feature_files
        exit 0
    elif [ "${ARGUMENT_MYSQL}" = '1' ]; then
        requirement_root
        requirement_os
        feature_mysql
        exit 0
    # return error on invalid argument
    elif [ "${ARGUMENT_NONE}" = '1' ]; then
        error_invalid_argument
    fi
}

# call main function
backupbot_main
