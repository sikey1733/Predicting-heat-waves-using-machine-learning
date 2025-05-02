# Подключение библиотек
library(ecmwfr)

# Параметры для: Чувашии
request_year <- list(
  dataset_short_name = "reanalysis-era5-single-levels",
  product_type = "reanalysis",
  variable = c(
    "10m_u_component_of_wind",
    "10m_v_component_of_wind",
    "2m_temperature",
    "mean_sea_level_pressure",
    "sea_surface_temperature",
    "surface_pressure",
    "total_precipitation",
    "surface_solar_radiation_downwards",
    "total_cloud_cover",
    "soil_temperature_level_1"
  ),
  year = as.character(2010:2014),
  month = sprintf("%02d", 1:12),  
  day = sprintf("%02d", 1:31),    
  time = "12:00",
  area = c(56.5, 46, 54.5, 48.5), 
  format = "netcdf",
  target = "era5_data.nc"
)

# Отправка запроса 
wf_request(request = request, user = "sikey21rus")