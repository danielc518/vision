%image_pairs = 'bikes1 bikes2 bikes1 bikes3 graf1 graf2 graf1 graf3 leuven1 leuven2 leuven1 leuven3 wall1 wall2 wall1 wall3';

% Use the image pairs above (in the comment) to run full set of pairs
image_pairs = 'bikes1 bikes2'; % Two image pairs separated by single white space

image_pairs = strsplit(image_pairs, ' ');

num_of_pairs = size(image_pairs, 2);

% First round: use NCC

for pair_index = 1:2:num_of_pairs
    image_pair1 = char(image_pairs(pair_index));
    image_pair2 = char(image_pairs(pair_index + 1));
    
    image1 = imread(strcat(image_pair1, '.png'));
    image2 = imread(strcat(image_pair2, '.png'));
    
    [rows1, cols1] = detect_features(image1);
    [rows2, cols2] = detect_features(image2);
    
    feature_coords1 = [rows1, cols1];
    feature_coords2 = [rows2, cols2];
    
    matches = match_features(feature_coords1, feature_coords2, image1, image2);
    
    affine_xform = compute_affine_xform(matches, feature_coords1, feature_coords2, image1, image2);
    proj_xform = compute_proj_xform(matches, feature_coords1, feature_coords2, image1, image2);
    
    if cond(affine_xform) < 1e18
        imwrite(stitch_images(image1, image2, affine_xform', 'affine'), strcat(strcat(strcat(strcat('ncc_affine_', image_pair1), '_'), image_pair2), '.png'), 'PNG');
    end
    
    if cond(proj_xform) < 1e18
        imwrite(stitch_images(image1, image2, proj_xform', 'projective'), strcat(strcat(strcat(strcat('ncc_projective_', image_pair1), '_'), image_pair2), '.png'), 'PNG');
    end
    
    h = figure('Visible','off');
    
    set(h, 'name', 'NCC Feature Matching');
    
    [im1_num_rows,im1_num_cols] = size(image1(:,:,1));
    [im2_num_rows,im2_num_cols] = size(image2(:,:,1));
    stackedImage = uint8(zeros(max([im1_num_rows,im2_num_rows]), im1_num_cols+im2_num_cols,3));
    stackedImage(1:im1_num_rows,1:im1_num_cols,:) = image1;
    stackedImage(1:im2_num_rows,im1_num_cols+1:im1_num_cols+im2_num_cols,:) = image2;
    
    imshow(stackedImage), hold on
    
    width_offset = size(image1, 2);
    
    number_of_matches = size(matches, 1);
    
    for i = 1:1:number_of_matches
        x(1) = cols1(matches(i,1));
        y(1) = rows1(matches(i,1));
        x(2) = cols2(matches(i,2)) + width_offset;
        y(2) = rows2(matches(i,2));
        
        xform_coord = affine_xform * [x(1); y(1); 1];
        
        x_diff = xform_coord(1) - cols2(matches(i,2));
        y_diff = xform_coord(2) - rows2(matches(i,2));
        
        if abs(x_diff) < 3 && abs(y_diff) < 3
            line(x, y, 'Color', [0 1 0]);
        else
            line(x, y, 'Color', [1 0 0]);
        end
    end
    
    f = getframe(h); imwrite(f.cdata, strcat(strcat(strcat(strcat('ncc_', image_pair1), '_'), image_pair2), '.png'), 'PNG');
    
    hold off
end

% Second round: use simple SIFT

for pair_index = 1:2:num_of_pairs
    image_pair1 = char(image_pairs(pair_index));
    image_pair2 = char(image_pairs(pair_index + 1));
    
    image1 = imread(strcat(image_pair1, '.png'));
    image2 = imread(strcat(image_pair2, '.png'));
    
    [rows1, cols1] = detect_features(image1);
    [rows2, cols2] = detect_features(image2);
    
    feature_coords1 = [rows1, cols1];
    feature_coords2 = [rows2, cols2];
    
    matches = ssift_match_features(feature_coords1, feature_coords2, image1, image2);
    
    affine_xform = compute_affine_xform(matches, feature_coords1, feature_coords2, image1, image2);
    proj_xform = compute_proj_xform(matches, feature_coords1, feature_coords2, image1, image2);
    
    if cond(affine_xform) < 1e18
        imwrite(stitch_images(image1, image2, affine_xform', 'affine'), strcat(strcat(strcat(strcat('ssift_affine_', image_pair1), '_'), image_pair2), '.png'), 'PNG');
    end
    
    if cond(proj_xform) < 1e18
        imwrite(stitch_images(image1, image2, proj_xform', 'projective'), strcat(strcat(strcat(strcat('ssift_projective_', image_pair1), '_'), image_pair2), '.png'), 'PNG');
    end
    
    h = figure('Visible','off');
    
    set(h, 'name', 'SSIFT Feature Matching');
    
    [im1_num_rows,im1_num_cols] = size(image1(:,:,1));
    [im2_num_rows,im2_num_cols] = size(image2(:,:,1));
    stackedImage = uint8(zeros(max([im1_num_rows,im2_num_rows]), im1_num_cols+im2_num_cols,3));
    stackedImage(1:im1_num_rows,1:im1_num_cols,:) = image1;
    stackedImage(1:im2_num_rows,im1_num_cols+1:im1_num_cols+im2_num_cols,:) = image2;
    
    imshow(stackedImage), hold on
    
    width_offset = size(image1, 2);
    
    number_of_matches = size(matches, 1);
    
    for i = 1:1:number_of_matches
        x(1) = cols1(matches(i,1));
        y(1) = rows1(matches(i,1));
        x(2) = cols2(matches(i,2)) + width_offset;
        y(2) = rows2(matches(i,2));
        
        xform_coord = affine_xform * [x(1); y(1); 1];
        
        x_diff = xform_coord(1) - cols2(matches(i,2));
        y_diff = xform_coord(2) - rows2(matches(i,2));
        
        if abs(x_diff) < 3 && abs(y_diff) < 3
            line(x, y, 'Color', [0 1 0]);
        else
            line(x, y, 'Color', [1 0 0]);
        end
        
    end
    
    f = getframe(h); imwrite(f.cdata, strcat(strcat(strcat(strcat('ssift_', image_pair1), '_'), image_pair2), '.png'), 'PNG');
    
    hold off
end