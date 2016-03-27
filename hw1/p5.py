'''
Created on 2015. 9. 17.

@author: schoi60
'''

import numpy as np

def p5(image_in): #return edge_image_out
    shape = np.shape(image_in)
    
    num_rows = shape[0]
    num_cols = shape[1]
    
    edge_image_out = np.empty(shape, dtype=int)
    
    max_intensity = 0
    
    # Compute gradient values
    
    for i in range(num_rows):
        for j in range(num_cols):
            gradient = get_gradient(image_in, j, i, num_rows, num_cols)
            
            edge_image_out[i][j] = gradient
            
            if (gradient > max_intensity):
                max_intensity = gradient
    
    # Compute scaled intensities
    
    for x in np.nditer(edge_image_out, op_flags=['readwrite']):
        scaled_intensity = (float(x) / float(max_intensity)) * 255.0
        x[...] = int(round(scaled_intensity))
    
    return edge_image_out

def get_gradient(image_in, x, y, num_rows, num_cols):
    # 3x3 Sobel matrices (flipped) 
    sobel_x = [[1, 0, -1], [2, 0, -2], [1, 0, -1]]
    sobel_y = [[-1, -2, -1], [0, 0, 0], [1, 2, 1]]
    
    x_gradient = 0.0
    y_gradient = 0.0
    
    for i in range(3):
        for j in range(3):
            intensity = get_intensity(image_in, x - 1 + j, y - 1 + i, num_rows, num_cols)
            
            if intensity == -1:
                return 0
            
            x_gradient += (sobel_x[i][j] * intensity)
            y_gradient += (sobel_y[i][j] * intensity)
    
    gradient = np.sqrt(np.power(x_gradient, 2) + np.power(y_gradient, 2))
    
    return int(round(gradient))

def get_intensity(image_in, x, y, num_rows, num_cols):
    if x < 0 or y < 0 or x > num_cols - 1 or y > num_rows - 1:
        return -1
    else:
        return image_in[y][x]