mysql-up:
	docker compose -f docker-compose.yml -f docker-compose.mysql.yml up -d
mariadb-up:
	docker compose -f docker-compose.yml -f docker-compose.mariadb.yml up -d
sqlsrv-up:
	docker compose -f docker-compose.yml -f docker-compose.sqlsrv.yml up -d
php:
	docker compose  -f docker-compose.yml exec php bash
down:
	docker compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml  down
destroy:
	docker compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml down --rmi all --volumes --remove-orphans
ps:
	docker compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml ps
logs:
	docker compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml logs
exec:
	docker compose  -f docker-compose.yml -f docker-compose.mysql.yml -f docker-compose.sqlsrv.yml -f docker-compose.mariadb.yml exec
logs-watch:
	docker compose logs --follow
mysql-init:
	@make down
	@make mysql-up
	docker compose -f docker-compose.yml exec -T php bash -c "find . -path '*/.git' -prune -o -print0 | xargs -0 chown www-data:www-data"
	docker compose -f docker-compose.yml exec -T -e COMPOSER_PROCESS_TIMEOUT=600 php composer install
	docker compose -f docker-compose.yml exec -T php cp .env.mysql .env
	docker compose -f docker-compose.yml exec -T php php artisan key:generate
	docker compose -f docker-compose.yml exec -T php php artisan passport:key --force

mariadb-init:
	@make down
	@make mariadb-up
	docker compose -f docker-compose.yml exec -T php bash -c "find . -path '*/.git' -prune -o -print0 | xargs -0 chown www-data:www-data"
	docker compose -f docker-compose.yml exec -T -e COMPOSER_PROCESS_TIMEOUT=600 php composer install
	docker compose -f docker-compose.yml exec -T php cp .env.mariadb .env
	docker compose -f docker-compose.yml exec -T php php artisan key:generate
	docker compose -f docker-compose.yml exec -T php php artisan passport:key --force

sqlsrv-init:
	@make down
	@make sqlsrv-up
	@make ps
	@make logs
	sleep 30
	docker compose -f docker-compose.yml -f docker-compose.sqlsrv.yml run -T sqlsrv-create-db
	@make ps
	@make logs
	docker compose -f docker-compose.yml exec -T php bash -c "find . -path '*/.git' -prune -o -print0 | xargs -0 chown www-data:www-data"
	docker compose -f docker-compose.yml exec -T -e COMPOSER_PROCESS_TIMEOUT=600 php composer install
	docker compose -f docker-compose.yml exec -T php cp .env.sqlsrv .env
	docker compose -f docker-compose.yml exec -T php php artisan key:generate
	docker compose -f docker-compose.yml exec -T php php artisan passport:key --force

# --- Coverage targets -------------------------------------------------------
# COV_DIR: where per-suite *.cov dumps land (inside the container path).
COV_DIR=storage/logs/coverage
EXMENT_TESTS=./vendor/exceedone/exment/tests

# Run unit tests with --coverage-php so the merge step can pick them up.
test-coverage-unit:
	docker compose -f docker-compose.yml exec -T -e COMPOSER_PROCESS_TIMEOUT=0 php \
	  bash -c "mkdir -p $(COV_DIR) && php artisan exment:inittest --yes && php -d memory_limit=1024M vendor/bin/phpunit $(EXMENT_TESTS)/Unit --coverage-php $(COV_DIR)/unit.cov"

# Run feature tests with --coverage-php.
test-coverage-feature:
	docker compose -f docker-compose.yml exec -T -e COMPOSER_PROCESS_TIMEOUT=0 php \
	  bash -c "mkdir -p $(COV_DIR) && php artisan exment:inittest --yes && php -d memory_limit=1024M vendor/bin/phpunit $(EXMENT_TESTS)/Feature --coverage-php $(COV_DIR)/feature.cov"

# Merge .cov files and emit clover/html/text reports under $(COV_DIR)/merged/.
test-coverage-merge:
	docker compose -f docker-compose.yml exec -T php php -d memory_limit=2048M /usr/local/bin/merge-coverage.php

# One-shot: unit + feature + merge.
test-coverage:
	@make test-coverage-unit
	@make test-coverage-feature
	@make test-coverage-merge

# Browser tests segfault under PCOV; run them with pcov.enabled=0 and no coverage.
test-browser:
	docker compose -f docker-compose.yml exec -T -e COMPOSER_PROCESS_TIMEOUT=0 php \
	  bash -c "php artisan exment:inittest --yes && php -d pcov.enabled=0 vendor/bin/phpunit $(EXMENT_TESTS)/Browser --no-coverage"
