library(tidyverse)
library(scales)

data <- read_csv("clean_data/summary_tab_map_data.csv")

data_ae <- data %>%
  filter(metric == "A&E % Treated in 4 h") %>% 
  mutate(scaled_value = rescale(value, to = c(2, 20)))

data_bed <- data %>%
  filter(metric == "Bed Occupancy (%)") %>% 
  mutate(scaled_value = rescale(value, to = c(2, 20)))

data <- rbind(data_ae, data_bed)

write_csv(data, "clean_data/summary_tab_map_data.csv")
