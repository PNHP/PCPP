# import libraries
import arcpy, os
from arcpy import env
from arcpy.sa import *
import numpy as np
import pandas as pd
import sqlite3 as sqlite

######################################################################################################################################################
# set paths to data and workspaces
gdb = r'H:\Projects\PCPP\PCPP.gdb'
sql_db = r'W:\Heritage\Heritage_Projects\1495_PlantConservationPlan\PCPP_DB\PCPP.db'
distance = 300
pcpp_final = os.path.join(gdb, 'pcpp_final')
sites = os.path.join(gdb, "PCPP_sites_" + str(distance) + "_meters")
species_table = os.path.join(gdb, "species_table_" + str(distance) + "_meters")
invasives_table = os.path.join(gdb, "invasives_table_" + str(distance) + "_meters")
tiers = r'W:\Conservation_Science\Science\_GeophysicalSettingRevision2018\NWPA_Geophys_Update.gdb\PA_NW_Tiers_Combined2'
PALTA = r'W:\\Heritage\\Heritage_Projects\\1495_PlantConservationPlan\\PCPP_DB\\PCPP_layers.gdb\\PALTA_ProtectedLand_merged'
NHA = r"C:\\Users\\MMoore\\AppData\\Roaming\\Esri\\ArcGISPro\\Favorites\\PNHP_Working_pgh-gis0.sde\\PNHP.DBO.NHA_Core"
counties = r"C:\\Users\\MMoore\\AppData\\Roaming\\Esri\\ArcGISPro\\Favorites\\StateLayers_Default_pgh-gis0.sde\\StateLayers.DBO.Boundaries_Political\\StateLayers.DBO.County"
invasives = r'W:\\Heritage\\Heritage_Projects\\1495_PlantConservationPlan\\PCPP_DB\\PCPP_layers.gdb\\imap_merge_2022'
######################################################################################################################################################

# set environmental variables
arcpy.env.overwriteOutput = True
arcpy.env.qualifiedFieldNames = False
arcpy.env.workspace = gdb


def CalcStats(sites, sites_tab_intersect, stat_field, stat_type, new_field):
    print("Calculating stats for " + stat_field)
    stat = arcpy.Statistics_analysis(sites_tab_intersect, os.path.join("in_memory", new_field),
                                     [[stat_field, stat_type]], "site_id")
    arcpy.AddField_management(stat, new_field, "DOUBLE")
    with arcpy.da.UpdateCursor(stat, [stat_type + "_" + stat_field, new_field]) as cursor:
        for row in cursor:
            row[1] = row[0]
            cursor.updateRow(row)
    arcpy.JoinField_management(sites, "site_id", stat, "site_id", new_field)


