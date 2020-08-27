rm(list=ls(all=TRUE))

# install.packages("tidyverse", dependencies = TRUE)
# install.packages("sf", dependencies = TRUE)

library(tidyverse)
library(sf)

setwd("/Users/Monica/Google Drive/ABM/Administrative_Subdivisions")

lbr_int  <- sf::read_sf("/Users/Monica/Google Drive/ABM/Administrative_Subdivisions/data/gadm36_LBR_shp/gadm36_LBR_0.shp")
lbr_adm1   <- sf::read_sf("/Users/Monica/Google Drive/ABM/Administrative_Subdivisions/data/gadm36_LBR_shp/gadm36_LBR_1.shp")
lbr_adm2   <- sf::read_sf("/Users/Monica/Google Drive/ABM/Administrative_Subdivisions/data/gadm36_LBR_shp/gadm36_LBR_2.shp")

ggplot() +
  geom_sf(data = lbr_int,
          color = "black",
          fill = "gold",
          alpha = 0.75) +
  geom_sf_text(data = lbr_int,
               aes(label = "Liberia"),
               color = "black")

 ggplot() +
  geom_sf(data = lbr_adm1,
          color = "black",
          fill = "gold",
          alpha = 0.75) +
  geom_sf(data = lbr_int,
          color = "black",
          fill = "gold",
          alpha = 0.75) +
  geom_sf_text(data = lbr_adm1,
               aes(label = lbr_adm1$NAME_1),
               size = 2,
               color = "black") +
  geom_sf_label(data = lbr_int,
                aes(label = "Liberia"),
                color = "black")
 
 ggplot() +
   geom_sf(data = lbr_adm2,
           color = "black",
           fill = "gold",
           alpha = 0.75) +
   geom_sf(data = lbr_adm1,
           color = "black",
           fill = "gold",
           alpha = 0.75) +
   geom_sf(data = lbr_int,
           alpha = 0.75) +
   geom_sf_text(data = lbr_adm2,
                aes(label = lbr_adm2$NAME_2),
                size = 1) +
   geom_sf_text(data = lbr_adm1,
                aes(label = lbr_adm1$NAME_1),
                size = 3)
 
 ggsave("liberia.png")

montserrado_adm1 <- lbr_adm1 %>%
   filter(NAME_1 == "Montserrado")
 
lbr_adm2 %>%
   filter(NAME_1 == "Montserrado") %>%

  
 ggplot() +
    geom_sf(fill = "gold") +
    geom_sf_text(aes(label = NAME_2),
               size = 1.75,
               color = "black") +
    geom_sf(data = montserrado_adm1,
            size = 0.75,
            alpha = 0.4) +
    geom_sf_text(data = montserrado_adm1,
                 aes(label = "Montserrado"),
                 size = 4) +
    xlab("longitude") + ylab("latitude") +
    ggtitle("Montserrado County", subtitle = "Liberia's most populous county and its subdivisions") +
    theme(plot.title = element_text(hjust = 0.5), 
          plot.subtitle = element_text(hjust = 0.5))
 
 ggsave("montserrado.png")
               
 plot1 <- ggplot() +
   geom_sf(data = lbr_adm1,
           size = 0.5,
           color = "gray50",
           fill = "gold3",
           alpha = 0.5) +
   geom_sf(data = lbr_int,
           size = 2.0,
           alpha = 0) +
   geom_rect(data = lbr_adm1, xmin = -10.95, xmax = -10.3, ymin = 6.2, ymax = 6.9, 
             fill = NA, colour = "green", size = 2) +
   geom_rect(data = lbr_adm1, xmin = -8.80, xmax = -7.35, ymin = 4.3, ymax = 5.65, 
             fill = NA, colour = "blue", size = 2) +
   geom_sf_text(data = lbr_adm1,
                aes(label = NAME_1),
                size = 3) +
 #  geom_sf_text(data = lbr_adm1,
  #              aes(x = -10.60, y = 6.05, label = "Detail A"),
  #              size = 2,
   #             color = "green") +
  # geom_sf_text(data = lbr_adm1,
    #            aes(x = -9.10, y = 4.6, label = "Detail B"),
    #            size = 2,
    #            color = "blue") +
   xlab("longitude") + ylab("latitude") +
   ggtitle("Liberia", subtitle = "Details A & B") +
   theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5),
         panel.background = element_rect(fill = "azure"),
         panel.border = element_rect(fill = NA))
 
 ### Create Detail A Map
 
 mont_cnty <- lbr_adm1 %>%
   filter(NAME_1 == "Montserrado")
 
 plot2 <- lbr_adm2 %>%
   filter(NAME_1 == "Montserrado") %>%
   ggplot() +
   geom_sf(size = .15,
           fill = "Green") +
   geom_sf_text(aes(label = NAME_2),
                size = 1.75) +
   geom_sf(data = mont_cnty,
           size = .5,
           alpha = 0) +
   geom_sf_text(data = mont_cnty,
                aes(label = "Montserrado"),
                size = 3.75,
                alpha = .5) +
   xlab("longitude") + ylab("latitude") +
   ggtitle("Detail A", subtitle = "Montserrado County") +
   theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5),
         panel.background = element_rect(fill = "azure"),
         panel.border = element_rect(fill = NA))
 
 
 ### Create Detail B Map
 
 east_cnties <- lbr_adm1 %>%
   filter(NAME_1 == "Grand Kru" | NAME_1 == "Maryland" | NAME_1 == "River Gee")
 
 plot3 <- lbr_adm2 %>%
   filter(NAME_1 == "Grand Kru" | NAME_1 == "Maryland" | NAME_1 == "River Gee") %>%
   ggplot() +
   geom_sf(size = .15,
           fill = "Blue") +
   
   geom_sf_text(aes(label = NAME_2),
                size = 1.75) +
   geom_sf(data = east_cnties,
           size = .5,
           alpha = 0) +
   geom_sf_text(data = east_cnties,
                aes(label = NAME_1),
                size = 3.75,
                alpha = .5) +
   xlab("longitude") + ylab("latitude") +
   ggtitle("Detail B", subtitle = "River Gee, Grand Kru & Maryland Counties") +
   theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5),
         panel.background = element_rect(fill = "azure"),
         panel.border = element_rect(fill = NA))
 
 
 
 ggplot() +
   coord_equal(xlim = c(0, 6.0), ylim = c(0, 4), expand = FALSE) +
   annotation_custom(ggplotGrob(plot1), xmin = 0.0, xmax = 4.0, ymin = 0, 
                     ymax = 4.0) +
   annotation_custom(ggplotGrob(plot3), xmin = 4.0, xmax = 6.0, ymin = 0, 
                     ymax = 2.0) +
   annotation_custom(ggplotGrob(plot2), xmin = 4.0, xmax = 6.0, ymin = 2.0, 
                     ymax = 4.0) +
   theme_void()
 
 ggsave("details.png")
 