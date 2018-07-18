clear;
close all;


datasetName = 'linear';
datasetFolder = 'dataset/';
filename = [datasetFolder datasetName '.mat'];

N = 500;     % Number of Points

sig = 0.1;     % Inlier Varience

osig = 1;       % Outlier Varience

d = 8;       % Data dimensions

outlierP = 40;  % Outlier percentage;

balancedData = 1; % if set to 1 the generated outliers are evenly  distributed on both sides of the hyperplane.
                  %Otherwise, outliers are distributed only on the positive side of the hyperplane
linearData = {};
    
    for inst = 1:dataInstance
        dtp = dtp + 1;
        [x,y,m,c, ~, inlNoise, trueInliers, trueOutliers, th] = genRandomLinearData(N, d, sig, osig, outlierP, balancedData);
        data.N = N;
        data.x = x;
        data.y = y;

        if (d==2)
         close all;        
         plot(data.x(:,1), data.y, '+');
         fig = gcf;
         hold on;
         lineplot(fig, [-1;1], [m;c], 'red');
        end         
        data.m = m;
        data.c = c;
        data.trueInliers = trueInliers;
        data.th = th;
        data.dim = d;
        data.sig = sig;
        data.osig = osig;
        data.outlierP = outlierP;
        data.dataInstance = inst;
        linearData{dtp} = data;
    end

    outlierP = outlierP + pOutlierStep;

end

disp(['Generating Dataset  ' filename]);

%save(filename,'linearData');

if (exist(filename, 'file')>0 && ~config.overwrite)
    error('File exists');    
else
    save(filename,'linearData');    
end