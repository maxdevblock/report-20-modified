library(dplyr)
library(lubridate)
source("Subnational_Analysis/code/plotting/format_data_plotting.R")

make_scenario_comparison_plots_compliance <- function(JOBID, StanModel, len_forecast, last_date_data, 
                                                    baseline, compliance_decrease = 20){
  print(paste0("Making scenario comparision plots for ", compliance_decrease , "%"))
  load(paste0('Subnational_Analysis/results/sim-constant-com-', StanModel, '-', len_forecast, '-0-', JOBID, '-stanfit.Rdata'))
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
    load(paste0('Subnational_Analysis/results/sim-decrease-com-baseline-', StanModel, '-', len_forecast, '-', compliance_decrease, '-', JOBID, '-stanfit.Rdata'))
  } else {
    load(paste0('Subnational_Analysis/results/sim-decrease-com-current-', StanModel, '-', len_forecast, '-', compliance_decrease, '-', JOBID, '-stanfit.Rdata'))
  }
  out <- rstan::extract(fit)
  
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
  
  nametrans <- read.csv("Subnational_Analysis/Italy/province_name_translation.csv")
  
  com_data <- com_data %>% filter(!(country %in% c("Lombardia","Marche","Veneto","Toscana","Piemonte","Emilia-Romagna","Liguria"))) %>%
                            droplevels()
  
  com_data$country<-recode(com_data$country, Lombardia="Lombardy",Piemonte="Piedmont",Toscana="Tuscany",P.A._Bolzano="Bolzano",
                           P.A._Trento="Trento",Puglia="Apulia",Sardegna="Sardinia",Sicilia="Sicily",Valle_dAosta="Aosta")
  
  data_half <- data_half %>% filter(!(country %in% c("Lombardia","Marche","Veneto","Toscana","Piemonte","Emilia-Romagna","Liguria"))) %>%
                              droplevels()

  data_half$country<-recode(data_half$country, Lombardia="Lombardy",Piemonte="Piedmont",Toscana="Tuscany",P.A._Bolzano="Bolzano",
                            P.A._Trento="Trento",Puglia="Apulia",Sardegna="Sardinia",Sicilia="Sicily",Valle_dAosta="Aosta")
    
  last_date_data<-com_data$date[nrow(com_data)]
  
  p <- ggplot(com_data) +
    geom_bar(data = data_half, aes(x = date, y = reported_deaths), stat='identity') +
    geom_ribbon(aes(x = date, ymin = deaths_min, ymax = deaths_max, group = key, fill = key), alpha = 0.5) +
    #geom_line(aes(date,deaths_max),color="black",size=0.2)+
    #geom_line(aes(date,deaths_min),color="black",size=0.2)+
    #geom_line(aes(date,estimated_deaths),color="black",size=0.3)+
    #geom_ribbon(aes(x = date, ymin = deaths_min, ymax = deaths_max, fill = "ICL"), alpha = 0.5) +
    scale_fill_manual(name = "", values = c("pink", "skyblue")) + 
    scale_x_date(date_breaks = "2 weeks", labels = date_format("%e %b"), limits = c(as.Date("2020-03-02"), last_date_data)) + 
    facet_wrap(~country, scales = "free") + 
    xlab("") + ylab("Daily number of deaths") +
    theme_minimal() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1,size = 14), axis.title = element_text( size = 14 ),axis.text = element_text( size = 14 ),
          legend.position = "right",strip.text = element_text(size = 14),legend.text=element_text(size=14))
  
  ggsave(paste0("Subnational_Analysis/figures/scenarios_decrease_baseline-", len_forecast, '-', compliance_decrease, '-', JOBID, "top_7.pdf"), p, height = 15, width = 20)
  
  if (baseline == TRUE){
    ggsave(paste0("Subnational_Analysis/figures/scenarios_decrease_baseline-", len_forecast, '-', compliance_decrease, '-', JOBID, ".pdf"), p, height = 15, width = 20)
  } else {
    ggsave(paste0("Subnational_Analysis/figures/scenarios_decrease_current-", len_forecast, '-', compliance_decrease, '-', JOBID, ".pdf"), p, height = 15, width = 20)
  }
}
