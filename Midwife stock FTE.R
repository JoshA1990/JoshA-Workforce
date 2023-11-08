
# Summary of FTE data by nationality

###################################Install and load the packages###################################
#(note only need to install packages once, but need to reload library each time)
#Working with strings package
#install.packages ("stringr")
library(stringr)

#data wrangling/ analysis package
library(dplyr)

#Viewing data package
library(kableExtra) 

#data wrangling/ analysis package
library(tidyverse)

library(lubridate)

#Dates package
library(eeptools)

#visualisation
library(ggplot2)

###################################Set working directory and load data###################################
#Note, you'll need to set the working directory to where the files are saved
getwd()
setwd("C:/Users/Josh.Andrews/OneDrive - Department of Health and Social Care/Nurse Data")

#2022
Raw_Data_202102 <- read_csv("Staff in Post - Workforce 202102 extracted Apr 21.csv")
Raw_Data_202103 <- read_csv("Staff in Post - Workforce 202103 extracted May 21.csv")
Raw_Data_202104 <- read_csv("Staff in Post - Workforce 202104 extracted Jun 21.csv")
Raw_Data_202105 <- read_csv("Staff in Post - Workforce 202105 extracted Jul 21.csv")
Raw_Data_202106 <- read_csv("Staff in Post - Workforce 202106 extracted Aug 21.csv")
Raw_Data_202107 <- read_csv("Staff in Post - Workforce 202107 extracted Sep 21.csv")
Raw_Data_202108 <- read_csv("Staff in Post - Workforce 202108 extracted Oct 21.csv")
Raw_Data_202109 <- read_csv("Staff in Post - Workforce 202109 extracted Nov 21.csv")
Raw_Data_202110 <- read_csv("Staff in Post - Workforce 202110 extracted Dec 21.csv")
Raw_Data_202111 <- read_csv("Staff in Post - Workforce 202111 extracted Jan 22.csv")
Raw_Data_202112 <- read_csv("Staff in Post - Workforce 202112 extracted Feb 22.csv")

#2023
Raw_Data_202201 <- read_csv("Staff in Post - Workforce 202201 extracted Mar 22.csv")
Raw_Data_202202 <- read_csv("Staff in Post - Workforce 202202 extracted Apr 22.csv")
Raw_Data_202203 <- read_csv("Staff in Post - Workforce 202203 extracted May 22.csv")
Raw_Data_202204 <- read_csv("Staff in Post - Workforce 202204 extracted Jun 22.csv")
Raw_Data_202205 <- read_csv("Staff in Post - Workforce 202205 extracted Jul 22.csv")
Raw_Data_202206 <- read_csv("Staff in Post - Workforce 202206 extracted Aug 22.csv")
Raw_Data_202207 <- read_csv("Staff in Post - Workforce 202207 extracted Sep 22.csv")
Raw_Data_202208 <- read_csv("Staff in Post - Workforce 202208 extracted Oct 22.csv")
Raw_Data_202209 <- read_csv("Staff in Post - Workforce 202209 extracted Nov 22.csv")
Raw_Data_202210 <- read_csv("Staff in Post - Workforce 202210 extracted Dec 22.csv")
Raw_Data_202211 <- read_csv("Staff in Post - Workforce 202211 extracted Jan 23.csv")
Raw_Data_202212 <- read_csv("Staff in Post - Workforce 202212 extracted Feb 23.csv")

#2024
Raw_Data_202301 <- read_csv("Staff in Post - Workforce 202301 extracted Mar 23.csv")
Raw_Data_202302 <- read_csv("Staff in Post - Workforce 202302 extracted Apr 23.csv")
Raw_Data_202303 <- read_csv("Staff in Post - Workforce 202303 extracted May 23.csv")
Raw_Data_202304 <- read_csv("Staff in Post - Workforce 202304 extracted Jun 23.csv")

#OR if there are a lot of ESR files, can load all in one go:
#files <- list.files(path = "C:/R/20200918 Nurse analysis/Test - load all files at once", pattern = "*.csv", full.names = T)

#Raw_data <- sapply(files, read_csv, simplify=FALSE) %>% 
  #bind_rows(.id = "id")

nationality <- read_csv("Nationality groupings.csv")
NHS_orgs <- read_csv("Org Codes NHS Digital.csv")

#If fulljoin error, check column names are different and then change column names:

#names(Raw_Data_202105)[names(Raw_Data_202105) == "ODS Code"] <- "Ocs Code"
#head(Raw_Data_202105)


###################################Data wrangling###################################
#Union data - update this to the files you want to summarise 
Raw_data <- rbind(Raw_Data_202304)


#Amend column names so the dots are replaced with spaces
colnames(Raw_data) <- str_replace_all(colnames(Raw_data), " ", "_")
colnames(nationality) <- str_replace_all(colnames(nationality), " ", "_")

