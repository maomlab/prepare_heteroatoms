#!/usr/bin/env python

import sys
import csv
import shutil
import os
import glob
import pandas as pd
import numpy as np
import regex as re
from sklearn.cluster import AgglomerativeClustering

# returns n predictions, where there are n clusters and the highest ranking prediction from each cluster is returns
# outputs list of sdf files to be converted to pdbs by obabel_to_pdb.sh

# set the directory where the sdf file predictions are
pred_dir = sys.argv[1]  

# set the number of clusters (and thus the number of sdfs to be converted to pdbs)
n = int(sys.argv[2])

parent_dir = os.getcwd()

os.chdir(pred_dir)
os.chdir('rank1_cube_preds')

# get the 3D atom coordinates of a diffdock prediction and return list of coordinates
def extract_molecule_name(file_name):
    # Find the last underscore in the file name
    last_underscore_index = file_name.rfind('_')

    # Find the position of the dot before the file extension
    dot_before_extension_index = file_name.rfind('.')

    # Extract the molecule name (variable {z}) between the last underscore and the dot
    molecule_name = file_name[last_underscore_index + 1:dot_before_extension_index]

    return molecule_name
                        
def com(points_list):
    points_array = np.array(points_list)
    center_of_mass = np.mean(points_array, axis=0)
    return center_of_mass.tolist()

def get_coords(pred_sdf):
    sdf_name = pred_sdf
    with open(pred_sdf, 'r') as sdf:
        lines = sdf.readlines()

    coord_lines = []

    for i in range(len(lines)):
        line = lines[i]
        entries = line.split(" ")
        if len(entries) >= 30:
            coord_lines.append(lines[i])
        else:
            continue
    
    coord_list = []
    for line in coord_lines:
        coords = line.split()
        coords = list(map(float, coords[:3]))
        #Changed to calculate based on the center of mass for variable molecules
        coord_list.append(coords)

    #print("DEBUG: coord_line var is: ")
    #print(coord_list)
    sdf_com  = com(coord_list)

    #playing around with using TPSA as a dimension for clustering...
    #TPSA is topological polar surface area in units of A^2
    TPSA={ "PHE"   : 20.2 ,
           "BEN"   : 00.0 ,
           "CHX"   : 00.0 ,
           "NMA"   : 29.1 ,
           "ACE"   : 40.1 ,
           "IPA"   : 20.2 ,
           "PYR"   : 25.8 ,
           "IDZ"   : 28.7 ,}
    mol_name=extract_molecule_name(sdf_name)

    sdf_com.append(TPSA[mol_name])
    
    #print("DEBUG: com var is: ")
    #print(sdf_com)
    return(sdf_name, sdf_com)

prediction_coords = []
prediction_names = []

# prepare coordinates of each prediction for clustering
for sdf in glob.glob('*.sdf'):
    pred_name, pred_coords = get_coords(sdf)
    if len(pred_coords) == 0:
        continue
    else:
        prediction_names.append(pred_name)
        prediction_coords.append(pred_coords)
#print(prediction_coords)
#print(prediction_coords[0].type())


prediction_coords = np.asarray(prediction_coords)

# hierarchical clustering of diffdock predictions (3 clusters) by 3D coordinates of atoms
hierarchical_cluster = AgglomerativeClustering(n_clusters=n, metric='euclidean', linkage='ward')

print(prediction_coords)
# cluster label of each prediction
labels = hierarchical_cluster.fit_predict(prediction_coords)

# prediction labels
pred_labels = {}

# fix to work properly for n clusters (check if clustering above is working too)
for i in range(len(prediction_names)):
    pred_labels[prediction_names[i]] = labels[i]

cluster_dicts = []
for i in range(n):
    label = str(i)
    dicto = {}
    for key in pred_labels:
        rank = key.split("_")[0]
        rank = int(re.findall(r'\d+', rank)[0])
        if pred_labels[key] == i:
            dicto[key] = rank
        else:
            continue
    cluster_dicts.append(dicto)

# get the highest ranking prediction from each of the three clusters
to_convert = []
for i in range(len(cluster_dicts)):    
    clust = cluster_dicts[i]
    min_clust = min(clust.values())
    for key in clust:
        if clust[key] == min_clust:
            pred = key
        else:
            continue
    to_convert.append(pred)

# write predictions to be converted to pdbs to 'to_convert.txt'
with open('to_convert.txt', 'w') as out:
    for sdf in to_convert:
        out.write(sdf)
        out.write('\n')

os.chdir(parent_dir)
