'''
Created on 2015. 9. 17.

@author: Sanghyun
'''

import numpy as np

def p6(edge_image_in, edge_thresh): #return [edge_image_thresh_out, hough_image_out]
    shape = np.shape(edge_image_in)
    
    num_rows = shape[0]
    num_cols = shape[1]
    
    diagonal_length = np.sqrt(np.power(num_rows, 2) + np.power(num_cols, 2))
    
    theta_resolution = 800
    rho_resolution = diagonal_length
    
    edge_image_thresh_out = np.empty(shape, dtype=int)
    accumulator = np.zeros((rho_resolution, theta_resolution), dtype=int)
    hough_image_out = np.zeros((rho_resolution, theta_resolution), dtype=int)
    
    max_acc_value = 1
    
    for i in range(num_rows):
        for j in range(num_cols):
            if edge_image_in[i][j] > edge_thresh:
                edge_image_thresh_out[i][j] = 255
                
                for theta_index in range(theta_resolution):
                    theta = ((np.pi / theta_resolution) * theta_index) - (np.pi / 2)
                    rho = (i * np.cos(theta)) - (j * np.sin(theta))
                    rho_index = int(round(((rho_resolution) / (2 * diagonal_length)) * (rho + diagonal_length)))
                    
                    accumulator[rho_index][theta_index] = accumulator[rho_index][theta_index] + 1
                    
                    if (accumulator[rho_index][theta_index] > max_acc_value):
                        max_acc_value = accumulator[rho_index][theta_index]
            else:
                edge_image_thresh_out[i][j] = 0
    
    for i in range(int(round(rho_resolution))):
        for j in range(theta_resolution):
            hough_image_out[i][j] = int(round((float(accumulator[i][j]) / float(max_acc_value)) * 255.0))
    
    return [edge_image_thresh_out, hough_image_out]
    