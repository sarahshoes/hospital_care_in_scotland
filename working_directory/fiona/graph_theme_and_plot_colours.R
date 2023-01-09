theme_nhs <- function(){
  
  theme_minimal() %+replace%   
    
    theme(
      axis.line = element_line(colour = "grey50"),
      axis.ticks = element_line(colour = "grey50"),
      plot.title = element_text(size = 16, 
                                face = "bold", 
                                colour = "grey30",
                                margin = margin(b = 12),
                                hjust = 0),
      plot.subtitle = element_text(size = 14,  
                                   colour = "grey30",
                                   margin = margin(b = 12),
                                   hjust = 0),
      axis.title = element_text(size = 12, 
                                face = "bold", 
                                colour = "grey30"),
      axis.title.x = element_text(margin = margin(t = 12)),
      # changing the margin on y-axis causes it to flip to horizontal   
      # axis.title.y = element_text(margin = margin(b = 12)),
      axis.text = element_text(size = 11, 
                               colour = "grey30"),
      legend.title = element_blank(),
      legend.text = element_text(size = 11, 
                                 colour = "grey30")
    )
}

plot_colours <- c("#446e9b", "#999999", "#3cb521", "#d47500", "#cd0200", "#3399f3",
                           "#333333", "#6610f2", "yellow", "brown", "peachpuff", "#6f42c1",
                           "#e83e8c", "#fd7e14", "#20c997", "#000000", "grey50", "#eeeeee")