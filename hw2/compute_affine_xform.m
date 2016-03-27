function [affine_xform] = compute_affine_xform(matches,features1,features2,image1,image2)
%%%
	% Computer Vision 600.461/661 Assignment 2
	% Args:
	%	matches : list of index pairs of possible matches. For example, if the 4-th feature in feature_coords1 and the 1-st feature
	%							  in feature_coords2 are determined to be matches, the list should contain (4,1).
    %   features1 (list of tuples) : list of feature coordinates corresponding to image1
    %   features2 (list of tuples) : list of feature coordinates corresponding to image2
	% 	image1 : The input image corresponding to features_coords1
	% 	image2 : The input image corresponding to features_coords2
	% Returns:
	%	affine_xform (numpy.ndarray): a 3x3 Affine transformation matrix between the two images, computed using the matches.
	% 
rows1 = features1(:,1);
cols1 = features1(:,2);

rows2 = features2(:,1);
cols2 = features2(:,2);

number_of_matches = size(matches, 1);

if number_of_matches < 3
    affine_xform = [0 0 0; 0 0 0; 0 0 1];
    return;
end

num_of_iterations = 200;

best_affine_xform = zeros(6, 1);
best_number_of_inliers = -inf;

for i = 1:num_of_iterations
    % generate three random indices
    
    permutations = randperm(number_of_matches);
    random_match_indices = permutations(1:3);
    
    % obtain three constraints
    
    x(1) = cols1(matches(random_match_indices(1),1));
    y(1) = rows1(matches(random_match_indices(1),1));
    
    x(2) = cols1(matches(random_match_indices(2),1));
    y(2) = rows1(matches(random_match_indices(2),1));
    
    x(3) = cols1(matches(random_match_indices(3),1));
    y(3) = rows1(matches(random_match_indices(3),1));
    
    x_prime(1) = cols2(matches(random_match_indices(1),2));
    y_prime(1) = rows2(matches(random_match_indices(1),2));
    
    x_prime(2) = cols2(matches(random_match_indices(2),2));
    y_prime(2) = rows2(matches(random_match_indices(2),2));
    
    x_prime(3) = cols2(matches(random_match_indices(3),2));
    y_prime(3) = rows2(matches(random_match_indices(3),2));
    
    % formulate matrix 'A' (6 x 6)
    
    A = [[x(1) y(1) 1 0 0 0]; [0 0 0 x(1) y(1) 1]; [x(2) y(2) 1 0 0 0]; [0 0 0 x(2) y(2) 1]; [x(3) y(3) 1 0 0 0]; [0 0 0 x(3) y(3) 1]]; 
    
    if cond(A) > 1e15
        num_of_iterations = num_of_iterations + 1;
        continue;
    end
    
    % formulate 'b' (6 x 1)
    
    b = [x_prime(1); y_prime(1); x_prime(2); y_prime(2); x_prime(3); y_prime(3)];
    
    % compute affine transformation matrix
    
    temp_affine_xform = A\b;
    
    number_of_inliers = 0;
    
    for j = 1:1:number_of_matches
        x_diff = (temp_affine_xform(1) * cols1(matches(j,1)) + temp_affine_xform(2) * rows1(matches(j,1)) + temp_affine_xform(3)) - cols2(matches(j,2));
        y_diff = (temp_affine_xform(4) * cols1(matches(j,1)) + temp_affine_xform(5) * rows1(matches(j,1)) + temp_affine_xform(6)) - rows2(matches(j,2));
        
        if abs(x_diff) < 3 && abs(y_diff) < 3
            number_of_inliers = number_of_inliers + 1;
        end
    end
    
    if number_of_inliers > best_number_of_inliers
        xform = [[temp_affine_xform(1) temp_affine_xform(2) temp_affine_xform(3)]; [temp_affine_xform(4) temp_affine_xform(5) temp_affine_xform(6)]; [0 0 1]];
        
        if cond(xform) < 1e15
            best_number_of_inliers = number_of_inliers;
            best_affine_xform = temp_affine_xform;
        else 
            num_of_iterations = num_of_iterations + 1;
        end
    end
end

affine_xform = [[best_affine_xform(1) best_affine_xform(2) best_affine_xform(3)]; [best_affine_xform(4) best_affine_xform(5) best_affine_xform(6)]; [0 0 1]];

end

