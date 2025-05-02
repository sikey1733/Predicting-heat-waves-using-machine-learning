# Подключение библиотек
library(zoo)
library(lubridate)
library(dplyr)
library(purrr)


# Подготовка данных для машинного обучения
weather_era5_ml <- weather_era5_clean %>% 
  rename(c("total_precipitation" = "tp",
           "solar_radiation_downwards" = "ssrd",
           "temperature_celsius" = "t2m",
           "soil_temperature_level_1" = "stl1",
           "surface_pressure" = "sp",
           "mean_sea_level_pressure" = "msl",
           "total_cloud_cover" = "tcc")) %>% 
  mutate(year = year(date),
         month = month(date),
         year_day = yday(date),
         day_week = wday(date),
         season = case_when(
           month %in% 3:5 ~ "Весна",
           month %in% 6:8 ~ "Лето",
           month %in% 9:11 ~ "Осень",
           TRUE ~ "Зима"
         ),
         temp_lag1 = lag(temperature_celsius, 1),
         temp_lag2 = lag(temperature_celsius, 2),
         temp_lag3 = lag(temperature_celsius, 3),
         
         temp_ma7 = rollmean(temperature_celsius, 7, fill = NA, align = "right"),
         temp_ma14 = rollmean(temperature_celsius, 14, fill = NA, align = "right"),
         
         target = lead(heatwave) %>% as.integer() %>% factor()
         ) %>%
  filter(!is.na(target)) %>% 
  select(-date, -heatwave, -heatwave_id)

# Проверка структуры, баланса классов и пропущенных значения
str(weather_era5_ml)
colSums(is.na(weather_era5_ml))
table(weather_era5_ml$target)