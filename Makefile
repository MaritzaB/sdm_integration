.PHONY: connection disconnection clean tests network absence_4var_extraction

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
	rm -rf model_dataset_2vars/
	rm -rf model_dataset_4vars/
	rm -rf presence_absence_2vars/
	rm -rf presence_absence_4vars/
	clear

clean_models:
	rm -rf Phoebastria.Immutabilis/

full_clean: clean
	rm --force -R data/
	rm -rf presence_data_2v/
	rm -rf presence_data_4v/

network:
	docker network create qgis_devtools_postgis_net

presence_2var_extraction:
	Rscript src/prepare_full_dataset.R "presence" 2

presence_4var_extraction:
	Rscript src/prepare_full_dataset.R "presence" 4

absence_2var_extraction:
	Rscript src/prepare_full_dataset.R "absence" 2

absence_4var_extraction:
	Rscript src/prepare_full_dataset.R "absence" 4

presence_absence_2vars: absence_2var_extraction
	Rscript src/join_presence_absence.R 2

presence_absence_4vars: absence_4var_extraction
	Rscript src/join_presence_absence.R 4
