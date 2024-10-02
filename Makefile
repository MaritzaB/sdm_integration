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

clean_models:
	rm -rf Phoebastria.Immutabilis/

full_clean: clean
	rm --force -R data/

network:
	docker network create qgis_devtools_postgis_net

# Si queremos hacer la extracción de todas las variables o solo de 2 variables,
# debemos de indicarlo dentro del script de R, modificando la variable
# number_of_variables <- 2 (sst y chlc) o number_of_variables <- 4 (sst, chlc,
# wind_speed y wind_direction)
presence_var_extraction:
	Rscript src/prepare_full_dataset.R "presence"