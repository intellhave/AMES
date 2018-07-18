% Perform homography estimation between two images
% data.x1: Keypoints found on image 1
% data.x2: Keypoints found on image 2
% method: 'RANSAC' for ransac and 'EP' for Exact Penalty method
% 


function [theta, inls, runtime] = homographyFit(data, th, method, theta0, config)

    x1 = data.x1;
    x2 = data.x2;        
    T2 = data.T2;
    
    [A, b, c, d] = genMatrixHomography(x1, x2);
    [lA, lb] = genLinearMatrixFromQuasiconvex(A, b, c, d, th);    
    
    
    if (strcmp(method,'RANSAC'))                      
        tic    
        [ransacH] =  ransacfithomography(x1, x2, th);                
        runtime = toc;       
        theta = ransacH(:);
                    
    elseif (strcmp(method,'EP'))

        alpha = config.alpha;
        kappa = config.kappa;        
        QThresh = config.QThresh;
        alphaMax = config.alphaMax;  
        
        % Normalize matrix if a 3x3 matrix was supplied
        if (length(theta0)==9)
            theta0 = theta0./theta0(end);             
            theta0 = theta0(1:end-1);
        end                   
        [x0, y0] = genStartingPoint(lA, lb, theta0);        % From theta0, compute u0,s0, v0
        tic
        while (true)
            % Execute Frank-Wolfe algorithm
            [x0, y0, theta, P, F, Q] = fwQuasiconvex(lA, lb, c, d, x0, y0, alpha, config);

            printSeparator('-');
            if ( Q <= QThresh || alpha > alphaMax)                   % Reach feasible region, stop
                disp(['EP TERMINATED as Q(z) reaches ' num2str(Q)]);                
                break;
            end
            alpha = kappa*alpha;                                     % increase alpha
            
        end        
        runtime = toc;          
      elseif (strcmp(method, 'AMES'))
        if (length(theta0)==9)
            theta0 = theta0./theta0(end);             
            theta0 = theta0(1:end-1);
        end             
        tic;
        theta = admm_M_estimator(A, b, c, d, th, theta0, config);
        runtime = toc;
    else 
        error('Unkown method');        
        
    end    
    [~, ~, inls]=compute_residuals_l2(A, b, c, d, theta, th);
    

       
end