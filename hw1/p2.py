'''
Created on 2015. 9. 3.

@author: schoi60
'''

import numpy as np

def p2(binary_in): # return labels_out
    # Image dimension
    shape = np.shape(binary_in)
    
    num_rows = shape[0]
    num_cols = shape[1]
    
    labels_out = np.empty(shape, dtype=int)
    
    ds = DisjointSet() # To keep track of equivalent labels
    
    label = 50
    
    for i in range(num_rows):
        for j in range(num_cols):
            if binary_in[i][j] > 0: # Not background
                if i == 0:
                    if j > 0:
                        left = labels_out[i][j-1]
                        if left > 0:
                            labels_out[i][j] = left
                        else:
                            labels_out[i][j] = label
                            label += 1
                    else:
                        labels_out[i][j] = label
                        label += 1
                elif j == 0:
                    if i > 0:
                        top = labels_out[i-1][j]
                        if top > 0:
                            labels_out[i][j] = top
                        else:
                            labels_out[i][j] = label
                            label += 1
                    else:
                        labels_out[i][j] = label
                        label += 1
                else:
                    left = labels_out[i][j-1]
                    top_left = labels_out[i-1][j-1]
                    top = labels_out[i-1][j]
                    
                    if left == 0 and top_left == 0 and top == 0:
                        labels_out[i][j] = label
                        label += 1
                    elif top_left > 0:
                        labels_out[i][j] = top_left
                    elif left > 0 and top_left == 0 and top == 0:
                        labels_out[i][j] = left
                    elif left == 0 and top_left == 0 and top > 0:
                        labels_out[i][j] = top
                    elif left > 0 and top_left == 0 and top > 0:
                        labels_out[i][j] = top
                        if left != top:
                            # Note down in equivalence table
                            ds.add(left, top)
                    else:
                        labels_out[i][j] = label
                        label += 1
            else:
                labels_out[i][j] = 0 # Background
    
    num_groups = len(ds.group)
    
    for i in range(num_rows):
        for j in range(num_cols):
            label = labels_out[i][j]
            if label > 0:
                index = 0
                for k in ds.group:
                    if label in ds.group[k]:
                        # Assign scaled intensities
                        labels_out[i][j] = int(round(55 + ((200 / num_groups) * (index + 1))))
                        break
                    index += 1
    
    return labels_out

# This data structure implementation was obtained from following site:
# http://stackoverflow.com/questions/3067529/a-set-union-find-algorithm
class DisjointSet(object):

    def __init__(self):
        self.leader = {} # maps a member to the group's leader
        self.group = {} # maps a group leader to the group (which is a set)

    def add(self, a, b):
        leadera = self.leader.get(a)
        leaderb = self.leader.get(b)
        if leadera is not None:
            if leaderb is not None:
                if leadera == leaderb: return # nothing to do
                groupa = self.group[leadera]
                groupb = self.group[leaderb]
                if len(groupa) < len(groupb):
                    a, leadera, groupa, b, leaderb, groupb = b, leaderb, groupb, a, leadera, groupa
                groupa |= groupb
                del self.group[leaderb]
                for k in groupb:
                    self.leader[k] = leadera
            else:
                self.group[leadera].add(b)
                self.leader[b] = leadera
        else:
            if leaderb is not None:
                self.group[leaderb].add(a)
                self.leader[a] = leaderb
            else:
                self.leader[a] = self.leader[b] = a
                self.group[a] = set([a, b])
                
