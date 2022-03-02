mysql-up:
	docker-compose -f docker-compose.yml -f docker-compose.mysql.yml up -d
sqlsrv-up:
	docker-compose -f docker-compose.yml -f docker-compose.sqlsrv.yml up -d
mariadb-up:
	docker-compose -f docker-compose.yml -f docker-compose.mariadb.yml up -d
php:
	docker-compose  -f docker-compose.yml exec php bash
down:
	docker-compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml  down
ps:
	docker-compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml ps
logs:
	docker-compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml logs
exec:
	docker-compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml exec
logs-watch:
	docker-compose logs --follow
mysql-init:
	@make down
	#git clone git@github.com:oreno4649/exment-boilerplate.git
	@make mysql-up
	docker-compose -f docker-compose.yml exec -T php chown www-data:www-data -R .
	docker-compose -f docker-compose.yml exec -T php composer install
	docker-compose -f docker-compose.yml exec -T php cp .env.mysql .env
	docker-compose -f docker-compose.yml exec -T php php artisan key:generate
test:
	@make mysql-up
	docker-compose exec -T php composer run exment:test:browser
