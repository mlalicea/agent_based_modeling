rm(list=ls(all=TRUE))

# install.packages("tidyverse", dependencies = TRUE)
# install.packages("sf", dependencies = TRUE)
#install.packages("raster", dependencies = TRUE)
#install.packages("doParallel", dependencies = TRUE)
#install.packages("snow", dependencies = TRUE)
#install.packages("units", depdedencies = TRUE)
#install.packages("scales", depdedencies = TRUE)
#install.packages("ggpubr", depdedencies = TRUE)
#install.packages('Rcpp', dependencies = TRUE)
#install.packages("data.table", type = "binary")
#install.packages("ggrepel", dependencies = TRUE)

library(tidyverse)
library(sf)
library(raster)
library(doParallel)
library(snow)
library(units)
library(scales)
library(data.table)
library(ggpubr)
library(ggrepel)

setwd("/Users/Monica/Google Drive/ABM/Geometric_BarPlot")

bhutan_pop19 <- raster("/Users/Monica/Google Drive/ABM/data/world_pop/btn_ppp_2019.tif")
bhutan_pop19

##ADM1
bhutan_adm1  <- read_sf("/Users/Monica/Google Drive/ABM/data/gadm36_BTN_shp/gadm36_BTN_1.shp")
bhutan_adm1

ncores <- detectCores() - 1
beginCluster(ncores)
pop_vals_adm1 <- raster::extract(bhutan_pop19, bhutan_adm1, df = TRUE)
endCluster()

save(pop_vals_adm1, file = "pop_vals_adm1.RData")

load("pop_vals_adm1.RData")

totals_adm1 <- pop_vals_adm1 %>%
  group_by(ID) %>%
  summarize(totals_adm1 = sum(btn_ppp_2019, na.rm = TRUE))

bhutan_adm1 <- bhutan_adm1 %>%
  add_column(pop19 = totals_adm1$totals_adm1)

save(bhutan_adm1, file = "btn_amd1_2.0.RData")
load("btn_amd1_2.0.RData")

bhutan_adm1 <- bhutan_adm1 %>%
  mutate(area = sf::st_area(bhutan_adm1))

bhutan_adm1 <- bhutan_adm1 %>%
  mutate(area = sf::st_area(bhutan_adm1) %>% 
           units::set_units(km^2))

bhutan_adm1 <- bhutan_adm1 %>%
  mutate(area = sf::st_area(bhutan_adm1) %>% 
           units::set_units(km^2)) %>%
  mutate(density = area / pop19)

bhutan_adm1 %>%
  ggplot(aes(x=NAME_1, y=pop19)) +
  geom_bar(stat="identity", color="blue", width=.5) +
  coord_flip() +
  xlab("County") + ylab("Population")

btn_bar <- bhutan_adm1 %>%
  mutate(NAME_1 = fct_reorder(NAME_1, pop19)) %>%
  ggplot(aes(x=NAME_1, y=pop19, fill = pop19)) +
  geom_bar(stat="identity", color="blue", width=0.5) +
  coord_flip() +
  xlab("County") + ylab("Population") +
  geom_text(aes(label=percent(pop19/sum(pop19))),
          position = position_stack(vjust = 0.5),
          size=2.0) +
  scale_fill_gradient(low = "yellow", high = "red")

btn_spatial <- ggplot(bhutan_adm1) +
  geom_sf(aes(fill = pop19)) +
  geom_sf_text(aes(label = NAME_1),
               color = "black",
               size = 1.9) +
  geom_sf_text(aes(label=round(bhutan_adm1$density, 2)),
               color="black", size=2, nudge_y = -0.08) +
  scale_fill_gradient(low = "yellow", high = "red") +
  xlab("Latitude") + ylab("Longitude") 
  
bhutan <- ggarrange(btn_spatial, btn_bar, nrow = 1, widths = c(2.25,2))
annotate_figure(bhutan, top = text_grob("Bhutan in 2019", color = "black", face = "bold", size = 15))

ggsave("bhutan.png", width = 20, height = 10, dpi = 200)

#ADM2
bhutan_adm2  <- read_sf("/Users/Monica/Google Drive/ABM/data/gadm36_BTN_shp/gadm36_BTN_2.shp")
bhutan_adm2

ncores <- detectCores() - 1
beginCluster(ncores)
pop_vals_adm2 <- raster::extract(bhutan_pop19, bhutan_adm2, df = TRUE)
endCluster()

save(pop_vals_adm2, file = "pop_vals_adm2.RData")

load("pop_vals_adm2.RData")

totals_adm2 <- pop_vals_adm2 %>%
  group_by(ID) %>%
  summarize(totals_adm2 = sum(btn_ppp_2019, na.rm = TRUE))

bhutan_adm2 <- bhutan_adm2 %>%
  add_column(pop19 = totals_adm2$totals_adm2)

save(bhutan_adm2, file = "btn_adm2_2.0.RData")
load("btn_adm2_2.0.RData")

bhutan_adm2 <- bhutan_adm2 %>%
  mutate(area = sf::st_area(bhutan_adm2) %>% 
           units::set_units(km^2)) %>%
  mutate(density = area / pop19)

bhutan_adm2 %>%
  ggplot(aes(x=NAME_1, y=pop19, weight = pop19, fill = NAME_2)) +
  geom_bar(stat="identity", color="blue", width=.75) +
  coord_flip() +
  theme(legend.position = "none") +
  geom_text_repel(aes(label = NAME_2),
                  position = position_stack(vjust = 0.5),
                  force = 0.0005,
                  direction = "y",
                  size = 1.35,
                  segment.size = .2,
                  segment.alpha = .4)

ggsave("btn_adm2_bp.png", width = 20, height = 15, dpi = 300)
