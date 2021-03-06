#library('latex2exp')
library(ggplot2)
library(grid)
source("dateFormatRoutines.r")

plotSplineDerivative<- function(spline.table, outputpath) {
  p_spline_d1 <- ggplot(data=spline.table, aes(x=t, y=value)) +
    #geom_point(aes(tt.df[,1], d1_gam), alpha=0.5, size=2) +
    geom_line(color="red", size = 2, alpha=0.7)+
    xlab("") +
    ylab(expression(paste("derivative of est.", theta))) +
    theme(axis.text = element_text(size=14),
          axis.title = element_text(size=14,face="bold"),
          legend.text = element_text(size=12),
          legend.title = element_text(size=12, face="bold"))

  outputFile = paste0(outputpath, "/esti_theta_derivSplineFit.pdf")
  ggsave(p_spline_d1,
         height = 8,
         width = 16,
         dpi = 220,
         device = "pdf",
         file = outputFile)
}

plotRatio <- function(ratios, outputFile) {
  data <- data.frame(t=seq(from = 0, to = length(ratios)-1,by=1),x=ratios)
  plot_r <- ggplot(data=data, aes(x=t,y=ratios)) +
    geom_line(color="blue", size=2, alpha=0.7)+
    xlab("") +
    ylab("ratio")
  ggsave(plot_r,
         height = 8,
         width = 16,
         dpi = 220,
         device = "pdf",
         file = outputFile)
}

# plotRatioThetaVsCases <- function(spline.table){
#   minX <- min(spline.table$value_trueN)
#   maxX <- max(spline.table$value_trueN)
#   minY <- min(spline.table$value)
#   maxY <- max(spline.table$value)
#   minDate <-
#
#   casesRescaled <- rescale(spline.table$value_trueN, minX, maxX, minY, maxY)
#
#   ratio <- spline.table$value/casesRescaled
#
#   theta_01 <- (spline.table$value- min(spline.table$value))/max(spline.table$value -  min(spline.table$value)) +0.5
#   cases_01 <- (spline.table$value_trueN- min(spline.table$value_trueN))/max(spline.table$value_trueN -  min(spline.table$value_trueN)) +0.5
#
#   ratio = (theta_01 -cases_01)/theta_01
#   ratio <- theta_01/cases_01
#   ggplot() +
#     geom_line(aes(x=day.as.Date(spline.table$t, )[ratio != -Inf], y=ratio[ratio != -Inf]))
#
#
# }

rescale <- function(x, minX, maxX, minY, maxY) {
  return((maxY-minY)*(x - minX)/(maxX-minX) + minY)
}

plotSplineWithNewCases <-function(data.table, input.table, spline.table, outputFile, minDate) {
  
  minX <- max(min(data.table$new_cases),0)
  maxX <- max(data.table$new_cases)
  minY <- max(min(spline.table$value),0)
  maxY <- max(spline.table$value)
  ylimMax <- max(data.table$new_cases)
  mycolors <- c("estid"="darkblue", "trued"="darkred","esti"="blue", "true"="red")
  p_spline_esti_realN <- ggplot() +
    #geom_point(aes(doy.as.Date(data.table$doy), data.table$trueN*rel_vs_true_ratio), size=2, color=mycolors["trued"], alpha=0.5)+
    geom_line(aes(days.as.Date(data.table$t, minDate), rescale(data.table$new_cases, minX, maxX, minY, maxY)),size=2, color=mycolors["trued"], alpha=0.5)+
    geom_point(aes(x=days.as.Date(input.table$t, minDate), y=input.table$value), colour=mycolors["esti"], size=input.table$pointSize, alpha=0.3)+
    #geom_line(aes(x=doy.as.Date(spline.table$doy), y=spline.table$value_trueN*rel_vs_true_ratio), color=mycolors["true"], size = 2, alpha=0.5)+
    #geom_line(aes(x=days.as.Date(spline.table$t, minDate), y=rescale(spline.table$value_trueN, minX, maxX, minY, maxY)), color=mycolors["true"], size = 2, alpha=0.5)+
    geom_line(aes(x=days.as.Date(spline.table$t, minDate), y=spline.table$value), color=mycolors["esti"], size = 2, alpha=0.5)+
    scale_size_continuous(range = c(min(data.table$pointSize), max(data.table$pointSize))) +
    scale_y_continuous(
      expression(paste(theta[est])),
      #sec.axis = sec_axis(~ . * 1/rel_vs_true_ratio, name = "new cases")
      sec.axis = sec_axis(~ rescale(., minY, maxY, minX, maxX ), name = "new reported cases\n")) +
    xlab("")+
    #coord_cartesian(xlim=c(minDate, maxDate),ylim=c(0,ylimMax)) +
    scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
    theme(
      axis.text.x=element_text(angle = 0, vjust = 1, hjust=0),
      axis.title.y = element_text(color = mycolors["estid"]),
      axis.text.y = element_text(color = mycolors["estid"]),
      axis.title.y.right = element_text(color = mycolors["trued"]),
      axis.text.y.right = element_text(color = mycolors["trued"]),
      axis.text = element_text(size=12),
      axis.title = element_text(size=12),
      legend.text = element_text(size=11),
      legend.title = element_text(size=13, face="bold"),
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      panel.background = element_blank(), axis.line = element_line(colour = "black")
    )

  ggsave(p_spline_esti_realN,
           height = 8,
           width = 16,
           dpi = 220,
           device = "pdf",
           file = outputFile)
}

