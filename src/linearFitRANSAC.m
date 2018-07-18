%% Perform RANSAC for linear fitting
% x, y: input data
% th: inlier threshold (epsilon)

function [theta, inliers] = linearFitRANSAC(x, y, th)    

    X = [x, y]'; 
    fittingfn = @myFitTchebycheff;    % Function to fit linear data
    distfn    = @lineptdist;          % Function to compute residual
    degenfn   = @isdegenerate;

    maxTrials = 1e9;        % Stopping criteria of rho = 0.99 should be satisfied first. This value is to have a safeguard to prevent infinite loop
    maxDataTrials = 1000;
       
    s = size(x, 2);         
    [theta] = myRANSAC(X, fittingfn, distfn, degenfn, s, th, maxDataTrials,maxTrials);
    
end


function [inliers, xn] = lineptdist(xn, XY, t)
% compute residuals and find inliers for a specific
% theta (xn) and inlier threshold (t)

    X = XY(1:end-1, :)';  
    Y = XY(end, :)'; 
    d = X*xn - Y;     
    inliers = find(abs(d) < t);

    
end

function r = isdegenerate(X)
    r = 0; % Degenerate function can be implemented based on application. For now assume r = 0;
end