def CalcPercentile(inputFeatureClass, percentileField, updateField):
    c_arr = arcpy.da.FeatureClassToNumPyArray(inputFeatureClass, (percentileField))
    arr = [float(x[0]) for x in np.ndarray.flatten(c_arr)]

    ##to create 3 rank for example
    p1 = np.percentile(arr, 5, interpolation='lower')  # rank = 0
    p2 = np.percentile(arr, 10, interpolation='lower')  # rank = 1
    p3 = np.percentile(arr, 15, interpolation='lower')  # rank = 2
    p4 = np.percentile(arr, 20, interpolation='lower')  # rank = 3
    p5 = np.percentile(arr, 25, interpolation='lower')  # rank = 4
    p6 = np.percentile(arr, 30, interpolation='lower')  # rank = 5
    p7 = np.percentile(arr, 35, interpolation='lower')  # rank = 6
    p8 = np.percentile(arr, 40, interpolation='lower')  # rank = 7
    p9 = np.percentile(arr, 45, interpolation='lower')  # rank = 8
    p10 = np.percentile(arr, 50, interpolation='lower')  # rank = 9
    p11 = np.percentile(arr, 55, interpolation='lower')  # rank = 10
    p12 = np.percentile(arr, 60, interpolation='lower')  # rank = 11
    p13 = np.percentile(arr, 65, interpolation='lower')  # rank = 12
    p14 = np.percentile(arr, 70, interpolation='lower')  # rank = 13
    p15 = np.percentile(arr, 75, interpolation='lower')  # rank = 14
    p16 = np.percentile(arr, 80, interpolation='lower')  # rank = 15
    p17 = np.percentile(arr, 85, interpolation='lower')  # rank = 16
    p18 = np.percentile(arr, 90, interpolation='lower')  # rank = 17
    p19 = np.percentile(arr, 95, interpolation='lower')  # rank = 18
    p20 = np.percentile(arr, 100, interpolation='lower')  # rank = 19

    # use cursor to update the new rank field
    with arcpy.da.UpdateCursor(inputFeatureClass, [percentileField, updateField]) as cursor:
        for row in cursor:
            if row[0] is None:
                pass
            if row[0] < p1:
                row[1] = 5  # rank 0
            elif p1 <= row[0] and row[0] < p2:
                row[1] = 10
            elif p2 <= row[0] and row[0] < p3:
                row[1] = 15
            elif p3 <= row[0] and row[0] < p4:
                row[1] = 20
            elif p4 <= row[0] and row[0] < p5:
                row[1] = 25
            elif p5 <= row[0] and row[0] < p6:
                row[1] = 30
            elif p6 <= row[0] and row[0] < p7:
                row[1] = 35
            elif p7 <= row[0] and row[0] < p8:
                row[1] = 40
            elif p8 <= row[0] and row[0] < p9:
                row[1] = 45
            elif p9 <= row[0] and row[0] < p10:
                row[1] = 50
            elif p10 <= row[0] and row[0] < p11:
                row[1] = 55
            elif p11 <= row[0] and row[0] < p12:
                row[1] = 60
            elif p12 <= row[0] and row[0] < p13:
                row[1] = 65
            elif p13 <= row[0] and row[0] < p14:
                row[1] = 70
            elif p14 <= row[0] and row[0] < p15:
                row[1] = 75
            elif p15 <= row[0] and row[0] < p16:
                row[1] = 80
            elif p16 <= row[0] and row[0] < p17:
                row[1] = 85
            elif p17 <= row[0] and row[0] < p18:
                row[1] = 90
            elif p18 <= row[0] and row[0] < p19:
                row[1] = 95
            elif p19 <= row[0]:
                row[1] = 100
            else:
                pass
            cursor.updateRow(row)


single_part = arcpy.MultipartToSinglepart_management(pcpp_final, os.path.join("in_memory", "single_part"))
buff = arcpy.Buffer_analysis(single_part, os.path.join("in_memory", "buff"), distance / 2, dissolve_option="ALL")
single_part2 = arcpy.MultipartToSinglepart_management(buff, os.path.join("in_memory", "single_part2"))

# add group_id field
print("Adding group id for site creation...")
arcpy.AddField_management(single_part2, "group_id", "LONG")

i = 1
with arcpy.da.UpdateCursor(single_part2, "group_id") as cursor:
    for row in cursor:
        row[0] = i
        cursor.updateRow(row)
        i += 1

#spatial join to get group id back to original single part PCPP feature layer
sp_join = arcpy.SpatialJoin_analysis(single_part, single_part2, os.path.join("in_memory", "sp_join"))

#create minimum convex polygon around all grouped features and dissolve overlapping features
sites_temp = arcpy.MinimumBoundingGeometry_management(sp_join, os.path.join("in_memory", "sites_temp"), "CONVEX_HULL",group_option="LIST", group_field="group_id")
sites = arcpy.Dissolve_management(sites_temp, os.path.join(gdb, "PCPP_sites_" + str(distance) + "_meters"),multi_part="SINGLE_PART")

#add site id field and fill with ID num
print("Adding site IDs...")
arcpy.AddField_management(sites, "site_id", "LONG")
i = 1
with arcpy.da.UpdateCursor(sites, "site_id") as cursor:
    for row in cursor:
        row[0] = i
        cursor.updateRow(row)
        i += 1

#create layer with all current NHAs
where = "STATUS = 'C'"
NHA_lyr = arcpy.MakeFeatureLayer_management(NHA, "NHA_lyr", where)

#prepare to loop spatial joins to get overlapping NHAs and counties
joins = [NHA_lyr, counties]
fields = ["SITE_NAME", "COUNTY_NAM"]
out_names = ["NHA_Sites", "county"]
out_aliases = ["NHA Sites", "County"]

