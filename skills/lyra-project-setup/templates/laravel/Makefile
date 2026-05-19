.PHONY: up down logs shell artisan migrate fresh seed composer

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f {{SLUG}}-app

shell:
	docker compose exec {{SLUG}}-app bash

artisan:
	docker compose exec {{SLUG}}-app php artisan $(filter-out $@,$(MAKECMDGOALS))

migrate:
	docker compose exec {{SLUG}}-app php artisan migrate

fresh:
	docker compose exec {{SLUG}}-app php artisan migrate:fresh --seed

seed:
	docker compose exec {{SLUG}}-app php artisan db:seed

composer:
	docker compose exec {{SLUG}}-app composer $(filter-out $@,$(MAKECMDGOALS))

%:
	@:
