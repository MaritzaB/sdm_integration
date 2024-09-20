.PHONY: connection disconnection clean tests network

build:
	docker compose build

up_rstudio:
	docker compose up --build --detach
	@echo "Access R-Studio at: localhost:8787"
	docker compose exec r-studio bash -c "cd workdir && exec bash"


up_jupyter:
	docker compose up --build --detach
	docker compose exec niche-modelling bash -c "cd workdir && exec bash"

wallace:
	docker compose up --build --detach
	@echo "Access Wallace at: http://127.0.0.1:3333/sample-apps/SIG/wallace/shiny/"
	docker compose exec wallace bash -c "cd workdir && exec bash"

down:
	docker system prune --force
	docker compose down
	clear

connection:
	python3 connection/database_connection.py

disconnection:
	python3 connection/database_disconnection.py

clean:
	rm -rf maps/
	rm -rf model_dataset/
	clear

full_clean: clean
	rm --force -R data/

network:
	docker network create qgis_devtools_postgis_net
