function [proj_xform] = compute_proj_xform(matches,features1,features2,image1,image2)
	%%%
	% Computer Vision 600.461/661 Assignment 2
	% Args:
	%	matches : list of index pairs of possible matches. For example, if the 4-th feature in feature_coords1 and the 1-st feature
	%							  in feature_coords2 are determined to be matches, the list should contain (4,1).
    %   features1 : list of feature coordinates corresponding to image1
    %   features2 : list of feature coordinates corresponding to image2
	% 	image1 : The input image corresponding to features_coords1
	% 	image2 : The input image corresponding to features_coords2
	% Returns:
	%	proj_xform (numpy.ndarray): a 3x3 Projective transformation matrix between the two images, computed using the matches.
	% 
rows1 = features1(:,1);
cols1 = features1(:,2);

rows2 = features2(:,1);
cols2 = features2(:,2);

number_of_matches = size(matches, 1);

if number_of_matches < 4
    proj_xform = [0 0 0; 0 0 0; 0 0 0];
    return;
end

num_of_iterations = 200;

best_affine_xform = zeros(9, 1);
best_number_of_inliers = -inf;

for i = 1:num_of_iterations
    % generate four random indices
    
    permutations = randperm(number_of_matches);
    random_match_indices = permutations(1:4);
    
    % obtain four constraints
    
    x(1) = cols1(matches(random_match_indices(1),1));
    y(1) = rows1(matches(random_match_indices(1),1));
    
    x(2) = cols1(matches(random_match_indices(2),1));
    y(2) = rows1(matches(random_match_indices(2),1));
    
    x(3) = cols1(matches(random_match_indices(3),1));
    y(3) = rows1(matches(random_match_indices(3),1));
    
    x(4) = cols1(matches(random_match_indices(4),1));
    y(4) = rows1(matches(random_match_indices(4),1));
    
    x_prime(1) = cols2(matches(random_match_indices(1),2));
    y_prime(1) = rows2(matches(random_match_indices(1),2));
    
    x_prime(2) = cols2(matches(random_match_indices(2),2));
    y_prime(2) = rows2(matches(random_match_indices(2),2));
    
    x_prime(3) = cols2(matches(random_match_indices(3),2));
    y_prime(3) = rows2(matches(random_match_indices(3),2));
    
    x_prime(4) = cols2(matches(random_match_indices(4),2));
    y_prime(4) = rows2(matches(random_match_indices(4),2));
    
    % formulate matrix 'A' (8 x 9)
    
    A = [x(1) y(1) 1 0 0 0 -(x_prime(1) * x(1)) -(x_prime(1) * y(1)) -x_prime(1)];
    A = [A ; [0 0 0 x(1) y(1) 1 -(y_prime(1) * x(1)) -(y_prime(1) * y(1)) -y_prime(1)]];
    A = [A ; [x(2) y(2) 1 0 0 0 -(x_prime(2) * x(2)) -(x_prime(2) * y(2)) -x_prime(2)]];
    A = [A ; [0 0 0 x(2) y(2) 1 -(y_prime(2) * x(2)) -(y_prime(2) * y(2)) -y_prime(2)]];
    A = [A ; [x(3) y(3) 1 0 0 0 -(x_prime(3) * x(3)) -(x_prime(3) * y(3)) -x_prime(3)]];
    A = [A ; [0 0 0 x(3) y(3) 1 -(y_prime(3) * x(3)) -(y_prime(3) * y(3)) -y_prime(3)]];
    A = [A ; [x(4) y(4) 1 0 0 0 -(x_prime(4) * x(4)) -(x_prime(4) * y(4)) -x_prime(4)]];
    A = [A ; [0 0 0 x(4) y(4) 1 -(y_prime(4) * x(4)) -(y_prime(4) * y(4)) -y_prime(4)]];
    
    [U S V] = svd(double(A));
    
    temp_proj_xform = V(:,9);
    
    number_of_inliers = 0;
    
    for j = 1:1:number_of_matches
        x_diff = ((temp_proj_xform(1) * cols1(matches(j,1)) + temp_proj_xform(2) * rows1(matches(j,1)) + temp_proj_xform(3)) / (temp_proj_xform(7) * cols1(matches(j,1)) + temp_proj_xform(8) * rows1(matches(j,1)) + temp_proj_xform(9))) - cols2(matches(j,2));
        y_diff = ((temp_proj_xform(4) * cols1(matches(j,1)) + temp_proj_xform(5) * rows1(matches(j,1)) + temp_proj_xform(6)) / (temp_proj_xform(7) * cols1(matches(j,1)) + temp_proj_xform(8) * rows1(matches(j,1)) + temp_proj_xform(9))) - rows2(matches(j,2));
        
        if abs(x_diff) < 3 && abs(y_diff) < 3
            number_of_inliers = number_of_inliers + 1;
        end
    end
    
    if number_of_inliers > best_number_of_inliers
        xform = [[temp_proj_xform(1) temp_proj_xform(2) temp_proj_xform(3)]; [temp_proj_xform(4) temp_proj_xform(5) temp_proj_xform(6)]; [temp_proj_xform(7) temp_proj_xform(8) temp_proj_xform(9)]];
        
        if cond(xform) < 1e15
            best_number_of_inliers = number_of_inliers;
            best_affine_xform = temp_proj_xform;
        else 
            num_of_iterations = num_of_iterations + 1;
        end
    end
end

proj_xform = [[best_affine_xform(1) best_affine_xform(2) best_affine_xform(3)]; [best_affine_xform(4) best_affine_xform(5) best_affine_xform(6)]; [best_affine_xform(7) best_affine_xform(8) best_affine_xform(9)]];

end