for j, f, n, a in zip(joins, fields, out_names, out_aliases):
    fieldmappings = arcpy.FieldMappings()
    fieldmappings.addTable(sites)
    fieldmappings.addTable(j)

    index = fieldmappings.findFieldMapIndex(f)
    fieldmap = fieldmappings.getFieldMap(index)

    field = fieldmap.outputField
    field.name = n
    field.aliasName = a
    field.length = 500
    fieldmap.outputField = field

    fieldmap.mergeRule = "join"
    fieldmap.joinDelimiter = "; "

    fieldmappings.replaceFieldMap(index, fieldmap)

    sp_join = arcpy.SpatialJoin_analysis(sites, j, "in_memory\\sp_join", "JOIN_ONE_TO_ONE", "KEEP_ALL", fieldmappings,"INTERSECT")
    arcpy.JoinField_management(sites, "site_id", sp_join, "site_id", n)

print("Calculating percent of protected lands...")
sp_join = arcpy.SpatialJoin_analysis(pcpp_final, sites, os.path.join("in_memory", "sp_join1"))
tab_intersect = arcpy.TabulateIntersection_analysis(sp_join, "site_id", PALTA, os.path.join("in_memory", "tab_intersect"))
arcpy.AlterField_management(tab_intersect, "PERCENTAGE", "PALTA_percent", "Percent Protected (PALTA)")
arcpy.JoinField_management(sites, "site_id", tab_intersect, "site_id", "PALTA_percent")
with arcpy.da.UpdateCursor(sites, "PALTA_percent") as cursor:
    for row in cursor:
        if row[0] is None:
            row[0] = 0
            cursor.updateRow(row)

#get total number of species across all sites to use in calculating weighted rarity score
sites_tab_intersect = arcpy.TabulateIntersection_analysis(sites, "site_id", pcpp_final, os.path.join("in_memory", "sites_tab_intersect"), "ELCODE")
elcode_count = arcpy.Statistics_analysis(sites_tab_intersect, os.path.join("in_memory", "elcode_count"), [["ELCODE", "COUNT"]], "ELCODE")

# create related species table
species_table = arcpy.TabulateIntersection_analysis(sites, "site_id", pcpp_final, species_table, "EO_ID")
arcpy.JoinField_management(species_table, "EO_ID", pcpp_final, "EO_ID",
                           ["ELCODE", "SNAME", "SCOMNAME", "LASTOBS_YR", "EORANK", "GRANK", "SRANK", "USESA", "SPROT",
                            "PBSSTATUS", "EO_TRACK", "EO_DATA", "GEN_DESC", "EORANKCOM", "MGMT_COM", "GENERL_COM"])
arcpy.CreateRelationshipClass_management(sites, species_table, "sitesTOspecies", "SIMPLE", "species", "sites", "NONE", "ONE_TO_MANY", "NONE", "site_id", "site_id")

eo_count = arcpy.Statistics_analysis(species_table, os.path.join("in_memory", "eo_count"), [["EO_ID", "COUNT"]],"site_id")
arcpy.JoinField_management(sites, "site_id", eo_count, "site_id", "COUNT_EO_ID")
species_count = arcpy.Statistics_analysis(sites_tab_intersect, os.path.join("in_memory", "eo_count"),[["ELCODE", "COUNT"]], "site_id")
arcpy.JoinField_management(sites, "site_id", species_count, "site_id", "COUNT_ELCODE")

obsdate_stats = arcpy.Statistics_analysis(species_table, os.path.join("in_memory", "obsdate_stats"),[["LASTOBS_YR", "MEAN"], ["LASTOBS_YR", "MAX"], ["LASTOBS_YR", "MIN"]],"site_id")
arcpy.JoinField_management(sites, "site_id", obsdate_stats, "site_id",["MEAN_LASTOBS_YR", "MIN_LASTOBS_YR", "MAX_LASTOBS_YR"])

conn = sqlite.connect(sql_db)
et = pd.read_sql_query("select * from et_plants", conn)
grank = pd.read_sql_query("select * from rounded_grank", conn)
srank = pd.read_sql_query("select * from rounded_srank", conn)
resp = pd.read_sql_query("select * from species_responsibility", conn)

et = pd.merge(et, grank, how='left', on=["GRANK", "GRANK"])
et = pd.merge(et, srank, how='left', on=["SRANK", "SRANK"])

with conn:
    cur = conn.cursor()

