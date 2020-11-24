                                              Final Project: Gravity Model of Nepal
The goal of the final project to model movement across Nepal. 

## Analysis of London Gravity Model 
As an introduction to gravity modeling, I attempted to construct a model for London using "Dr Ds Idiots Guide to Spatial Interaction Modelling for Dummies". To model movement across London, I used census data that reported people's home, workplace, and mode of transport. This data allowed me to estimate commuter flows across boroughs. Using this commuter flow data (which excludes commutes that occur internally within each borough) and the distance between each borough, I could make a model of spatial interactions across London. Below is the resulting origin-destination matrix for London. The matrix rows and columns represent the boroughs, with each cell representing the distance between each borough. 

![Origin/Destination Matrix: London](project_3/odm_london.png)

This exercise not only helped me practice for creating a gravity model of my location, but it also taught me several important factors to consider when modeling movement. First, I learned that flow between two places is proportional to the mass at the destination and origin and the inverse of their distance. This means that as mass at a point increases, the flow between them increases. Furthermore, as the distance between two places increases, the flow decreases. This gravity model theory was echoed in the Garcia et al. paper, "Modeling internal migration flows in sub-Saharan Africa using census microdata". The paper also stressed the importance of variable selection to gravity modeling. For example, flow is largely influenced by job commute; however, it can also be affected by more unexpected variables such as destination attractiveness or average salary in an area. Garcia et al. found that a strong driving factor for migration in sub-Saharan Africa is males looking for economic opprotunity. As a result, they were careful to select variables such as "proportion of males in a region" that refected this migration,  All of this information on the basis of good spatial modeling techniques from "Modeling internal migration flows in sub-Saharan Africa using census microdata" and "Dr Ds Idiots Guide to Spatial Interaction Modelling for Dummies" helped me develop a strong approach to creating my own gravity model for Nepal. 

## In/Out Migration in Nepal
For my project, I model migration patterns in Nepal. For data on movement patterns, I use migration flow and nighttime light data from WorldPop. These data sets are separated by Nepal's pre-2015 adm2 borders; therefore, I use pre-2015 adm2 data as the basis of my maps. To begin, I created spatial plots to describe the in and out migrations in each subdivision. As can be seen in both maps, the highest number of in and out migrations (lightest blue) are in the administrative division of Janakpur. Janakpur sits between the districts that hold the capital of Nepal (the Bagmati district) and the district that has Mount Everest (Sagarmatha). These are the two most desirable areas of Nepal; therefore, it makes sense that people would travel to and from these destinations, specifically through the Janakpur district. Outside of Janakpur, the maps show general trends of having more in/out migration on the eastern side of the country and less on the western side. This is most likely due to the eastern side having more of Nepal's destinations and having a higher number of border crossings. 

![](project_3/inmigration.png)
![](project_3/outmigration.png)

## Origin-Destination Matrix and Gravity Model for Nepal
To create a gravity model representing the migration of the plots above, I created a matrix similar to the one I created for the London gravity model. I began by finding the distance and migration between each adm2 district. As an additional variable to measure movement, I also accounted for the amount of nighttime lights across the country (designated by variable "ntl"). Finally, the table has geometry columns containing the longitude and latitude of the center point for each origin and destination district. A sample of this table is below. 

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

After creating this od matrix, I begin to make a gravity model. To do this, I found the path between the center points of every division. These paths help reflect the physical movement of people between the subdivisions. Specifically, this data reflects five years of data (2005-2010) on migration. The below simulation shows these migration patterns between each subdivision over 2005-2010. To improve this model, I would modify the time variable by using more granular data. Instead of five years, using one year data for the most recent year would allow the model to be as up to date and close to reality as possible. 
![](project_3/output.gif)

## Voronoi polygons of Siraha, Nepal
To look more granularly at movement in Nepal, I created a tessellation of voronoi polygons representing Siraha-- an adm3 district in Nepal. The voronoi polygon plot illustrates the main settlements in Siraha and their center points. Using the information and by calculating the distance between each settlement, I could begin to build an od matrix for this higher resolution subdivision. To produce an OD matrix for Siraha, I would also have to find migration data at the adm3 level and data for another variable that provides information on the attractiveness of the subdivisions. For example, Siraha has a famous border crossing that would cause a lot of in/out migration into the area. Nepal is very mountainous, and as such has a limited number of major roads and transportation hubs (like the Siraha border crossing). Therefore, transportation infrastructure would play a large role in migration patterns. Transportation information could be easily obtained through the road data I used in project 1 and would significantly improve my model results. With information about the distance between each subdivision, transportation hubs, and migration data, I could successfully create an od matrix. 

![](project_3/sir_vornoi.png)

