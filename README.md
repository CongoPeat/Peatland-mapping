# Central Congo Basin peatland mapping

Data and code required for reproducing the peatland extent, peat thickness and/or peat carbon density maps as reported in the following publication:

*Crezee et al. (2022). Mapping peat thickness and carbon stocks of the central Congo Basin using field data. Nature Geoscience*

Please cite this paper if you're using any of the data or code presented here.

**Data**

The .csv file contains the locations (Lat/Lon) of 1,736 ground-truth datapoints across the Republic of Congo and Democratic Republic of Congo. 
Each datapoint is classified as one of five landcover classes: 
Water, Savanna, Non-peat forming forest (terra firme + seasonally inundated forest), Palm-dominated peat swamp forest, and Hardwood-dominated peat swamp forest.

Field-measured peat thickness (LOI or corrected pole-method, in m) is listed for 477 datapoints > 0 m. 
Field-measured peat carbon density (in Mg C/ha) is listed for 80 datapoints.

**Code**

The .pro file contains the IDL code to run the Maximum Likelihood model of peatland extent in ENVI software (L3Harris Geospatial, IDL 8.7.3 and ENVI 5.5.3). If using this code, please also cite: Dargie et al., 2017. Age, extent and carbon storage of the central Congo Basin peatland complex. *Nature* 542, 86–90.

To run, create an input folder (specified under 'infolderpath') that contains five separate .csv files with lat/lon combinations only, for each of the five landcover classes used. Also create an empty output folder (specified under 'outfolderpath') to store the output files.

The remote sensing bands (6 principal components) must be stored as ENVI raster file, together with an ASCII header file (.hdr) in a single folder. Specifiy the file path of the ENVI raster file under 'RSfilepath'.

**Other**

Peat thickness and carbon density density maps presented in Crezee et al. (2022) were developed in Google Earth Engine, please see: 
https://code.earthengine.google.com/?accept_repo=users/gybjc/Central_Congo_Peatlands_2022

For questions, please contact crezeebart [at] gmail.com
