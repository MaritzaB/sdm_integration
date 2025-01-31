# sdm_integration

## Lista de scripts con funciones utilizadas para el preprocesamiento de datos de distribución de especies.

1. `functions/process_raster_data.r`
1. `functions/process_occurrence_data.r`
1. `functions/generate_pseudo_absences.r`
1. `functions/balance_presence_absence.r`
1. `src/prepare_full_dataset.r`
1. `src/join_presence_absence.r`

Para ejecutar el flujo de trabajo completo se puede usar el siguiente comando:

```bash
$ make models
```

Los datos de presencia no están disponibles en el repositorio, pero deberían de
tener la siguiente estructura:

```csv
nyear,nmonth,longitude,latitude,phoebastria_immutabilis
2014,01,-121.19608,28.178852,1
2014,01,-123.930663,28.181968,1
2014,01,-123.929472,28.182598,1
2014,01,-123.928995,28.183552,1
```

Donde la columna `nyear` es el año de la observación, `nmonth` es el mes de la
observación. Las coordenadas de longitud y latitud son las coordenadas donde
estuvo presente la especie. La columna `phoebastria_immutabilis` es la columna
asociada a la presencia (1) o ausencia (0) de la especie. Inicialmente todos los
datos de presencia se encuentran en un solo archivo por lo que solo tendremos el
valor de 1 en la columna de presencia. Las ausencias se generan posteriormente
usando la técnica de _Surface range envelope_ (SRE).

# Species Distribution Modeling using different machine learning techniques.

Para ver las paqueterias de R instaladas en el sistema, se puede usar el siguiente comando:

```bash
Rscript -e 'installed.packages()'
Rscript -e 'installed.packages()[, "Package"]'
``` 

# Ejemplos de generación de pseudo-absences para modelos de distribución de especies.

1. [https://damariszurell.github.io/EEC-MGC/b5_pseudoabsence.html](https://damariszurell.github.io/EEC-MGC/b5_pseudoabsence.html)
1. [https://rspatial.org/sdm/3_sdm_absence-background.html](https://rspatial.org/sdm/3_sdm_absence-background.html)
1. [https://kevintshoemaker.github.io/NRES-746/SDM_v6.html](https://kevintshoemaker.github.io/NRES-746/SDM_v6.html)
1. [https://cran.r-project.org/web/packages/biomod2/vignettes/vignette_pseudoAbsences.html](https://cran.r-project.org/web/packages/biomod2/vignettes/vignette_pseudoAbsences.html)
1. [https://biomodhub.github.io/biomod2/articles/vignette_pseudoAbsences.html#:~:text=Pseudo%2Dabsences%20(sometimes%20also%20referred,presences)%20against%20what%20is%20available.](https://biomodhub.github.io/biomod2/articles/vignette_pseudoAbsences.html#:~:text=Pseudo%2Dabsences%20(sometimes%20also%20referred,presences)%20against%20what%20is%20available.)
1. [Tutorial
   Biomod2](https://cran.r-project.org/web/packages/biomod2/biomod2.pdf)
1. [Ejemplo de un vatito en Youtube](https://www.youtube.com/watch?v=QrwqhJgRbnY)
