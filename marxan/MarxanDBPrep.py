#-------------------------------------------------------------------------------
# Name:        Marxan Database Prep
# Purpose:     Prepare files and folders necessary for Marxan inputs.
# Author:      MMOORE
# Created:     05/17/2018
#-------------------------------------------------------------------------------

import arcpy, os, string
from arcpy.sa import *

# establish connections/input folders
db_location = arcpy.GetParameterAsText(0)
db_name = arcpy.GetParameterAsText(1)
db_path = os.path.join(db_location, db_name)
pu_lyr = arcpy.GetParameterAsText(2)
prot_land = arcpy.GetParameterAsText(3)
spec_lyr = arcpy.GetParameterAsText(4)

# create new database with appropriate subfolders
if not os.path.exists(db_path):
    os.makedirs(db_path)
    os.makedirs(os.path.join(db_path, "input"))
    os.makedirs(os.path.join(db_path, "output"))
    os.makedirs(os.path.join(db_path, "pu"))

arcpy.AddField_management(pu_lyr, "id", "TEXT")
arcpy.AddField_management(pu_lyr, "cost", "DOUBLE")
arcpy.AddField_management(pu_lyr, "status", "SHORT")

zcount = len(str(arcpy.GetCount_management(pu_lyr)))
num = 1
with arcpy.da.UpdateCursor(pu_lyr, ["id", "cost"]) as cursor:
    for row in cursor:
        row[0] = str(num).zfill(zcount)
        row[1] = 1
        cursor.updateRow(row)
        num += 1

scratch = "in_memory"
arcpy.AddField_management(prot_land, "class", "TEXT")
state = "PA"
arcpy.CalculateField_management(prot_land, "class", expression = '"{0}"'.format(state))
TabulateArea(pu_lyr, "id", prot_land, "class", os.path.join(scratch, "tab_area"))
arcpy.JoinField_management(pu_lyr, "id", os.path.join(scratch, "tab_area"), "id", "PA")
with arcpy.da.UpdateCursor(pu_lyr, ["PA", "Shape_Area", "status"]) as cursor:
    for row in cursor:
        if row[0]/row[1] < 0.50:
            row[2] = 0
            cursor.updateRow(row)
        else:
            row[2] = 2
            cursor.updateRow(row)
