'''
Created on 2015. 9. 17.

@author: Sanghyun
'''

import copy
import cv2
import numpy as np

def p7(image_in, hough_image_in, hough_thresh): #return line_image_out
    line_image_out = copy.copy(image_in)
    
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
                
                x_1 = x - diagonal_length * np.cos(theta)
                y_1 = y - diagonal_length * np.sin(theta)
                
                x_2 = x + diagonal_length * np.cos(theta)
                y_2 = y + diagonal_length * np.sin(theta)
                
                white_color = (255, 255, 255)
                
                cv2.line(line_image_out, (int(round(x_1)), int(round(y_1))), (int(round(x_2)), int(round(y_2))), white_color)
    
    return line_image_out
                