data_smoother <- function(date,data,indicator){
  
  #define smoothing period
  if (indicator == "weekly"){
      sm=12
  }else{
      sm=3
  }

library(slider)
  
data_rolling <- weekly_admissions_spec %>% 
    filter(wdate > as.Date("2020-05-01")) %>% 
    filter(speciality == "All") %>% 
    filter(admission_type == "All") %>% 
    filter(hb_name =="All Scotland") %>%  
    mutate(
      moving_avg = slide_dbl(
        .x = number_admissions, 
        .f = ~ mean(., na.rm = TRUE),
        .before = 12,
        .after = 12,
        .complete = FALSE
      )
    )

}