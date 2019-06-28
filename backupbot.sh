#!/bin/bash

#############################################################################
# Version 0.0.0-ALPHA (28-06-2019)
#############################################################################

#############################################################################
# Copyright 2016-2019 Nozel/Sebas Veeke. Licenced under a Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# See https://creativecommons.org/licenses/by-nc-sa/4.0/
#
# Contact:
# > e-mail      mail@nozel.org
# > GitHub      onnozel
#############################################################################

# THIS SCRIPT HAS THE FOLLOWING LAY-OUT
# - VARIABLES
# - ARGUMENTS
# - GENERAL FUNCTIONS
# - REQUIREMENT FUNCTIONS
# - ERROR FUNCTIONS
# - GATHER FUNCTIONS
# - MANAGEMENT FUNCTIONS
# - FEATURE FUNCTIONS
# - METHOD FUNCTIONS
# - MAIN FUNCTION
# - CALL MAIN FUNCTION

# add line numbers in index?

#############################################################################
# VARIABLES
#############################################################################

# serverbot version
VERSION='0.0.0'

# check whether serverbot.conf is available and source it
if [ -f /etc/serverbot/serverbot.conf ]; then
    source /etc/serverbot/serverbot.conf
else
    # otherwise use these default values
    #FEATURE_BACKUP='enabled'
    #FEATURE_FILES='enabled'
    #FEATURE_SQL='enabled'
    METHOD_CLI='enabled'
    METHOD_TELEGRAM='disabled' # won't work without serverbot.conf
    METHOD_EMAIL='disabled' # won't work without serverbot.conf
    FEATURE_CRON='disabled' # won't work without serverbot.conf
    FEATURE_CONFIG='enabled'
    FEATURE_UPGRADE='disabled' # won't work without serverbot.conf ### maybe use --upgrade for both install and upgrade with --install linking to --upgrade

    # backup retention in number of days.
    #RETENTION_DAILY='14'
    #RETENTION_WEEKLY='180'
    #RETENTION_MONTHLY='180'
    #RETENTION_YEARLY='0'
fi

#############################################################################
# ARGUMENTS
#############################################################################

# enable help, version and a cli option
while test -n "$1"; do
    case "$1" in
        # options
        --version)
            echo
            echo "backupbot ${VERSION}"
            echo "Copyright (C) 2018 Nozel."
            echo
            echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
            echo
            echo "Written by Sebas Veeke"
            echo
            shift
            ;;

        --help|-help|help|--h|-h)
            echo
            echo "Usage:"
            echo " serverbot [feature/option]... [method]..."
            echo
            echo "Features:"
            echo " -b, --backup          Backup sql and files"
            echo
            echo "Methods:"
            echo " -c, --cli             Output [feature] to command line"
            echo " -t, --telegram        Output [feature] to Telegram bot"
            #echo " -e, --email           Output [feature] to e-mail"
            echo
            echo "Options:"
            echo " --cron               Effectuate cron changes from serverbot config"
            echo " --install            Installs serverbot on the system and unlocks all features"
            echo " --upgrade            Upgrade serverbot to the latest stable version"
            echo " --help               Display this help and exit"
            echo " --version            Display version information and exit"
            echo
            shift
            ;;

        # features
        --backup|backup|-b)
            ARGUMENT_BACKUP='1'
            shift
            ;;

        # methods
        --cli|cli|-c)
            ARGUMENT_CLI='1'
            shift
            ;;

        --telegram|telegram|-t)
            ARGUMENT_TELEGRAM='1'
            shift
            ;;

        --email|email|-e)
            ARGUMENT_EMAIL='1'
            shift
            ;;

        # options
        --cron)
            ARGUMENT_CRON='1'
            shift
            ;;

        --install)
            ARGUMENT_INSTALL='1'
            shift
            ;;

        --upgrade)
            ARGUMENT_UPGRADE='1'
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
# GENERAL FUNCTIONS
#############################################################################

function check_version {

    # make comparison of serverbot versions
    echo "$@" | gawk -F. '{ printf("%03d%03d%03d\n", $1,$2,$3); }';
}

#############################################################################
# REQUIREMENT FUNCTIONS
#############################################################################