plotSplineWithNewCasesSE <-function(data.table, spline.table, outputFile_trueNSE) {

  minX <- max(min(spline.table$value_trueN),0)
  maxX <- max(spline.table$value_trueN)
  minY <- max(min(spline.table$value),0)
  maxY <- max(spline.table$value)
  ylimMax <- max(data.table$value)
  minDate <- min(as.Date(data.table$meanBinDate))
  maxDate <- max(days.as.Date(spline.table$t, minDate))

  mycolors <- c("estid"="darkblue", "trued"="darkred","esti"="blue", "true"="red")
  rel_vs_true_ratio = max(spline.table$value)/max(spline.table$value_trueN)
  p_spline_esti_realN <- ggplot() +
    #geom_point(aes(doy.as.Date(data.table$doy), data.table$trueN*rel_vs_true_ratio), size=2, color=mycolors["trued"], alpha=0.5)+
    #geom_line(aes(x=doy.as.Date(spline.table$doy), y=spline.table$value_trueN*rel_vs_true_ratio), color=mycolors["true"], size = 2, alpha=0.5)+
    geom_line(aes(x=days.as.Date(spline.table$t, minDate), y=rescale(spline.table$value_trueN, minX, maxX, minY, maxY)), color=mycolors["true"], size = 2, alpha=0.5)+
    geom_ribbon(aes(x=days.as.Date(spline.table$t, minDate), ymin = spline.table$lower, ymax = spline.table$upper), fill = "grey70",alpha=0.5) +
    geom_line(aes(x=days.as.Date(spline.table$t, minDate), y=spline.table$value), color=mycolors["esti"], size = 2, alpha=0.5) +
    scale_y_continuous(
      expression(paste(theta[est],"\\",Delta,"t","\n")),
      #sec.axis = sec_axis(~ . * 1/rel_vs_true_ratio, name = "new cases")
      sec.axis = sec_axis(~ rescale(., 0, maxY, 0, maxX ), name = "new reported cases\n")) +
    xlab("")+
    coord_cartesian(xlim=c(minDate, maxDate),ylim=c(0,ylimMax)) +
    scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
    theme(
      axis.text.x=element_text(angle = 0, vjust = 1, hjust=0),
      axis.title.y = element_text(color = mycolors["estid"]),
      axis.text.y = element_text(color = mycolors["estid"]),
      axis.title.y.right = element_text(color = mycolors["trued"]),
      axis.text.y.right = element_text(color = mycolors["trued"]),
      axis.text = element_text(size=12),
      axis.title = element_text(size=12),
      legend.text = element_text(size=11),
      legend.title = element_text(size=13, face="bold"),
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      panel.background = element_blank(), axis.line = element_line(colour = "black")
    )

  ggsave(p_spline_esti_realN,
           height = 8,
           width = 16,
           dpi = 220,
           device = "pdf",
           file = outputFile)
}

plotCummulativeSampleSize <- function(data.table,outputFile) {
  minDate <- min(as.Date(data.table$meanBinDate))
  mycolors <- c("estid"="darkred", "trued"="darkblue","esti"="red", "true"="blue")
  p_sample_size <- ggplot() +
    #geom_point(aes(doy.as.Date(data.table$doy), data.table$trueN*rel_vs_true_ratio), size=2, color=mycolors["trued"], alpha=0.5)+
    geom_line(aes(days.as.Date(data.table$t, minDate), cumsum(data.table$sampleSize)),size=2, color=mycolors["trued"], alpha=0.5)+
    #geom_line(aes(x=doy.as.Date(spline.table$doy), y=spline.table$value_trueN*rel_vs_true_ratio), color=mycolors["true"], size = 2, alpha=0.5)+
    scale_y_continuous("sample size") + xlab("")+
    theme(axis.text = element_text(size=11),
        axis.title = element_text(size=15),
        legend.text = element_text(size=14),
        legend.title = element_text(size=17, face="bold"))
    #outputFile = paste0(outputpath, "/esti_vs_real_PopulationSize_splineFit.pdf")
    ggsave(p_sample_size,
           height = 8,
           width = 16,
           dpi = 220,
           device = "pdf",
           file = outputFile)
}


