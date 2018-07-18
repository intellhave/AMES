% Perform Linear Fitting using Linear Equilibrium constraints
function [xn, yn, theta,  P, F, Q] = fwQuasiconvex(A, b, cd,dd, x0, y0, alpha, config, denThresh) %Note: cd, dd are to enforce strictly cheirality contraints

    if (nargin < 9)  denThresh = 0; end;  
    
    n = size(A,1);
    d = size(A,2);
    % Build the matrices
    
    N11 = [-A A*ones(d,1)];
    % generate cN matrix similar to N11 for A to enforce c_i^T\theta + d_i
    % > 0 to prevent possible divide by 0; 
    cdp = cd';    
    cN11 = [-cdp cdp*ones(d,1)];    
    ddp = dd' - denThresh*ones(numel(dd),1);        
    ri = x0(1:n);
    si = x0(n+1:end);
    yi = y0;            
    iter = 0;
    [P, F, Q] = evalP(ri, si, yi, alpha);

    disp(['+++Running EP with alpha = ' num2str(alpha) '......']);
    while (true)
        iter = iter + 1; 
        Ays = [-N11 -1*eye(n)];
        Ays = [Ays; -eye(n+d+1)];
        bys = [b; zeros(d+1+n,1)];  
        
        % Now add the cheirality constraints, only add if user wants denThresh > 0
        if (denThresh > 0)
            Ays = [Ays; [cN11 zeros(size(cN11,1), n)]];
            bys = [bys; ddp];
            disp(['Adding Constraints CiTx+d > ' num2str(denThresh)] );
        end        
        fys = [N11'*ri; ones(n,1)];                     
        [ys, exitFlag] = feval(config.lpsolver, fys, Ays, bys);                
        %syy = [ys1 ys]
        if (exitFlag<1)
            disp(exitFlag);
            disp('LP1 failed');          
            break;
        end
        yip = ys(1:d+1);
        sip = ys(d+2:end);                        
        fr = ones(n,1)+ alpha*(N11*yip+b);        
        [rip, ~] = solve_u_lp(fr);                                
        [Pnew, Fnew, Qnew] = evalP(rip, sip, yip, alpha);
        
        % Update new results
        ri = rip;
        si = sip;
        yi = yip;               
        F = Fnew;
        Q = Qnew;                        
        disp(['Iter = ' num2str(iter) ' P = ' num2str(Pnew) ' F = ' num2str(Fnew) ' Q = ' num2str(Qnew)]);               
        if ( (abs(Pnew-P)<1e-9) || (Pnew>=P)); break; end;
        P = Pnew;                       
    end    
        
    xn = [ri; si];
        yn = yi;
    theta = computeTheta(yi);
    

    function [P, F, Q] = evalP(r, s, y, alpha)        
        F = sum(r);
        Q = abs(r'*(s+N11*y+b) + s'*(-r+ones(n,1)));
        P = F + alpha*Q;        
    end

    function tt = computeTheta(yi)
        tt = yi(1:d) - repmat(yi(d+1),d,1);
    end

end


