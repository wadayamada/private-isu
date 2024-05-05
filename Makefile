DB_USER:=isuconp
DB_PASS:=isuconp
DB_NAME:=isuconp

MYSQL_CMD:=mysql -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)
MYSQL_LOG:=/var/log/mysql/slow-query.log

# show databases;
# show tables;
# show full columns from comments;
# show create table comments;

.PHONY: slow-on
slow-on:
	@echo "slow-querry ONにします"
	sudo mysql -e "set global slow_query_log_file = '$(MYSQL_LOG)'; set global long_query_time = 0; set global slow_query_log = ON;"
	sudo mysql -e "show variables like 'slow%';"

.PHONY: install-pt-query-digest
install-pt-query-digest:
	sudo apt update
	sudo apt install percona-toolkit

.PHONY: pt-query-digest
pt-query-digest:
	sudo pt-query-digest /var/log/mysql/slow-query.log

.PHONY mysql
mysql:
	mysql -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)