function requirement_root {

    # checking whether the script runs as root
    if [ "$EUID" -ne 0 ]; then
        echo
        echo '[!] Error: this feature requires root privileges.'
        echo
        exit 1
    else
        if [ "${ARGUMENT_UPGRADE}" == '1' ]; then
            echo '[i] Info: script has correct privileges...'
        fi
    fi
}

function requirement_os {

    # checking whether supported operating system is installed
    # source /etc/os-release to use variables
    if [ -f /etc/os-release ]; then
        source /etc/os-release

        # put distro name and version in variables
        DISTRO="${NAME}"
        DISTRO_VERSION="${VERSION_ID}"

        # check all supported combinations of OS and version
        if [ "${DISTRO} ${DISTRO_VERSION}" == "CentOS Linux 7" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "CentOS Linux 8" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "Fedora 27" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "Fedora 28" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "Fedora 29" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "Fedora 30" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "Fedora 31" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "Debian GNU/Linux 8" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "Debian GNU/Linux 9" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "Debian GNU/Linux 10" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "Debian GNU/Linux 11" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "Ubuntu 14.04" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "Ubuntu 16.04" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "Ubuntu 18.04" ] || \
        [ "${DISTRO} ${DISTRO_VERSION}" == "Ubuntu 18.10" ]; then
            if [ "${ARGUMENT_UPGRADE}" == '1' ]; then
                echo '[i] Info: operating system is supported...'
            fi
        else
            error_os_not_supported
        fi
    else
        error_os_not_supported
    fi
}

function requirement_internet {

    # checking internet connection
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        echo '[i] Info: is connected to the internet...'
    else
        echo
        echo '[!] Error: access to the internet is required.'
        echo
        exit 1
    fi
}

