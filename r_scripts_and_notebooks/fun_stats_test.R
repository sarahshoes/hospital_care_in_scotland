stats_test <- function(smoothed_data){

# library for analysis
library(infer)
  
#calculate difference to create mvar
smoothed_data <- smoothed_data %>% 
  mutate(mvar = param - moving_avg) 

### Hypothesis Test
# Is summer is significantly different to winter?
#  
# The null hypothesis is that the average value for summer is the same or lower than the average # # # value for winter.
# H0 : mean winter - mean summer <= 0
# HA : mean winter - mean summer >0 
  
#calculate winter/summer stats
seasonal_avg <- smoothed_data  %>%
    group_by(iswinter) %>% 
    summarise(mean= mean(mvar, na.rm=TRUE))
  
observed_stat = seasonal_avg$mean[seasonal_avg$iswinter ==TRUE]
  -seasonal_avg$mean[seasonal_avg$iswinter ==FALSE]

#setup null distribution
null_distribution <- smoothed_data  %>%
    specify(response = mvar, explanatory = iswinter) %>%
    hypothesize(null = "independence") %>%
    generate(reps = 1000, type = "permute") %>%
    calculate(stat = "diff in means", order = c(TRUE,FALSE)) #winter - summer

#visualise - not needed in function
#null_distribution %>%
#    visualise(bins = 30) + 
#    shade_p_value(obs_stat = observed_stat
#                  , direction = "greater")

#extract p value and return it  
p_value <- null_distribution %>% 
    get_p_value(obs_stat = observed_stat
                , direction = "greater")


# If pvalue is less than alpha we can reject null hypothesis
#  if(p_value > alpha_test){
#    print("We cannot reject the null hypothesis. The average winter values in this data are the same as the #average summer values")
#  }else{
#    print("We can reject the null hypothesis in favour of the alternative hypothesis. The average winter #values in this data are significantly different to the average winter values")}

p_value 
  }