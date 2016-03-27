'''
Created on 2015. 9. 3.

@author: schoi60
'''

import numpy as np
import copy

def p1(gray_in, thresh_val): # return binary_out
    binary_out = copy.copy(gray_in)
    
    for x in np.nditer(binary_out, op_flags=['readwrite']):
        if x < thresh_val:
            x[...] = 0
        else:
            x[...] = 255
            
    return binary_out