function requirement_argument_validity {

    # check whether a argument was given
    if [ $# == 0 ]; then
        error_invalid_option
    fi

    # check whether given arguments are compatible
    #if [ "${ARGUMENT_METRICS}" == '1' ]; && { [ "${ARGUMENT_ALERT}" == '1' ] || [ "${ARGUMENT_UPDATES}" == '1' ] || [ "${ARGUMENT_OUTAGE}" == '1' ] || [ "${ARGUMENT_BACKUP}" == '1' ]; } then
    # } && [ "${VAR3}" == 'yes' ]; then
}

#############################################################################
# ERROR FUNCTIONS
#############################################################################

function error_invalid_option {

    echo
    echo "serverbot: invalid option -- '$@'"
    echo "Try 'serverbot --help' for more information."
    echo
    exit 1
}

function error_not_yet_implemented {

    echo
    echo "[!] Error: this feature has not been implemented yet."
    echo
    exit 1
}

function error_os_not_supported {

    echo
    echo '[!] Error: this operating system is not supported.'
    echo
    exit 1
}

function error_method_not_available {

    echo
    echo '[!] Error: this method is not available without Serverbot configuration file.'
    echo
    exit 1
}

#############################################################################
# GATHER FUNCTIONS
#############################################################################

#############################################################################
# MANAGEMENT FUNCTIONS
#############################################################################

#############################################################################
# FEATURE FUNCTIONS
#############################################################################

function feature_backup {

    # this feature function differs from most other feature functions because
    # the methods (e.g. Telegram or CLI) are incorporated here

    # set default file permission
    umask 007

    # backup files when enabled
    if [ "${BACKUP_FILES}" == 'yes' ]; then
        if [ "${RETENTION_DAILY}" -gt '0' ]; then
        FILES_NAME_DAILY="daily_$(date '+%Y-%m-%d_%Hh%Mm%Ss').tar.gz"
        tar -cpzf /var/lib/serverbot/files/${FILES_NAME_DAILY} "${BACKUP_FILES_PATH}"
        fi

        if [ "${RETENTION_WEEKLY}" -gt '0' ] && [ "$(date +'%u')" -eq "${BACKUP_WEEK_DAY}" ]; then
        FILES_NAME_WEEKLY="weekly_$(date '+%Y-%m-%d_%Hh%Mm%Ss').tar.gz"
        tar -cpzf /var/lib/serverbot/files/${FILES_NAME_WEEKLY} "${BACKUP_FILES_PATH}"
        fi

        if [ "${RETENTION_MONTHLY}" -gt '0' ] && [ "$(date +'%d')" -eq "${BACKUP_MONTH_DAY}" ]; then
        FILES_NAME_MONTHLY="monthly_$(date '+%Y-%m-%d_%Hh%Mm%Ss').tar.gz"
        tar -cpzf /var/lib/serverbot/files/${FILES_NAME_MONTHLY} "${BACKUP_FILES_PATH}"
        fi

        if [ "${RETENTION_YEARLY}" -gt '0' ] && [ "$(date +'%j')" -eq "${BACKUP_YEAR_DAY}" ]; then
        FILES_NAME_YEARLY="yearly_$(date '+%Y-%m-%d_%Hh%Mm%Ss').tar.gz"
        tar -cpzf /var/lib/serverbot/files/${FILES_NAME_MONTHLY} "${BACKUP_FILES_PATH}"
        fi

        # set backup ownership
        chown root:root /var/lib/serverbot/files/*

        # touch files to prevent find from giving errors
        touch /var/lib/serverbot/files/daily-touch
        touch /var/lib/serverbot/files/weekly-touch
        touch /var/lib/serverbot/files/monthly-touch
        touch /var/lib/serverbot/files/yearly-touch

        # delete older backups
        find /var/lib/serverbot/files/daily* -mtime +"${RETENTION_DAILY}" -type f -delete
        find /var/lib/serverbot/files/weekly* -mtime +"${RETENTION_WEEKLY}" -type f -delete
        find /var/lib/serverbot/files/monthly* -mtime +"${RETENTION_MONTHLY}" -type f -delete
        find /var/lib/serverbot/files/year* -mtime +"${RETENTION_YEARLY}" -type f -delete
    fi

    # backup SQL when enabled
    if [ "${BACKUP_SQL}" == 'yes' ]; then
        if [ "${RETENTION_DAILY}" -gt '0' ]; then
        SQL_NAME_DAILY="daily_$(date '+%Y-%m-%d_%Hh%Mm%Ss').tar.gz"
        tar -cpzf /var/lib/serverbot/sql/${SQL_NAME_DAILY} "${BACKUP_FILES_PATH}"
        fi

        if [ "${RETENTION_WEEKLY}" -gt '0' ] && [ "$(date +'%u')" -eq "${BACKUP_WEEK_DAY}" ]; then
        SQL_NAME_WEEKLY="weekly_$(date '+%Y-%m-%d_%Hh%Mm%Ss').tar.gz"
        tar -cpzf /var/lib/serverbot/sql/${SQL_NAME_WEEKLY} "${BACKUP_FILES_PATH}"
        fi

        if [ "${RETENTION_MONTHLY}" -gt '0' ] && [ "$(date +'%d')" -eq "${BACKUP_MONTH_DAY}" ]; then
        SQL_NAME_MONTHLY="monthly_$(date '+%Y-%m-%d_%Hh%Mm%Ss').tar.gz"
        tar -cpzf /var/lib/serverbot/sql/${SQL_NAME_MONTHLY} "${BACKUP_FILES_PATH}"
        fi

        if [ "${RETENTION_YEARLY}" -gt '0' ] && [ "$(date +'%j')" -eq "${BACKUP_YEAR_DAY}" ]; then
        SQL_NAME_YEARLY="yearly_$(date '+%Y-%m-%d_%Hh%Mm%Ss').tar.gz"
        tar -cpzf /var/lib/serverbot/sql/${SQL_NAME_MONTHLY} "${BACKUP_FILES_PATH}"
        fi
    fi

    # report backup to Telegram if configured
    if [ "${BACKUP_TELEGRAM}" == 'yes' ]; then
        if [ -f /var/lib/serverbot/files/${FILES_NAME_DAILY} ]; then
            FILES_DAILY_MESSAGE="\\n- ${FILES_NAME_DAILY}"
        fi
        if [ -f /var/lib/serverbot/files/${FILES_NAME_WEEKLY} ]; then
            FILES_WEEKLY_MESSAGE="\\n- ${FILES_NAME_WEEKLY}"
        fi
        if [ -f /var/lib/serverbot/files/${FILES_NAME_MONTHLY} ]; then
            FILES_MONTHLY_MESSAGE="\\n- ${FILES_NAME_MONTHLY}"
        fi
        if [ -f /var/lib/serverbot/files/${FILES_NAME_YEARLY} ]; then
            FILES_YEARLY_MESSAGE="\\n- ${FILES_NAME_YEARLY}"
        fi
        if [ -f /var/lib/serverbot/sql/${SQL_NAME_YEARLY} ]; then
            SQL_YEARLY_MESSAGE="\\n- ${SQL_NAME_YEARLY}"
        fi
        if [ -f /var/lib/serverbot/sql/${SQL_NAME_YEARLY} ]; then
            SQL_YEARLY_MESSAGE="\\n- ${SQL_NAME_YEARLY}"
        fi
        if [ -f /var/lib/serverbot/sql/${SQL_NAME_YEARLY} ]; then
            SQL_YEARLY_MESSAGE="\\n- ${SQL_NAME_YEARLY}"
        fi
        if [ -f /var/lib/serverbot/sql/${SQL_NAME_YEARLY} ]; then
            SQL_YEARLY_MESSAGE="\\n- ${SQL_NAME_YEARLY}"
        fi

        # create message for Telegram
        TELEGRAM_MESSAGE="$(echo -e "The following file backups have been created on <b>${HOSTNAME}</b>:\\n<code>${FILES_DAILY_MESSAGE}${FILES_WEEKLY_MESSAGE}${FILES_MONTHLY_MESSAGE}${FILES_YEARLY_MESSAGE}${SQL_DAILY_MESSAGE}${SQL_WEEKLY_MESSAGE}${SQL_MONTHLY_MESSAGE}${SQL_YEARLY_MESSAGE}</code>")"

        # call method_telegram
        method_telegram

        # exit when done
        exit 0
    fi

    # report backup to email if configured
    if [ "${BACKUP_EMAIL}" == 'yes' ]; then
        error_method_not_available
    fi
}

#############################################################################
# METHOD FUNCTIONS
#############################################################################

function method_telegram {

    # give error when telegram is unavailable
    if [ "${METHOD_TELEGRAM}" == 'disabled' ]; then
        error_method_not_available
    fi

    # create payload for Telegram
    TELEGRAM_PAYLOAD="chat_id=${TELEGRAM_CHAT}&text=${TELEGRAM_MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

    # sent payload to Telegram API and exit
    curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${TELEGRAM_PAYLOAD}" "${TELEGRAM_URL}" #> /dev/null 2>&1 &
}

function method_email {

    # planned for version 1.1
    error_not_yet_implemented
}

#############################################################################
# MAIN FUNCTION
#############################################################################

function backupbot_main {

    ### SOME WAY OF CHECKING VALIDITY OF INPUT HERE ###

    # option cron
    if [ "${ARGUMENT_CRON}" == '1' ]; then
        serverbot_cron
    # option upgrade
    elif [ "${ARGUMENT_INSTALL}" == '1' ]; then
        serverbot_install_check
    elif [ "${ARGUMENT_UPGRADE}" == '1' ]; then
        serverbot_upgrade
    # feature backup; method none
    elif [ "${ARGUMENT_BACKUP}" == '1' ]; then
        requirement_root
        gather_information_server
        feature_backup
    # feature backup; method cli
    #elif [ "${ARGUMENT_BACKUP}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
    #   error_not_yet_implemented
    # feature backup; method telegram
    #elif [ "${ARGUMENT_BACKUP}" == '1' ] && [ "${ARGUMENT_TELEGRAM}" == '1' ]; then
    #    error_not_yet_implemented
    # feature backup; method email
    #elif [ "${ARGUMENT_BACKUP}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
    #    error_not_yet_implemented
    # undefined argument given
    elif [ "${ARGUMENT_NONE}" == '1' ]; then
        error_invalid_option
    fi
}

#############################################################################
# CALL MAIN FUNCTION
#############################################################################

# call main function
backupbot_main
