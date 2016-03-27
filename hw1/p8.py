'''
Created on 2015. 9. 17.

@author: Sanghyun
'''

import copy
import numpy as np

def p8(image_in, hough_image_in, edge_thresholded_in, hough_thresh): #return cropped_lines_image_out
    cropped_lines_image_out = copy.copy(image_in)
    
    shape_image_in = np.shape(image_in)
    
    num_rows = shape_image_in[0]
    num_cols = shape_image_in[1]
    
    diagonal_length = np.sqrt(np.power(num_rows, 2) + np.power(num_cols, 2))
    
    shape_hough_image_in = np.shape(hough_image_in)
    
    rho_resolution = shape_hough_image_in[0]
    theta_resolution = shape_hough_image_in[1]
    
    for rho_index in range(rho_resolution):
        for theta_index in range(theta_resolution):
            if hough_image_in[rho_index][theta_index] > hough_thresh:
                theta = ((np.pi / theta_resolution) * theta_index) - (np.pi / 2)
                rho = (((2 * diagonal_length) / rho_resolution) * rho_index) - diagonal_length
                
                x = rho * np.cos(theta + (np.pi / 2))
                y = rho * np.sin(theta + (np.pi / 2))
                
                x = x - (diagonal_length * np.cos(theta))
                y = y - (diagonal_length * np.sin(theta))
                    
                while not valid_pixel_location(x, y, num_cols, num_rows):
                    x = x + np.cos(theta)
                    y = y + np.sin(theta)
                
                while valid_pixel_location(x, y, num_cols, num_rows):
                    intensity = edge_thresholded_in[int(round(y))][int(round(x))]
                    
                    if intensity > 0:
                        cropped_lines_image_out[int(round(y))][int(round(x))] = 255
                    
                    x = x + np.cos(theta)
                    y = y + np.sin(theta)
    
    return cropped_lines_image_out

def valid_pixel_location(x, y, num_cols, num_rows):
    if int(round(x)) >= 0 and int(round(y)) >= 0 and int(round(x)) < num_cols and int(round(y)) < num_rows:
        return True
    else:
        return False