plotSplineWithNewCasesSeqData <-function(data.table, spline.table, meta.table.freq, date_m, outputFile) {

  minX <- max(min(spline.table$value_trueN),0)
  maxX <- max(spline.table$value_trueN)
  minY <- max(min(spline.table$value),0)
  maxY <- max(spline.table$value)
  ylimMax <- max(data.table$value)
  minDate <- min(as.Date(data.table$meanBinDate))
  maxDate <- max(days.as.Date(spline.table$t, minDate))

  mycolors <- c("estid"="darkblue", "trued"="darkred","esti"="blue", "true"="red")
  p_spline_esti_realN <- ggplot() +
    #geom_point(aes(doy.as.Date(data.table$doy), data.table$trueN*rel_vs_true_ratio), size=2, color=mycolors["trued"], alpha=0.5)+
    geom_point(aes(days.as.Date(data.table$t, minDate), rescale(data.table$trueN, minX, maxX, minY, maxY)),size=2, color=mycolors["trued"], alpha=0.5)+
    geom_point(aes(x=days.as.Date(data.table$t, minDate), y=data.table$value), colour=mycolors["esti"], size=data.table$pointSize, alpha=0.3)+
    #geom_line(aes(x=doy.as.Date(spline.table$doy), y=spline.table$value_trueN*rel_vs_true_ratio), color=mycolors["true"], size = 2, alpha=0.5)+
    geom_line(aes(x=days.as.Date(spline.table$t, minDate), y=rescale(spline.table$value_trueN, minX, maxX, minY, maxY)), color=mycolors["true"], size = 2, alpha=0.5)+
    geom_line(aes(x=days.as.Date(spline.table$t, minDate), y=spline.table$value), color=mycolors["esti"], size = 2, alpha=0.5)+
    geom_vline(xintercept=as.Date(date_m), linetype = "dashed", color="darkgray") +
    scale_size_continuous(range = c(min(data.table$pointSize), max(data.table$pointSize))) +
    scale_y_continuous(
      expression(paste(theta[est],"\\",Delta,"t","\n")),
      #sec.axis = sec_axis(~ . * 1/rel_vs_true_ratio, name = "new cases")
      sec.axis = sec_axis(~ rescale(., 0, maxY, 0, maxX ), name = "new reported cases\n")) +
    xlab("")+
    coord_cartesian(xlim=c(minDate, maxDate),ylim=c(0,ylimMax)) +
    scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
    theme(
      axis.text.x=element_text(angle = 0, vjust = 1, hjust=0),
      axis.title.y = element_text(color = mycolors["estid"]),
      axis.text.y = element_text(color = mycolors["estid"]),
      axis.title.y.right = element_text(color = mycolors["trued"]),
      axis.text.y.right = element_text(color = mycolors["trued"]),
      axis.text = element_text(size=16),
      axis.title = element_text(size=16),
      legend.text = element_text(size=15),
      legend.title = element_text(size=17, face="bold"),
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      panel.background = element_blank(), axis.line = element_line(colour = "black")
    )
    #meta.table.freq.e<-meta.table.freq[!(as.Date(meta.table.freq$Var1)>maxDate),]
    #print(meta.table.freq.e)
    p_sample_size <- ggplot() +
    geom_line(aes(x=days.as.Date(meta.table.freq$t,minDate),y=cumsum(meta.table.freq$Freq)), geom = "step", size=0.7, color="darkgray")+
    geom_vline(xintercept=as.Date(date_m), linetype = "dashed", color="darkgray") +
    scale_y_continuous(
      expression("number of sequences"),
      sec.axis = sec_axis(~ . , name = derive())) +
    coord_cartesian(xlim=c(minDate, maxDate),ylim=c(0, max(cumsum(meta.table.freq$Freq)))) +
    xlab("") +
    scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
    theme(
      axis.text.x=element_text(angle = 0, vjust = 1, hjust=0),
      axis.title.y = element_text(color = "black"),
      axis.text.y = element_text(color = "black"),
      axis.title.y.right = element_text(color = "black"),
      axis.text.y.right = element_text(color = "black"),
      axis.text = element_text(size=16),
      axis.title = element_text(size=16),
      legend.text = element_text(size=15),
      legend.title = element_text(size=17, face="bold"),
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      panel.background = element_blank(), axis.line = element_line(colour = "black")
    )

    ggrid <- grid.arrange(p_spline_esti_realN, p_sample_size, heights=c(0.65, 0.35), nrow=2)
    pdf(outputFile, height = 10, width = 13, paper = "special")
    grid.draw(ggrid)
    dev.off()
}

