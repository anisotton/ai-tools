.PHONY: up down logs shell install npm

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f {{SLUG}}-app

shell:
	docker compose exec {{SLUG}}-app sh

install:
	docker compose exec {{SLUG}}-app npm install

npm:
	docker compose exec {{SLUG}}-app npm $(filter-out $@,$(MAKECMDGOALS))

%:
	@:
