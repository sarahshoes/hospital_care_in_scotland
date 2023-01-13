#rscript for the function that creates a standard plot

#this function defines the plot

timeseriesplot_z <- function(plotdata,plotmapping,plottitle,plotylabel){
  plotlim <- as.Date(c("2020-01-01","2022-12-31")) 
  ggplot(plotdata,plotmapping) +
    geom_line() + 
    #add zero line
    geom_hline(yintercept = 0, colour = palette$mycolours[8], linetype = "dashed") + 
    # add dashed lines to show the boundaries 
    geom_vline(xintercept=ymd(20201001),color="gray",linetype="dotted", linewidth = 0.5) +                                   geom_vline(xintercept=ymd(20211001),color="gray",linetype="dotted", linewidth = 0.5) + 
    geom_vline(xintercept=ymd(20221001),color="gray",linetype="dotted", linewidth = 0.5) + 
    geom_vline(xintercept=ymd(20200401),color="gray",linetype="dotted", linewidth = 0.5) + 
    geom_vline(xintercept=ymd(20210401),color="gray",linetype="dotted", linewidth = 0.5) + 
    geom_vline(xintercept=ymd(20220401),color="gray",linetype="dotted", linewidth = 0.5) +
    scale_x_date(limits=plotlim, date_breaks="3 month", labels = scales::label_date_short(), expand = c(0,0)) +
    # SH removed this as think we need a little space 
    #scale_y_continuous(expand = c(0,0)) +
    scale_colour_manual(values = palette$mycolours) + 
    xlab("Date") +   
    ylab(plotylabel) +
    ggtitle(plottitle) +  
    theme_phs +
    #add rectangles to denote winter
    annotate("rect", 
             xmin=c(ymd(plotlim[1]),ymd(20201001),ymd(20211001),ymd(20221001)),
             xmax=c(ymd(20200401),ymd(20210401),ymd(20220401),plotlim[2]), 
             ymin=c(-Inf,-Inf,-Inf,-Inf), 
             ymax=c(Inf,Inf,Inf,Inf), 
             alpha=0.1, fill="gray")
   
}

