library(readr)
library(countrycode)
library(dplyr)
library(wbstats)
library(ggcorrplot)
library(ggplot2)
library(GGally) # contains ggcorr function
#setwd('~/Downloads')

###########
# GET DATA
###########

## All Countries
df.all_countries <- read_csv("countries.csv")
# inspect
df.all_countries

# get country codes
df.all_countries$iso2c <- countrycode(df.all_countries$Country, 'country.name', 'iso2c')
# inspect
df.all_countries

# recode countries with NA code
df.all_countries <- df.all_countries %>%
  mutate(iso2c=replace(iso2c, Country == "Central African Rep", "CF")) %>%
  mutate(iso2c=replace(iso2c, Country == "Kosovo", "XK")) %>%
  mutate(iso2c=replace(iso2c, Country == "Afganistan", "AF")) %>%
  mutate(iso2c=replace(iso2c, Country == "Korea North", "KP")) %>%  
  mutate(iso2c=replace(iso2c, Country == "Micronesia", "FM"))
# inspect
df.all_countries

## Proposed EDI Countries
df.proposed_countries <- read_csv("country.csv")
# inspect
df.proposed_countries

# get country codes
df.proposed_countries <- left_join(df.proposed_countries, df.all_countries, by = c("Country"))
# inspect
df.proposed_countries


######################
# GET WORLD BANK STATS
######################

get_wb_data <- function(col_name, indicator, startdate = 2016, enddate = 2016) {
  df.stat <- wb(indicator = indicator, startdate = startdate, enddate = enddate) 
  df.stat
  df.stat <- df.stat %>%
    select(iso2c, value)
  colnames(df.stat) <- c("iso2c", col_name)
  df.wb_data <- left_join(df.wb_data, df.stat, by = "iso2c")
}

# PRE-ALLOCATE: create empty dataframe CHANGE THIS TO # COUNTRIES BY N INDICATORS 
df.wb_data <- df.all_countries
str(df.wb_data)

## Get WB Data
# general characteristics
df.wb_data <- get_wb_data("population", "SP.POP.TOTL")

# economy
df.wb_data <- get_wb_data("gdp_usd", "NY.GDP.MKTP.CD")
df.wb_data <- get_wb_data("ppp_usd", "NY.GDP.PCAP.CD")
df.wb_data <- get_wb_data("gdp_growth_percent", "NY.GDP.MKTP.KD.ZG")
df.wb_data <- get_wb_data("ppp_growth_percent", "NY.GDP.PCAP.KD.ZG")
df.wb_data <- get_wb_data("consumer_price_inflation_percent", "FP.CPI.TOTL.ZG")
df.wb_data <- get_wb_data("gdp_percent_inports", "NE.IMP.GNFS.ZS")
df.wb_data <- get_wb_data("gdp_percent_services", "NV.SRV.TETC.ZS")

# crime & safety
df.wb_data <- get_wb_data("homicide_rate_per100k_2015", "VC.IHR.PSRC.P5", 2015, 2015)
df.wb_data <- get_wb_data("peacekeeping_troops","VC.PKP.TOTL.UN")

# government 
df.wb_data <- get_wb_data("central_government_debt_asPercentGDP", "GC.DOD.TOTL.GD.ZS")
df.wb_data <- get_wb_data("statistical_capacity", "IQ.SCI.OVRL")
df.wb_data <- get_wb_data("gdp_percent_tax_revenue", "GC.TAX.TOTL.GD.ZS")

# refugees & IDPs
df.wb_data <- get_wb_data("refugee_population", "SM.POP.REFG.OR")
df.wb_data <- get_wb_data("total_idps_conflict_violence", "VC.IDP.TOCV")
df.wb_data <- get_wb_data("new_idps_conflict_violence", "VC.IDP.NWCV")
df.wb_data <- get_wb_data("n_international_tourists", "IC.BUS.EASE.XQ") # TO DO: MULTIPLY BY 1000
df.wb_data <- get_wb_data("ease_of_doing_business_2017", "IC.BUS.EASE.XQ", startdate = 2017, enddate = 2017) # 1 = most business-friendly 
df.wb_data <- get_wb_data("logistics_performance_index", "LP.LPI.OVRL.XQ") # 1 = low, 5 = high
df.wb_data <- get_wb_data("time_to_import_2014", "IC.IMP.DURS", startdate = 2014, enddate = 2014) # days

# military expenditures
df.wb_data <- get_wb_data("armed_forces_percentof_labor_force", "MS.MIL.TOTL.TF.ZS", startdate = 2015, enddate = 2015)
df.wb_data <- get_wb_data("total_armed_forces_personnel_2015", "MS.MIL.TOTL.P1", startdate = 2015, enddate = 2015)
df.wb_data <- get_wb_data("gdp_percent_military_expenditure", "MS.MIL.XPND.GD.ZS")
df.wb_data <- get_wb_data("centralgov_percent_military_expenditure", "MS.MIL.XPND.ZS")
df.wb_data <- get_wb_data("arms_imports", "MS.MIL.MPRT.KD")
df.wb_data <- get_wb_data("arms_exports", "MS.MIL.XPRT.KD") # TO DO: MULTIPLY VALUE BY 1000

# inspect
df.wb_data

# rename 
df.all_countries_wb <- df.wb_data

# Get just the EDI countries data
df.proposed_countries_wb <- left_join(df.proposed_countries, df.wb_data, by = c("Country", "iso2c"))
# inspect
df.proposed_countries_wb

########################
# EXPORT WORLD BANK DATA
########################

# write all countries' data
write_csv(df.all_countries_wb, file.path("~/Downloads", "all_countries_wb.csv"), na = "NA")

# write proposed countries' data
write_csv(df.proposed_countries_wb, file.path("~/Downloads", "proposed_countries_wb.csv"), na = "NA")