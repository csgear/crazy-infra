#!/bin/bash
sql_slave_user='CREATE USER "replica"@"%" IDENTIFIED BY "123456"; GRANT REPLICATION SLAVE ON *.* TO "replica"@"%"; FLUSH PRIVILEGES; FLUSH TABLES WITH READ LOCK;'
docker exec mysql_master sh -c "mysql -u root -p123456 -e '$sql_slave_user'"
MS_STATUS=`docker exec mysql_master sh -c 'mysql -u root -p123456 -e "SHOW MASTER STATUS\G"'`
CURRENT_LOG=`echo $MS_STATUS | grep File: | awk '{print $2}'`
CURRENT_POS=`echo $MS_STATUS | grep Position: | awk '{print $2}'`
sql_set_master="CHANGE MASTER TO MASTER_HOST='mysql_master',MASTER_USER='replica',MASTER_PASSWORD='123456',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd='mysql -u root -p123456 -e "'
start_slave_cmd+="$sql_set_master"
start_slave_cmd+='"'
docker exec mysql_slave sh -c "$start_slave_cmd"
docker exec mysql_slave sh -c "mysql -u root -p123456 -e 'SHOW SLAVE STATUS \G'"