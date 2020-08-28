rm(list=ls(all=TRUE))

# install.packages("tidyverse", dependencies = TRUE)
# install.packages("sf", dependencies = TRUE)
#install.packages("raster", dependencies = TRUE)
#install.packages("doParallel", dependencies = TRUE)
#install.packages("snow", dependencies = TRUE)

library(tidyverse)
library(sf)
library(raster)
library(doParallel)
library(snow)

setwd("/Users/Monica/Google Drive/ABM/Extracting_Populations")

bhutan_pop19 <- raster("/Users/Monica/Google Drive/ABM/data/world_pop/btn_ppp_2019.tif")
bhutan_pop19

##ADM1
bhutan_adm1  <- read_sf("/Users/Monica/Google Drive/ABM/data/gadm36_BTN_shp/gadm36_BTN_1.shp")
bhutan_adm1

plot(bhutan_pop19)
plot(st_geometry(bhutan_adm1), add = TRUE)

#ncores <- detectCores() - 1
#beginCluster(ncores)
#pop_vals_adm1 <- raster::extract(bhutan_pop19, bhutan_adm1, df = TRUE)
#endCluster()

save(pop_vals_adm1, file = "pop_vals_adm1.RData")

load("pop_vals_adm1.RData")

totals_adm1 <- pop_vals_adm1 %>%
  group_by(ID) %>%
  summarize(totals_adm1 = sum(btn_ppp_2019, na.rm = TRUE))

bhutan_adm1 <- bhutan_adm1 %>%
  add_column(pop19 = totals_adm1$totals_adm1)

ggplot(bhutan_adm1) +
  geom_sf(aes(fill = pop19)) +
  geom_sf_text(aes(label = NAME_1),
               color = "black",
               size = 2.40) +
  scale_fill_gradient(low = "yellow", high = "red")

ggsave("bhutan_pop19_adm1.png")

##ADM2
bhutan_adm2  <- read_sf("/Users/Monica/Google Drive/ABM/data/gadm36_BTN_shp/gadm36_BTN_2.shp")
bhutan_adm2

plot(bhutan_pop19)
plot(st_geometry(bhutan_adm2), add = TRUE)

#ncores <- detectCores() - 1
#beginCluster(ncores)
#pop_vals_adm2 <- raster::extract(bhutan_pop19, bhutan_adm2, df = TRUE)
#endCluster()

save(pop_vals_adm2, file = "pop_vals_adm2.RData")

load("pop_vals_adm2.RData")

totals_adm2 <- pop_vals_adm2 %>%
  group_by(ID) %>%
  summarize(totals_adm2 = sum(btn_ppp_2019, na.rm = TRUE))

bhutan_adm2 <- bhutan_adm2 %>%
  add_column(pop19 = totals_adm2$totals_adm2)

ggplot(bhutan_adm2) +
  geom_sf(aes(fill = log(pop19))) +
  geom_sf_text(aes(label = NAME_2),
               color = "black",
               size = 1.25) +
  scale_fill_gradient(low = "yellow", high = "red")

ggsave("bhutan_pop19_adm2.png")

##Both
ggplot() +
  geom_sf(data = bhutan_adm2, aes(fill = log(pop19)),
          size = 0.1, color = "grey50") +
  geom_sf_text(data = bhutan_adm2, 
               aes(label = NAME_2),
               color = "black",
               size = 1.0) +
  geom_sf(data = bhutan_adm1, size = 0.65, alpha = 0) +
  geom_sf_text(data = bhutan_adm1, aes(label = NAME_1),
               color = "black",
               size = 2.5,
               alpha = 0.35) +
  scale_fill_gradient2(low = "blue", mid="yellow", high="red", midpoint = 8.5) +
  xlab("longitude") + ylab("latitude") +
  ggtitle("Bhutan's Districts", subtitle = "Log of Population") +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5),
        panel.background = element_rect(fill = "azure"),
        panel.border = element_rect(fill = NA))

ggsave("bhutan_pop19_both.png")

## 3D
#install.packages("devtools")
#library(devtools)
#devtools::install_github("tylermorganwall/rayshader")

library(rayshader)

ggbtn_adm2 <- ggplot(bhutan_adm2) +
  geom_sf(aes(fill = log(pop19))) +
  scale_fill_gradient2(low = "blue", mid="yellow", high="red", midpoint = 8.5)

plot_gg(ggbtn_adm2, multicore = TRUE, width = 6 ,height=2.7, fov = 70)

