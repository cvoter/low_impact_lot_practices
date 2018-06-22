# low_impact_lot_practices
Materials supporting the chapter of my PhD dissertation about low impact features on residential parcels, currently in review at Water Resources Research (Voter, C.B. and S.P. Loheide II. Urban Residential Surface and Subsurface Hydrology: Synergistic Effects of Low-Impact Features at the Parcel-Scale). 

Throughout this README, emphasis is used to highlight **filenames** and *variables*.

# data
## data/colormaps
Includes several matlab colormaps used in plots. All but **map_ylgrbu.mat** and **map_reverse_jet.mat** are tied to values of *parcelCover* (i.e., for values spanning 1 through 9).

## data/initial_pressure
Includes initial pressure (m) conditions for silt loam (SiL), moderately-compacted silt loam (SiL2c), and highly-compacted silt loam (SiL10c) baseline soil conditions. Each **\*.mat** file includes the following variables:  
  * *pSP*: complete record of pressure head (m) on April 1 for 300 year spinup simulation  
  * *pSP30*: record of pressure head (m) on April 1 at end of each 30-year loop of weather (i.e., every 30 years)  
  * *sSP*: as pSP, but saturation (-)  
  * *sSP30*: as pSP30, but saturation (-)  
  * *spIC*: pressure head on April 1 of last simulated year, used as initial conditions for model  

## data/layouts
Includes information about 2D layout of parcel features and microtopography elevations. Files include:  
  * **lot_microelev.mat**: deviations in elevation for microtopography scenario. Variables include:
    * *microElev*: matrix (*ny* X *nx*) indicating deviations in elevation (m) from overall land slope (2%) for microtopography scenarios. 
    * *sd*: standard deviation in elevation specified during random generation of elevations (Onstad, 1984)
    * *RRcalc*: calculated random roughness from randomly generated deviations in elevation (Onstad, 1984)
    * *DScalc*: calculated depression storage (cm), based on calculated random roughness (Onstad, 1984)
  * **Lot00.mat**: limited domain information for lot with connected downspout and connected sidewalk. Variables include:  
    * *dx*,*dy*: discretization in x and y direction (0.5m for both)
    * *nx*,*ny*: number of elements in x and y direction (44 and 75, respectively)
    * *xL*,*yL*: lower limit of x and y domain (0m for both)
    * *P*,*Q*: number of processors allocated to x and y domain (4 and 5, respectively)
    * *parcelCover*: matrix (*ny* X *nx*) indicating type of feature on each pixel. Key: 0 = turfgrass, 1 = street, 2 = alley, 3 = parking lot, 4 = sidewalk, 5 = driveway, 6 = frontwalk, 7 = house, 8 = house2 (extra house behind garage), 9 = garage
    * *fc*: coordinates of each impervious feature. Rows correspond to parcelCover key (i.e., row #1 = street coordinates). Columns indicate [lowerX upperX lowerY upperY].
  * **Lot10.mat**: same as Lot00, but with disconnected downspout  
  * **Lot01.mat**: same as Lot00, but with disconnected sidewalk  
  * **Lot11.mat**: same as Lot00, but with both disconnected downspout and disconnected sidewalk 

## data/model_inputs
Subdirectories indicate model runs, formatted 'Lot%d%d%d%d_%s_%s', where the four integers indicate presence (1) or absence (0) of disconnected downspout, disconnected sidewalk, transverse slope to front walk and driveway, and microtopography; the first string indicates soil type (SiL, silt loam; SiL2c, moderately-compacted; SiL10c, highly-compacted); and the last string indicates the growing season weather scenario (average or dry). Each directory includes the file **domainInfo.mat**, which includes the following variables:  
  * *dx*,*dy*,*dz*: discretization in x, y, z (0.5m horizontal, 0.1m vertical)
  * *nx*,*ny*,*nz*: number of elements in x, y, z (44, 75, 100)
  * *x*,*y*,*z*: vectors with the center x, y, or z coordinate of each element
  * *P*,*Q*,*R*: number of processors in x, y, z (4, 5, 1)
  * *domainArea*: surface area (m<sup>2</sup>) of domain
  * *elev*,*DScalc*: final elevation (m) for each pixel and calculated depression storage based on random roughness approach (Onstad, 1984)
  * *Ks_imperv*,*porosity_imperv*,*Sres_imperv*,*Ssat_imperv*,*VGa_imperv*,*VGn_imperv*: impervious surface hydraulic conductivity (m/hr), porosity (-), residual saturation (-), saturation (-), van Genuchten alpha (1/m), and van Genuchten n (-).
  * *Ks_soil*,*porosity_soil*,*Sres_soil*,*Ssat_soil*,*VGa_soil*,*VGn_soil*: as above, for soil.
  * *mn_grass*,*mn_imperv*: Manning's n (hr\*m<sup>1/3</sup>) for turfgrass and impervious surfaces
  * *parcelCover*,*fc*: parcel cover indicating feature cover and coordinates of the impervious features (see data/layouts)
  * *NaNimp*,*pervX*,*pervY*: matrix with NaNs at impervious pixels, for viewing results as well as row and column of random pervious element (sometimes helpful to have during post-processing visualization)
  * *slopeX*,*slopeY*: matrices with slope in x and slope in y directions
 
## data/soil
Includes subsurface hydraulic parameters for impervious surfaces (imperv), silt loam (SiL), moderately-compacted silt loam (SiL2c), and highly-compacted silt loam (SiL10c) baseline soil conditions. This information is ultimately incorporated into **domainInfo.mat** (see data/model_inputs).

## data/weather
Includes meterological forcing information for average and dry growing season weather scenarios, as well as non-changing CLM inputs. Each subdirectory includes the following files: 
  * **drv_clmin_start.dat**,**drv_clmin_restart.dat**: CLM timing information for new start and restart models.
  * **drv_vegp.dat**: CLM vegetation parameters (LAI, rooting parameters, etc.) for each landcover type.
  * **nldas.1hr.clm.txt**: hourly meteorological inputs needed for CLM. Columns are 1) *DSWR*, shortwave radiation (W/m<sup.2</sup>), 2) *DLWR*, longwave radiation (W/m<sup.2</sup>), 3) *APCP*, precipitation (mm/s), 4) *Temp*, air temperature (K), 5) *UGRD*, east-west wind speed (m/s), 6) *VGRD*, north-south wind speed (m/s), 7) *Press*, atmospheric pressure (pa), 8) *SPFH*, specific humidity (kg/kg).
  * **precip.mat**: hourly precipitation timeseries (m) extracted from **nldas.1hr.clm.txt** for use in Matlab post-processing.
 
