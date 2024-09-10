.PHONY: connection disconnection clean tests network

build:
	docker compose build

up_rstudio:
	docker compose up --build --detach
	docker compose exec r-studio bash -c "cd workdir && exec bash"

up_jupyter:
	docker compose up --build --detach
	docker compose exec niche-modelling bash -c "cd workdir && exec bash"



down:
	docker system prune --force
	docker compose down
	clear

connection:
	python3 connection/database_connection.py

disconnection:
	python3 connection/database_disconnection.py

clean:
	rm --force -R data/
	clear

network:
	docker network create qgis_devtools_postgis_net
