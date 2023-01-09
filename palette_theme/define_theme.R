# This script will setup a standard theme for all plots

#defines a standard theme to apply to plots
#change theme elements here
theme_phs <- 
  theme(
    text = element_text(size = 14),
    title = element_text(size = 14),
    axis.text = element_text(size = 14),
    legend.text = element_text(size = 12),
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background = element_rect(fill = "transparent", colour = NA),
    legend.background = element_rect(fill = "transparent", colour = NA),
    legend.box.background = element_rect(fill = "transparent", colour = NA),
    panel.grid = element_line(colour = "gray90", linetype = "dashed"),
    legend.position = "bottom"
  )

#example code chunk to add annotations to all plots - not quite sure yet how to put this into a theme?
#maybe I can define a function?

#```{r}
#plotlim <- as.Date(c("2020-01-01","2022-12-31")) 
#p <-  ggplot(
#  weekly_admissions_spec %>% 
#    filter(speciality == "All") %>% 
#    filter(admission_type == "All") %>% 
#    filter(hb_name =="All Scotland")  
#) +
#  aes(x=wdate, y = number_admissions) +
#  geom_line(color = palette$colours[2]) +    
#  #add dashed lines to show the boundaries 
#  geom_vline(xintercept=ymd(20201001),color="gray",linetype="dotted", size = 1) +   
#  geom_vline(xintercept=ymd(20211001),color="gray",linetype="dotted", size = 1) + 
#  geom_vline(xintercept=ymd(20221001),color="gray",linetype="dotted", size = 1 ) + 
#  geom_vline(xintercept=ymd(20200401),color="gray",linetype="dotted", size = 1) + 
#  geom_vline(xintercept=ymd(20210401),color="gray",linetype="dotted", size = 1) + 
#  geom_vline(xintercept=ymd(20220401),color="gray",linetype="dotted", size = 1) + 
#  scale_x_date(limits=plotlim, date_breaks="3 month", labels = scales::label_date_short(), expand = c(0,0.01)) +
#  scale_y_continuous(expand = c(0,0)) +
#  xlab("Date") +   
#  ylab("Hospital Admissions with Covid") +
#  theme_phs 
#p
#extract ylimits from plot
#ylimits = layer_scales(p)$y$get_limits()
#xlimits = layer_scales(p)$x$get_limits()
#add gray shaded rectangles to note winter
#p + annotate("rect", xmin=c(ymd(plotlim[1]),ymd(20201001),ymd(20211001),ymd(20221001)), 
#             xmax=c(ymd(20200401),ymd(20210401),ymd(20220401),plotlim[2]), 
#             ymin=c(ylimits[1],ylimits[1],ylimits[1],ylimits[1]), 
#             ymax=c(ylimits[2]*1.01,ylimits[2],ylimits[2],ylimits[2]), 
#             alpha=0.1, fill=palette$colours[4]) 
#```