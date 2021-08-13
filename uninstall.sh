#!/usr/bin/env bash

source $(dirname $0)/include/info.sh

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

# Exit on errors, xtrace
# set -ex 
# set -x
set -e

uninstallWordPress() {
    if [ -d "$WP_INSTALL_DIR" ]; then
    
        # Sometimes the directory cannot be removed. In that case attempt to move it to a different location
        # mv -f "$WP_INSTALL_DIR" "$TEMP/test-$PROJECT_SLUG"
        # rm -rf "$TEMP/test-$PROJECT_SLUG"
        
        # Sometimes the directory cannot be moved. In that case just delete it.
        rm -rf "$WP_INSTALL_DIR"
        
    fi
    if [ -d "$WP_INSTALL_DIR" ]; then
        echo "The directory could not be removed: $WP_INSTALL_DIR"
    fi
}
uninstallDatabase(){

    if [[ -z "$DB_PASS" ]]; then
        DB_PASS="\"\""
    fi
    RESULT=`mysql -u$DB_USER --password=$DB_PASS --skip-column-names -e "SHOW DATABASES LIKE '$DB_NAME'"`
    if [ "$RESULT" == "$DB_NAME" ]; then
        mysqladmin -u$DB_USER -p$DB_PASS drop $DB_NAME --force
    fi
        
}


# Call functions
uninstallDatabase
uninstallWordPress
echo Uninstallation has been completed!
