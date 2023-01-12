library(tidyverse)

metric <- c("A&E Waiting Times % < 4 h (Target 85%)", "B", "C")

avg201819 <- c("92.8", "xx", "yy")

current_status <- c("77.2", "xxxx", "yyyy")

summary_tab_data <- as.data.frame(metric)

summary_tab_data <- cbind(summary_tab_data, avg201819, current_status)


write_csv(summary_tab_data, here::here("clean_data/summary_tab_table_data.csv"))
