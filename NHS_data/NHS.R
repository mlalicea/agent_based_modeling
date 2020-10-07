#install.packages("haven", dependencies = TRUE)
setwd("/Users/Monica/Google Drive/ABM/NHS_data")

 install.packages("foreign", dependencies = TRUE)
 install.packages("reshape", dependencies = TRUE)
 install.packages("gdata", dependencies = TRUE)
 install.packages("VIM", dependencies = TRUE)

# install.packages("raster", dependencies = TRUE)
# install.packages("sf", dependencies = TRUE)
# install.packages("tidyverse", dependencies = TRUE)
# install.packages("maptools", dependencies = TRUE)
# install.packages("spatstat", dependencies = TRUE)
# install.packages("units", dependencies = TRUE)

library(foreign)
library(reshape)
library(gdata)

library(VIM)
library(tidyverse)
library(haven)
library(raster)
library(sf)
library(tidyverse)
library(maptools)
library(spatstat)
library(units)

# persons <- read.dta("LBR_DHS_13/LBIR6ADT/LBIR6AFL.DTA")
# households <- read.dta("LBR_DHS_13/LBHR6ADT/LBHR6AFL.DTA")


persons <- read_dta("/Users/Monica/Google Drive/ABM/data/NPIR7HDT/NPIR7HFL.DTA")
households <- read_dta("/Users/Monica/Google Drive/ABM/data/NPPR7HDT/NPPR7HFL.DTA")

weights <- households$hv005
size <- households$hv009
sex <- households$hv104
age <- households$hv105

hhs <- cbind.data.frame(weights, size, sex, age)

# What is the population of your selected country
# How many households in your selected country
# What is the population of your selected subdivision
# How many households in your selected subdivision

siraha <- subset(households, shdist == 16)
sum(households$hv005)
sum(siraha$hv005)
table(siraha$hv009) #maybe we expand the sample

########################
### set our location ###
########################

npl_pop16 <- raster("/Users/Monica/Google Drive/ABM/data/world_pop/npl_ppp_2016.tif")

npl_adm0 <- read_sf("/Users/Monica/Google Drive/ABM/data/NPL-ADM0-all/geoBoundariesSimplified-3_0_0-NPL-ADM0-shp/geoBoundariesSimplified-3_0_0-NPL-ADM0.shp")
npl_adm2  <- read_sf("/Users/Monica/Google Drive/ABM/data/NPL-ADM2-all/geoBoundariesSimplified-3_0_0-NPL-ADM2-shp/geoBoundariesSimplified-3_0_0-NPL-ADM2.shp")

sir <- npl_adm2 %>%
  filter(shapeName == "Siraha")

sir_pop16 <- crop(npl_pop16, sir)
sir_pop16 <- mask(sir_pop16, sir)

#pop <- floor(cellStats(lbr_pop15, 'sum'))
pop <- floor(cellStats(sir_pop16, 'sum'))

pop <- pop/100
houses <- ceiling(pop / 4.6)

 #png("sir_pop16.png", width = 800, height = 800)
 plot(sir_pop16, main = NULL)
 plot(st_geometry(sir), add = TRUE)
# dev.off()
 
sir2 <- st_collection_extract(sir, "POLYGON")
 
#st_write(npl_adm0, "npl.shp", delete_dsn=TRUE)
st_write(sir, "siraha_new.shp", delete_dsn=TRUE)

#lbr_mt <- readShapeSpatial("lbr.shp")
sir_mt <- st_read("siraha_new.shp")

win <- as(sir_mt, "owin")

sir_houses <- rpoint(houses, f = as.im(sir_pop16), win = win)

png("siraha_pipo.png", width = 2000, height = 2000)
plot(win, main = NULL)
plot(sir_houses, cex = .15)
dev.off()


