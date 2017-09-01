TRUNCATE TABLE cache;
UPDATE system SET STATUS = 0 WHERE name = 'drupalauth4ssp';
UPDATE system SET STATUS = 1 WHERE name = 'stage_file_proxy';
REPLACE INTO variable SET name = 'stage_file_proxy_hotlink', value = 'i:1;';
REPLACE INTO variable SET name = 'stage_file_proxy_origin', value = 's:23:"https://sharedvalue.org";';
/* Update admin user to 'admin' and password to 'password' */
UPDATE users SET name = 'docker-for-acquia' pass ='$S$DiEBjeOcejo2Yby7VWb.24e8A0J6.NgOUcuqSKWkCRAv6gp9kG9V' WHERE uid = 1;
/* Disable the project's 'securelogin' module for local development */
UPDATE system SET status = 0 WHERE name = 'securelogin';
