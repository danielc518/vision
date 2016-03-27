function [ matches ] = match_features(feature_coords1,feature_coords2,image1,image2)
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

ncc_descriptors1 = ncc_descriptor(image1, feature_coords1);
ncc_descriptors2 = ncc_descriptor(image2, feature_coords2);

number_of_descriptors1 = size(ncc_descriptors1, 3);
number_of_descriptors2 = size(ncc_descriptors2, 3);

match_candidates = [];

for i = 1:1:number_of_descriptors1
    
    match_index = -1;
    longest_distance = -inf;
    
    for j = 1:1:number_of_descriptors2
        ncc = compute_ncc(ncc_descriptors1, ncc_descriptors2, i, j);
        
        if ncc > longest_distance
            longest_distance = ncc;
            match_index = j;
        end
        
    end
    
    if match_index > -1
        match = [i match_index];
        match_candidates = vertcat(match_candidates, match);
    end
    
end

for i = 1:1:number_of_descriptors2
    
    match_index = -1;
    longest_distance = -inf;
    
    for j = 1:1:number_of_descriptors1
        ncc = compute_ncc(ncc_descriptors1, ncc_descriptors2, j, i);
        
        if ncc > longest_distance
            longest_distance = ncc;
            match_index = j;
        end
    end
    
    if match_index > -1
        marriage_index = -1;
        
        for k = 1:1:length(match_candidates)
            if match_candidates(k, 2) == i
                marriage_index = k;
            end
        end
        
        if marriage_index > -1
            match = [match_index i];
            matches = vertcat(matches, match);
        end
        
    end
    
end

    function ncc = compute_ncc(ncc_descriptors1, ncc_descriptors2, descriptors1_index, descriptors2_index)
        norm1 = compute_norm(ncc_descriptors1, descriptors1_index);
        norm2 = compute_norm(ncc_descriptors2, descriptors2_index);
        ncc = norm1 .* norm2;
        ncc = sum(sum(ncc));
    end

    function norm_value = compute_norm(descriptors, index)
        norm_value = descriptors(:,:,index);
        norm_value = norm_value ./ norm(norm_value);
    end
end

