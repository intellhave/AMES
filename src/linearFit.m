% Perform linearFitting using RANSAC/Least Square or EP method
% x, y: data;
% th: inlier threshold
% method: 'RANSAC' for ransac, 'LSQ' for least square and 'EP' for
% exact penalty
% theta0: starting point (this can be theta obtained from RANSAC or LSQ)
% config: config.lpsolver specifies LP solver
%         config.alpha specifies initial alpha
%         and config.kappa specifies incremental rate

function [theta, nInls, runtime] = linearFit(x, y, th, method, theta0, config)
    
    N = size(x,1);
    d = size(x,2);
    
    if strcmp(method, 'RANSAC')   %% RANSAC 
        tic
        [theta] = linearFitRANSAC(x, y, th);        
        runtime = toc;        
        
    elseif strcmp(method, 'LSQ')    %% Least Squares
        tic
        theta = lsqlin(x, y, [],[]);
        runtime = toc;         
    elseif (strcmp(method, 'EP'))   %% Exact penalty    
        
        [A, b]= genLinearMatrix(x, y, th);         % Collect data into matrix A and vector b
                                                   % to form set of constrains Ax <= b
        [x0, y0] = genStartingPoint(A, b, theta0); % From theta0, compute u0, s0, v0

        alpha = config.alpha;                      % Inital alpha
        kappa = config.kappa;                      % Incremental rate

        tic          
        
        iter = 0;        
        while true
            % Execute Frank-Wolfe
            [x0, y0, theta, P1, F, Q] = fw(A, b, x0, y0, alpha, config.lpsolver);           %[xn, yn, theta, currP, f, Q, iter]                                 
            printSeparator('-');
            if (Q<=config.QThresh || alpha > config.maxAlpha)                               % Q reaches zero, stop
                disp([' EP TERMINATED  as Q(z) reaches ' num2str(Q) ]);
                printSeparator('.');
                break;
            end
            % Increase alpha
            alpha = alpha*kappa;                                              
            
        end
        runtime = toc; 
    elseif strcmp(method, 'AMES')
        tic
        [A, b, c, d] = genQuasiconvexMatrixLinear(x, y);
        [theta, ~] = admm_M_estimator(A, b, c, d, th, theta0, config);       
        runtime = toc;        
    end
    
    %% Find Inliers
    if (isempty(theta))
        theta = theta0;
    end
    inls = find(abs(y-x*theta)<=th);
    nInls = numel(inls);
end












