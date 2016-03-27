function [ rows,cols ] = detect_features( image )
%%%
% Computer Vision 600.461/661 Assignment 2
% Args:
% 	image (numpy.ndarray): The input image to detect features on. Note: this is NOT the image name or image path.
% Returns:
% 	rows: A list of row indices of detected feature locations in the image
% 	cols: A list of col indices of detected feature locations in the image
%%%

image_gray = double(rgb2gray(image));

gaussian_kernel = fspecial('gaussian', [3 3], 1);

sobel_x = fspecial('sobel');
sobel_y = sobel_x';

i_x = filter2(sobel_x, image_gray);
i_y = filter2(sobel_y, image_gray);

f_xx = filter2(gaussian_kernel, i_x.* i_x);
f_xy = filter2(gaussian_kernel, i_x.* i_y);
f_yy = filter2(gaussian_kernel, i_y.* i_y);

CS = ((f_xx.* f_yy) - (f_xy.^2)) ./ (f_xx + f_yy + 1 * 10^-16);

[rows, cols] = nonmaxsuppts(CS, 2, 6000);

[num_of_features] = size(rows);

max_num_of_features = 1000;
% Treshold the number of features to 1000 (by random shuffling).
% Otherwise we get TOO MANY features for 'wall' images and the computation takes forever.
if num_of_features(1) > max_num_of_features
    permutations = randperm(num_of_features(1));
    random_match_indices = permutations(1:max_num_of_features);
    
    rows = rows(random_match_indices,:);
    cols = cols(random_match_indices,:);
end

end