#filter to midwives only in active assignment
midwife <- Raw_data %>% 
  mutate(Staff_group = if_else(substr(Occupation_Code, 1, 1) %in% c(0,1,2,8,9) ,"x.Medical", 
                               if_else(Occupation_Code %in% c("N2C", "N2J", "N2L"),"midwife",
                               if_else(Occupation_Code %in% c("N0A", "N0B", "N0C", "N0D", "N0E", "N0F", "N0G", "N0H", "N0J", "N0K", "N0L", 
                                                              "N1A","N1B", "N1C", "N1H", "N1J", "N1L", "N4D", "N4F", "N4H", "N5D", "N5F", "N5H",
                                                              "N6A", "N6B", "N6C", "N6D", "N6E", "N6F", "N6G", "N6H", "N6J", "N6K", "N6L",
                                                              "N7A", "N7B", "N7C", "N7D", "N7E", "N7F", "N7G", "N7H", "N7K", "N7L", "NAA",
                                                              "NAB", "NAC", "NAD", "NAE", "NAF", "NAG", "NAH", "NAJ", "NAK", "NAL", "NBK",
                                                              "NCA", "NCB", "NCC", "NCD", "NCE", "NCF", "NCG", "NCH", "NCJ", "NCK", "NCL", "NNN",
                                                              "NEH", "P2B", "P2E", "P2C", "P2D", "P3C", "P3D", "P3E", "N7J","P2A","P3A"), "x.Nurse", 
                                if_else(Occupation_Code %in% "N3H", "x.health_visitor",
                                if_else(Occupation_Code %in% c("H1A", "N9A", "NFA"), "Support","x.Other"))))))%>%
  filter(Status %in% c("Active Assignment", "Internal Secondment", "Acting Up"))%>%
  filter(Asg_Type_Of_Contract %in% c("Locum", "Fixed Term Temp", "Permanent")) %>%
  filter(Staff_group=="midwife")

#merge on NHS D organisation codes and nationality file
midwife <- full_join(midwife,NHS_orgs)
midwife <- full_join(midwife,nationality)

#filter to only NHS trusts and CCGs and override NA nationality with Unknowns
midwife <- midwife %>% filter(NHSD_trust_or_CCG==1 & is.na(Unique_Nhs_Identifier)==FALSE) %>%
mutate(Nationality_grouping = if_else(is.na(Nationality_grouping)==TRUE, 'Unknown',Nationality_grouping)) %>%
  filter(is.na(Unique_Nhs_Identifier)==FALSE) %>%
  mutate (Nationality_grouping_v2 = if_else(Nationality_grouping %in% c('UK','Unknown'),'Domestic',
                                            if_else(Nationality_grouping %in% c('EU','ROW'),'IR','Other')))


###################################Summaries###################################
#nationality split
summary_nat <- midwife %>% group_by(Tm_Year_Month,Nationality_grouping) %>%
  summarise (FTE=sum(Contracted_Wte)) %>% 
  arrange(Tm_Year_Month,Nationality_grouping)

#FTE by nat summary
summary_nat_2 <- midwife %>% group_by(Tm_Year_Month,Nationality_grouping_v2) %>%
  summarise (FTE=sum(Contracted_Wte)) %>% 
  arrange(Tm_Year_Month,Nationality_grouping_v2)

#FTE summary
summary <- midwife %>% group_by(Tm_Year_Month) %>%
  summarise (FTE=sum(Contracted_Wte))

#align columns for FTE summary to FTE by nat
summary <- summary %>% mutate (Nationality_grouping="All")

summary_nat_2 <- rename (summary_nat_2, Nationality_grouping=Nationality_grouping_v2)

#bind grouping split and total and add date
summary <- bind_rows(summary, summary_nat,summary_nat_2) %>%
mutate(Date=as.Date(str_replace_all(str_replace_all(paste(Tm_Year_Month,"01")," ",""),"-",""),"%Y%B%d")) %>%
arrange(Date,Nationality_grouping)

#Extract csv
write.csv(summary, paste("C:/Users/Josh.Andrews/OneDrive - Department of Health and Social Care/Nurse Data/Outputs/",str_replace_all(Sys.Date(),"-",""),"stock.csv"))

# ###################################duplicate checks###################################
# #all duplicates in Jul 2020
# Nurses <- Nurses %>% filter (Tm_Year_Month=="2021-FEB")
# Nurses$Unique_Nhs_Identifier[duplicated(Nurses$Unique_Nhs_Identifier)]
# 
# Nurses <- Nurses[order(Nurses$Staff_group,-Nurses$Contracted_Wte), ]
# Dedup <- Nurses[ duplicated(Nurses$Unique_Nhs_Identifier), ]
# 
# #e.g.
# test <- Nurses %>% filter (Unique_Nhs_Identifier==2065062)
# 
# #summarise FTE anc check where it's above 1 - 337 records
# Nurses %>% group_by(Unique_Nhs_Identifier) %>%
#   summarise (FTE=sum(Contracted_Wte)) %>%
#   filter(FTE>1)
# 
# test <- Nurses %>% filter (Unique_Nhs_Identifier==75439) # check with Mike


