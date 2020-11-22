rm(list=ls(all=TRUE))

# install.packages("raster", dependencies = TRUE)
# install.packages("sf", dependencies = TRUE)
# install.packages("tidyverse", dependencies = TRUE)
# install.packages("maptools", dependencies = TRUE)
# install.packages("spatstat", dependencies = TRUE)
# install.packages("units", dependencies = TRUE)

library(raster)
library(sf)
library(tidyverse)
library(maptools)
library(spatstat)
library(units)

setwd("/Users/Monica/Google Drive/ABM/project_3")

##########################################
### Import and subset spatial polygons ###
##########################################

npl_adm2 <- read_sf("/Users/Monica/Google Drive/ABM/data/geoBoundaries-NPL-ADM2-shp/geoboundariesSSCGS-3_0_0-NPL-ADM2.shp")

siraha <- npl_adm2 %>%
  filter(shapeName == "Siraha")
###############################
### Import and crop rasters ###
###############################
npl_pop16 <- raster("/Users/Monica/Google Drive/ABM/data/world_pop/npl_ppp_2016.tif")

sir_pop16 <- crop(npl_pop16, siraha)
sir_pop16 <- mask(sir_pop16, siraha)

# confirm projection

plot(sir_pop16)
plot(st_geometry(siraha), add = TRUE)

### load synthetic housholds and persons

load("/Users/Monica/Google Drive/ABM/DHS_data/siraha_pns.RData")

st_geometry(siraha_pns) <- siraha_pns$geometry


### load de facto settlement boundaries

load("/Users/Monica/Google Drive/ABM/defacto_description/all_polys_sir.RData")

# filter out

all_polys_subdiv <- all_polys_subdiv %>%
  filter(area < 1.50e+03)

# plot & analyze

subdiv_cntr_pts <-  all_polys_subdiv %>% 
  st_centroid() %>% 
  st_cast("MULTIPOINT")

ggplot() +
  geom_sf(data = siraha,
          size = 0.75,
          color = "gray50",
          fill = "gold3",
          alpha = 0.15) +
  geom_sf(data = all_polys_subdiv,
          fill = "lightblue",
          size = 0.25,
          alpha = 0.5) +
  geom_sf_text(data = all_polys_subdiv,
               aes(label = pop16),
               size = 2.5) +
  geom_sf(data = siraha_pns,
          size = .01,
          alpha = .01) +
  geom_sf(data = subdiv_cntr_pts,
          aes(size = pop16,
              color = density),
          show.legend = 'point') +
  scale_color_gradient(low = "yellow", high = "red") +
  xlab("longitude") + ylab("latitude") +
  ggtitle("Urbanized Areas throughout the county of Bomi, Liberia")

mk_bb <- st_bbox(swz_mk) %>% st_as_sfc() #getting bounding box and turning into a poly
mk_voronoi <- st_voronoi(st_union(urban_centroids), mk_bb) #producing voronoi polys
#st_voronoi(st_geometry(subdiv_cntr_pts), bomi)

ggsave("bomi.png", plot, width = 10, height = 10, dpi = 300)
