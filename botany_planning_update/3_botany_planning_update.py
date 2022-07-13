# import libraries
import arcpy, os
from arcpy import env
from arcpy.sa import *
import numpy as np
import pandas as pd

######################################################################################################################################################
######################################################################################################################################################
# set paths to data and workspaces
new_sites = r"H:\\Projects\\PCPP\\PCPP.gdb\\PCPP_sites_300_meters"
old_sites = r"H:\\Projects\\PCPP\\PCPP.gdb\\BotanySites2019"
output_change_tbl = r"H:\\Projects\\PCPP\\PCPP.gdb\\site_updates_2022"
######################################################################################################################################################

# set environmental variables
arcpy.env.overwriteOutput = True
arcpy.env.qualifiedFieldNames = False
arcpy.env.workspace = "memory"

# add site_id_txt field to each site feature class so that the join attribute function can be used in spatial joins
for fc in [new_sites,old_sites]:
    if len(arcpy.ListFields(fc,"site_id_txt")) == 0:
        arcpy.AddField_management(fc,"site_id_txt","TEXT","","",100)
    with arcpy.da.UpdateCursor(fc,["site_id","site_id_txt"]) as cursor:
        for row in cursor:
            row[1] = str(row[0])
            cursor.updateRow(row)

# create update table
output_change_tbl = arcpy.CreateTable_management(os.path.dirname(output_change_tbl),os.path.basename(output_change_tbl))
update_fields = ["site_id_new","site_id_old","spatial_change"]
for f in update_fields:
    arcpy.AddField_management(output_change_tbl,f,"TEXT","","",50)

#prepare fieldmap for old to new spatial join
fieldmappings = arcpy.FieldMappings()
fieldmappings.addTable(old_sites)
fieldmappings.addTable(new_sites)

#remove unneeded fields
keepers = ["site_id","site_id_txt"]
for field in fieldmappings.fields:
    if field.name not in keepers:
        fieldmappings.removeFieldMap(fieldmappings.findFieldMapIndex(field.name))

#update field properties for site_id_txt that will be joined by commas
index = fieldmappings.findFieldMapIndex("site_id_txt")
fieldmap = fieldmappings.getFieldMap(index)
fieldmap.mergeRule = "join"
fieldmap.joinDelimiter = ","
fieldmappings.replaceFieldMap(index,fieldmap)

#perform spatial joins
oldTOnew_join = arcpy.SpatialJoin_analysis(old_sites, new_sites, "memory\\oldTOnew_join", "JOIN_ONE_TO_ONE", "KEEP_ALL", fieldmappings,"INTERSECT")
newTOold_join = arcpy.SpatialJoin_analysis(new_sites, old_sites, "memory\\newTOold_join", "JOIN_ONE_TO_ONE", "KEEP_ALL", fieldmappings,"INTERSECT")

#get list of geometry tokens from old sites
old_geoms = []
with arcpy.da.SearchCursor(old_sites,"SHAPE@") as cursor:
    for row in cursor:
        old_geoms.append(row[0])
#assign insert cursor for site update table
icur = arcpy.da.InsertCursor(output_change_tbl,update_fields)
#begin search cursor on join table to start logic expressions
with arcpy.da.SearchCursor(oldTOnew_join,["Join_Count","site_id","site_id_txt"]) as scursor:
    for row in scursor:
        #if 0 new sites intersect old sites, insert row designating deleted site
        if row[0] == 0:
            icur.insertRow([None,str(row[1]),"deleted site"])
        #if more than 1 new sites intersect old sites, insert row designating that the site was split
        elif row[0] > 1:
            for i in row[2].split(',')[1:]:
                icur.insertRow([i,str(row[1]),"split site"])
        else:
            pass

with arcpy.da.SearchCursor(newTOold_join,["Join_Count","site_id","site_id_txt","SHAPE@"]) as scursor:
    for row in scursor:
        #if 0 old sites intersect new sites, insert row designating added site
        if row[0] == 0:
            icur.insertRow([str(row[1]),None,"added site"])
        #if more than 1 old sites intersect new sites, insert row designating that sites were merged
        elif row[0] > 1:
            for i in row[2].split(',')[1:]:
                icur.insertRow([str(row[1]),i,"merged site"])
        elif row[0] == 1 and row[3] in old_geoms:
            icur.insertRow([str(row[1]),row[2].split(',')[1],"no spatial change"])
        elif row[0] == 1 and row[3] not in old_geoms:
            icur.insertRow([str(row[1]),row[2].split(',')[1],"spatial change"])
        else:
            pass

del icur

fields = ["site_id_previous","spatial_update_description"]
types = ["SHORT","TEXT"]
length = [8,50]

for f,t,l in zip(fields,types,length):
    arcpy.AddField_management(new_sites,f,t,"","",l)

update_dict = {row[0]:[row[1],row[2]] for row in arcpy.da.SearchCursor(output_change_tbl,["site_id_new","site_id_old","spatial_change"])}

with arcpy.da.UpdateCursor(new_sites,["site_id_txt","site_id_previous","spatial_update_description"]) as cursor:
    for row in cursor:
        if row[0] is None:
            pass
        else:
            for k,v in update_dict.items():
                if str(k) == str(row[0]):
                    if v[0] is not None:
                        row[1] = int(v[0])
                    row[2] = v[1]
                    cursor.updateRow(row)


