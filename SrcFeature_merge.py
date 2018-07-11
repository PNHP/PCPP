#-------------------------------------------------------------------------------
# Name:        SrcFeature_merge.py
# Purpose:     prepares the three source feature inputs for the plant
#              conservation prioritorization
#
# Author:      ctracey
#
# Created:     10/07/2018
#-------------------------------------------------------------------------------

#import packages
import os, arcpy, datetime, re
from arcpy import env

# set directories and env variables
arcpy.env.overwriteOutput = True
arcpy.env.qualifiedFieldNames = False

# set input paramenters for Tool
ptrep = arcpy.GetParameterAsText(0)
srcpt = arcpy.GetParameterAsText(1)
srcln = arcpy.GetParameterAsText(2)
srcpy = arcpy.GetParameterAsText(3)
PALTA_merge = arcpy.GetParameterAsText(4)
outGDB = arcpy.GetParameterAsText(5)

# create tool variables
cutoff = int(time.strftime("%Y")) - 50

# process source points
print("Processing Source Points")
srcpt_out = arcpy.CopyFeatures_management(srcpt, os.path.join(outGDB,"srcpt"))
arcpy.JoinField_management(srcpt_out, "EO_ID", ptrep, "EO_ID", ["EORANK","LASTOBS","SURVEYDATE","PREC_BCD","EO_TRACK"])
arcpy.AddField_management(srcpt_out, "year", "LONG")
with arcpy.da.UpdateCursor(srcpt_out,["LASTOBS","year"]) as cursor:
    for row in cursor:
        try:
            row[1]=int(row[0][0:4])
            cursor.updateRow(row)
        except:
            row[1] = None
            cursor.updateRow(row)
with arcpy.da.UpdateCursor(srcpt_out,["year","EORANK","EO_TRACK","EST_RA"]) as cursor:
    for row in cursor:
        if row[3] == "Very Low":
            cursor.deleteRow()
        if row[2] != "Y" and row[2] != "W":
            cursor.deleteRow()
        if row[1] == "H" or row[1] == "H?" or row[1] == "X" or row[1] == "X?":
            cursor.deleteRow()
        if row[0] is None:
            cursor.deleteRow()
        elif row[0] < cutoff:
            cursor.deleteRow()

#srcpt_final = arcpy.CopyFeatures_management("srcpt_out_lyr", os.path.join(outGDB,"srcptfinal"))

# process source lines
print("Processing Source Lines")
srcln_out = arcpy.CopyFeatures_management(srcln, os.path.join(outGDB,"srcln"))
arcpy.JoinField_management(srcln_out, "EO_ID", ptrep, "EO_ID", ["EORANK","LASTOBS","SURVEYDATE","PREC_BCD","EO_TRACK"])
arcpy.AddField_management(srcln_out, "year", "LONG")
with arcpy.da.UpdateCursor(srcln_out,["LASTOBS","year"]) as cursor:
    for row in cursor:
        try:
            row[1]=int(row[0][0:4])
            cursor.updateRow(row)
        except:
            row[1] = None
            cursor.updateRow(row)
with arcpy.da.UpdateCursor(srcln_out,["year","EORANK","EO_TRACK","EST_RA"]) as cursor:
    for row in cursor:
        if row[3] == "Very Low":
            cursor.deleteRow()
        if row[2] != "Y" and row[2] != "W":
            cursor.deleteRow()
        if row[1] == "H" or row[1] == "H?" or row[1] == "X" or row[1] == "X?":
            cursor.deleteRow()
        if row[0] is None:
            cursor.deleteRow()
        elif row[0] < cutoff:
            cursor.deleteRow()


# process source polygons
print("Processing Source Polygons")
print("Processing Source Lines")
srcpy_out = arcpy.CopyFeatures_management(srcpy, os.path.join(outGDB,"srcpy"))
arcpy.JoinField_management(srcpy_out, "EO_ID", ptrep, "EO_ID", ["EORANK","LASTOBS","SURVEYDATE","PREC_BCD","EO_TRACK"])
arcpy.AddField_management(srcpy_out, "year", "LONG")
with arcpy.da.UpdateCursor(srcpy_out,["LASTOBS","year"]) as cursor:
    for row in cursor:
        try:
            row[1]=int(row[0][0:4])
            cursor.updateRow(row)
        except:
            row[1] = None
            cursor.updateRow(row)
with arcpy.da.UpdateCursor(srcpy_out,["year","EORANK","EO_TRACK","EST_RA"]) as cursor:
    for row in cursor:
        if row[3] == "Very Low":
            cursor.deleteRow()
        if row[2] != "Y" and row[2] != "W":
            cursor.deleteRow()
        if row[1] == "H" or row[1] == "H?" or row[1] == "X" or row[1] == "X?":
            cursor.deleteRow()
        if row[0] is None:
            cursor.deleteRow()
        elif row[0] < cutoff:
            cursor.deleteRow()

# buffer the src pts and lines by 5 meters and merge to one polygon data set
distanceField = "5 Meters"
srcpt_buffer = arcpy.Buffer_analysis(srcpt_out,"srcpt_buffer", distanceField, "FULL", "ROUND" )
srcln_buffer = arcpy.Buffer_analysis(srcln_out,"srcln_buffer", distanceField, "FULL", "ROUND" )

src_merge = arcpy.Merge_management([srcpt_buffer,srcln_buffer,srcpy_out], "src_merge")
src_merge1 = arcpy.Dissolve_management(src_merge, "src_merge1", ["EO_ID"],"","MULTI_PART")
arcpy.JoinField_management(src_merge1, "EO_ID", ptrep, "EO_ID", ["SNAME","SCOMNAME","EORANK","LASTOBS","SURVEYDATE","PREC_BCD","EST_RA","EO_TRACK"])
# merge with protected land
src_protected = arcpy.Identity_analysis(src_merge1,PALTA_merge, "src_protected")
arcpy.TableToTable_conversion(src_protected,"E:\pcpp\PCPP\EO_x_landowner","intersect.csv")
