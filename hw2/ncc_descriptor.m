function [ descriptors ] = ncc_descriptor( image, feature_coords )

rows = feature_coords(:,1);
cols = feature_coords(:,2);

image_gray = rgb2gray(image);

[img_height, img_width] = size(image_gray);

num_of_features = length(rows);

window_size = 13;
delta = (window_size -  1) / 2;

descriptors = zeros(window_size, window_size, num_of_features);

for i = 1:1:num_of_features
    if rows(i) > delta && cols(i) > delta && cols(i) + delta < img_width && rows(i) + delta < img_height
        descriptors(:,:,i) = double(image_gray((rows(i) - delta):(rows(i) + delta), (cols(i) - delta):(cols(i) + delta)));
    end
end

descriptors = double(descriptors);

end

