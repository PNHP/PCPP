import arcpy
import pandas as pd
import matplotlib.pyplot as plt
import os
import numpy as np

gdb = r'H:\Projects\PCPP\PCPP.gdb'
sql_db = r'H:\Projects\PCPP\PCPP.db'
distance = "300 METERS"
in_poly = os.path.join(gdb,'pcpp_final')
sites = os.path.join(gdb,"PCPP_sites_"+distance.replace(" ","_").lower())

def arcgis_table_to_df(in_fc, input_fields, query=""):
    """Function will convert an arcgis table into a pandas dataframe with an object ID index, and the selected
    input fields using an arcpy.da.SearchCursor."""
    OIDFieldName = arcpy.Describe(in_fc).OIDFieldName
    final_fields = [OIDFieldName] + input_fields
    data = [row for row in arcpy.da.SearchCursor(in_fc,final_fields,where_clause=query)]
    fc_dataframe = pd.DataFrame(data,columns=final_fields)
    fc_dataframe = fc_dataframe.set_index(OIDFieldName,drop=True)
    return fc_dataframe

def polyfit(x, y, degree):
    results = {}

    coeffs = np.polyfit(x, y, degree)
     # Polynomial Coefficients
    results['polynomial'] = coeffs.tolist()

    correlation = np.corrcoef(x, y)[0,1]

     # r
    results['correlation'] = correlation
     # r-squared
    results['determination'] = correlation**2

    return results



x = 'rwr'
y = 'resp_rank'

df = arcgis_table_to_df(sites,[x,y],query="")
df = df[np.isfinite(df[x])]
df = df[np.isfinite(df[y])]

plt.scatter(x=x,y=y, marker='x', c='black', data=df)

z = np.polyfit(df[x],df[y],1)
r2 = polyfit(df[x],df[y],1)
r2 = round(r2['determination'],2)
p = np.poly1d(z)
plt.plot(df[x],p(df[x]),"k:")

plt.xlim(0,)
plt.ylim(0,)
plt.xlabel(x,fontsize=12)
plt.ylabel(y,fontsize=12)

plt.text(30,1.5,'$R^2$ = '+str(r2),fontsize=12)