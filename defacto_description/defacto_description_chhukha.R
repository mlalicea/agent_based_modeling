library(raster)
library(sf)
library(tidyverse)
library(maptools)
library(spatstat)
library(units)

setwd("/Users/Monica/Google Drive/ABM/defacto_description")

btn_pop19 <- raster("/Users/Monica/Google Drive/ABM/data/world_pop/btn_ppp_2019.tif")
btn_pop19[is.na(btn_pop19)] <- 0

btn_adm1  <- read_sf("/Users/Monica/Google Drive/ABM/data/gadm36_BTN_shp/gadm36_BTN_1.shp")
btn_adm2  <- read_sf("/Users/Monica/Google Drive/ABM/data/gadm36_BTN_shp/gadm36_BTN_2.shp")


chhukha <- btn_adm1 %>%
  filter(NAME_1 == "Chhukha")

#plot(st_geometry(chhukha))

chhukha_pop19 <- crop(btn_pop19, chhukha) 
chhukha_pop19 <- mask(chhukha_pop19, chhukha)

pop_c <- floor(cellStats(chhukha_pop19, 'sum'))

#png("chhukhka_pop19.png", width = 800, height = 800)
#plot(chhukha_pop19, main = NULL)
#plot(st_geometry(chhukha), add = TRUE)
#dev.off()

st_write(chhukha, "chhukha.shp", delete_dsn=TRUE)
chhukha_mt <- readShapeSpatial("chhukha.shp")
win <- as(chhukha_mt, "owin")

set.seed(5)
chhukha_ppp <- rpoint(pop_c, f = as.im(chhukha_pop19), win = win)

#png("chhukha_points.pdf", width = 800, height = 800)
plot(win, main = NULL)
plot(chhukha_ppp, cex = 0.02, add = TRUE)
#dev.off()

#bw_c <- bw.ppl(chhukha_ppp)
#save(bw_c, file = "bw_c.RData")
load("bw_c.RData")

chhukha_density <- density(chhukha_ppp, sigma = bw_c)
plot(chhukha_density)

Dsg_c <- as(chhukha_density, "SpatialGridDataFrame")  # convert to spatial grid class
Dim_c <- as.image.SpatialGridDataFrame(Dsg_c)  # convert again to an image
Dcl_c <- contourLines(Dim_c, levels = 500000)  # create contour object
SLDF_c <- ContourLines2SLDF(Dcl_c, CRS("+proj=longlat +datum=WGS84 +no_defs"))

SLDFs_c <- st_as_sf(SLDF_c, sf)

png("chhukha_density.png", width = 2000, height = 2000)
plot(Dsg_c, main = NULL)
plot(SLDFs_c, add = TRUE)
dev.off()

inside_polys_c <- st_polygonize(SLDFs_c)
outside_lines_c <- st_difference(SLDFs_c, inside_polys_c)
outside_buffers_c <- st_buffer(outside_lines_c, 0.001)
outside_intersects_c <- st_difference(chhukha, outside_buffers_c)

oi_polys <- st_cast(outside_intersects_c, "POLYGON")
in_polys <- st_collection_extract(inside_polys_c, "POLYGON")

in_polys[ ,1] <- NULL
oi_polys[ ,1:12] <- NULL

# in_polys <- st_cast(in_polys, "POLYGON")
# oi_polys <- st_cast(oi_polys, "POLYGON")

all_polys <- st_union(in_polys, oi_polys)
all_polys <- st_collection_extract(all_polys, "POLYGON")
all_polys <- st_cast(all_polys, "POLYGON")
all_polys_subdiv <- all_polys %>%
  unique()

# extract values
all_polys_ext <- raster::extract(chhukha_pop19, all_polys_subdiv, df = TRUE)
all_polys_ttls <- all_polys_ext %>%
  group_by(ID) %>%
  summarize(pop19 = sum(layer, na.rm = TRUE))
all_polys_subdiv <- all_polys_subdiv %>%
  add_column(pop19 = all_polys_ttls$pop19) %>%
  mutate(area = as.numeric(st_area(all_polys_subdiv) %>%
                             set_units(km^2))) %>%
  mutate(density = as.numeric(pop19 / area))

# filter out

all_polys_subdiv <- all_polys_subdiv %>%
  filter(density > 30 & density < 250)

all_polys_subdiv <- all_polys_subdiv %>%
  filter(pop19 > 10)

# plot & analyze

subdiv_cntr_pts <-  all_polys_subdiv %>% 
  st_centroid() %>% 
  st_cast("MULTIPOINT")

ggplot() +
  geom_sf(data = chhukha,
          size = 0.75,
          color = "gray50",
          fill = "gold3",
          alpha = 0.15) +
  geom_sf(data = all_polys_subdiv,
          fill = "lightblue",
          size = 0.25,
          alpha = 0.5) +
  geom_sf(data = subdiv_cntr_pts,
          aes(size = pop19,
              color = density),
          show.legend = 'point') +
  scale_color_gradient(low = "yellow", high = "red") +
  xlab("longitude") + ylab("latitude") +
  ggtitle("Urbanized Areas throughout the subdivision of Chhukha, Bhutan")

ggsave("urbanized_areas.png", width = 12, height = 12)



