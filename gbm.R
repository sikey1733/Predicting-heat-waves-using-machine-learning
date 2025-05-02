# Подключение библиотек
library(h2o)

# Запуск кластера
h2o.init()

# Преобразование в обьект h2o
weather_h2o <- as.h2o(weather_era5_ml)

# Проверка баланса классов
h2o.table(train[,y])

y = "target"
x = setdiff(names(weather_era5_ml), y)

# Разделение
parts <- h2o.splitFrame(weather_h2o, ratios = 0.8, seed = 35)
train <- parts[[1]]
test <- parts[[2]]

# Обучение модели
m <- h2o.gbm(
  x = x, 
  y = y, 
  training_frame = train,
  nfolds = 10,
  model_id = "GBM_defaults",
  balance_classes = TRUE,
  class_sampling_factors = c(1, 8),
  ntrees = 30,
  max_depth = 3,
  min_rows = 20,
  sample_rate = 0.7,
  col_sample_rate = 0.8,
  stopping_rounds = 5,             
  stopping_metric = "AUC"
)


# Важность предикторов
h2o.varimp(m)

# Проверка качества модели
h2o.performance(m, test)