function [ stitched_image ] = stitch_images( image1, image2, xform_matrix, xform_type )
% Stitches two images together using the given 'xform_matrix' and 'xform_type'
% This code was referenced from the following source: http://www.leet.it/home/giusti/teaching/matlab_sessions/stitching/stitch.html

T = maketform(xform_type,xform_matrix);
[im2t,xdataim2t,ydataim2t]=imtransform(image1,T);
% now xdataim2t and ydataim2t store the bounds of the transformed image1
xdataout=[min(1,xdataim2t(1)) max(size(image2,2),xdataim2t(2))];
ydataout=[min(1,ydataim2t(1)) max(size(image2,1),ydataim2t(2))];
% let's transform both images with the computed xdata and ydata
im2t=imtransform(image1,T,'XData',xdataout,'YData',ydataout);
im1t=imtransform(image2,maketform(xform_type,eye(3)),'XData',xdataout,'YData',ydataout);
stitched_image=im1t/2+im2t/2;

end

