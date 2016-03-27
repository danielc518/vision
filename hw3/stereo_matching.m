scene_l = mat2gray(imread('scene_l.bmp'));
scene_r = mat2gray(imread('scene_r.bmp'));

[scene_l_height, scene_l_width] = size(scene_l);

baseline = 0.1;
focal_length = 400;

window_size = 15;
delta = (window_size -  1) / 2;

max_disparity = 16;

depth_image = zeros(scene_l_height - (2 * delta), scene_l_width - (2 * delta) - max_disparity);

for i=(1 + delta):(scene_l_height - delta)
    for j=(1 + delta):(scene_l_width - delta - max_disparity)
        min_ncc = 0.0;
        
        min_disparity = 0;
        
        for disparity=0:max_disparity
            ncc_numerator=0.0;
            ncc_denominator_r=0.0;
            ncc_denominator_l=0.0;
            
            for d_y=-delta:delta
                for d_x=-delta:delta
                   ncc_numerator = ncc_numerator + (scene_r(i + d_y, j + d_x) * scene_l(i + d_y, j + d_x + disparity));
                   ncc_denominator_l = ncc_denominator_l + (power(scene_l(i + d_y, j + d_x + disparity), 2));
                   ncc_denominator_r = ncc_denominator_r + (power(scene_r(i + d_y, j + d_x), 2));
                end
            end
            
            ncc = ncc_numerator / sqrt(ncc_denominator_r * ncc_denominator_l);
            
            if (min_ncc < ncc)
                min_ncc = ncc;
                min_disparity = disparity;
            end
        end
        
        depth_image(i,j) = (baseline * focal_length) / min_disparity;
    end
end

center = size(scene_l) / 2;

point_cloud = [];

fid = fopen('point_cloud.txt','wt');
for i=(1 + delta):(scene_l_height - delta)
    for j=(1 + delta):(scene_l_width - delta - max_disparity)
        x = (j - center(2)) * depth_image(i, j) / focal_length;
        y = (i - center(1)) * depth_image(i, j) / focal_length;
        fprintf(fid, '%f ', [x y depth_image(i, j)]);
        fprintf(fid, '\n');
    end
end
fclose(fid);

imagesc(depth_image);

%pcshow(point_cloud);