plotSplineWithNewCasesSESeqData <-function(data.table, spline.table, meta.table, date_m, outputFile_trueNSE) {

  minX <- max(min(spline.table$value_trueN),0)
  maxX <- max(spline.table$value_trueN)
  minY <- max(min(spline.table$value),0)
  maxY <- max(spline.table$value)
  ylimMax <- max(data.table$value)
  minDate <- min(as.Date(data.table$meanBinDate))
  maxDate <- max(days.as.Date(spline.table$t, minDate))

  mycolors <- c("estid"="darkblue", "trued"="darkred","esti"="blue", "true"="red")
  p_spline_esti_realN <- ggplot() +
    #geom_point(aes(doy.as.Date(data.table$doy), data.table$trueN*rel_vs_true_ratio), size=2, color=mycolors["trued"], alpha=0.5)+
    #geom_line(aes(x=doy.as.Date(spline.table$doy), y=spline.table$value_trueN*rel_vs_true_ratio), color=mycolors["true"], size = 2, alpha=0.5)+
    geom_line(aes(x=days.as.Date(spline.table$t, minDate), y=rescale(spline.table$value_trueN, minX, maxX, minY, maxY)), color=mycolors["true"], size = 2, alpha=0.5)+
    geom_ribbon(aes(x=days.as.Date(spline.table$t, minDate), ymin = spline.table$lower, ymax = spline.table$upper), fill = "grey70",alpha=0.5) +
    geom_line(aes(x=days.as.Date(spline.table$t, minDate), y=spline.table$value), color=mycolors["esti"], size = 2, alpha=0.5) +
    geom_vline(xintercept=as.Date(date_m), linetype = "dashed", color="darkgray") +
    scale_y_continuous(
      expression(paste(theta[est],"\\",Delta,"t","\n")),
      #sec.axis = sec_axis(~ . * 1/rel_vs_true_ratio, name = "new cases")
      sec.axis = sec_axis(~ rescale(., 0, maxY, 0, maxX ), name = "new reported cases\n")) +
    xlab("")+
    coord_cartesian(xlim=c(minDate, maxDate),ylim=c(0,ylimMax)) +
    scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
    theme(
      axis.text.x=element_text(angle = 0, vjust = 1, hjust=0),
      axis.title.y = element_text(color = mycolors["estid"]),
      axis.text.y = element_text(color = mycolors["estid"]),
      axis.title.y.right = element_text(color = mycolors["trued"]),
      axis.text.y.right = element_text(color = mycolors["trued"]),
      axis.text = element_text(size=16),
      axis.title = element_text(size=16),
      legend.text = element_text(size=15),
      legend.title = element_text(size=17, face="bold"),
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      panel.background = element_blank(), axis.line = element_line(colour = "black")
    )
    #meta.table.freq.e<-meta.table.freq[!(as.Date(meta.table.freq$Var1)>maxDate),]
  p_sample_size <- ggplot() +
    geom_line(aes(x=days.as.Date(meta.table$t,minDate),y=cumsum(meta.table$Freq)), geom = "step", size=0.7, color="darkgray")+
    geom_vline(xintercept=as.Date(date_m), linetype = "dashed", color="darkgray") +
    scale_y_continuous(
      expression("number of sequences"),
      sec.axis = sec_axis(~ . , name = derive())) +
    coord_cartesian(xlim=c(minDate, maxDate),ylim=c(0, max(cumsum(meta.table$Freq)))) +
    xlab("") +
    scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
    theme(
      axis.text.x=element_text(angle = 0, vjust = 1, hjust=0),
      axis.title.y = element_text(color = "black"),
      axis.text.y = element_text(color = "black"),
      axis.title.y.right = element_text(color = "black"),
      axis.text.y.right = element_text(color = "black"),
      axis.text = element_text(size=16),
      axis.title = element_text(size=16),
      legend.text = element_text(size=15),
      legend.title = element_text(size=17, face="bold"),
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      panel.background = element_blank(), axis.line = element_line(colour = "black")
    )
  ggrid <- grid.arrange(p_spline_esti_realN, p_sample_size, heights=c(0.65, 0.35), nrow=2)
  pdf(outputFile, height = 10, width = 13, paper = "special")
  grid.draw(ggrid)
  dev.off()
}


