DATE:=$(shell date +%Y%m%d-%H%M%S)

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

.PHONY: mysql
mysql:
	mysql -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)

.PHONY: rotate
rotate:
	sudo mv /var/log/mysql/slow-query.log /var/log/mysql/slow-query.log.`date +%Y%m%d-%H%M%S`
	sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.`date +%Y%m%d-%H%M%S`

.PHONY: mysql
benchmark: rotate slow-on
	/home/isucon/private_isu/benchmarker/bin/benchmarker -u /home/isucon/private_isu/benchmarker/userdata -t http://localhost