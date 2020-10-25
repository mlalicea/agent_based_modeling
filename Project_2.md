*Provide a written description of your selected household survey including the number of household and person observations as well as the variables in your source data.*

For this project, I aimed to create a synthetic population of an adm1 and adm2 region in Nepal. Having an accurate population is important for any agent-based model; however, since populations are constantly growing and population surveys are often infrequent, it is often most effective to make a synthetic population. My synthetic population is modeled off of a DHS household survey of Nepal from 2016. I obtained this data via the following research proposal: 
> I’m an undergraduate student in a 400-level class about agent-based modeling. For my research project, I am developing an agent based model of Nepal in order to better understand human behavior, transportation, and health-care in the Himalayas. With the DHS Nepal data, I will be creating multinomial logistic regression modelsto generate a closer-to-reality synthetic population by specifying, estimating,and validating a continuous spatial model. This model would be compared to my previous work estimating a discretized spatial model of Bhutan. Central to achieving this research goal of continuous spatial multinomial logistic regression model (for inferring conditional probabilities) will be increasing the resolution of the sampling unit from political subdivisions to individual households. I will achieve this goal by meeting the following objectives.
> 1. Use remotely sensed data to estimate all dwelling unit locations across Nepal.
> 2. Use survey data to estimate a spatially continuous multinomial logistic regression model for predicting household size, gender and age of all dwelling units across Nepal.
> 3. Use survey data to estimate a spatially continuous multinomial logistic regression model for predicting the remaining demographic characteristics of all household members. 

> References: [1] Adrian Baddeley, Ege Rubak, and Rolf Turner. Spatial Point Patterns: Methodology and Applications with R. CRC Press, 2016. [2] Tyler Frazier and Andreas Alfons. “Generating a close-to-reality synthetic population of Ghana”. unpublished. accessible at https://works.bepress.com/tylerfrazier/. 2012.

The household survey reports data for 11,040 households across 3,920 variables. To create my model, I focused on the following variables (with their column label):
- Household ID (hhid)
- Unit (hv004)
- Survey weights (hv005/1000000)
- Province (hv024)
- District (shdist)
- Size (hv009)
- Gender (columns 350-387)
- Age (columns 388-425)
- Education (columns 426-463)
- Wealth (columns 426-463)

In this dataset, each row represents one household and every person in the household is represented by a column. For example, the "Gender" variable spans 38 columns because every household member is represented by one column and the largest household in the dataset has 38 members. To determine the total number of people in the survey, I pivoted the columns representing household members, creating a dataset where every row represents a person. This demonstrated a total of 49,064 person observations in the household survey.  


*Provide a written description of your spatially located households at the adm1 level of your selected location, including how you located each household, generated the household structure including demographic attributes of persons, and the percent error calculated. If you faced computational issues at the adm1 level when attempting to pivot from households to persons, describe those limitations.*

The first location that I spatially locatd households was at the adm1 level of Nepal: Province 2. Originally, I attempted to locate households across adm0, but the area was too large and the code would not run with my laptop's limited computing power. As a result, I decided to look at a smaller area, such as Province 2. 

Province 2 is a southeastern region of Nepal that borders India. Subsetting the household survey by province revealed that the survey reported on 1,626 households in Province 2. 

![](DHS_data/prov2.png)

Provide a written description of your spatially located households at the adm2 level of your selected location, again including how you located each household, generated the household structure including demographic attributes of persons, and the percent error calculated. Further analyze your synthetically generated households and persons with regard to percent error. Do you think this population is more or less accurate than the one generated at the adm1 level? What could you have done to improve your measures of accuracy?

![](DHS_data/siraha.png)

When compared to a randomly generated synthetic population that describes the demographic attributes of households and persons, does yours more closely approximate reality? How is yours an improvement over a synthetic population that was generated in accordance with complete spatial randomness? Generate plots and incorporate results from your work as evidence in support of an argument that the synthetic population you generated is a good approximation of the reality that existed in your selected location at that given time.
