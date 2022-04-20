#!/usr/bin/env bash

# Script information
SCRIPT_NAME="WordPress Installer"
SCRIPT_VERSION="1.0.0"

# Scripts defining custom functions
source $(dirname $0)/include/download.sh
source $(dirname $0)/include/info.sh
source $(dirname $0)/include/downloadWPCLI.sh

# Parse arguments
CONFIGURATION_FILE_PATH="settings.cfg"
while getopts “hpvt:c:” OPTION
do
    case $OPTION in
        h)
            printUsage
            exit 1
            ;;
        v)
            printVersion
            exit 1
            ;;
        c)
            CONFIGURATION_FILE_PATH=$OPTARG
            ;;
        ?)
            echo option not found
            printUsage
            exit 1
            ;;
    esac
done

# Configuration File
if [ ! -f "$CONFIGURATION_FILE_PATH" ]; then
    echo The setting file could not be loaded.
    exit 1
fi
source "$CONFIGURATION_FILE_PATH"
echo "Using the configuration file: $CONFIGURATION_FILE_PATH"

# Variables
WORKING_DIR=$(pwd)
cd "$WORKING_DIR"

if [ -z ${WPCLI_VERSION+x} ]; then
  WPCLI_VERSION="latest"
fi

TEMP=$([ -z "${TEMP}" ] && echo "/tmp" || echo "$TEMP")
WPCLI="$TEMP/wp-cli.${WPCLI_VERSION}.phar"

# convert any relative path or Windows path to linux/unix path to be usable for some path related commands such as basename
if [ ! -d "$WP_INSTALL_DIR" ]; then
  mkdir -p "$WP_INSTALL_DIR"
fi
cd "$WP_INSTALL_DIR"
WP_INSTALL_DIR=$(pwd)
cd "$WORKING_DIR"

echo "Working Directory: $WORKING_DIR"
echo "WordPress Installation Directory: $WP_INSTALL_DIR"

# Exit on errors, xtrace
# set -x
# set -ex
set -e

installWordPress() {

    # Download WordPress using wp-cli
    php "$WPCLI" core download --force --path="$WP_INSTALL_DIR" --locale="$WP_LOCALE" --version="$WP_VERSION"

    # Change directory to the test WordPres install directory.
    cd "$WP_INSTALL_DIR"
    
    rm -f wp-config.php
    dbpass=
    if [[ $DB_PASS ]]; then
        echo 'db pass is not empty'
        dbpass=--dbpass="${DB_PASS}"
    fi
    php "$WPCLI" config create --dbname=$DB_NAME --dbuser="$DB_USER" $dbpass --dbprefix="$WP_TABLE_PREFIX" --dbhost="$DB_HOST"
    php "$WPCLI" config set WP_DEBUG true --raw
    php "$WPCLI" config set WP_DEBUG_LOG true --raw
    
    # Renew the database table
    setup_database_table
    # Create/renew the database - if the environment variable WP_MULTISITE is set, install multi site network Wordpress.
    if [[ $WP_MULTISITE = 1 ]]; then    
        php "$WPCLI" core multisite-install --url="$WP_URL" --title="$WP_SITE_TITLE" --admin_user="$WP_ADMIN_USER_NAME" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL"
    else
        php "$WPCLI" core install --url="$WP_URL" --title="$WP_SITE_TITLE" --admin_user="$WP_ADMIN_USER_NAME" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL"
    fi

}
    setup_database_table(){
        
        # If the database table already exists, drop it.
        # if [[ -z "$DB_PASS" ]]; then
            # DB_PASS="\"\""
        # fi
        dbpass=
        if [[ $DB_PASS ]]; then
            echo 'db pass is not empty'
            dbpass="-p${DB_PASS}"
        fi           
        # RESULT=`mysql -u$DB_USER -p$DB_PASS --skip-column-names -e "SHOW DATABASES LIKE '$DB_NAME'"`
        RESULT=`mysql -u$DB_USER $dbpass --skip-column-names -e "SHOW DATABASES LIKE '$DB_NAME'"`
        if [ "$RESULT" == "$DB_NAME" ]; then
            php "$WPCLI" db drop --yes
        fi
    
        # mysql -u $DB_USER -p$DB_PASS -e --f "DROP $DB_NAME"
        # mysqladmin -u$#DB_USER -p$DB_PASS drop -f $DB_NAME
        php "$WPCLI" db create
        
    }
    

# Uninstalls default plugins    
uninstallPlugins() {
    cd "$WP_INSTALL_DIR"
    php "$WPCLI" plugin uninstall akismet
    php "$WPCLI" plugin uninstall hello
}

# Installs the project plugin
installPlugins() {
    
    # Install user specified plugins
    if [[ $WP_MULTISITE = 1 ]]; then    
        local OPTION_ACTIVATE="--activate-network"
    else
        local OPTION_ACTIVATE="--activate"
    fi         
    for _INSTALL_ACTIVE_PLUGIN in "${INSTALL_ACTIVE_PLUGINS[@]}" 
    do :
        php "$WPCLI" plugin install "$_INSTALL_ACTIVE_PLUGIN" $OPTION_ACTIVATE
    done
    for _INSTALL_INACTIVE_PLUGIN in "${INSTALL_INACTIVE_PLUGINS[@]}"
    do :
        php "$WPCLI" plugin install "$_INSTALL_INACTIVE_PLUGIN"
    done
}

# Download necessary applications
echo Downloading WP-CLI
downloadWPCLI "$WPCLI" "$WPCLI_VERSION"
cd "$WORKING_DIR"

# Install components
installWordPress
echo Installed WordPress
uninstallPlugins
echo Installed
installPlugins

# Done
echo Installation has been completed!
WP_URL_ADMIN="$WP_URL/wp-admin"
echo Opening, "$WP_URL_ADMIN"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  xdg-open "$WP_URL_ADMIN"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  open "$WP_URL_ADMIN"
elif [[ "$OSTYPE" == "cygwin" ]]; then
  start "$WP_URL_ADMIN"
elif [[ "$OSTYPE" == "msys" ]]; then
  start "$WP_URL_ADMIN"
elif [[ "$OSTYPE" == "win32" ]]; then
  start "$WP_URL_ADMIN"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
  xdg-open "$WP_URL_ADMIN"
fi