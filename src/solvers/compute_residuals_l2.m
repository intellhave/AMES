function [resn, s, inliers] = compute_residuals_l2(A, b, c, d, x, th,  normalizeH)

    if (nargin < 7); normalizeH = 1; end;        
    if (nargin<6);   th = 1;   end;    
    
    if (normalizeH == 1) && (length(x)==9); x = x./x(end); end; % For homography: If normalize, normalize homography matrix to set H33 = 1;
    
    if (size(A,2)<length(x))
        x=x(1:size(A,2));
    end
    
    nbrimages = numel(d); 
    p = size(A, 2); 
    AxPb = reshape(A*x,2,nbrimages) + b; % Ax + b
    Sqrt_AxPb = sqrt(sum(AxPb.^2));                     % sqrt(Ax + b)
    CxPd = (x'*c + d);
    
    resn = zeros(nbrimages, 1);
    id = (CxPd)>0;
    resn(id) = Sqrt_AxPb(id)./abs(CxPd(id));
    resn(~id) = max(resn);
    inliers = find(abs(resn) <= th); 
    %s = (Sqrt_AxPb./th - CxPd)';
    %s = Sqrt_AxPb(id)./abs(CxPd(id));
    s  = AxPb;
    
end
