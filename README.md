## Get up and running

### Requirements for local development

- Docker Toolbox
- Git
- Entry in /etc/hosts pointing docker.vm at 192.168.99.100

### Get the project running

1. Clone this repository to a local directory under your home directory
2. Create the /repo directory and clone your Acquia project into it (so that directory /repo/docroot exists and contains the Drupal docroot files)
3. Copy /app/config/settings.local.php to /repo/docroot/sites/default
4. Open "Docker Quickstart Terminal" to start the Docker Machine
5. Using the Docker Machine shell "cd" into your project directory root from step 1
6. Type "docker-compose up -d" to start the configured containers
7. Assuming the IP address of your VM is 192.168.99.100 (default for Docker Toolbox) then you should be able to access
the site using this IP in your browser

### Initial setup

Setup Notes:
The Drupal files directories are mapped to ./app/default/files and ./app/default/files-private. If you need to pull in
files from a canonical source, put them in those folders and they will be mapped into the container in the correct
location.
If you run into permission problems with files directories in Drupal, run the prep.sh file in this repository.
The MySQL data directory is stored outside the container in ./mysql-data. This folder is git-ignored and not in the
repository. On initial checkout it will not exist. Once you start the docker containers you will need to import the
canonical DB in with the following commands:

    docker exec -it svi_mysql_1 bash
    mysql -uroot -ppassword drupal < /var/lib/mysql-dump/default.sql
    mysql -uroot -ppassword drupal < /var/lib/mysql-dump/scrub.sql

Once your site is up and running, killing and starting the containers will not remove any data and files. Only on fresh
install, or the import of another db will you need to do the steps above.

If you wish to export your db, run the following comamand:

    mysqldump -uroot -ppassword drupal > /var/lib/mysql-dump/mydbbackup.sql

It will be placed in the ./mysql-dump folder, but do not commit it to the repository.

Default site credentials: user: SVI-admin, pass: password

### Configure PHPStorm for debugging

- Under File > Settings > Languages and Frameworks > Debug make sure the debug port is set to 9000 and "can accept
incoming connections" is enabled
- Under File > Settings > Languages and Frameworks > Debug > DBGp Proxy make sure the host is configured for the bridged
host of the docker setup (172.17.0.1 by default) and the port is set to 9000
- Under File > Settings > Languages and Frameworks > Servers setup a new server configured with the host (192.168.99.100
for Docker Machine by default) with port 80, make sure XDebug is setup as the debugger.
- Make sure "use path mappings is checked" and you map the themes and modules directory to their corresponding
directories in the container
    - app/default -> /var/www/html/sites/default
    - app/libraries -> /var/www/html/libraries
    - app/modules -> /var/www/html/modules
    - app/themes -> /var/www/html/themes
    - drupal8-src -> /var/www/html
- Start the server with the debugging parameter specified by clicking the "Run" menu and then "Debug [project]" (or on
PC Shift + F9).
- Make sure PHPStorm is listening for remote debugging connections by clicking Run > Start Listening for PHP Debug
Connections (you don't need to do this if you use the step above).

### Development workflow

Please follow the Github Flow workflow for all feature development. Checkins directly to master are a no-no.

## Troubleshooting

### When your Drupal project running in a Docker environment on a Mac has insufficient permissions to write files.

Inside the container, if the sites/default directory looks like this:

    drwxr-xr-x 1 1000 staff 102 Sep 14 13:39 config
    -rw-r--r-- 1 1000 staff 24427 Mar 17 17:20 default.settings.php
    drwxrwxrwx 1 1000 staff 510 Sep 14 14:55 files
    drwxr-xr-x 1 1000 staff 68 Sep 14 14:16 files-private
    -rw-r--r-- 1 1000 staff 756 Mar 17 17:20 local.db.inc
    -rw-r--r-- 1 1000 staff 6095 Sep 14 13:39 settings.php

It's because Drupal is running as www-data; as such it cannot write to the files (and/or in this case, the files-private) directories.

The container's user cannot make any changes to these ownership settings (e.g. "chown -R www-data:www-data files" has no effect.)

A solution[on github](https://github.com/boot2docker/boot2docker/issues/587#issuecomment-114868208 "boot2docker on github") is to change the user within the container:

STEP-BY-STEP GUIDE

1. Modify the user within the container

     usermod -u 1000 www-data

2. It's necessary to restart Apache in order for this change to take effect - but the act of stopping Apache stops the container from running; you'll be popped back out to your Mac command line when you execute:

     service apache2 restart

3. Start your container again:

     docker-compose up -d

RESULT

Now if you ls -l your project's sites/default folder, you'll see:

    drwxr-xr-x 1 www-data staff 102 Sep 14 13:39 config
    -rw-r--r-- 1 www-data staff 24427 Mar 17 17:20 default.settings.php
    drwxrwxrwx 1 www-data staff 510 Sep 14 14:55 files
    drwxr-xr-x 1 www-data staff 68 Sep 14 14:16 files-private
    -rw-r--r-- 1 www-data staff 756 Mar 17 17:20 local.db.inc
    -rw-r--r-- 1 www-data staff 6095 Sep 14 13:39 settings.php

And Drupal will have permission to write its files.
### If the theme is borked on your local dev environment

Check to see what the database has set for the temporary files directory (execute either in the mysql container or via drush sqlc / sqlq in the web container):

>select name, value from variable where name like 'file_temporary_path';

If that directory doesn't exist in the web container, create it.

