#4. Configure the Replica Server
docker exec -it mysql-slave bash
mysql -uroot -p


#Configure the replication settings using the master log file and position:
CHANGE MASTER TO
  MASTER_HOST='mysql-master',
  MASTER_USER='replication_user',
  MASTER_PASSWORD='replication_password',
  MASTER_LOG_FILE='mysql-bin.xxxxxx',
  MASTER_LOG_POS=xxxx;


