# WordPress Installer

Configure the setting file, `settings.cfg`, and run `install.sh`.

## Requirements

- PHP must be installed to perform the `php` command and run `wp-cli`.
- The MySQL server set to `DB_HOST` must be running.

## Getting Started

1. **Important** Rename `settings-sample.cfg` to `settings.cfg`. Edit the file and set up necessary paths, database user name password, and host, plugin slug, test site location etc.
2. Run

```
bash install.sh
```
   
4. When to uninstall the WordPress site including the database, run the uninstaller script by typing the following.

```
bash uninstall.sh
```

### Notes

To run `.sh` files on Windows, you need a Bash emulator. Here is [one](https://git-for-windows.github.io/).

## Command Arguments

### `c`

Specify a configuration file with the `c` option. If not specified, the script tries to read `settings.cofg`.

For example, to test WordPress 5.7 and 5.8, have separate configuration files like `settings-wp57.cfg` and `settings-wp58.cfg`. Then run

```
bash install.sh -c settings-wp57.cfg
bash install.sh -c settings-wp58.cfg
```

## Configurations
Set necessary options in a setting file. The default setting file that the script tries to load is `settings.cfg`. The name can be changed and in that case use the `c` command option to specify it.  

Copy `settings.sample.cfg`, rename it and edit the options accordingly.   

### `WP_VERSION`
The WordPress version to install. The default is `latest`. e.g. `5.8`. 

```shell
WP_VERSION="5.7"
```
### `DB_NAME`
The database name. 

```shell
DB_NAME="test_wp58"
```
### `DB_USER`
The database user name.
```shell
DB_USER="root"
```
### `DB_PASS`
The database password.
```shell
DB_PASS="mypassword"
```
### `DB_HOST`
The database password.
```shell
DB_HOST="localhost"
```
### `WP_TABLE_PREFIX`
The database table prefix.
```shell
WP_TABLE_PREFIX="wp58_"
```

### `WP_INSTALL_DIR`
The installation directory path.
```shell
WP_INSTALL_DIR="C:/www/test-wp58"
```

### `WP_INSTALL_DIR`
The installation site URL.
```shell
WP_URL="http://localhost/test-wp58"
```
### `WP_LOCALE`
The installation site URL.
```shell
WP_LOCALE="en_US"
```
### `WP_ADMIN_USER_NAME`
The initial user as an administrator of the site.
```shell
WP_ADMIN_USER_NAME="admin"
```
### `WP_ADMIN_PASSWORD`
The initial administrator's password.
```shell
WP_ADMIN_PASSWORD="admin"
```
### `WP_ADMIN_EMAIL`
The initial administrator's Email address.
```shell
WP_ADMIN_EMAIL="local@some.where"
```
### `WP_SITE_TITLE`
The site title.
```shell
WP_SITE_TITLE="Testing WordPress 5.8"
```

### `INSTALL_ACTIVE_PLUGINS[]`
Plugins to install and activate. The value is a URL of the plugin file. Usually the latest version is `latest-stable` keyword and a version number can be replaced with it.

```shell
INSTALL_ACTIVE_PLUGINS[0]="http://downloads.wordpress.org/plugin/admin-page-framework.latest-stable.zip"
INSTALL_ACTIVE_PLUGINS[1]="http://downloads.wordpress.org/plugin/disable-wordpress-updates.latest-stable.zip"
```

### `INSTALL_INACTIVE_PLUGINS[]`
Plugins to install and leave inactive.

```shell
INSTALL_INACTIVE_PLUGINS[0]="http://downloads.wordpress.org/plugin/wp-downgrade.latest-stable.zip"
```

### `WP_MULTISITE`
Whether the site is for multisite or not. Set `0` for normal sites; otherwise, `1`.
```shell
WP_MULTISITE=0
```

### `WPCLI_VERSION`
The WP-CLI version. Accepts `latest` or a version number.
```shell
WPCLI_VERSION="2.4.0"
```