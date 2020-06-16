library(dplyr)
library(lubridate)
library(grid)
library(gtable)
source("Italy/code/plotting/format-data-plotting.r")

make_scenario_comparison_plots_compliance <- function(JOBID, StanModel, len_forecast, last_date_data, 
                                                    baseline=FALSE, compliance_decrease = 20,top=7){
  print(paste0("Making scenario comparision plots for ", compliance_decrease , "%"))
  load(paste0('Italy/results/sim-constant-com-', StanModel, '-', len_forecast, '-0-', JOBID, '-stanfit.Rdata'))

  countries <- states
  
  out <- rstan::extract(fit)
  
  com_data <- NULL
  for (i in 1:length(countries)){
    data_state_plot <- format_data(i = i, dates = dates, countries = countries, 
                                   estimated_cases_raw = estimated_cases_raw, 
                                   estimated_deaths_raw = estimated_deaths_raw, 
                                   reported_cases = reported_cases,
                                   reported_deaths = reported_deaths,
                                   out = out, forecast = 0, SIM = TRUE)
    # Cuts data on last_data_date
    data_state_plot <- data_state_plot[which(data_state_plot$date <= last_date_data),]
    
    subset_data <- select(data_state_plot, country, date, reported_deaths, estimated_deaths, 
                          deaths_min, deaths_max)
    subset_data$key <- rep("Constant compliance", length(subset_data$country))
    com_data <- rbind(com_data, subset_data)
  }    
  
  if (baseline == TRUE){
    load(paste0('Italy/results/sim-decrease-com-baseline-', StanModel, '-', len_forecast, '-', compliance_decrease, '-', JOBID, 
                '-stanfit.Rdata'))
    out <- rstan::extract(fit)
  } else {
    load(paste0('Italy/results/sim-decrease-com-current-', StanModel, '-', len_forecast, '-', compliance_decrease, '-', 
                JOBID, '-stanfit.Rdata'))
    out <- rstan::extract(fit)
  }
  for (i in 1:length(countries)){
    data_state_plot <- format_data(i = i, dates = dates, countries = countries, 
                                   estimated_cases_raw = estimated_cases_raw, 
                                   estimated_deaths_raw = estimated_deaths_raw, 
                                   reported_cases = reported_cases,
                                   reported_deaths = reported_deaths,
                                   out = out, forecast = 0, SIM = TRUE)
    # Cuts data on last_data_date
    data_state_plot <- data_state_plot[which(data_state_plot$date <= last_date_data),]
    subset_data <- select(data_state_plot, country, date, reported_deaths, estimated_deaths, 
                          deaths_min, deaths_max)
    subset_data$key <- rep("decreased compliance", length(subset_data$country))
    com_data <- rbind(com_data, subset_data)
  }    
  
  data_half <- com_data[which(com_data$key == "decreased compliance"),]
  com_data$key <- factor(com_data$key)
  data_half$key <- factor(data_half$key)
  
  #nametrans <- read.csv("Subnational_Analysis/Italy/province_name_translation.csv")
  
  # To do top 7:
  if(top==7){
   com_data <- com_data %>% filter(country %in% c("Lombardy","Marche","Veneto","Tuscany","Piedmont","Emilia-Romagna","Liguria")) %>%
                              droplevels()

    data_half <- data_half %>% filter(country %in% c("Lombardy","Marche","Veneto","Tuscany","Piedmont","Emilia-Romagna","Liguria")) %>%
        droplevels()
  }
  if(top==8){
  # # To do all others"
   com_data <- com_data %>% filter((country %in% c("Abruzzo","Basilicata","Calabria","Campania","Friuli-Venezia_Giulia","Lazio","Molise"))) %>%
                             droplevels()
  data_half <- data_half %>% filter((country %in% c("Abruzzo","Basilicata","Calabria","Campania","Friuli-Venezia_Giulia","Lazio","Molise"))) %>%
      droplevels()
  }
  if(top==9){
    # # To do all others"
    com_data <- com_data %>% filter((country %in% c("Bolzano","Trento","Apulia","Sardinia","Sicily","Umbria","Aosta"))) %>%
      droplevels()
    data_half <- data_half %>% filter((country %in%  c("Bolzano","Trento","Apulia","Sardinia","Sicily","Umbria","Aosta"))) %>%
      droplevels()
  }

  last_date_data<-com_data$date[nrow(com_data)]
  
  #com_data$label <- com_data$key %>% str_replace_all(" ", "_") %>% recode( Constant_compliance= "compliance held constant", decreased_compliance = "decreased compliance: ",compliance_decrease,"% return to pre-lockdown level")
  
  levels(com_data$key)=c("compliance held constant",paste0("decreased compliance: ",compliance_decrease,"% return to pre-lockdown level"))
  
  p <- ggplot(com_data) +
    geom_bar(data = com_data, aes(x = date, y = reported_deaths), stat='identity') +
    geom_ribbon(aes(x = date, ymin = deaths_min, ymax = deaths_max, group = key, fill = key), alpha = 0.5) +
    #geom_line(aes(date,deaths_max),color="black",size=0.2)+
    #geom_line(aes(date,deaths_min),color="black",size=0.2)+
    #geom_line(aes(date,estimated_deaths),group = key,size=0.5)+
    geom_line(aes(date,estimated_deaths, group = key, color = key),size = 1)  +scale_colour_manual(values= c("skyblue","red"))+
    #geom_ribbon(aes(x = date, ymin = deaths_min, ymax = deaths_max, fill = "ICL"), alpha = 0.5) +
    scale_fill_manual(name = "", labels = c("compliance held constant", paste0("decreased compliance: ",compliance_decrease,"% return to pre-lockdown level")), values = c("skyblue","red")) + 
    scale_x_date(date_breaks = "2 weeks", labels = date_format("%e %b"), limits = c(as.Date("2020-03-02"), last_date_data)) + 
    #facet_wrap(~country, scales = "free",nrow=7) + 
    facet_grid(country ~key, scales = "free_y")+
    xlab("") + ylab("Daily number of deaths") +
    theme_minimal() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1,size = 26), axis.title = element_text( size = 26 ),axis.text = element_text( size = 26),
          legend.position = "none",strip.text = element_text(size = 26),legend.text=element_text(size=26))
  ggsave(paste0("Italy/figures/scenarios_decrease_baseline-", len_forecast, '-', compliance_decrease, '-', JOBID, "top_",top,".png"), p, height = 30, width = 20)

}
