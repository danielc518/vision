'''
Created on 2015. 9. 3.

@author: schoi60
'''

import copy
import cv2
import numpy as np

def p3(labels_in): #return [database_out, overlays_out] 
    # Image dimension
    shape = np.shape(labels_in)
    
    num_rows = shape[0]
    num_cols = shape[1]
    
    database_out = []
    overlays_out = copy.copy(labels_in)
    
    attribute_dict = {} # label : [ area, x_pos, y_pos, a, b, c, theta_min, theta_max, E_min, E_max ]
    
    # Compute area, x_pos, y_pos 
    for i in range(num_rows):
        for j in range(num_cols):
            label = labels_in[i][j]
            if label > 0: # Not background
                if label not in attribute_dict:
                    attribute_dict[label] = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
                attribute_dict[label][0] = attribute_dict[label][0] + 1
                attribute_dict[label][1] = attribute_dict[label][1] + j
                attribute_dict[label][2] = attribute_dict[label][2] + i
    
    # Divide x_pos and y_pos by area to get the correct value
    for key in attribute_dict:
        attribute_dict[key][1] = attribute_dict[key][1] / attribute_dict[key][0]
        attribute_dict[key][2] = attribute_dict[key][2] / attribute_dict[key][0]
    
    # Compute values of a, b, c
    for i in range(num_rows):
        for j in range(num_cols):
            label = labels_in[i][j]
            if label > 0: # Not background
                i_prime = i - attribute_dict[label][2] # (i - y_pos)
                j_prime = j - attribute_dict[label][1] # (j - x_pos)
                
                attribute_dict[label][3] = attribute_dict[label][3] + (j_prime * j_prime) # a
                attribute_dict[label][4] = attribute_dict[label][4] + (2 * i_prime * j_prime) # b
                attribute_dict[label][5] = attribute_dict[label][5] + (i_prime * i_prime) # c
    
    # Compute angles
    for key in attribute_dict:
        a = attribute_dict[key][3]
        b = attribute_dict[key][4]
        c = attribute_dict[key][5]
        
        theta_1 = (np.arctan2(b, a - c)) / 2
        theta_2 = theta_1 + (np.pi / 2)
        
        E_1 = get_second_moment(theta_1, a, b, c)
        E_2 = get_second_moment(theta_2, a, b, c)
        
        if (E_1 > E_2):
            attribute_dict[key][6] = theta_2
            attribute_dict[key][7] = theta_1
            attribute_dict[key][8] = E_2
            attribute_dict[key][9] = E_1
        else:
            attribute_dict[key][6] = theta_1
            attribute_dict[key][7] = theta_2
            attribute_dict[key][8] = E_1
            attribute_dict[key][9] = E_2

    database_index = 0
    
    # configure database_out
    for key in attribute_dict:
        database_out.append({ 'object_label' : '', 'x_position' : -1, 'y_position' : -1, 'min_moment' : -1, 'orientation' : -1, 'roundness' : -1})
        
        x_pos = attribute_dict[key][1]
        y_pos = attribute_dict[key][2]
        theta_min = attribute_dict[key][6]
        
        database_out[database_index]['object_label'] = key
        database_out[database_index]['x_position'] = x_pos
        database_out[database_index]['y_position'] = y_pos
        database_out[database_index]['min_moment'] = attribute_dict[key][8]
        database_out[database_index]['orientation'] = np.degrees((np.pi / 2) - theta_min)
        database_out[database_index]['roundness'] = attribute_dict[key][8] / attribute_dict[key][9]
        
        database_index = database_index + 1
        
        white_color = (255, 255, 255)
        
        cv2.circle(overlays_out, (x_pos, y_pos), 5, white_color)
        cv2.line(overlays_out, (int(x_pos - 100 * np.cos(theta_min)), int(y_pos - 100 * np.sin(theta_min))), (int(x_pos + 100 * np.cos(theta_min)), int(y_pos + 100 * np.sin(theta_min))), white_color)
    
    return [database_out, overlays_out]

def get_second_moment(theta, a , b, c): # return second_moment
    second_moment = (a * np.power(np.sin(theta), 2)) - (b * np.sin(theta) * np.cos(theta)) + (c * np.power(np.cos(theta), 2))
    return second_moment
                