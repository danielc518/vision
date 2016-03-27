function [ descriptors ] = ssift_descriptor(feature_coords,image)
%%%
% Computer Vision 600.461/661 Assignment 2
% Args:
%	feature_coords: list of (row,col) tuple feature coordinates from image
%	image: The input image to compute ssift descriptors on. Note: this is NOT the image name or image path.
% Returns:
%	descriptors: n-by-128 ssift descriptors. The first row corresponds
%	to the ssift descriptor of the first feature (index=1) in
%	feature_coords
%%%

rows = feature_coords(:,1);
cols = feature_coords(:,2);

image_gray = rgb2gray(image);

sobel_x = fspecial('sobel');

[img_height, img_width] = size(image_gray);

i_x = filter2(sobel_x, image_gray);
i_y = filter2(sobel_x', image_gray);

gradient = sqrt(i_x.^2 + i_y.^2);

thetas = (180 / pi) * atan2(i_y, i_x);

window_size = 41;
delta = (window_size -  1) / 2;

num_of_feature_coords = length(rows);
num_of_histograms = 8;
num_of_degrees_histogram = 360 / num_of_histograms;

descriptors = zeros(1, 128, num_of_feature_coords);

for i = 1:1:num_of_feature_coords
    if rows(i) > delta && cols(i) > delta && cols(i) + delta < img_width && rows(i) + delta < img_height
        feature_descriptor = [];
        
        degrees_histogram = zeros([1 num_of_degrees_histogram]);
        
        % Iterate over 41 x 41 window (delta = 20) for each match

        for col = (cols(i) - delta):1:(cols(i) + delta)
            for row = (rows(i) - delta):1:(rows(i) + delta)
                
                theta = thetas(row, col); % get orientation
                
                while theta < 0
                    theta = theta + 360; % rotate until positive value is obtained
                end
                
                degrees_histogram_index = ceil(theta / num_of_histograms);
                
                if degrees_histogram_index == 0
                    degrees_histogram_index = num_of_degrees_histogram;
                end
                
                degrees_histogram(degrees_histogram_index) = degrees_histogram(degrees_histogram_index) + gradient(row, col);
                
            end
        end
        
        % search for dominant orientation
        
        max_vote = -inf;
        max_vote_histogram_index = 1;
        
        for degrees_histogram_index = 1:num_of_degrees_histogram
            if degrees_histogram(degrees_histogram_index) > max_vote
                max_vote = degrees_histogram(degrees_histogram_index);
                max_vote_histogram_index = degrees_histogram_index;
            end
        end
        
        dominant_theta = max_vote_histogram_index * num_of_histograms;
        
        for col_delta = 0:1:3
            for row_delta = 0:1:3
                
                begin_col = cols(i) - delta + (col_delta * 10);
                end_col = begin_col + 10;
                
                begin_row = rows(i) - delta + (row_delta * 10);
                end_row = begin_row + 10;
                
                histogram = zeros([1 num_of_histograms]);
                
                for col = begin_col:end_col
                    for row = begin_row:end_row
                        
                        theta = thetas(row, col) - dominant_theta;
                        
                        while theta < 0
                            theta = theta + 360;
                        end
                        
                        degrees_histogram_index = ceil(theta / num_of_degrees_histogram);
                        if degrees_histogram_index == 0
                            degrees_histogram_index = num_of_histograms;
                        end
                        
                        histogram(degrees_histogram_index) = histogram(degrees_histogram_index) + gradient(row, col);
                        
                    end
                end
                
                feature_descriptor = horzcat(feature_descriptor, histogram);
                
            end
        end
        
        % Normalization
        feature_descriptor = feature_descriptor ./ norm(feature_descriptor);
        
        % Threshold each bin at the value 0.2
        for index = 1:1:128
            if feature_descriptor(index) > 0.2
                feature_descriptor(index) = 0.2;
            end
        end
        
        % Re-normalization
        feature_descriptor = feature_descriptor ./ norm(feature_descriptor);
        
        descriptors(:,:,i) = feature_descriptor;
        
    end
    
end        

end