gsrank_dict = {}
cur.execute('select gsrank_combined,score_gsrank from score_gsrank')
result = cur.fetchall()
for gsrank_combined, score_gsrank in result:
    gsrank_dict[gsrank_combined] = score_gsrank

et['rank_score'] = (et['GRANK_rounded'] + et['SRANK_rounded']).map(gsrank_dict)
et.rank_score = pd.to_numeric(et["rank_score"]).fillna(0)

et = pd.merge(et, resp[['ELCODE', 'resp_score']], how='left', on=['ELCODE', 'ELCODE'])
et.resp_score = pd.to_numeric(et["resp_score"]).fillna(0)

arcpy.AddField_management(elcode_count, "rarity_score", "DOUBLE")
with arcpy.da.UpdateCursor(elcode_count, ["rarity_score", "COUNT_ELCODE"]) as cursor:
    for row in cursor:
        row[0] = 1.0 / row[1]
        cursor.updateRow(row)

rarity_dict = {row[0]: row[1] for row in arcpy.da.SearchCursor(elcode_count, ["ELCODE", "rarity_score"])}
et['rarity_score'] = et['ELCODE'].map(rarity_dict)

# et_csv = os.path.join(os.path.realpath(__file__),"et_csv.csv")
et_csv = os.path.join("H:","et_csv.csv")
et.to_csv(et_csv,encoding='utf-8')
et_table = arcpy.TableToTable_conversion(et_csv,gdb,"et_table")

# x = np.array(np.rec.fromrecords(et.values))
# names = et.dtypes.index.tolist()
# x.dtype.names = tuple(names)
# et_table = arcpy.da.NumPyArrayToTable(x, r'H:\\Projects\\PCPP\\PCPP.gdb\\et_table')
# et_table = os.path.join(gdb, "et_table")

arcpy.JoinField_management(sites_tab_intersect, "ELCODE", et_table, "ELCODE",["rank_score", "rarity_score", "resp_score"])

stat_field = ["rank_score", "rarity_score", "resp_score"]
stat_type = ["SUM", "SUM", "SUM"]
new_field = ["site_rank", "rwr", "resp_rank"]

for stat_f, stat_t, new_f in zip(stat_field, stat_type, new_field):
    CalcStats(sites, sites_tab_intersect, stat_f, stat_t, new_f)
    arcpy.AddField_management(sites, new_f + "_percentile", "SHORT")
    CalcPercentile(sites, new_f, new_f + "_percentile")

##sp_join_invasives = arcpy.SpatialJoin_analysis(sites,invasives,"in_memory\\sp_join_invasives","JOIN_ONE_TO_ONE","KEEP_ALL","","INTERSECT")
##invasives_dict = {row[0]:row[1] for row in arcpy.da.SearchCursor(sp_join_invasives,["site_id","Join_Count"])}
##arcpy.AddField_management(sites,"imap_count","SHORT","","","","iMap Count")
##with arcpy.da.UpdateCursor(sites,["site_id","imap_count"]) as cursor:
##    for row in cursor:
##        for k,v in invasives_dict.items():
##            if k==row[0]:
##                row[1]=v
##                cursor.updateRow(row)

# create related invasive species table
invasives_table = arcpy.TabulateIntersection_analysis(sites, "site_id", invasives, invasives_table, "imap_id")
arcpy.JoinField_management(invasives_table, "imap_id", invasives, "imap_id",["scientific_name", "common_name", "observation_date", "imap_url"])
arcpy.CreateRelationshipClass_management(sites, invasives_table, "sitesTOinvasives", "SIMPLE", "invasives", "sites","NONE", "ONE_TO_MANY", "NONE", "site_id", "site_id")

invasives_count = arcpy.Statistics_analysis(invasives_table, os.path.join(gdb, "invasives_count"),[["imap_id", "COUNT"]], "site_id")
arcpy.JoinField_management(sites, "site_id", invasives_count, "site_id", "COUNT_imap_id")

with arcpy.da.UpdateCursor(sites, ["COUNT_imap_id"]) as cursor:
    for row in cursor:
        if row[0] is None:
            row[0] = 0
            cursor.updateRow(row)

print("Calculating EO score...")
eo_dict = {}
cur.execute('select eorank,score_eorank from score_eorank')
result = cur.fetchall()
for eorank, score_eorank in result:
    eo_dict[eorank] = score_eorank

