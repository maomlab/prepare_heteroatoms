#!/usr/bin/env python

import sys
import csv
import shutil
import os
import glob

# gets all the predictions that are within a cube of x distance from the middle of prediction 1 and copies them to directory called rank1_cube_preds

# set directory name where diffdock predictions (sdf files) live
pred_dir = sys.argv[1] 

# set the size of the cube (from center of cube) in angstroms
dist = int(sys.argv[2])

parent_dir = os.getcwd()

os.chdir(pred_dir)

# rank1 prediction file name
rank1_pred = glob.glob('rank1_confidence*')[0]
print(rank1_pred)

# make txt file where each line is the file name of a diffdock prediction
with open('preds.txt', 'w') as prediction_list:
    for sdf_file in glob.glob('*.sdf'):
        name = sdf_file
        prediction_list.write(name)
        prediction_list.write('\n')

prediction_list = 'preds.txt'

# function to get the 3D atom coordinates of a diffdock prediction
def get_coords(pred_sdf):
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

    x = []
    y = []
    z = []
    
    for line in coord_lines:
        coords = line.split()
        x.append(float(coords[0]))
        y.append(float(coords[1]))
        z.append(float(coords[2]))

    return x,y,z

# get x,y,z coordinates of 
rank1x, rank1y, rank1z = get_coords(rank1_pred)

# get the minimum and maximum x,y,and z coordinates of the rank1 prediction
max_x = (max(rank1x))
min_x = (min(rank1x))
max_y = (max(rank1y))
min_y = (min(rank1y))
max_z = (max(rank1z))
min_z = (min(rank1z))

# determine the x,y,z coordinates of the middle of the center of the cube
mid_x = float((max_x+min_x)/2)
mid_y = float((max_y+min_y)/2)
mid_z = float((max_z+min_z)/2)

# determine dimensions of the cube (determined by middle of cube and by dist defined above)
range_x = [(mid_x - dist),(mid_x + dist)]
range_y = [(mid_y - dist),(mid_y + dist)]
range_z = [(mid_z - dist),(mid_z + dist)]

cube_coords = []

# get the 8 vertices of the cube
for x_coord in range_x:
    for y_coord in range_y:
        for z_coord in range_z:
            vertex = [x_coord, y_coord, z_coord]
            cube_coords.append(vertex)

# now need to determine which other predictions are in the cube 

# get a list of each of the other predictions then iterate over list then output list of predictions that are within cube

with open(prediction_list, 'r') as pred_list:
    preds = pred_list.readlines()

if not os.path.exists('rank1_cube_preds'):
    os.mkdir('rank1_cube_preds')

for pred in preds:
    pred = pred[:-1]
    xs,ys,zs = get_coords(pred)

    # check if atoms of prediction are all in cube. if so, cp prediction to rank1_cube_preds
    good_atms = []
    for i in range(len(xs)):
        x = xs[i]
        y = ys[i]
        z = zs[i]
        atom = []
        # if the x,y,z coords are in the cube range, add atom to good_atms list
        if ((mid_x - dist) <= x <= (mid_x + dist)):
            if ((mid_y - dist) <= y <= (mid_y + dist)):
                if ((mid_z - dist) <= z <= (mid_z + dist)):
                    atom.append(x)
                    atom.append(y)
                    atom.append(z)
                else:
                    continue
            else:
                continue
        else:
            continue
        if len(atom) == 3:
            good_atms.append(atom)
        else:
            continue
    # if all the atoms are in the good_atms list, cp pred to rank1_cube_preds
    if len(good_atms) == len(xs):
        print(pred,': in cube')
        shutil.copy(pred, 'rank1_cube_preds')

    else:
        print(pred,': not in cube')

os.chdir(parent_dir)









