rm(list=ls())

# install.packages("devtools")
# install.packages("gravity", dependencies = TRUE)
#install.packages("units")
# library(jsonlite)
library(tidyverse)
library(dplyr)
library(sf)
library(rmapshaper)
# library(imputeTS)
library(gganimate)
# library(stplanr)
devtools::install_github("itsleeds/od")
library(gravity)
library(raster)
library(units)

setwd("/Users/Monica/Google Drive/ABM/project_3")

# api <- "https://www.worldpop.org/rest/data/"
# x <- as.data.frame(fromJSON(api))


###################
### Import Data ###
###################
shp <- read_sf('/Users/Monica/Google Drive/ABM/data/NPL_5yrs_InternalMigFlows_2010/NPL_AdminUnit_Centroids/NPL_AdminUnit_Centroids.shp')

#npl_adm1 <- read_sf("/Users/Monica/Google Drive/ABM/data/geoBoundaries-NPL-ADM1-shp/geoboundariesSSCGS-3_0_0-NPL-ADM1.shp")
npl_adm2 <- read_sf("/Users/Monica/Google Drive/ABM/data/gadm36_NPL_shp/gadm36_NPL_2.shp")
npl2_simp <- ms_simplify(npl_adm2)

# center points
# cpts <- read_sf("LBR_5yrs_InternalMigFlows_2010/LBR_AdminUnit_Centroids/LBR_AdminUnit_Centroids.shp")
adm2_cpts <- st_centroid(npl2_simp)

# Import migratory flows
flows <- read_csv("/Users/Monica/Google Drive/ABM/data/NPL_5yrs_InternalMigFlows_2010/NPL_5yrs_InternalMigFlows_2010.csv")

# Night time lights
npl_ntl16 <- raster("/Users/Monica/Google Drive/ABM/data/world_pop/npl_viirs_100m_2016.tif")

############################################
### Create Origin-Destination Data Frame ###
############################################

# names of origin and destination counties

adm2_cpts <- adm2_cpts[ ,c(7,14)]
#adm2_cpts$shapeName <- gsub(" ","_",adm2_cpts$shapeName)

nms_o <- adm2_cpts$NAME_2
nms_d <- adm2_cpts$NAME_2

names(nms_o) <- "origin_county"
names(nms_d) <- "dest_county"

odm <- expand_grid(nms_o, nms_d)

odm <- odm %>%
  filter(nms_o != nms_d)

odm <- odm %>% 
  rename(origin_county  = nms_o,
         dest_county  = nms_d)

# distances of origin and destination counties

o <- st_geometry(adm2_cpts)
d <- st_geometry(adm2_cpts)

dist <- st_distance(o,d) %>%
  set_units(km) %>%
  as.data.frame()

dist <- dist %>%
  rownames_to_column(var = "origin") %>%
  pivot_longer(names_to = "destination",
               values_to = "distance",
               cols = V1:V14)

dist$distance <- as.numeric(dist$distance)

dist <- dist %>%
  filter(distance > 0)

odm <- odm %>%  
  add_column(distance = dist$distance) %>%
  add_column(migration = flows$PrdMIG)

# add night-time lights

 #npl_ntl_vals_2<- raster::extract(npl_ntl16, npl_adm2, df = TRUE)
# save(npl_ntl_vals_2, file = "npl_ntl_2.RData")
load("npl_ntl_2.RData")

ntl_ttls <- npl_ntl_vals_2 %>%
  group_by(ID) %>%
  summarize_all(sum, na.rm = TRUE)

ntl_o <- ntl_ttls$npl_viirs_100m_2016
ntl_d <- ntl_ttls$npl_viirs_100m_2016

od_ntl <- expand_grid(ntl_o, ntl_d)

od_ntl <- od_ntl %>%
  filter(ntl_o != ntl_d)

odm <- odm %>% 
  add_column(ntl = od_ntl$ntl_d)

# add origin and destination centerpoints, union od points as multipoint

cpts_o <- rep(o, each = 14)
cpts_d <- rep(o, 14)

cpts <- cbind.data.frame(cpts_o,cpts_d)

names(cpts) <- c("origin_cpt", "dest_cpt")

cpts <- cpts %>%
  filter(origin_cpt != dest_cpt)


odpts <- st_union(o,d) %>%
  st_as_sf()

