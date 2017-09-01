<?php

$databases['default']['default'] = array (
  'database' => $_ENV['DRUPAL_MYSQL_DB'],
  'username' => $_ENV['DRUPAL_MYSQL_USER'],
  'password' => $_ENV['DRUPAL_MYSQL_PASS'],
  'prefix' =>   '',
  'host' =>     $_ENV['DRUPAL_MYSQL_HOST'],
  'port' =>     $_ENV['DRUPAL_MYSQL_PORT'],
  'driver' =>   'mysql',
);

ini_set('memory_limit', '640M');
ini_set('xdebug.max_nesting_level', 512);

$conf['memcache_servers']           = array('memcached:11211' => 'default');
$conf['drupal_http_request_fails']  = FALSE;