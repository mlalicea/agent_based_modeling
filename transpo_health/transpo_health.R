library(raster)
library(sf)
library(tidyverse)
library(maptools)
library(spatstat)
library(units)

setwd("/Users/Monica/Google Drive/ABM/transpo_health")

btn_roads <- read_sf('/Users/Monica/Google Drive/ABM/transpo_health/btn_rdsl_2015_osm/btn_rdsl_2015_osm.shp')

chhukha_roads <- st_crop(btn_roads, all_polys_subdiv)

table(chhukha_roads$type)

road <- chhukha_roads %>%
  filter(type == "road")
residential <- chhukha_roads %>%
  filter(type == "residential")
trunk <- chhukha_roads %>%
  filter(type == "trunk")
service <- chhukha_roads %>%
  filter(type == "service")
unclass <- chhukha_roads %>%
  filter(type == "unclassified")
track <- chhukha_roads %>%
  filter(type == "track")
tertiary <- chhukha_roads %>%
  filter(type == "tertiary")

ggplot() +
  geom_sf(data = chhukha,
          size = 0.75,
          color = "gray50",
          fill = "gold3",
          alpha = 0.15) +
  geom_sf(data = all_polys_subdiv,
          size = 0.75,
          color = "gray50",
          fill = "gold3",
          alpha = 0.15) +
  geom_sf(data = trunk,
         # size = set_size,
          color = "red4") +
  geom_sf(data = residential,
         # size = set_size,
          color = "red2") +
  geom_sf(data = road,
         # size = set_size,
          color = "red3") +
  geom_sf(data = service,
         # size = set_size,
          color = "red1") +
  geom_sf(data = unclass,
        #  size = set_size,
          color = "red") +
  geom_sf(data = track,
        #  size = set_size,
          color = "red") +
  geom_sf(data = tertiary,
       #   size = set_size,
          color = "red") +
  xlab("longitude") + ylab("latitude") +
  ggtitle("Roadways throughout Chhukha, Bhutan")

#ggsave("chhukha_roads.png",  width = 12, height = 12)

btn_health <- read_sf('/Users/Monica/Google Drive/ABM/transpo_health/hotosm_btn_health_facilities_points_shp/hotosm_btn_health_facilities_points.shp')

chhukha_health <- st_crop(btn_health, all_polys_subdiv)

btn_health <- read_sf('/Users/Monica/Google Drive/ABM/transpo_health/healthsites/healthsites.shp')

table(chhukha_health$amenity)

hospitals <- chhukha_health %>%
  filter(amenity == "hospital")


ggplot() +
  geom_sf(data = chhukha,
          size = 0.75,
          color = "gray50",
          fill = "gold3",
          alpha = 0.15) +
  geom_sf(data = all_polys_subdiv,
          size = 0.75,
          color = "gray50",
          fill = "gold3",
          alpha = 0.15) +
  geom_sf(data = trunk,
          # size = set_size,
          color = "darkorange3") +
  geom_sf(data = residential,
          # size = set_size,
          color = "darkorange2") +
  geom_sf(data = road,
          # size = set_size,
          color = "darkorange1") +
  geom_sf(data = service,
          # size = set_size,
          color = "darkorange") +
  geom_sf(data = unclass,
          #  size = set_size,
          color = "red") +
  geom_sf(data = track,
          #  size = set_size,
          color = "red") +
  geom_sf(data = tertiary,
          #   size = set_size,
          color = "red") +
  geom_sf(data = hospitals,
          color = "red4",
          shape = 3) +
  geom_sf(data = subdiv_cntr_pts,
          aes(size = pop19,
              color = density),
          show.legend = 'point') +
  scale_color_gradient(low = "yellow", high = "red") +
  xlab("longitude") + ylab("latitude") +
ggtitle("Access to Health Care Serivces throughout Chhukha, Bhutan")

ggsave("chhukha_health.png",  width = 12, height = 12)


