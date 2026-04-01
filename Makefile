include .env
export

export container_db=todoapp-postgres
export container_migrate=todoapp-migrate
export container_port=port-forwarder
export LOCAL_PATH=$(shell pwd)

db-up:
	@docker compose up -d ${container_db}

db-down:
	@docker compose down ${container_db}

db-cleanup:
	@read -p "Do you really want to clean up environment files? [y/N]: " ans; \
	if [ "$$ans" = "y" ]; then \
		$(MAKE) db-down && \
		rm -rf ./out/pgdata && \
		echo "Operation completed successfully !"; \
	else \
		echo "Operation cancelled."; \
	fi

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Please, specify the seq parameter. For example: make migrate seq=yourtexthere" ; \
		exit 1; \
	else \
		docker compose run --rm ${container_migrate} \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)" ;\
	fi

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Please, specify the action you want to do [up/down]" ; \
		exit 1; \
	else \
		docker compose run --rm ${container_migrate} \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${container_db}:5432/${POSTGRES_DB}?sslmode=disable \
		"${action}" ; \
	fi

migrate-up:
	@$(MAKE) migrate-action action=up
migrate-down:
	@$(MAKE) migrate-action action=down

port-forward:
	@docker compose up -d ${container_port}

port-close:
	@docker compose down ${container_port}

todoapp-run:
	@go run cmd/todoapp/main.go