plotSplineWithNewCasesSeqDataRepData <-function(data.table, cases.table, spline.table, spline.cases.table, meta.table.freq, date_m, outputFile) {

  minX <- max(min(cases.table$new_cases_smoothed),0)
  maxX <- max(cases.table$new_cases_smoothed)
  minY <- max(min(spline.table$value),0)
  maxY <- max(spline.table$value)
  ylimMax <- max(data.table$value)
  minDate <- min(as.Date(data.table$meanBinDate))
  minDateRepCases <- min(as.Date(cases.table$date))
  maxDate <- max(days.as.Date(spline.table$t, minDate))

  mycolors <- c("estid"="darkblue", "trued"="darkred","esti"="blue", "true"="red")
  p_spline_esti_realN <- ggplot() +
    #geom_point(aes(doy.as.Date(data.table$doy), data.table$trueN*rel_vs_true_ratio), size=2, color=mycolors["trued"], alpha=0.5)+
    #geom_point(aes(days.as.Date(data.table$t, minDate), rescale(data.table$trueN, minX, maxX, minY, maxY)),size=2, color=mycolors["trued"], alpha=0.5)+
    geom_point(aes(x=days.as.Date(data.table$t, minDate), y=data.table$value), 
               colour=mycolors["esti"], size=data.table$pointSize, alpha=0.3)+
    #geom_line(aes(x=days.as.Date(cases.table$t, minDateRepCases), y=rescale(cases.table$new_cases_smoothed, minX, maxX, minY, maxY)), color=mycolors["true"], size = 2, alpha=0.5)+
    geom_line(aes(x=days.as.Date(cases.table$t, minDateRepCases), 
                  y=rescale(cases.table$new_confirmed, minX, maxX, minY, maxY)), 
              color=mycolors["true"], size = 2, alpha=0.5)+
    
    geom_line(aes(x=days.as.Date(spline.table$t, minDate), y=spline.table$value), color=mycolors["esti"], size = 2, alpha=0.5)+
    geom_vline(xintercept=as.Date(date_m), linetype = "dashed", color="darkgray") +
    scale_y_continuous(
      expression(paste(theta[est],"\\",Delta,"t","\n")),
      #sec.axis = sec_axis(~ . * 1/rel_vs_true_ratio, name = "new cases")
      sec.axis = sec_axis(~ rescale(., 0, maxY, 0, maxX ), name = "new reported cases, smoothed\n")) +
    xlab("")+
    coord_cartesian(xlim=c(minDate, maxDate),ylim=c(0,ylimMax)) +
    scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
    scale_size_continuous(range = c(min(data.table$pointSize), max(data.table$pointSize))) +
    theme(
      axis.text.x=element_text(angle = 0, vjust = 1, hjust=0),
      axis.title.y = element_text(color = mycolors["estid"]),
      axis.text.y = element_text(color = mycolors["estid"]),
      axis.title.y.right = element_text(color = mycolors["trued"]),
      axis.text.y.right = element_text(color = mycolors["trued"]),
      axis.text = element_text(size=16),
      axis.title = element_text(size=16),
      legend.text = element_text(size=15),
      legend.title = element_text(size=17, face="bold"),
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      panel.background = element_blank(), axis.line = element_line(colour = "black")
    )
    #meta.table.freq.e<-meta.table.freq[!(as.Date(meta.table.freq$Var1)>maxDate),]
    #print(meta.table.freq.e)
    p_sample_size <- ggplot() +
    geom_line(aes(x=days.as.Date(meta.table.freq$t,minDate),y=cumsum(meta.table.freq$Freq)), geom = "step", size=0.7, color="darkgray")+
    geom_vline(xintercept=as.Date(date_m), linetype = "dashed", color="darkgray") +
    scale_y_continuous(
      expression("number of sequences"),
      sec.axis = sec_axis(~ . , name = derive())) +
    coord_cartesian(xlim=c(minDate, maxDate),ylim=c(0, max(cumsum(meta.table.freq$Freq)))) +
    xlab("") +
    scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
    theme(
      axis.text.x=element_text(angle = 0, vjust = 1, hjust=0),
      axis.title.y = element_text(color = "black"),
      axis.text.y = element_text(color = "black"),
      axis.title.y.right = element_text(color = "black"),
      axis.text.y.right = element_text(color = "black"),
      axis.text = element_text(size=16),
      axis.title = element_text(size=16),
      legend.text = element_text(size=15),
      legend.title = element_text(size=17, face="bold"),
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      panel.background = element_blank(), axis.line = element_line(colour = "black")
    )

    ggrid <- grid.arrange(p_spline_esti_realN, p_sample_size, heights=c(0.65, 0.35), nrow=2)
    pdf(outputFile, height = 10, width = 13, paper = "special")
    grid.draw(ggrid)
    dev.off()
}

