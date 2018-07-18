% ADMM-based estimator
% A, b, c, d: set of constraints in the form of ||a_i*theta + b_i||/(c^T_i*theta+d_i)

function [bestTheta, bestInls] = admm_M_estimator(A,b,c,d, th0, theta0, config)

    N = size(A,1)/2;
    dim = size(A,2);

    % Initial values
    theta = theta0;
    theta_p = repmat(theta0, 1, N); % Auxiliary variables
    lambda = sparse(zeros(dim, N)); % Scaled Lagrangian multipliers
    
    iter = 0;    
    beta = config.beta_admm;
    gamma = config.ames_gamma;
    th = th0;
    
    [~, ~, inls]=compute_residuals_l2(A, b, c, d, theta0, th0);         
    maxInls = length(inls);
    disp(['Init inls = ' num2str(length(inls))]);
    bestInls = inls;
    bestTheta = theta0;
    
    % Prepare the matrices
    Aq1_arr = cell(1,N); Aq2_arr = cell(1,N);       
    bq1_arr = zeros(size(A,2), N); bq2_arr = bq1_arr; 
    Q1_arr = Aq1_arr; Q2_arr = Aq2_arr;
    D1_arr = Aq1_arr; D2_arr = Aq2_arr;
    r1_arr = zeros(1, N); r2_arr = r1_arr;
    
    for i=1:N
           a1 = A(2*i-1,:); b1 = b(1,i); a2 = A(2*i,:); b2 = b(2,i);
           Aq1 = a1'*a1; Aq2 = a2'*a2; 
           Cq = c(:,i)*c(:,i)';
           
           bq1 = b1.*a1'; bq2 = b2.*a2'; cq = d(i).*c(:,i);
           
           Aq1_arr{i} =  Aq1 + Aq2 - th.^2*Cq;
           bq1_arr(:,i) =  2*(bq1 + bq2 - th.^2*cq);
           r1_arr(i) =   b1^2 + b2^2 - (th*d(i))^2;           
           
           
           
           Aq2_arr{i} = -(Aq1 + Aq2) + th.^2*Cq;
           bq2_arr(:,i) =  2*(th.^2*cq - bq1 - bq2);
           r2_arr(i) = (th*d(i)).^2 - b1^2 - b2^2;
           
            
           P1 = 0.5*( Aq1_arr{i} +  Aq1_arr{i}');
           [Q,D] = eigs(P1);   
           Q1_arr{i} = Q; D1_arr{i} = D;
           
           P2 = 0.5*( Aq2_arr{i} +  Aq2_arr{i}');
           [Q,D] = eigs(P2);   
           Q2_arr{i} = Q; D2_arr{i} = D;
           
     end
    % Start ADMM Update
    while (true)
        % Auxiliary update
        parfor i=1:N

           tld = theta - lambda(:,i);
           %z = (beta*1.0/(beta-1/N))*tld; %% Note here changed to beta -1
           z = (beta*1.0/(beta-gamma))*tld; %% Note here changed to beta -1           
           Aq = Aq1_arr{i}; bq = bq1_arr(:,i) ; Q = Q1_arr{i}; D = D1_arr{i}; 
           r = r1_arr(i);
           [t1,~] = qcqp_oneconstr(z, Aq, bq, r, Q, D);
           
           Aq = Aq2_arr{i}; bq = bq2_arr(:,i) ; Q = Q2_arr{i}; D = D2_arr{i}; 
           r = r2_arr(i); 
           [t2,~] = qcqp_oneconstr(z, Aq, bq, r, Q, D);

           % Recompute cost
           
           c1 = 0 - gamma*norm(t1)^2 + beta*norm(t1 - tld)^2;
           c2 = 1 - gamma*norm(t2)^2 + beta*norm(t2 - tld)^2;
           
           % pick theta_p that induces smaller cost	   
           if (c1<=c2)
               theta_p(:,i) = t1; 
           else
               theta_p(:,i) = t2;            
           end	              
           
        end
            
        %theta update
        ptheta = theta;
        theta =  (beta./(N*beta - N*gamma)).*sum(theta_p + lambda,2); % redo N*beta + N
        
        % Lambda Update
        lambda = lambda + theta_p - repmat(theta,1,N);
        
        
        beta = beta*config.ames_rho_increase_rate;
        
        for i=1:N
            [~, ~, inls]=compute_residuals_l2(A, b, c, d, theta_p(:,i) , th0);  
            if (length(inls) > maxInls) 
                maxInls = length(inls); bestInls = inls; bestTheta = theta_p(:,i);                 
            end
        end
        % Stopping criterion
        [~, ~, inls]= compute_residuals_l2(A, b, c, d, theta, th0);         
        iter = iter + 1  ;   
        disp([' iter = ' num2str(iter) ' rho  =  ' num2str(beta) '  diff = ' num2str(norm(theta-ptheta)) ' maxInls = ' num2str(maxInls)...
            ]);
        
        
        
        if (length(inls) > maxInls) 
            maxInls = length(inls); bestInls = inls; bestTheta = theta;            
        end
            
        if (iter > config.ames_max_iter); disp('Reached max iter ');break; end
        if (norm(theta - ptheta) <  config.ames_theta_diff && iter > 10 ); disp(['Converged ' num2str(norm(theta-ptheta))]);break; end
        
        
    end
    
    %disp(maxInls);

end
