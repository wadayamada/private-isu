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
	@echo "--- slow-query-logをONにします ---"
	sudo mysql -e "set global slow_query_log_file = '$(MYSQL_LOG)'; set global long_query_time = 0; set global slow_query_log = ON;"
	sudo mysql -e "show variables like 'slow%';"

.PHONY: install-pt-query-digest
install-pt-query-digest:
	sudo apt update
	sudo apt install percona-toolkit

.PHONY: pt-query-digest
pt-query-digest:
	sudo pt-query-digest /var/log/mysql/slow-query.log

.PHONY: alp
alp:
	sudo cat /var/log/nginx/access.log | alp json --sort sum -r -m "/posts/[0-9]+, /image/[0-9]+, /@.+"

.PHONY: mysql
mysql:
	mysql -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)

.PHONY: rotate
rotate:
	@echo "--- rotateします ---"
	sudo mv /var/log/mysql/slow-query.log /var/log/mysql/slow-query.log.`date +%Y%m%d-%H%M%S`
	sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.`date +%Y%m%d-%H%M%S`
	sudo touch /var/log/mysql/slow-query.log
	sudo chmod 666 /var/log/mysql/slow-query.log
	sudo touch /var/log/nginx/access.log
	sudo chmod 666 /var/log/nginx/access.log

# sudo systemctl status isu-go.service
# sudo systemctl list-units

.PHONY: restart
restart:
	@echo "--- 再起動 ---"
	sudo systemctl restart nginx.service
	sudo systemctl restart mysql.service
	sudo systemctl restart isu-go.service

# go build app.go

.PHONY: benchmark
benchmark: rotate restart slow-on 
	@echo "--- benchmark ---"
	/home/isucon/private_isu/benchmarker/bin/benchmarker -u /home/isucon/private_isu/benchmarker/userdata -t http://localhost