plotSplineWithNewCasesSeqDataRepDataSplined <-function(data.table, cases.table, spline.table, spline.cases.table, meta.table.freq, date_m, outputFile, withCI) {

  minX <- max(min(spline.cases.table$value),0)
  maxX <- max(spline.cases.table$value)
  minY <- max(min(spline.table$value),0)
  maxY <- max(spline.table$value)
  ylimMax <- max(data.table$value)
  minDate <- min(as.Date(data.table$meanBinDate))
  minDateRepCases <- min(as.Date(cases.table$date))
  maxDate <- max(days.as.Date(spline.table$t, minDate))
  print(minX)
  print(maxX)
  print(minY)
  print(maxY)
  mycolors <- c("estid"="darkblue", "trued"="darkred","esti"="blue", "true"="red")
  p_spline_esti_realN <- ggplot() 
  if(withCI) {
    p_spline_esti_realN <- p_spline_esti_realN +
    geom_ribbon(data=spline.table, aes(x=days.as.Date(t, minDate), ymin=lowerSim, 
                                         ymax = upperSim), fill=mycolors["esti"], color=NA, alpha=0.2, show.legend = F)+
    geom_ribbon(data=spline.table, aes(x=days.as.Date(t, minDate), ymin =lower, 
                    ymax = upper), fill="green", color=NA, alpha=0.2, show.legend = F)+
    geom_ribbon(data=spline.cases.table, aes(x=days.as.Date(t, minDateRepCases), ymin = rescale(lower, minX, maxX, minY, maxY), 
                    ymax = rescale(upper, minX, maxX, minY, maxY)), fill=mycolors["true"], color=NA, alpha=0.2, show.legend = F)
  }
    #geom_point(aes(doy.as.Date(data.table$doy), data.table$trueN*rel_vs_true_ratio), size=2, color=mycolors["trued"], alpha=0.5)+
    #geom_point(aes(days.as.Date(data.table$t, minDate), rescale(data.table$trueN, minX, maxX, minY, maxY)),size=2, color=mycolors["trued"], alpha=0.5)+
  p_spline_esti_realN <- p_spline_esti_realN + 
    geom_point(aes(x=days.as.Date(data.table$t, minDate), y=data.table$value), 
               colour=mycolors["esti"], size=data.table$pointSize, alpha=0.3)+
    #geom_line(aes(x=doy.as.Date(spline.table$doy), y=spline.table$value_trueN*rel_vs_true_ratio), color=mycolors["true"], size = 2, alpha=0.5)+
    geom_line(aes(x=days.as.Date(spline.cases.table$t, minDateRepCases), 
              y=rescale(spline.cases.table$value, minX, maxX, minY, maxY)), 
              color=mycolors["true"], size = 2, alpha=0.5)+
    geom_line(aes(x=days.as.Date(spline.table$t, minDate), y=spline.table$value), color=mycolors["esti"], size = 2, alpha=0.5)+
    geom_vline(xintercept=as.Date(date_m), linetype = "dashed", color="darkgray") +
    scale_y_continuous(
      expression(paste(theta[est],"\\",Delta,"t","\n")),
      #sec.axis = sec_axis(~ . * 1/rel_vs_true_ratio, name = "new cases")
      sec.axis = sec_axis(~ rescale(., 0, maxY, 0, maxX ), name = "new reported cases, smoothed\n")) +
    xlab("")+
    coord_cartesian(xlim=c(minDate, maxDate),ylim=c(0,ylimMax)) +
    scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
    scale_size_continuous(range = c(min(data.table$pointSize), max(data.table$pointSize))) +
    theme(
      axis.text.x=element_text(angle = 0, vjust = 1, hjust=0),
      axis.title.y = element_text(color = mycolors["estid"]),
      axis.text.y = element_text(color = mycolors["estid"]),
      axis.title.y.right = element_text(color = mycolors["trued"]),
      axis.text.y.right = element_text(color = mycolors["trued"]),
      axis.text = element_text(size=16),
      axis.title = element_text(size=16),
      legend.text = element_text(size=15),
      legend.title = element_text(size=17, face="bold"),
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      panel.background = element_blank(), axis.line = element_line(colour = "black")
    )
    #meta.table.freq.e<-meta.table.freq[!(as.Date(meta.table.freq$Var1)>maxDate),]
    #print(meta.table.freq.e)
    p_sample_size <- ggplot() +
    geom_line(aes(x=days.as.Date(meta.table.freq$t,minDate),y=cumsum(meta.table.freq$Freq)), geom = "step", size=0.7, color="darkgray")+
    geom_vline(xintercept=as.Date(date_m), linetype = "dashed", color="darkgray") +
    scale_y_continuous(
      expression("number of sequences"),
      sec.axis = sec_axis(~ . , name = derive())) +
    coord_cartesian(xlim=c(minDate, maxDate),ylim=c(0, max(cumsum(meta.table.freq$Freq)))) +
    xlab("") +
    scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
    theme(
      axis.text.x=element_text(angle = 0, vjust = 1, hjust=0),
      axis.title.y = element_text(color = "black"),
      axis.text.y = element_text(color = "black"),
      axis.title.y.right = element_text(color = "black"),
      axis.text.y.right = element_text(color = "black"),
      axis.text = element_text(size=16),
      axis.title = element_text(size=16),
      legend.text = element_text(size=15),
      legend.title = element_text(size=17, face="bold"),
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      panel.background = element_blank(), axis.line = element_line(colour = "black")
    )

    ggrid <- grid.arrange(p_spline_esti_realN, p_sample_size, heights=c(0.65, 0.35), nrow=2)
    pdf(outputFile, height = 10, width = 13, paper = "special")
    grid.draw(ggrid)
    dev.off()
}

