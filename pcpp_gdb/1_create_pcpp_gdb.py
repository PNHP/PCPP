import os, arcpy, datetime, math

######################################################################################################################################################
folder = r'H:\Projects\PCPP' # path to folder where PCPP gdb will be created
pcpp_gdb = "PCPP.gdb"
biotics_gdb = r'W:\Heritage\Heritage_Data\Biotics_datasets.gdb' # path to current biotics gdb
eo_reps = r'eo_reps' # name of eoreps layer
cpp = r"C:\\Users\\MMoore\\AppData\\Roaming\\Esri\\ArcGISPro\\Favorites\\PNHP_Working_pgh-gis0.sde\\PNHP.DBO.CPPConservationPlanningPolygons\\PNHP.DBO.CPP_Core" # path to current cpp core layer
######################################################################################################################################################

arcpy.env.overwriteOutput = True
arcpy.env.workspace = "memory"
date = datetime.datetime.now()
year = date.year
month = date.month
day = date.day
##pcpp_gdb = "PCPP_"+str(year)+"_"+str(month)+"_"+str(day)+".gdb"

print("Creating empty PCPP file geodatabase...")
arcpy.CreateFileGDB_management(folder, pcpp_gdb)

print("Importing Biotics plant EOs into PCPP geodatabase...")
plant_clause = "((ELCODE LIKE '{}') OR (ELCODE LIKE '{}'))".format("P%","N%")
##plant_clause = "((ELCODE LIKE '{}') OR (ELCODE LIKE '{}')) AND ((GRANK NOT LIKE '{}') AND (GRANK NOT LIKE '{}') AND (GRANK NOT LIKE '{}'))".format("P%","N%","G1%","G2%","G3%")
eo_reps_plants = arcpy.FeatureClassToFeatureClass_conversion(os.path.join(biotics_gdb,eo_reps),os.path.join(folder,pcpp_gdb),"eo_reps_plants",plant_clause)

print("Adding exclude fields to plant EOs...")
arcpy.AddField_management(eo_reps_plants,"exclude_reason","TEXT","","",150)
arcpy.AddField_management(eo_reps_plants,"PCPP_use","TEXT","","",12)

cutoff_year = year-50
print("Applying exclusion criteria to exclude fields...")
with arcpy.da.UpdateCursor(eo_reps_plants,['EO_TRACK','EORANK','EST_RA','PREC_BCD','Shape_Area','LASTOBS_YR','USESA','exclude_reason']) as cursor:
    for row in cursor:
        if row[0] == 'N':
            row[7] = "EO_TRACK"
            cursor.updateRow(row)
        elif row[1] == 'X' or row[1] == 'X?':
            row[7] = "EORANK"
            cursor.updateRow(row)
        elif row[2] == 'Very Low' or row[2] == 'Low':
            row[7] = "EST_RA"
            cursor.updateRow(row)
        elif row[3] == 'G':
            row[7] = "PREC_BCD"
            cursor.updateRow(row)
        elif row[4] > 19500000:
            row[7] = "AREA_IMPRECISION"
            cursor.updateRow(row)
        elif (row[5] < 1950 and row[6] is not None) or row[5] < cutoff_year:
            row[7] = "ER_DATE"
            cursor.updateRow(row)
        else:
            pass

with arcpy.da.UpdateCursor(eo_reps_plants,['exclude_reason','PCPP_use']) as cursor:
    for row in cursor:
        if row[0] is None:
            row[1] = 'Y'
            cursor.updateRow(row)
        else:
            row[1] = 'N'
            cursor.updateRow(row)

print("Creating PCPP dataset...")
plant_clause = "PCPP_use = '{}'".format("Y")
pcpp_eo_reps = arcpy.FeatureClassToFeatureClass_conversion(eo_reps_plants,os.path.join(folder,pcpp_gdb),"pcpp_final",plant_clause)

print("Calculating buffer distance...")
arcpy.AddField_management(pcpp_eo_reps,'buffer_dist','DOUBLE')
with arcpy.da.UpdateCursor(pcpp_eo_reps,['Shape_Area','buffer_dist']) as cursor:
    for row in cursor:
        if row[0] < 45238.93:
            row[1] = 120 - math.sqrt((row[0]/math.pi))
            cursor.updateRow(row)
        else:
            row[1] = 0
            cursor.updateRow(row)

with arcpy.da.SearchCursor(cpp,'EO_ID') as cursor:
    cpp_list = sorted({row[0] for row in cursor})

eo_buff = os.path.join(folder,pcpp_gdb,"eo_buff")
pcpp_lyr = arcpy.MakeFeatureLayer_management(pcpp_eo_reps,"pcpp_eo_reps_lyr")
select_qry = "{} NOT IN ({})".format("EO_ID",", ".join([str(n) for n in cpp_list]))
arcpy.SelectLayerByAttribute_management(pcpp_lyr,'NEW_SELECTION',select_qry)
arcpy.Buffer_analysis(pcpp_lyr,eo_buff,"buffer_dist","FULL","ROUND","LIST",["EO_ID"])

print("Replacing PCPP EOs with CPPs or buffered EOs...")
eo_buff_dict = {}
with arcpy.da.SearchCursor(eo_buff,["EO_ID","SHAPE@"]) as scursor:
    for row in scursor:
        eo_buff_dict[str(row[0])] = row[1]

with arcpy.da.UpdateCursor(pcpp_eo_reps,["EO_ID","SHAPE@"]) as ucursor:
    for row in ucursor:
        recordID = str(row[0])
        if recordID in eo_buff_dict:
            row[1] = eo_buff_dict[recordID]
            ucursor.updateRow(row)

cpp_dict = {}
with arcpy.da.SearchCursor(cpp, ["EO_ID", "SHAPE@"]) as sCursor:
    for row in sCursor:
        cpp_dict[str(row[0])] = row[1]

with arcpy.da.UpdateCursor(pcpp_eo_reps, ["EO_ID", "SHAPE@"]) as uCursor:
    for row in uCursor:
        recordID = str(row[0])
        if recordID in cpp_dict:
            row[1] = cpp_dict[recordID]
            uCursor.updateRow(row)

arcpy.AlterAliasName(eo_reps_plants,"EO Reps - Plants")
arcpy.AlterAliasName(pcpp_eo_reps,"PCPP Features")

arcpy.Delete_management(eo_buff)