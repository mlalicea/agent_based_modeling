rm(list=ls(all=TRUE))

#install.packages("haven", dependencies = TRUE)
setwd("/Users/Monica/Google Drive/ABM/DHS_data")

# install.packages("foreign", dependencies = TRUE)
# install.packages("reshape", dependencies = TRUE)
# install.packages("gdata", dependencies = TRUE)
 #install.packages("VIM", dependencies = TRUE)

# install.packages("raster", dependencies = TRUE)
# install.packages("sf", dependencies = TRUE)
# install.packages("tidyverse", dependencies = TRUE)
# install.packages("maptools", dependencies = TRUE)
# install.packages("spatstat", dependencies = TRUE)
# install.packages("units", dependencies = TRUE)

#library(foreign)
#library(reshape)
#library(gdata)

library(VIM)
library(tidyverse)
library(haven)
library(raster)
library(sf)
library(tidyverse)
library(maptools)
library(spatstat)
#library(units)

#persons <- read_dta("/Users/Monica/Google Drive/ABM/data/NPIR7HDT/NPIR7HFL.DTA")
households <- read_dta("/Users/Monica/Google Drive/ABM/data/NPHR7HDT/NPHR7HFL.DTA")

hhid <- households$hhid
unit <- households$hv004
weights <- households$hv005 /1000000
province <- as_factor(households$hv024)
dist <- as_factor(households$shdist)
size <- households$hv009
sex <- households[ ,350:387]
age <- households[ ,388:425]
edu <- households[ ,426:463]
wealth <- households$hv270

hhs <- cbind.data.frame(hhid, unit, weights, province, dist, size, sex, age, edu, wealth)

##########################################
### Import and subset spatial polygons ###
##########################################

#npl_adm0 <- read_sf("/Users/Monica/Google Drive/ABM/data/geoBoundaries-NPL-ADM0-shp/geoboundariesSSCGS-3_0_0-NPL-ADM0.shp")
npl_adm1 <- read_sf("/Users/Monica/Google Drive/ABM/data/geoBoundaries-NPL-ADM1-shp/geoboundariesSSCGS-3_0_0-NPL-ADM1.shp")
npl_adm2 <- read_sf("/Users/Monica/Google Drive/ABM/data/geoBoundaries-NPL-ADM2-shp/geoboundariesSSCGS-3_0_0-NPL-ADM2.shp")

prov2 <- npl_adm1 %>%
  filter(shapeName == "Province 2")

#plot(st_geometry(prov2))

siraha <- npl_adm2 %>%
    filter(shapeName == "Siraha")

#plot(st_geometry(siraha))

###############################
### Import and crop rasters ###
###############################
npl_pop16 <- raster("/Users/Monica/Google Drive/ABM/data/world_pop/npl_ppp_2016.tif")

prov2_pop16 <- crop(npl_pop16, prov2)
prov2_pop16 <- mask(prov2_pop16, prov2)

sir_pop16 <- crop(npl_pop16, siraha)
sir_pop16 <- mask(sir_pop16, siraha)

# confirm projection

#plot(sir_pop16)
#plot(st_geometry(siraha), add = TRUE)

####################################
### Expand households to persons ###
###       without locations      ###
####################################

gender_pivot <- hhs %>% 
  gather(key = "pnmbr", value = "gender", colnames(hhs)[7:44], na.rm = TRUE) # revise after adding new variable
gender_pivot <- gender_pivot[ ,-7:-82]
age_pivot <- hhs %>%
  gather(key = "pnmbr", value = "age", colnames(hhs)[45:82], na.rm = TRUE)
age_pivot <- age_pivot[ ,-7:-82]
edu_pivot <- hhs %>%
  gather(key = "pnmbr", value = "edu", colnames(hhs)[83:120], na.rm = TRUE)
edu_pivot <- edu_pivot[ ,-7:-82]

pns <- cbind.data.frame(gender_pivot, age = age_pivot$age, education = edu_pivot$edu)

# check household level error
sum(hhs$weights)
nrow(hhs)

# check person level error
sum(pns$weights) 
nrow(pns)
nrow(pns) / cellStats(npl_pop16, 'sum') # person sample proportion

pns_numeric <- pns
pns_numeric$dist <- as.numeric(pns_numeric$dist)
#write.csv(pns_numeric[ ,c(4:6,8:10)], file = "pns.csv")

############################
### Spatially locate all ###
###  households at adm1  ###
############################

prov2_hhs <- subset(hhs, province == "province 2")


# calculate average household size

prov2_hhs_n <- floor(cellStats(prov2_pop16, 'sum') / mean(prov2_hhs$size))

st_write(prov2, "prov2.shp", delete_dsn=TRUE)
prov2_mt <- readShapeSpatial("prov2.shp")
win <- as(prov2_mt, "owin")

hhs_adm1_pts <- rpoint(prov2_hhs_n, f = as.im(prov2_pop16), win = win) # randomly generate points
# ideal method is to use DHS coordinates with point process model

adm1_pts <- cbind.data.frame(x = hhs_adm1_pts$x, y = hhs_adm1_pts$y)

adm1_locs = st_as_sf(adm1_pts, coords = c("x", "y"), crs = st_crs(npl_adm1))

# random sample from generate households

prov2_hhs_pop <- slice_sample(prov2_hhs, n = prov2_hhs_n, replace = TRUE) # randomly expand households from survey to population 
# keep all columns, check weight_by argument

sum(prov2_hhs_pop$weights) #check error
nrow(prov2_hhs_pop) # check n rows
nrow(adm1_locs) # confirm

prov2_hhs_locs <- cbind.data.frame(prov2_hhs_pop, adm1_locs)

abs((nrow(prov2_hhs_locs) - sum(prov2_hhs_locs$weights)) / nrow(prov2_hhs_locs))

