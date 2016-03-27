function [ matches ] = ssift_match_features(feature_coords1,feature_coords2,image1,image2)
%%%
% Computer Vision 600.461/661 Assignment 2
% Args:
%	feature_coords1 : list of (row,col) feature coordinates from image1
%	feature_coords2 : list of (row,col)feature coordinates from image2
% 	image1 : The input image corresponding to features_coords1
% 	image2 : The input image corresponding to features_coords2
% Returns:
% 	matches : list of index pairs of possible matches. For example, if the 4-th feature in feature_coords1 and the 1-st feature
%							  in feature_coords2 are determined to be matches, the list should contain (4,1).
%%%
matches = [];

ssift_descriptors1 = ssift_descriptor(feature_coords1, image1);
ssift_descriptors2 = ssift_descriptor(feature_coords2, image2);

number_of_descriptors1 = size(ssift_descriptors1, 3);
number_of_descriptors2 = size(ssift_descriptors2, 3);

for i = 1:number_of_descriptors2
    
    match_index = -1;
    shortest_distance = inf;
    second_shortest_distance = inf;
    
    for j = 1:number_of_descriptors1
        
        distance = norm(ssift_descriptors2(:,:,i) - ssift_descriptors1(:,:,j));
        
        if distance < shortest_distance
            second_shortest_distance = shortest_distance;
            shortest_distance = distance;
            match_index = j;
        end
        
    end
    
    if match_index > -1 && second_shortest_distance < inf
        if (shortest_distance / second_shortest_distance) < 0.7
            matches = vertcat(matches, [match_index i]);
        end
    end
    
end

end

