#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      mmoore
#
# Created:     07/06/2019
# Copyright:   (c) mmoore 2019
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import sqlite3 as lite
import arcpy, os

db = r'H:\Projects\PCPP\PCPP.db'
con = lite.connect(db)

with con:
    cur = con.cursor()

dictionary = {}
cur.execute('select eorank,score_eorank from score_eorank')
result = cur.fetchall()
for eorank,score_eorank in result:
   dictionary[eorank] = score_eorank


def CalcEOScore(sites,pcpp_final):
    dictionary = {}
    cur.execute('select eorank,score_eorank from score_eorank')
    result = cur.fetchall()
    for eorank,score_eorank in result:
       dictionary[eorank] = score_eorank

    add_fields_text = ["eo_score"]
    for field in add_fields_text:
        if len(arcpy.ListFields(pcpp_final,field)) == 0:
            arcpy.AddField_management(pcpp_final,field,"DOUBLE")
        else:
            pass
    arcpy.AddField_management(pcpp_final,"eo_score","DOUBLE")
    with arcpy.da.UpdateCursor(pcpp_final,["EORANK","eo_score"]) as cursor:
        for row in cursor:
            for k,v in dictionary.items():
                if k==row[0]:
                    row[1]=v
                    cursor.updateRow(row)
                else:
                    row[1]=0

    occ_intersect = arcpy.TabulateIntersection_analysis(sites,"site_id",pcpp_final,os.path.join("in_memory","sites_tab_intersect"),"eo_score")
    eorank_score = arcpy.Statistics_analysis(occ_intersect,os.path.join("in_memory","eorank_score"),[["eo_score", "MEAN"]],"site_id")

    arcpy.AddField_management(eorank_score,"eo_score","DOUBLE")
    with arcpy.da.UpdateCursor(eorank_score,["MEAN_eo_score","eo_score"]) as cursor:
        for row in cursor:
            row[1]=row[0]
            cursor.updateRow(row)
    arcpy.JoinField_management(sites,"site_id",eorank_score,"site_id","eo_score")                                                                                                                       
