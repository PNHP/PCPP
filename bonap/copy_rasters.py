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

import arcpy, urllib, urllib2, requests
import os, time
from os import listdir
from os.path import isfile, join
from arcpy import env
from arcpy.sa import *
import shutil, sys

arcpy.env.overwriteOutput = True

image_folder = r'W:\Heritage\Heritage_Projects\1495_PlantConservationPlan\BONAP\test\bonap_originals'
image_gdb = 'W:\Heritage\Heritage_Projects\1495_PlantConservationPlan\bonap\test\bonap_rasters.gdb'

bonap_maps = [f for f in os.listdir(image_folder) if f.endswith('.png')]
bonap_maps = [os.path.join(image_folder,f) for f in bonap_maps]

arcpy.RasterToGeodatabase_conversion(bonap_maps, image_gdb)