odpts <- odpts[st_geometry_type(odpts) == "MULTIPOINT", ]

names(odpts) <- "od_pts"

odm <- odm %>% 
  add_column(origin_cpt = cpts$origin_cpt,
             dest_cpt = cpts$dest_cpt,
             od_pts = odpts$od_pts)


# Summarize origin in/out-migration flows

origin_flows_sums <- flows %>%
  group_by(NODEI) %>%
  summarise(sum(PrdMIG))

names(origin_flows_sums) <- c("county", "outmigration")

# Summarize destination in-migration flows

destination_flows_sums <- flows %>%
  group_by(NODEJ) %>%
  summarise(sum(PrdMIG))

names(destination_flows_sums) <- c("county", "inmigration")

npl2_simp <- npl2_simp %>% 
  add_column(outmigration = origin_flows_sums$outmigration,
             inmigration = destination_flows_sums$inmigration)

ggplot() +
  geom_sf(data = npl2_simp, aes(fill = outmigration))

ggplot() +
  geom_sf(data = npl2_simp, aes(fill = inmigration))

# create pie chart by adm1 with % origin/destination flows

# create od matrix
odm <- pivot_wider(data = flows, id_cols = NODEI, names_from = NODEJ, values_from = PrdMIG) #instead of spread() or pivot_longer instead of gather()
odm <- odm[ ,-1]
odm <- odm[ ,c(14,1:13)] 


#####################################################
### create vector paths to/from all center points ###
#####################################################

#adm1_cpts <- adm1_cpts[ ,c(4,11)]
#adm1_cpts$NAME_1 <- gsub(" ","_",adm1_cpts$NAME_1)

o <- st_geometry(adm2_cpts)
d <- st_geometry(adm2_cpts)

# od_combos <- expand_grid(o,d) #st_union accomplishes the same thing

# create for 1 to 2:15
pt <- st_union(o[1], d[2:14])

ln <- st_cast(pt, "LINESTRING") %>%
  st_as_sf()

# create for all

pts_all <- st_union(o, d) %>%
  st_as_sf()

mpts_all <- pts_all[st_geometry_type(pts_all) != "POINT", ]

lns_all <- st_cast(mpts_all, "LINESTRING") %>%
  st_as_sf()

# add migration values

 #bomi_origin <- subset(origin_flows, NODEI == 1)
 #ln_x <- add_column(ln, migration = bomi_origin$PrdMIG)

# produce line plot with lines as weights

ggplot() +
  geom_sf(data = npl2_simp) +
  geom_sf(data = lns_all)
  #geom_sf(data = origin_flows_sums, aes(size = outmigration)) 

ggplot() +
  geom_sf(data = npl2_simp) +
  geom_sf(data = ln)

####

#### next annimate

 library(lwgeom)

ln[1,]

p <- st_line_sample(st_transform(lns_all, 32629), 2) %>%
  st_cast("POINT") %>%
  st_as_sf()

# p <- lns_all %>%
#   st_transform(32629) %>%
#   st_startpoint() %>%
#   st_endpoint() %>%
#   st_cast("POINT") %>%
#   st_as_sf()

p$id <- rep(1:182, each = 2)
p$time <- seq(from = 0, to = 1, by = 1)

p <- p %>% st_transform(4251)

p$long <- st_coordinates(p)[,1]
p$lat <- st_coordinates(p)[,2]

ggplot() +
  geom_sf(data = npl2_simp) +
  # geom_sf(data = origin_flows_sums, aes(size = migration)) +
  geom_sf(data = adm2_cpts) +
  geom_sf(data = lns_all, alpha = .2) +
  geom_sf(data = p, size = .2)

a <- ggplot() +
  geom_sf(data = npl2_simp) +
  geom_sf(data = adm2_cpts) +
  geom_sf(data = lns_all, alpha =.1) +
  geom_point(data = p, size = .1, aes(x = long, y = lat))

##

anim = a + 
  transition_reveal(along = time)+
  ease_aes('linear')+
  ggtitle("Time: {frame_along}")

gganimate::animate(anim, nframes = 24, fps = 10)

anim_save("output.gif", animation = anim)

# CDR data

a <- read_sf("/Users/tyfrazier/Desktop/Spatial_Data/Settlements/settspops/setts-pops.shp")

ggplot() +
  geom_sf(data = a)