add_fields_text = ["eo_score"]
for field in add_fields_text:
    if len(arcpy.ListFields(pcpp_final, field)) == 0:
        arcpy.AddField_management(pcpp_final, field, "DOUBLE")
    else:
        pass
arcpy.AddField_management(pcpp_final, "eo_score", "DOUBLE")
with arcpy.da.UpdateCursor(pcpp_final, ["EORANK", "eo_score"]) as cursor:
    for row in cursor:
        for k, v in eo_dict.items():
            if k == row[0]:
                row[1] = v
                cursor.updateRow(row)
            else:
                row[1] = 0

occ_intersect = arcpy.TabulateIntersection_analysis(sites, "site_id", pcpp_final,os.path.join("in_memory", "sites_tab_intersect"), "eo_score")
eorank_score = arcpy.Statistics_analysis(occ_intersect, os.path.join("in_memory", "eorank_score"),[["eo_score", "MEAN"]], "site_id")

arcpy.AddField_management(eorank_score, "eo_score", "DOUBLE")
with arcpy.da.UpdateCursor(eorank_score, ["MEAN_eo_score", "eo_score"]) as cursor:
    for row in cursor:
        row[1] = row[0]
        cursor.updateRow(row)
arcpy.JoinField_management(sites, "site_id", eorank_score, "site_id", "eo_score")

print("Calculating geophysical tier ranks...")
arcpy.CheckOutExtension("Spatial")
rast_stat = TabulateArea(sites, "site_id", tiers, "Value", os.path.join(gdb, "rast_stat"), 5)
arcpy.AddField_management(sites, "Area", "DOUBLE")
with arcpy.da.UpdateCursor(sites, ["SHAPE@AREA", "Area"]) as cursor:
    for row in cursor:
        row[1] = row[0]
        cursor.updateRow(row)
arcpy.JoinField_management(rast_stat, "site_id", sites, "site_id", "Area")
Values = ["VALUE_1", "VALUE_2", "VALUE_3"]
AddFields = ["T1_percent", "T2_percent", "T3_percent"]
for v, f in zip(Values, AddFields):
    arcpy.AddField_management(rast_stat, f, "DOUBLE")
    with arcpy.da.UpdateCursor(rast_stat, [v, "Area", f]) as cursor:
        for row in cursor:
            row[2] = round((row[0] / row[1]) * 100, 2)
            cursor.updateRow(row)
arcpy.AddField_management(rast_stat, "tier_rank", "DOUBLE")
AddFields.append("tier_rank")
with arcpy.da.UpdateCursor(rast_stat, AddFields) as cursor:
    for row in cursor:
        row[3] = (row[0]) + (row[1] * 0.5) + (row[2] * 0.1)
        cursor.updateRow(row)
arcpy.JoinField_management(sites, "site_id", rast_stat, "site_id", AddFields)
arcpy.DeleteField_management(sites, "Area")

field_names = ["site_id", "COUNT_EO_ID", "COUNT_ELCODE", "MEAN_LASTOBS_YR", "MAX_LASTOBS_YR", "MIN_LASTOBS_YR",
               "site_rank", "site_rank_percentile", "rwr", "rwr_percentile", "resp_rank", "resp_rank_percentile",
               "COUNT_imap_id", "eo_score", "T1_percent", "T2_percent", "T3_percent", "tier_rank"]
field_aliases = ["PCPP Site ID", "EO Count", "Species Count", "Mean Lastobs Year", "Max Lastobs Year",
                 "Minimum Lastobs Year", "Site Rank", "Site Rank Percentile", "Rarity Weighted Richness",
                 "Rarity Weighted Richness Percentile", "Responsibility Rank", "Responsbility Rank Percentile",
                 "iMap Record Count", "EO Score", "Tier 1 Geophysical Setting Percent",
                 "Tier 2 Geophysical Setting Percent", "Tier 3 Geophysical Setting Percent", "Geophysical Tier Rank"]

for name, alias in zip(field_names, field_aliases):
    arcpy.AlterField_management(sites, name, new_field_alias=alias)

arcpy.AlterAliasName(sites, "PCPP Sites (300 Meters)")
arcpy.AlterAliasName(species_table, "PCPP Species/EO Table (300 Meters)")
arcpy.AlterAliasName(invasives_table, "PCPP Invasives Table (300 Meters)")

arcpy.Delete_management(rast_stat)