####################################
### Expand households to persons ###
###      with adm1 locations     ###
####################################

gender_pivot <- prov2_hhs_locs[ ,-45:-120]
gender_pivot <- gender_pivot %>% 
  gather(key = "pnmbr", value = "gender", colnames(gender_pivot)[7:44], na.rm = TRUE)

age_pivot <- prov2_hhs_locs[45:82]
age_pivot <- age_pivot %>%
  gather(key = "pnmbr", value = "age", colnames(age_pivot), na.rm = TRUE)

edu_pivot <- prov2_hhs_locs[83:120]
edu_pivot <- edu_pivot %>%
  gather(key = "pnmbr", value = "edu", colnames(edu_pivot), na.rm = TRUE)

prov2_pns <- cbind.data.frame(gender_pivot,age = age_pivot$age, edu = edu_pivot$edu)

sum(prov2_hhs_locs$weights)
nrow(prov2_hhs_locs)

sum(prov2_pns$weights) 
nrow(prov2_pns)
nrow(prov2_pns) / cellStats(prov2_pop16, 'sum') # compare DHS-based, generated synthetic person total proportion to ML/EO output

### plot ###

st_geometry(prov2_pns) <- prov2_pns$geometry

plot <- ggplot() +
  geom_sf(data = prov2) +
  geom_sf(data = prov2_pns,
          size = .001,
          alpha = .01)
plot
ggsave("prov2.png", plot, width = 20, height = 20, dpi = 300)


############################
### Spatially locate all ###
###  households at adm2  ###
############################

siraha_hhs <- subset(hhs, dist == "siraha")

# calculate average household size

siraha_hhs_n <- floor(cellStats(sir_pop16, 'sum') / mean(siraha_hhs$size))

st_write(siraha, "siraha.shp", delete_dsn=TRUE)
siraha_mt <- readShapeSpatial("siraha.shp")
win <- as(siraha_mt, "owin")

hhs_adm2_pts <- rpoint(siraha_hhs_n, f = as.im(sir_pop16), win = win) # randomly generate points
# ideal method is to use DHS coordinates with point process model

adm2_pts <- cbind.data.frame(x = hhs_adm2_pts$x, y = hhs_adm2_pts$y)

adm2_locs = st_as_sf(adm2_pts, coords = c("x", "y"), crs = st_crs(npl_adm2))

# analyze the data
sum(siraha_hhs$weights)
nrow(siraha_hhs)

table(prov2_hhs$size)
table(siraha_hhs$size)

ggplot() +
  geom_density(data = prov2_hhs,
               aes(x = size), fill = "gold")  +
  geom_density(data = siraha_hhs,
               aes(x = size), colour = "green")

adm2_sampP <- slice_sample(prov2_hhs, n = siraha_hhs_n, replace = TRUE)
adm2_sampP1 <- slice_sample(siraha_hhs, n = siraha_hhs_n, replace = TRUE)

ggplot() +
  geom_density(data = adm2_sampP,
               aes(x = size), fill = "gold")  +
  geom_density(data = adm2_sampP1,
               aes(x = size), colour = "green") 

# random sample from generate households

siraha_hhs_pop <- slice_sample(siraha_hhs, n = siraha_hhs_n, replace = TRUE) # randomly expand households from survey to population 
# keep all columns, check weight_by argument

sum(siraha_hhs_pop$weights) #check error
nrow(siraha_hhs_pop) # check n rows
nrow(adm2_locs) # confirm

siraha_hhs_locs <- cbind.data.frame(siraha_hhs_pop, adm2_locs)

abs((nrow(siraha_hhs_locs) - sum(siraha_hhs_locs$weights)) / nrow(siraha_hhs_locs))

####################################
### Expand households to persons ###
###      with adm2 location    ###
####################################

gender_pivot <- siraha_hhs_locs %>% 
  gather(key = "pnmbr", value = "gender", colnames(siraha_hhs_locs)[7:44], na.rm = TRUE)
gender_pivot <- gender_pivot[ ,-7:-82]

age_pivot <- siraha_hhs_locs[45:82]
age_pivot <- age_pivot %>%
  gather(key = "pnmbr", value = "age", colnames(age_pivot), na.rm = TRUE)

edu_pivot <- siraha_hhs_locs[83:120]
edu_pivot <- edu_pivot %>%
  gather(key = "pnmbr", value = "edu", colnames(edu_pivot), na.rm = TRUE)

siraha_pns <- cbind.data.frame(gender_pivot,age = age_pivot$age, edu = edu_pivot$edu)


sum(siraha_hhs_locs$weights)
nrow(siraha_hhs_locs)

sum(siraha_pns$weights) 
nrow(siraha_pns)
nrow(siraha_pns) / cellStats(sir_pop16, 'sum') # compare DHS-based, generated synthetic person total proportion to ML/EO output

st_geometry(siraha_pns) <- siraha_pns$geometry

### plot ###
plot <- ggplot() +
  geom_sf(data = siraha) +
  geom_sf(data = siraha_pns,
          size = .01,
          alpha = .05)

ggsave("siraha.png", plot, width = 20, height = 20, dpi = 300)

########################
### analyze the data ###
########################

#install.packages("heatmaply")
library(heatmaply)

pns_prep <- as.data.frame(pns[c(5:6,8:10)])
pns_prep <- slice_sample(pns_prep, n = 1000, replace = FALSE)

plot <- heatmaply(
  pns_prep, 
  xlab = "Features",
  ylab = "Combinations", 
  main = "Raw data",
  cexRow = .25,
)

plot <- heatmaply(
  scale(pns_prep), 
  xlab = "Features",
  ylab = "Combinations", 
  main = "Scaled data",
  cexRow = .25
)

