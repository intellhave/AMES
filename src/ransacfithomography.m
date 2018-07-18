% Find homography transformation between pointset x1 and x2 using ransac
% x1, x2: set of keypoints in image1 and image2 respectively
% t: inlier threshold
% H: Best model 


function [H] = ransacfithomography(x1, x2, t)
    
    if ~all(size(x1)==size(x2))
        error('Data sets x1 and x2 must have the same dimension');
    end
    
    [rows,npts] = size(x1);
    if rows~=2 & rows~=3
        error('x1 and x2 must have 2 or 3 rows');
    end
    
    if npts < 4
        error('Must have at least 4 points to fit homography');
    end
        
    if rows == 2    % Pad data with homogeneous scale factor of 1
        x1 = [x1; ones(1,npts)];
        x2 = [x2; ones(1,npts)];        
    end       
    
    s = 4;  % Minimum No of points needed to fit a homography.
    
    fittingfn = @homography2d;
    distfn    = @homogdist2d_l1;
    degenfn   = @isdegenerate;
    feedback = 0;
    % x1 and x2 are 'stacked' to create a 6xN array for ransac
    [H] = myHomographyRansac([x1; x2], fittingfn, distfn, degenfn, s, t, 1000, 1e9);

    
function [inliers, H] = homogdist2d_l1(H, x, t)    
    x1 = x(1:3,:);   % Extract x1 and x2 from x
    x2 = x(4:6,:);           
    [A, b, c, d] = genMatrixHomography(x1, x2);    
    H = H'; 
    [~, ~, inliers] = compute_residuals_l1(A, b, c, d, H(:), t);    
       
%----------------------------------------------------------------------
% Function to determine if a set of 4 pairs of matched  points give rise
% to a degeneracy in the calculation of a homography as needed by RANSAC.
% This involves testing whether any 3 of the 4 points in each set is
% colinear. 
     
function r = isdegenerate(x)

    x1 = x(1:3,:);    % Extract x1 and x2 from x
    x2 = x(4:6,:);    
    
    r = ...
        iscolinear(x1(:,1),x1(:,2),x1(:,3)) | ...
    iscolinear(x1(:,1),x1(:,2),x1(:,4)) | ...
    iscolinear(x1(:,1),x1(:,3),x1(:,4)) | ...
    iscolinear(x1(:,2),x1(:,3),x1(:,4)) | ...
    iscolinear(x2(:,1),x2(:,2),x2(:,3)) | ...
    iscolinear(x2(:,1),x2(:,2),x2(:,4)) | ...
    iscolinear(x2(:,1),x2(:,3),x2(:,4)) | ...
    iscolinear(x2(:,2),x2(:,3),x2(:,4));
    



