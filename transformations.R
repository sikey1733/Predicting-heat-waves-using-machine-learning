# Подключение библиотек
library(ncdf4)
library(dplyr)
library(purrr)

# Загрузка 1 файла
data_open_1 <- read_stars("data/data_stream-enda_stepType-instant.nc")

# Трансформация
data_cheb_transform <- as.data.frame(data_open_1) %>%
  mutate(
    valid_time = as.Date(as.POSIXct(valid_time, origin = "1970-01-01", tz = "UTC")),   # датавремя
    t2m = as.numeric(t2m) - 273.15,   # °C
    stl1 = as.numeric(stl1) - 273.15,   # °C
    sp = as.numeric(sp) / 100,   # гПа
    msl = as.numeric(msl) / 100, # гПа
    u10 = round(as.numeric(u10), 1),   # м/c
    v10 = round(as.numeric(v10), 1),   # м/c
    tcc = round(as.numeric(tcc) * 100, 2), # %
    wind_speed = round(sqrt(as.numeric(u10)^2 + as.numeric(v10)^2), 1),   # скорость ветра
    wind_dir = atan2(as.numeric(u10), as.numeric(v10)) * 180/pi + 180,    # направление в градусах
    pressure_anomaly = round(as.numeric(sp) - 1013.25, 1) # аномалии  
) %>% 
  select(-sst)


# Загрузка 2 файла
data_open_2 <- read_stars("data/data_stream-enda_stepType-accum.nc")

# Трансформация
data_cheb_transform_1 <- as.data.frame(data_open_2) %>%
  mutate(
    valid_time = as.Date(as.POSIXct(valid_time, origin = "1970-01-01", tz = "UTC")),   # датавремя
    tp = round(as.numeric(tp) * 1000, 2),   # мм
    ssrd = as.numeric(ssrd) / 1000,   # кДж/м² 
  ) 
  


# Проверка на совпадение сеток
all(data_cheb_transform$x == data_cheb_transform_1$x)
all(data_cheb_transform$y == data_cheb_transform_1$y)
all(data_cheb_transform$valid_time == data_cheb_transform_1$valid_time)


# Обьединение в один датафрейм
data_join <- full_join(data_cheb_transform,
                       data_cheb_transform_1,
                       by = c("x", "y", "valid_time"))

# Проверка структуры
str(data_join)

# Сохранение
write.csv(data_join, "weather_data_cheb.csv", , row.names = FALSE)