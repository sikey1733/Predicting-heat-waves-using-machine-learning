# Подключение библиотек
library(dplyr)
library(lubridate)
library(ggplot2)

# Загрузка данных 
weather_cheb_era5 <- read.csv("weather_data_cheb.csv")

# Проверка структуры и пропущеных значений
str(weather_cheb_era5)
colSums(is.na(weather_cheb_era5))

# Группировка и усреднение
weather_era5 <- weather_cheb_era5 %>%
  mutate(date = as.Date(valid_time)) %>%
  select(-u10, -v10, -valid_time) %>%
  group_by(date) %>% 
  summarise(across(c(tp, ssrd, t2m, stl1,
                     sp, msl, tcc, wind_speed, wind_dir,
                     pressure_anomaly), mean)) %>% 
  mutate(tp = round(tp, 2))

# Проверка структуры
str(weather_era5)

# Расчет 95-перцентель температуры
threshold_temp <- quantile(weather_era5$t2m, 0.95, na.rm = TRUE)

# Идентификация волн жары
identify_heatwaves <- function(temp_series, threshold, min_duration = 3) {
  runs <- rle(temp_series > threshold)
  heatwave_positions <- which(runs$values == TRUE & runs$lengths >= min_duration)
  
  heatwave_days <- rep(FALSE, length(temp_series))
  pos <- 1
  for (i in heatwave_positions) {
    start <- sum(runs$lengths[1:(i-1)]) + 1
    end <- start + runs$lengths[i] - 1
    heatwave_days[start:end] <- TRUE
    pos <- end + 1
  }
  return(heatwave_days)
}

# Добавление меток волн жары
weather_era5_clean <- weather_era5 %>% 
  mutate(
    heatwave = identify_heatwaves(t2m, threshold_temp),
    heatwave_id = cumsum(heatwave & !lag(heatwave, default = FALSE))
  )

# Проверка
str(weather_era5_clean)

# График температуры с выделением волн жары
ggplot(data = weather_era5_clean,
       aes(x = date, y = t2m)) +
  geom_line(color = "gray") +
  geom_point(data = filter(weather_era5_clean, heatwave),
             aes(color = "Волны жары"), size = 1) +
  geom_text(aes(x = min(date),
                y = threshold_temp, 
                label = paste("Порог:", round(threshold_temp,1),"°C")),
                hjust = 0.2,
                vjust = 1.2,
                color = "red",
                size = 3.5) +
  geom_hline(yintercept = threshold_temp,
             linetype = "dashed",
             color = "red") +
  geom_vline(data = filter(weather_era5_clean,
             month(date) == 8,
             day(date) == 1,
             year(date) == 2010),
             aes(xintercept = date),
             linetype = "dashed",
             color = "red",
             size = 0.3) +
  scale_x_date(date_breaks = "2 month",
               date_labels = "%b\n%Y",
               minor_breaks = "1 month") +
  labs(title = "Дневная температура в Чувашии",
       y = "Температура (°C)", x = "Дата",
       color = "") +
  scale_color_manual(values = "red") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 8, angle = 45, vjust = 0.5)  
  )

# Распределение температуры
ggplot(weather_era5_clean, aes(x = t2m)) +
  geom_density(fill = "gray", alpha = 0.5) +
  geom_vline(xintercept = threshold_temp,
             linetype = "dashed",
             color = "red",
             linewidth = 0.3) +
  geom_text(aes(x = threshold_temp + 2,  
                y = 0.05,               
                label = paste("Порог:", round(threshold_temp, 1), "°C")),
                color = "red",
                size = 3.5,
                hjust = 0) +  
  scale_x_continuous(
    breaks = seq(-30, 40, by = 5),
    limits = c(-30, 40)) +
  labs(title = "Распределение температуры",
       x = "Температура (°C)", 
       y = "Плотность") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5)) 



