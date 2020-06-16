JOBID = "276183"
source("Italy/code/utils/make-table.r")

# Prints attack rates to console
scenario_type = "constant-com"
mobility_increase = 0
compliance_decrease = 0
make_table_simulation(paste0('Italy/results/sim-', scenario_type, "-", StanModel, '-', len_forecast, '-', compliance_decrease, '-', JOBID, '-stanfit.Rdata'), 
                      date_till_percentage = max(dates[[1]]) + len_forecast)

for (com_dec in c(20, 40)){
  # Prints attack rates to console
  scenario_type = "decrease-com-current"
  mobility_increase = 0
  compliance_decrease = com_dec
  make_table_simulation(paste0('Italy/results/sim-', scenario_type, "-", StanModel, '-', len_forecast, '-', compliance_decrease, '-', JOBID, '-stanfit.Rdata'), 
                        date_till_percentage = max(dates[[1]]) + len_forecast)
}
