

library(dplyr)
library(stringr)
library(ggmap)
library(shiny)

LAPD_set <- 
  read.csv("~/Downloads/LAPD_Crime_and_Collision_Raw_Data_-_2014.csv",
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
LAPD_set = mutate(LAPD_set,Date_Occurred = paste0(DATE.OCC,TIME.OCC))
LAPD_set$Date_Occurred = strptime(LAPD_set$Date_Occurred,"%m/%d/%Y%H%M")
date_na = is.na(LAPD_set$Date_Occurred)
LAPD_set = LAPD_set[!date_na,]

geocode("Los Angeles")
la_latlong = c(lon = -118.2437,lat = 34.05223)
la_map = get_map(la_latlong,zoom=10,maptype="terrain")
ggmap(la_map,extent="normal",maprange = F) %+% LAPD_set +
  aes(x=Long,y=Lat) +
  geom_density2d() +
  stat_density2d(aes(fill = ..level.., alpha = ..level..),size=10,
                 bins=16,geom="polygon") + 
  scale_alpha(range=c(0.1,0.6)) +
  coord_map(projection="mercator",
            xlim=c(attr(la_map, "bb")$ll.lon, attr(la_map, "bb")$ur.lon),
            ylim=c(attr(la_map, "bb")$ll.lat, attr(la_map, "bb")$ur.lat))

