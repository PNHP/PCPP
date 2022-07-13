#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      MMoore
#
# Created:     14/06/2018
# Copyright:   (c) MMoore 2018
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import arcpy
import os

arcpy.env.overwriteOutput = True

image_folder = r'W:\Heritage\Heritage_Projects\1495_PlantConservationPlan\BONAP\bonap_originals1'
image_gdb = r'W:\Heritage\Heritage_Projects\1495_PlantConservationPlan\BONAP\bonap_rasters.gdb'

bonap_maps = [f for f in os.listdir(image_folder) if f.endswith('.tif')]
bonap_maps = [os.path.join(image_folder,f) for f in bonap_maps]

arcpy.RasterToGeodatabase_conversion(bonap_maps, image_gdb)
