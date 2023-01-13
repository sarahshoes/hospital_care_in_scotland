library(tidyverse)
library(scales)

data <- read_csv("clean_data/summary_tab_map_data.csv")

data_ae <- data %>%
  filter(metric == "A&E Attendances Waiting < 4h") %>% 
  mutate(scaled_value = rescale(value, to = c(2, 30)))

data_bed <- data %>%
  filter(metric == "Bed Occupancy (%)") %>% 
  mutate(scaled_value = rescale(value, to = c(2, 30)))

data_delay_discharge <- data %>% 
  filter(metric == "Delayed Discharge Bed Occupancy (%)") %>% 
  mutate(scaled_value = rescale(value, to = c(2, 30)))

data <- rbind(data_ae, data_bed, data_delay_discharge)

write_csv(data, "clean_data/summary_tab_map_data.csv")