# results
Due to size of output files, only a limited selection of output files are included in this repo (i.e., those used to create manuscript figures and hourly parcel fluxes).

Model subdirectories are named acording to the same convention in data/model_inputs. Each subdirectory may include the following files:
  * **WBstep.mat**: suite of variables with the hourly flux (m<sup>3</sup>) at each hour for all hydrologic fluxes (*can* = water stored in the canopy, *dd* = deep drainge, *etS* = evaptranssum, *ev* = evaporation, *precip* = precipitation, *re* = recharge, *sno* = snow water equivalent, *sr* = surface runoff, *Ss* = surface storage, *Sss* = subsurface storage, *SssRZ* = subsurface storage in the root zone aka top 1m). Files also includes the hourly forcing (*force*) for each model component (*CLM*, *PF* = parflow, *O* = overall), the hourly ouputs and storage (*calc*), and the difference between the forcing and calculated fluxes as a volume (*absErr*) and relative to the forcing (*relErr*).
  * **WBtotal.mat** (developed lots) or **WBcum.mat** (vacant lots): as with **WBstep.mat**, but with the running cumulative flux at each hour for all hydrologic fluxes. Due to changes in post-processing scripts, fluxes for developed lots are as a volume (m<sup>3</sup>), while fluxes for vacant lots are as a depth (mm).
  * **deep_drainage.grid.cum.mat**: matrix (*nx* X *ny*) with the cumulative growing season deep drainage (m<sup>3</sup>) for each model element.
  * **evaporation.grid.cum.mat**: as **deep_drainage.grid.cum.mat**, but for evaporation (from leaves and soil).
  * **transpiration.grid.cum.mat**: as **deep_drainage.grid.cum.mat**, but for transpiration.

# src

## src/manuscript_figures
Scripts here create manuscript figures based on files in results/selected_model_outputs. Files include:
  * **figure02_example_layout.m**: generates layout of lowest-impact parcel (all 5 interventions applied) with elevation indicated via heatmap.
  * **figures04_05_06_diffs_pairs.m**: calculates difference between each simulation and the baseline scenario as a depth and as a percent, as displayed in figures 4 and 5. Also calculates the synergistic effects of combining low impact interventiosn, as displayed in figure 6.
  * **figure07_compare_weather.m**: compares cumulative growing season deep drainage and evapotranspiration as spatial maps for the lowest impact lot (all 5 interventions applied) under average and dry weather scenarios.
  * **figure08_compare_vacant_lot.m**: compares total growing season runoff, deep drainage, evapotranspiration, and transpiration per unit vegetated area for the highly-compacted baseline, lowest-impact lot, and vacant lot under average and dry weather scenarios. 

## src/model_inputs
Scripts here create input directories for all 96 model simulations (in data/model_inputs) based on files in 'data' directory. Files include:
  * **lot_microtopography.m**: demonstrates how deviations in elevation were randomly generated for microtopography scenarios.
  * **lot_layouts.m**: uses lot data in data/layouts to calculate slopes and generate \*.sa input files for parflow based on downspout, sidewalk, transverse slope, and microtopography features
  * **lot_slopes.m**: fills in pits in microtopography elevation (if appropriate), calculates slopes on pervious pixels, then defines slopes for impervious features.
  * **matrixTOpfsa.m**: converts Matlab matrix (*nx* X *ny*) into **\*.sa** file suitable for input to parflow as pfsa file type.
  * **matrixTOvegm.m**: converts Matlab matrix (*nx* X *ny*) of vegetation land cover type into CLM input file **drv_vegm.dat**.
  * **model_inputs.m**: uses lot data generated by **lot_layouts.m** and adds information about soils and weather based on model scenario. After running this script, complete set of input files for all developed models resides in data/model_inputs.

## src/model_outputs
Scripts here copy and evaluate model outputs. Files include:
  * **copy_model_output.m**: script used to copy selected model output (hourly fluxes) from master directory with all parflow model outputs to this repository.
  * **assess_model_errors.m**. extracts overall absolute (mm) and relative (-) model error for each model and plots for visualization. "Error" here is the difference between model forcing (precipitation) and all other fluxes (outflows + change in storage). Relative error is calculcated relative to model forcing (precipitation). 

## src/runParflow.tcl
Version of parflow executable used to run these models. Note that for versions of parflow from 05/01/2017 to present (6/11/2018), there is a bug in how parflow interprets the Patch.bottom.BCPressure Dirichlet boundary condition. Related repositories for running parflow:
  * cvoter/parflow: forked from parflow/parflow.
  * cvoter/PFinstall: notes and scripts for installing parflow
  * cvoter/PFscripts: wrapper scripts for this executable, including additonal pre- and post-processing scripts. 

## src/plot_turfgrass_roots.m
Matlab script compares rooting parameters used in Parflow.CLM model to empirical observations of turgrass rooting depth from the literature.
