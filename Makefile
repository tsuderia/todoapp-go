include .env
export

export container_db = todoapp-postgres
export LOCAL_PATH = $(shell pwd)
 

db-up:
	@docker compose up -d ${container_db}

db-down:
	@docker compose down ${container_db}

db-cleanup:
	@stop &&
	rm -rf /out/pgdata