
source(here::here("palette_theme/define_theme.R"))
source(here::here("palette_theme/plot_timeseries.R"))
source(here::here("palette_theme/plot_timeseriesv2.R"))
palette = read_csv(here::here("palette_theme/phs_palette.csv"))


bed_occupancy <- read_csv(here::here("clean_data/bed_occupancy_clean.csv"))


plotdata <- bed_occupancy %>%
  filter(specialty_name == "All Acute") %>%
  filter(hb_name == "All Scotland") %>% 
  filter(location_qf == "d")
plotmapping <- aes(x = made_date, y = percentage_occupancy)
plottitle <- ("Hospital bed occupancy")
plotylabel <- ("% occupancy")
timeseriesplot(plotdata,plotmapping,plottitle,plotylabel) +
  geom_hline(yintercept = 85, colour = "#651C32", linetype = "dashed") + 
  annotate(geom = "label", x = as.Date("2022-08-01"), y = 85, 
           label = "85% Risk Threshold", colour = "#651C32", fill = "white",
           alpha = 0.8)

# Can get current status from this table
current_status <- bed_occupancy %>%
  filter(specialty_name == "All Acute") %>%
  filter(hb_name == "All Scotland") %>% 
  filter(location_qf == "d")

# avg bed occ for all scotland 2018 and 2019
bed_oc_avg1819 <- bed_occupancy %>%
  filter(specialty_name == "All Acute") %>%
  filter(hb_name == "All Scotland") %>% 
  filter(location_qf == "d") %>% 
  filter(quarter %in% c("2018Q1", "2018Q2", "2018Q3", "2018Q4", "2019Q1", 
                        "2019Q2", "2019Q3", "2019Q4")) %>% 
  summarise(percent_occ_avg_1819 = mean(percentage_occupancy))

# current bed occ by health board
current_bed_occ_by_hb <- bed_occupancy %>%
  filter(specialty_name == "All Acute") %>%
  #  filter(hb_name == "All Scotland") %>% 
  filter(location_qf == "d") %>% 
  filter(quarter == "2022Q2") %>% 
  select(hb, hb_name, percentage_occupancy)
