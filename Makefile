all: run-daemon

.PHONY: maintenance
maintenance:
	@echo "> improving database..."
	docker-compose exec -u 33 app php -f /var/www/html/occ db:convert-filecache-bigint -n -v
	docker-compose exec -u 33 app php -f /var/www/html/occ db:convert-mysql-charset -n -v
	docker-compose exec -u 33 app php -f /var/www/html/occ db:add-missing-indices -n -v
	@echo "> done!"

.PHONY: run-daemon
run-daemon:
	@echo "> running as daemon..."
	docker-compose up -d

.PHONY: run-foreground
run-foreground:
	@echo "> running in foreground..."
	-docker-compose up

.PHONY: update
update:
	@echo "> pulling new images..."
	docker-compose pull
	@echo "> re-deploying containers with updated images..."
	docker-compose up -d
	@echo "> done!"

.PHONY: stop
stop:
	@echo "> stopping containers..."
	docker-compose down
	@echo "> done!"

backup:
	@echo "> compressing files!"
	@sudo tar --exclude='./backups' -cpzf "./backups/$(shell date '+%Y-%m-%d_%H-%M-%S').tar.gz" .
	@echo "> done!"

.PHONY: clean
clean:
	@echo "> shutting down..."
	docker-compose down
	@echo "> removing persistent data..."
	@sudo rm -rf ./data/* ./backups/*
	@echo "> done!"
