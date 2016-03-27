'''
Created on 2015. 9. 17.

@author: Sanghyun
'''

import cv2
import p5
import p6
import p7
import p8

if __name__ == '__main__':
    edge_threshold = 15
    hough_threshold = 130
    
    test_file_name = "hough_simple_1.pgm"
    
    #Read image
    gray_in = cv2.imread(test_file_name, cv2.CV_LOAD_IMAGE_GRAYSCALE)
    
    # Detect edges
    edge_image_out = p5.p5(gray_in)
    
    # Save edge detection image
    cv2.imwrite("img_edge_detection.pgm", edge_image_out)
    
    # Detect edges with threshold
    edge_images_out = p6.p6(edge_image_out, edge_threshold)
    
    # Save edge detection (with threshold) image
    cv2.imwrite("img_edge_detection_thresh.pgm", edge_images_out[0])

    # Save Hough transformation image
    cv2.imwrite("img_edge_detection_hough.pgm", edge_images_out[1])
    
    # Detect strong lines
    line_image_out = p7.p7(gray_in, edge_images_out[1], hough_threshold)
    
    # Save image with strong lines
    cv2.imwrite("img_edge_detection_strong.pgm", line_image_out)
    
    # Crop the edges
    cropped_lines_image_out = p8.p8(gray_in, edge_images_out[1], edge_images_out[0], hough_threshold)
    
    # Save cropped image
    cv2.imwrite("img_edge_detection_cropped.pgm", cropped_lines_image_out)