plotSplineWithNewCasesSESeqDataRepData <-function(data.table, spline.table, spline.cases.table, meta.table, date_m, outputFile_trueNSE) {

  minX <- max(min(spline.table$value_trueN),0)
  maxX <- max(spline.table$value_trueN)
  minY <- max(min(spline.table$value),0)
  maxY <- max(spline.table$value)
  ylimMax <- max(data.table$value)
  minDate <- min(as.Date(data.table$meanBinDate))
  maxDate <- max(days.as.Date(spline.table$t, minDate))

  mycolors <- c("estid"="darkblue", "trued"="darkred","esti"="blue", "true"="red")
  rel_vs_true_ratio = max(spline.table$value)/max(spline.table$value_trueN)
  p_spline_esti_realN <- ggplot() +
    #geom_point(aes(doy.as.Date(data.table$doy), data.table$trueN*rel_vs_true_ratio), size=2, color=mycolors["trued"], alpha=0.5)+
    #geom_line(aes(x=doy.as.Date(spline.table$doy), y=spline.table$value_trueN*rel_vs_true_ratio), color=mycolors["true"], size = 2, alpha=0.5)+
    geom_line(aes(x=days.as.Date(spline.table$t, minDate), y=rescale(spline.table$value_trueN, minX, maxX, minY, maxY)), color=mycolors["true"], size = 2, alpha=0.5)+
    geom_ribbon(aes(x=days.as.Date(spline.table$t, minDate), ymin = spline.table$lower, ymax = spline.table$upper), fill = "grey70",alpha=0.5) +
    geom_line(aes(x=days.as.Date(spline.table$t, minDate), y=spline.table$value), color=mycolors["esti"], size = 2, alpha=0.5) +
    geom_vline(xintercept=as.Date(date_m), linetype = "dashed", color="darkgray") +
    scale_y_continuous(
      expression(paste(theta[est],"\\",Delta,"t","\n")),
      #sec.axis = sec_axis(~ . * 1/rel_vs_true_ratio, name = "new cases")
      sec.axis = sec_axis(~ rescale(., 0, maxY, 0, maxX ), name = "new reported cases\n")) +
    xlab("")+
    coord_cartesian(xlim=c(minDate, maxDate),ylim=c(0,ylimMax)) +
    scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
    theme(
      axis.text.x=element_text(angle = 0, vjust = 1, hjust=0),
      axis.title.y = element_text(color = mycolors["estid"]),
      axis.text.y = element_text(color = mycolors["estid"]),
      axis.title.y.right = element_text(color = mycolors["trued"]),
      axis.text.y.right = element_text(color = mycolors["trued"]),
      axis.text = element_text(size=16),
      axis.title = element_text(size=16),
      legend.text = element_text(size=15),
      legend.title = element_text(size=17, face="bold"),
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      panel.background = element_blank(), axis.line = element_line(colour = "black")
    )
    #meta.table.freq.e<-meta.table.freq[!(as.Date(meta.table.freq$Var1)>maxDate),]
  p_sample_size <- ggplot() +
    geom_line(aes(x=days.as.Date(meta.table$t,minDate),y=cumsum(meta.table$Freq)), geom = "step", size=0.7, color="darkgray")+
    geom_vline(xintercept=as.Date(date_m), linetype = "dashed", color="darkgray") +
    scale_y_continuous(
      expression("number of sequences"),
      sec.axis = sec_axis(~ . , name = derive())) +
    coord_cartesian(xlim=c(minDate, maxDate),ylim=c(0, max(cumsum(meta.table$Freq)))) +
    xlab("") +
    scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
    theme(
      axis.text.x=element_text(angle = 0, vjust = 1, hjust=0),
      axis.title.y = element_text(color = "black"),
      axis.text.y = element_text(color = "black"),
      axis.title.y.right = element_text(color = "black"),
      axis.text.y.right = element_text(color = "black"),
      axis.text = element_text(size=16),
      axis.title = element_text(size=16),
      legend.text = element_text(size=15),
      legend.title = element_text(size=17, face="bold"),
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      panel.background = element_blank(), axis.line = element_line(colour = "black")
    )
  ggrid <- grid.arrange(p_spline_esti_realN, p_sample_size, heights=c(0.65, 0.35), nrow=2)
  pdf(outputFile, height = 10, width = 13, paper = "special")
  grid.draw(ggrid)
  dev.off()
}


plotCummulativeSampleSize <- function(data.table,outputFile) {
  minDate <- min(as.Date(data.table$meanBinDate))
  mycolors <- c("estid"="darkred", "trued"="darkblue","esti"="red", "true"="blue")
  p_sample_size <- ggplot() +
    #geom_point(aes(doy.as.Date(data.table$doy), data.table$trueN*rel_vs_true_ratio), size=2, color=mycolors["trued"], alpha=0.5)+
    geom_line(aes(days.as.Date(data.table$t, minDate), cumsum(data.table$sampleSize)),size=2, color=mycolors["trued"], alpha=0.5)+
    #geom_line(aes(x=doy.as.Date(spline.table$doy), y=spline.table$value_trueN*rel_vs_true_ratio), color=mycolors["true"], size = 2, alpha=0.5)+
    scale_y_continuous("sample size") + xlab("")+
    theme(axis.text = element_text(size=11),
        axis.title = element_text(size=15),
        legend.text = element_text(size=14),
        legend.title = element_text(size=17, face="bold"))
    #outputFile = paste0(outputpath, "/esti_vs_real_PopulationSize_splineFit.pdf")
    ggsave(p_sample_size,
           height = 8,
           width = 16,
           dpi = 220,
           device = "pdf",
           file = outputFile)
}

