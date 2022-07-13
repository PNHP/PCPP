#import libraries
import arcpy, os
from arcpy import env
from arcpy.sa import *
import numpy as np
import pandas as pd
import sqlite3 as sqlite
import matplotlib.pyplot as plt

######################################################################################################################################################
gdb = r'H:\Projects\PCPP\PCPP.gdb'
sql_db = r'H:\Projects\PCPP\PCPP.db'
distance = "1000 METERS"
in_poly = os.path.join(gdb,'pcpp_final')
sites = os.path.join(gdb,"PCPP_sites_"+distance.replace(" ","_").lower())
tiers = r'W:\Conservation_Science\Science\_GeophysicalSettingRevision2018\NWPA_Geophys_Update.gdb\PA_NW_Tiers_Combined2'
######################################################################################################################################################

#set environmental variables
arcpy.env.overwriteOutput = True
arcpy.env.qualifiedFieldNames = False
arcpy.env.workspace = "in_memory"

def CalcPercentile(inputFeatureClass, percentileField, updateField):
    c_arr = arcpy.da.FeatureClassToNumPyArray(inputFeatureClass,(percentileField))
    arr = [float(x[0]) for x in np.ndarray.flatten(c_arr)]

    ##to create 3 rank for example
    p1 = np.percentile(arr, 25, interpolation='lower')  # rank = 0
    p2 = np.percentile(arr, 50, interpolation='lower')  # rank = 1
    p3 = np.percentile(arr, 55, interpolation='lower')  # rank = 2
    p4 = np.percentile(arr, 60, interpolation='lower')  # rank = 3
    p5 = np.percentile(arr, 65, interpolation='lower')  # rank = 4
    p6 = np.percentile(arr, 70, interpolation='lower')  # rank = 5
    p7 = np.percentile(arr, 75, interpolation='lower')  # rank = 6
    p8 = np.percentile(arr, 80, interpolation='lower')  # rank = 7
    p9 = np.percentile(arr, 85, interpolation='lower')  # rank = 8
    p10 = np.percentile(arr, 90, interpolation='lower')  # rank = 9
    p11 = np.percentile(arr, 91, interpolation='lower')  # rank = 10
    p12 = np.percentile(arr, 92, interpolation='lower')  # rank = 11
    p13 = np.percentile(arr, 93, interpolation='lower')  # rank = 12
    p14 = np.percentile(arr, 94, interpolation='lower')  # rank = 13
    p15 = np.percentile(arr, 95, interpolation='lower')  # rank = 14
    p16 = np.percentile(arr, 96, interpolation='lower')  # rank = 15
    p17 = np.percentile(arr, 97, interpolation='lower')  # rank = 16
    p18 = np.percentile(arr, 98, interpolation='lower')  # rank = 17
    p19 = np.percentile(arr, 99, interpolation='lower')  # rank = 18
    p20 = np.percentile(arr, 100, interpolation='lower')  # rank = 19

    #use cursor to update the new rank field
    with arcpy.da.UpdateCursor(inputFeatureClass,[percentileField,updateField]) as cursor:
        for row in cursor:
            if row[0] < p1:
                row[1] = 100  #rank 0
            elif p1 <= row[0] and row[0] < p2:
                row[1] = 75
            elif p2 <= row[0] and row[0] < p3:
                row[1] = 50
            elif p3 <= row[0] and row[0] < p4:
                row[1] = 45
            elif p4 <= row[0] and row[0] < p5:
                row[1] = 40
            elif p5 <= row[0] and row[0] < p6:
                row[1] = 35
            elif p6 <= row[0] and row[0] < p7:
                row[1] = 30
            elif p7 <= row[0] and row[0] < p8:
                row[1] = 25
            elif p8 <= row[0] and row[0] < p9:
                row[1] = 20
            elif p9 <= row[0] and row[0] < p10:
                row[1] = 15
            elif p10 <= row[0] and row[0] < p11:
                row[1] = 10
            elif p11 <= row[0] and row[0] < p12:
                row[1] = 9
            elif p12 <= row[0] and row[0] < p13:
                row[1] = 8
            elif p13 <= row[0] and row[0] < p14:
                row[1] = 7
            elif p14 <= row[0] and row[0] < p15:
                row[1] = 6
            elif p15 <= row[0] and row[0] < p16:
                row[1] = 5
            elif p16 <= row[0] and row[0] < p17:
                row[1] = 4
            elif p17 <= row[0] and row[0] < p18:
                row[1] = 3
            elif p18 <= row[0] and row[0] < p19:
                row[1] = 2
            elif p19 <= row[0] and row[0] <= p20:
                row[1] = 1
            else:
                pass
            cursor.updateRow(row)
            
CalcPercentile(sites,"rwr","rwr_percentile_1")

sites_tab_intersect = arcpy.TabulateIntersection_analysis(sites,"site_id",in_poly,os.path.join(gdb,"sites_tab_intersect"),"ELCODE")
elcode_count = arcpy.Statistics_analysis(sites_tab_intersect,os.path.join(gdb,"elcode_count"),[["ELCODE", "COUNT"]],"ELCODE")

arcpy.JoinField_management(sites_tab_intersect,"site_id",sites,"site_id","rwr_percentile_1")
with arcpy.da.SearchCursor(sites_tab_intersect,"rwr_percentile_1") as cursor:
    for row in cursor:
        percentiles = sorted({row[0] for row in cursor})
        
species_acc = {}
for p in percentiles:
    with arcpy.da.SearchCursor(sites_tab_intersect,["rwr_percentile_1","ELCODE"]) as cursor:
        n = len(sorted({row[1] for row in cursor if row[0] <= p}))
        species_acc[p] = n
        
x = 'PAD_percent'
y = 'rwr'

df = pd.DataFrame(species_acc.items(), columns=[x, y])
df = df[np.isfinite(df[x])]
df = df[np.isfinite(df[y])]

plt.scatter(x=x,y=y, marker='x', c='black', data=df)

#z = np.polyfit(df[x],df[y],1)
#r2 = polyfit(df[x],df[y],1)
#r2 = round(r2['determination'],2)
#p = np.poly1d(z)
#plt.plot(df[x],p(df[x]),"k:")

plt.xlim(0,)
plt.ylim(0,)
plt.xlabel("Percent of Sites",fontsize=12)
plt.ylabel("Species Represented",fontsize=12)    
