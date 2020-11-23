                                              Final Project: Gravity Model of Nepal
## Analysis of London Gravity Model 
As an introduction to gravity modeling, I attempted to construct a model for London using "Dr Ds Idiots Guide to Spatial Interaction Modelling for Dummies". To model movement across London, I used census data that reported people's home, workplace, and mode of transport. This data allowed me to estimate commuter flows across boroughs. Using this commuter flow data (which excludes commutes that occur internally within each borough) and the distance between each borough, I could make a model of spatial interactions across London. Below is the resulting origin-destination matrix for London. The matrix rows and columns represent the boroughs, with each cell representing the distance between each borough. 

![Origin/Destination Matrix: London](project_3/odm_london.png)

This exercise not only helped me practice for creating a gravity model of my location, but it also taught me several important factors to consider when modeling movement. First, I learned that flow between two places is proportional to the mass at the destination and origin and the inverse of their distance. This means that as mass at a point increases, the flow between them increases. Furthermore, as the distance between two places increases, the flow decreases. Outside of these basic principles, flow is also determined by model variables. For example, flow is largely influcenced by job commute; however, it can also be affected by more unexpected variables such as destination attractiveness or average salary in an area. All of this information from "Dr Ds Idiots Guide to Spatial Interaction Modelling for Dummies" helped me understand the best approach to creating my own gravity model for Nepal. 

## In/Out Migration in Nepal
*Additionally, incorporate the Garcia et al. paper into your description while introducing your the migration data for your selected country.*
For my project, I model migration patterns in Nepal. For data on movement patterns, I use migration flow and nightime light data from WorldPop. These data sets are separated by Nepal's pre-2015 adm2 borders; therefore, I use pre-2015 adm2 data as the basis of my maps. To begin, I created spatial plots to describe the in and out migrations in each subdivision. As can be seen in both maps, the highest number of in and out migrations (lightest blue) are in the administrative division of Janakpur. Janakpur sits between the districts that hold the capital of Nepal (the Bagmati district) and the district that has Mount Everest (Sagarmatha). These are the two most desireable areas of Nepal; therefore, it makes sense that people would travel to and from these destinations, specifically through the Janakpur district. Outside of Janakpur, the maps show general trends of having more in/out migration on the eastern side of the country and less on the western side. This is most likely due to the eastern side having more of Nepal's destinations and having a higher number of border crossings. 

![](project_3/inmigration.png)
![](project_3/outmigration.png)

## Origin-Destination Matrix and Gravity Model for Nepal
To create a gravity model representing the migration of the plots above, I created a matrix similar to the one I created for the London gravity model. I began by finding the distance and migration between each adm2 district. As an additional variable to measure movement, I also accounted for the amount of nighttime lights across the country (designated by variable "ntl"). Finally, the table has geometry columns contianing the longitude and latitude of the center point for each origin and destination district. A sample of this table is below. 

![](project_3/OD_npl.png)

All of the information in the above table contributed to an origin-destination matrix for movement in Nepal. The below matrix has 14 rows and columns, with each representing an origin and destination subdivision. Each cell contains the migration information between the column and row subdivision. Internal migrations are not considered, so cells that represent the same origin and destination subdivision have zero migration. This matrix allows me to model spatial interactions across all of Nepal's adm2s.

![](project_3/odm_npl.png)

Names of origin and destination administrative subdivisions:
1. Mechi  
2. Koshi  
3. Sagarmatha	  
4. Janakpur  
5. Bagmati  
6. Narayani  
7. Gandaki  
8. Dhawalagiri  
9. Lumbini	  
10. Rapti  
11. Bheri  
12. Karnali  
13. Seti  
14. Mahakali  


Describe your OD matrix and how it is used to model migration across the administrative subdivisions that comprise your selected location.
Produce an animation of migration and elaborate on how your OD matrix and gravity model could be integrated with your simulation.
How would you modify the number of points departing from each origin?
How would you modify the time variable? What scale is the temporal dimension at this level?
How would the gravity model update these attributes in order to produce a different simulation of migration that more closely approximates reality?

![](project_3/output.gif)

## Voronoi polygons of Siraha, Nepal
At the level of your selected, higher resolution administrative subdivision (where you produced defacto descriptions of settlements), use the center points of each settlement to produce a tesselation of voronoi polygons. Similar to your analysis of the higher level administrative subdivisions, address the following.
How would you produce an OD matrix of these higher resolution entities? Which variables would you include? Are you lacking any data that would improve upon your model results?
How would you modify the number of points departing from each origin? How would you determine each points destination?
How would you modify the time variable? What scale is the temporal dimension at this level?
How would the gravity model update these attributes in order to produce a different simulation of migration?
How would you go about integrating migration and transport activities at the differing geospatial and temporal scales of these hierarchical levels?

![](project_3/sir_vornoi.png)
