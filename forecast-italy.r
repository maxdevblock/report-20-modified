library(rstan)
library(data.table)
library(lubridate)
library(gdata)
library(dplyr)
library(tidyr)
library(EnvStats)
library(scales)
library(stringr)
library(abind)
library(optparse)
library(ggplot2)
library(ggrepel)
library(gtable)
library(zoo)

JOBID = "276183"

# code for scenarios runs only in full mode
if (FULL){
  source("Italy/code/utils/simulate-regional.r")
  len_forecast <- 8*7
  
  # Can make plots = TRUE if you want to see 3 panel plots for simulations and rt_plots
  simulate_scenarios(JOBID = JOBID,  StanModel, plots = TRUE, scenario_type = "decrease-com-current", len_forecast = len_forecast,
                     subdir='Italy',
                     simulate_code='Italy/code/stan-models/simulate.stan', 
                     mobility_vars=c(1,2,3), 
                     compliance_vars=c(4,5,6),
                     mobility_increase = 0,
                     compliance_decrease = 40
                     )
  simulate_scenarios(JOBID = JOBID,  StanModel, plots = TRUE, scenario_type = "decrease-com-current", len_forecast = len_forecast,
                     subdir='Italy',
                     simulate_code='Italy/code/stan-models/simulate.stan', 
                     mobility_vars=c(1,2,3), 
                     compliance_vars=c(4,5,6),
                     mobility_increase = 0,
                     compliance_decrease = 20
                     )
  simulate_scenarios(JOBID = JOBID,  StanModel, plots = TRUE, scenario_type = "constant-com", len_forecast = len_forecast,
                     subdir='Italy',
                     simulate_code='Italy/code/stan-models/simulate.stan', 
                     mobility_vars=c(1,2,3), 
                     compliance_vars=c(4,5,6),
                     mobility_increase = 0,
                     compliance_decrease = 0
                     )
  
  source("Italy/code/utils/make-table.r")
  # Prints attack rates to console
  scenario_type = "constant-com"
  mobility_increase = 0
  compliance_decrease = 0
  make_table_simulation(paste0('Italy/results/sim-', scenario_type, "-", StanModel, '-', len_forecast, '-', compliance_decrease, '-', JOBID, '-stanfit.Rdata'), 
                        date_till_percentage = max(dates[[1]]) + len_forecast)
  
  
  source("Italy/code/plotting/make-scenario-plots-top7.r")
  
  make_scenario_comparison_plots_compliance(JOBID = JOBID, StanModel, len_forecast = len_forecast, 
                                          last_date_data = max(dates[[1]]) + len_forecast, baseline = FALSE, 
                                          compliance_decrease = 20,top=7)
  make_scenario_comparison_plots_compliance(JOBID = JOBID, StanModel, len_forecast = len_forecast, 
                                          last_date_data = max(dates[[1]]) + len_forecast, baseline = FALSE, 
                                          compliance_decrease = 40,top=7)
  make_scenario_comparison_plots_compliance(JOBID = JOBID, StanModel, len_forecast = len_forecast, 
                                          last_date_data = max(dates[[1]]) + len_forecast, baseline = FALSE, 
                                          compliance_decrease = 20,top=8)
  make_scenario_comparison_plots_compliance(JOBID = JOBID, StanModel, len_forecast = len_forecast, 
                                          last_date_data = max(dates[[1]]) + len_forecast, baseline = FALSE, 
                                          compliance_decrease = 40,top=8)
  make_scenario_comparison_plots_compliance(JOBID = JOBID, StanModel, len_forecast = len_forecast, 
                                          last_date_data = max(dates[[1]]) + len_forecast, baseline = FALSE, 
                                          compliance_decrease = 20,top=9)
  make_scenario_comparison_plots_compliance(JOBID = JOBID, StanModel, len_forecast = len_forecast, 
                                          last_date_data = max(dates[[1]]) + len_forecast, baseline = FALSE, 
                                          compliance_decrease = 40,top=9)
}
