%% Generate random data
%  N: number of data points
%  d: dimensions
function [x,y] = genRandomLinearData(N, dim, in_var, out_var, outlierP, balance)
 
    if (nargin < 6)
        balance = 1;
    end
    rng('shuffle');
   
    sig = in_var; % Inlier Varience
    osig = out_var;   % Outlier Varience
    n = dim; % Dimension of space
    m = rand(n-1, 1);    
    c = randn; 
    
    %% Generate data
    xo = -1 + 2.*rand(n-1,N);  
    yo = m'*xo + repmat(c,1,N); 

    %% Perturb data by Gaussian noise
    x = xo;
    gNoise = sig*randn(1,N);
    y = yo + gNoise; 
    
    %% Generate outliers   
    t = outlierP; 
    t = round(N*t/100); 

    k1 = 1; k2 = -k1;
    if (~balance) k2 = k1; end;        

    for i=1:t        
        r = y(i) - yo(i);
        if (r > 0)
            y(i) = y(i)+ k1*osig*rand;
        else 
            y(i) = y(i)+ k2*osig*rand;
        end
    end
        
    x = x'; 
    x = [x, ones(N, 1)];
    y = y';
          
end


