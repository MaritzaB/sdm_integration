build:
	docker compose build

up:
	docker compose up --build --detach
	docker compose exec r-studio bash -c "cd /home/rstudio/src && exec bash"

down:
	docker compose down

connection:
	python3 src/database_connection.py

disconnection:
	python3 src/database_disconnection.py

clean:
	rm --force -R src/__pycache__/
	rm --force -R images/*.png
	rm --force -R src/notebooks/__pycache__/
	rm --force -R tests/__pycache__
	rm --force -R __pycache__
	rm src/data/*/*/processed/*.aux.xml
	clear

tests:
	pytest --verbose tests/test_sample_raster_data.py

network:
	docker network create qgis_devtools_postgis_net