plotSpline <- function(input.table, spline.table, outputFile) {
  minDate <- min(as.Date(input.table$meanBinDate))
  p_spline <- ggplot() +
    geom_ribbon(aes(x=days.as.Date(spline.table$t, minDate), ymin = spline.table$lowerSim, ymax = spline.table$upperSim), fill = "grey70",alpha=0.5) +
    geom_point(aes(days.as.Date(input.table$t, minDate), y=input.table$value, size=1/input.table$variance), alpha=0.5, show.legend = F) +
    geom_line(aes(x=days.as.Date(spline.table$t,minDate), spline.table$value), color="red", size = 2, alpha=0.7) +
    xlab("") +
    scale_x_date(date_breaks = "months" , date_labels = "%Y-%m-%d") +
    ylab(expression(paste("estim. ", theta)))+
    theme(axis.text = element_text(size=9,face="bold"),
          axis.title = element_text(size=12),
          legend.text = element_text(size=14),
          legend.title = element_text(size=14, face="bold"),
          panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"))
  

  ggsave(p_spline,
       height = 8,
       width = 16,
       dpi = 220,
       device = "pdf",
       file = outputFile)
}


plotChangeInNDvsPopSize_perBin <- function(Diversity_df) {
  p_nd_vs_pop <- ggplot(Diversity_df[!is.nan(nuclDiversity_df$delta_nd),], aes(x=delta_N, y=delta_nd, col=binning)) +
    # geom_pointrange(aes(ymin = nuclDiv - variance_sample, ymax = nuclDiv + variance_sample),#, size=N),
    #                 alpha=0.7,
    #                 #position=position_dodge(width = 5),
    #                 linetype='solid') +
    #TODO: ymin = max(0, nc-var) geht irgendwie nicht
    #geom_ribbon(aes(ymin = max(0,nuclDiv - sqrt(variance_sample)), ymax = nuclDiv + sqrt(variance_sample), fill=binning), alpha=0.2)+
    #geom_line(size=1, alpha=0.7) +
    geom_point(size=2, alpha=0.7) +
    theme(legend.position="bottom") +
    ylab(parse(text = TeX('$\\Delta\\pi$'))) +
    xlab(parse(text = TeX('$\\Delta N_p$')))

  return(p_nd_vs_pop)
}

plotDerivativesBoxPLot <- function(spline.deriv.table,outputFile) {
  # From spline.deriv.table with window markers
  box_p <- ggplot(data = spline.deriv.table, aes(x=interval, y=value)) +
    geom_boxplot() +
    xlab("\nInterval start date") +
    ylab(expression(paste("est. ",R[0]))) +
    theme(axis.text = element_text(size=9,face="bold"),
        axis.title = element_text(size=12),
        legend.text = element_text(size=14),
        legend.title = element_text(size=14, face="bold"),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
  ggsave(box_p,
           height = 4,
           width = 3.5,
           dpi = 220,
           device = "pdf",
           file = outputFile)

}

plotRzero <- function(spline.deriv.table, infPer, theta.table, outputFile) {
  minDate <- min(as.Date(theta.table$meanBinDate))
  maxDate <- max(days.as.Date(spline.table$t, minDate))
  
  maxR <- max(spline.deriv.table$value) + 0.25*max(spline.deriv.table$value)
  minR <- min(spline.deriv.table$value) - 0.25*min(spline.deriv.table$value)
  p_spline_d1 <- ggplot() +
    geom_ribbon(aes(x=days.as.Date(spline.deriv.table$t, minDate), ymin = spline.deriv.table$lower, ymax = spline.deriv.table$upper), fill = "pink",alpha=0.6) +
    geom_line(aes(x=days.as.Date(spline.deriv.table$t, minDate),y=spline.deriv.table$value), color="darkred", size = 2, alpha=1.0)+
    geom_hline(yintercept=1.0, linetype = "dashed", color="darkgray") + ylab(expression(paste("est. ",R[0])))
  p_spline_d1 <- p_spline_d1 + scale_x_date(date_breaks = "2 months" , date_labels = "%Y-%m-%d") + theme(
    legend.title = element_blank(),
    #axis.text.x=element_text(angle = 0, vjust = 1, hjust=0),
    #axis.text = element_text(size=22),
    #axis.title = element_text(size=24,face="bold"),
    #legend.text = element_text(size=22),
    legend.text = element_text(size=18),
    axis.title.y = element_text(size=20),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    axis.text = element_text(size=18),
    axis.title.x = element_blank(),
    axis.line = element_line(colour = "black")
  )
  
  ggsave(p_spline_d1,
         height = 6,
         width = 16,
         dpi = 220,
         device = "pdf",
         file = outputFile)
  
}
