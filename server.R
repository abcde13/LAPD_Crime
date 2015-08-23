
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(dplyr)
library(stringr)
library(ggvis)
library(shiny)

LAPD_set <- 
  read.csv("LAPD_Crime_and_Collision_Raw_Data_-_2014.csv",
           na.strings="",
           stringsAsFactors=FALSE)
na_locs = is.na(LAPD_set$Location.1)
LAPD_set = LAPD_set[!na_locs,]
traffic = LAPD_set$Crm.Cd.Desc == "TRAFFIC DR #"
LAPD_set = LAPD_set[!traffic,]
loc = LAPD_set$Location.1
loc = strsplit(LAPD_set$Location.1,c(','))
lat_n = seq(1,length(unlist(loc)),2)
long_n = seq(2,length(unlist(loc)),2)
lats = unlist(loc)[lat_n]
longs = unlist(loc)[long_n]
latlong = data.frame(lats,longs)
latlong = sapply(latlong,function(x) {
  x = gsub("[\\)]|[\\(]","",x,perl=T)
  x = str_trim(x)
},simplify=T)
lats = as.numeric(latlong[,1])
longs = as.numeric(latlong[,2])
LAPD_set = mutate(LAPD_set,"Lat" = lats,"Long" = longs)
LAPD_set$TIME.OCC = sapply(LAPD_set$TIME.OCC,function(x) {
  x = as.character(x)
  if(nchar(x) != 4)
    x = paste0("0",x)
  x
})
LAPD_set = LAPD_set %>% 
  group_by(Crm.Cd.Desc,DATE.OCC) %>% 
  summarize(IncidentCount = n())
LAPD_set$DATE.OCC = as.Date(strptime(LAPD_set$DATE.OCC,"%m/%d/%Y"))
not_2014 = LAPD_set$DATE.OCC < "2014-01-01"
LAPD_set = LAPD_set[!not_2014,]
LAPD_set$Crm.Cd.Desc = factor(LAPD_set$Crm.Cd.Desc)



shinyServer(function(input, output) {
   
   
  subset = reactive(LAPD_set[LAPD_set$Crm.Cd.Desc == input$crime_type,])
  
  subset %>% ggvis(~DATE.OCC,~IncidentCount,stroke:="red") %>% 
    add_axis("x",title = "Date of incident") %>%
    add_axis("y",title="# of incidents") %>%
    layer_lines() %>%
    bind_shiny("p","p_ui")
    
  
  output$crimeTypeSelector = renderUI({
    selectInput("crime_type","Type of crime:", 
                levels(LAPD_set$Crm.Cd.Desc) ,selectize=T)
  })
  
  output$incidentCount = reactive({
    subset = LAPD_set[LAPD_set$Crm.Cd.Desc == input$crime_type,]
    count = sum(subset$IncidentCount)
    paste("Total number of incidents: ",count)
  })

  
})
