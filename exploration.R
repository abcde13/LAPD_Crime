
library(dplyr)
library(stringr)
library(ggmap)
library(shiny)

LAPD_set <- 
  read.csv("~/Downloads/LAPD_Crime_and_Collision_Raw_Data_-_2014.csv",
           na.strings="\"\"",colClasses=c(Location.1 = "double"),
           stringsAsFactors=FALSE)

loc = LAPD_set$Location.1
loc = strsplit(LAPD_set$Location.1,c(','))
latlong = data.frame(matrix(unlist(loc),ncol=2))
latlong_n = sapply(head(latlong),function(x) {
  x = gsub("[\\)]|[\\(]","",x,perl=T)
  x = str_trim(x)
  print(x)
  },simplify=T)
lats = as.numeric(latlong_n[,1])
longs = as.numeric(latlong_n[,2])
LAPD_set = mutate(LAPD_set,"Lat" = lats,"Long" = longs)
