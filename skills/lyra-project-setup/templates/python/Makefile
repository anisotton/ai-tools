.PHONY: up down logs shell pip

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f {{SLUG}}-app

shell:
	docker compose exec {{SLUG}}-app bash

pip:
	docker compose exec {{SLUG}}-app pip $(filter-out $@,$(MAKECMDGOALS))

%:
	@:
