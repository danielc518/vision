'''
Created on 2015. 9. 7.

@author: schoi60
'''

import cv2
import p3
import numpy as np
import copy

def p4(labels_in, database_in): # return overlays_out 
    
    overlays_out = copy.copy(labels_in)
    
    database_full = p3.p3(labels_in)[0]
    database_recognized = []
    
    for i in range(len(database_full)):
        min_moment = database_full[i]['min_moment']
        roundness = database_full[i]['roundness']
        
        for j in range(len(database_in)):
            min_moment_in = database_in[j]['min_moment']
            roundness_in = database_in[j]['roundness'] 
            
            if getDifferenceRatio(min_moment, min_moment_in) > 0.9 and getDifferenceRatio(roundness, roundness_in) > 0.9:
                database_recognized.append(database_full[i])
    
    for i in range(len(database_recognized)):
        x_pos = database_recognized[i]['x_position']
        y_pos = database_recognized[i]['y_position']
        
        theta_min = (np.pi / 2) - np.radians(database_recognized[i]['orientation'])
        
        white_color = (255, 255, 255)
        
        cv2.circle(overlays_out, (x_pos, y_pos), 5, white_color)
        cv2.line(overlays_out, (int(x_pos - 100 * np.cos(theta_min)), int(y_pos - 100 * np.sin(theta_min))), (int(x_pos + 100 * np.cos(theta_min)), int(y_pos + 100 * np.sin(theta_min))), white_color)
    
    return overlays_out

def getDifferenceRatio(val_1, val_2): # return ratio
    ratio = 1
    if val_1 > val_2:
        ratio = val_2 / val_1
    else:
        ratio = val_1 / val_2
    return ratio
            