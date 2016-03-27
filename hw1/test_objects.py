'''
Created on 2015. 9. 3.

@author: schoi60
'''

import cv2
import p1
import p2
import p3
import p4

if __name__ == '__main__':
    gray_level_threshold = 130
    
    test_file_name = "two_objects.pgm"
    
    # Read PGM file
    gray_in = cv2.imread(test_file_name, cv2.CV_LOAD_IMAGE_GRAYSCALE)
    
    # Run binary processing
    binary_img = p1.p1(gray_in, gray_level_threshold)
    
    # Save binary image
    cv2.imwrite("img_binary.pgm", binary_img)
    
    # Run sequential labeling algorithm
    labeled_img = p2.p2(binary_img)
    
    # Save labeled image
    cv2.imwrite("img_labels.pgm", labeled_img)
    
    # Print object attributes
    obj_info_arr = p3.p3(labeled_img)
    obj_database = obj_info_arr[0]
    for i in range(len(obj_database)):
        print "Object # " + str(i + 1) + ":\n"
        print "label = " + str(obj_database[i]['object_label'])
        print "x position = " + str(obj_database[i]['x_position'])
        print "y position = " + str(obj_database[i]['y_position'])
        print "minimum moment = " + str(obj_database[i]['min_moment'])
        print "orientation = " + str(obj_database[i]['orientation'])
        print "roundness = " + str(obj_database[i]['roundness'])
        print "\n"
        
    # Save overlay image
    cv2.imwrite("img_overlay.pgm", obj_info_arr[1])
    
    # Check if similar two objects can be detected in 'many objects' image
    gray_in = cv2.imread("many_objects_1.pgm", cv2.CV_LOAD_IMAGE_GRAYSCALE)
    binary_img = p1.p1(gray_in, gray_level_threshold)
    labeled_img = p2.p2(binary_img)
    overlays_out = p4.p4(labeled_img, obj_database)
    
    # Save recognized objects image
    cv2.imwrite("img_similar_objects.pgm", overlays_out)
