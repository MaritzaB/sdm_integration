source("src/create_model.R")
source("src/load_model.R")


#seasons <- c('incubacion', 'empollamiento', 'crianza')
nvariables <- c(2, 4)
seasons <- c('incubacion')


for (season in seasons) {
    for (n_vars in nvariables) {
      #create_biomod_model(season, n_vars)
      #get_model_evaluations(season, n_vars)
      project_model(season, n_vars)
    }
}

