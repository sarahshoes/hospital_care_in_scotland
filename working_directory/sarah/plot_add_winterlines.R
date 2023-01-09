#rscript that adds vertical lines
geom_vline(xintercept=ymd(20201001),color="gray",linetype="dotted", size = 1) +   
geom_vline(xintercept=ymd(20211001),color="gray",linetype="dotted", size = 1) + 
geom_vline(xintercept=ymd(20221001),color="gray",linetype="dotted", size = 1 ) + 
geom_vline(xintercept=ymd(20200401),color="gray",linetype="dotted", size = 1) + 
geom_vline(xintercept=ymd(20210401),color="gray",linetype="dotted", size = 1) + 
geom_vline(xintercept=ymd(20220401),color="gray",linetype="dotted", size = 1)  