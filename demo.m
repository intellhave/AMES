
function demo()
    addpath('src/');
    addpath('src/solvers');
    printIntro();    
    printSeparator('-');
    
    % Linear
    disp('Please press any key to start demo for robust linear regression with synthetic data'); pause;% 
    linearRegressionDemo();

    % Homography
    disp('Please press any key to continue with robust homography estimation....');  pause;
    homographyDemo();


    %----------------------------------------------------------------------


    function linearRegressionDemo()
    %% Demo for linear regression with synthetic data
        printSeparator(' ');printSeparator('*'); 
        disp(' ROBUST LINEAR REGRESSION WITH SYNTHETIC DATA ');
        printSeparator('*'); printSeparator(' ');
        

        N = 1000;   % Number of points
        d = 20;     % data dimension
        sig = 0.1; % inlier variance used to generate Gaussian noise
        osig = 2.0;  % outlier vanrance

        outlierP = 60; % Outlier percentage
        balanceData = 0; % If balanceData = 1, outliers are evenly distributed on both sides of the hyperplane.
                         % Otherwise, if balanaceData = 0, outliers are distributed only on positive side of the hyperplane.

        epsilon = 0.4;   % Inlier threshold
        
        %============================================
        %   Configurations for AMES
        %============================================
        config.beta_admm = 0.1; % Initial Rho
        config.ames_rho_increase_rate = 1.2; % rho increase rate 
        config.ames_theta_diff  = 0.005; % stopping creterion 
        config.ames_max_iter = 1000;      % Maximum number of iterations
        config.ames_mu = 0.01;          % mu
        config.ames_gamma = 0.001;
        linearConfig = config;
        %-----------------------------------------------------------------------
        disp(['Generating Random Data with N = ' num2str(N) ' points in d=' num2str(d) ' dimensions with approx.' num2str(outlierP) '% of outliers' ]);
        if (balanceData) disp('Data generated is balanced'); elseif ('Data generated is unbalanced'); end
        printSeparator('-');
        [x,y] = genRandomLinearData(N, d, sig, osig, outlierP, balanceData);
        disp('Data generated. Press any key to execute Least squares (LSQ) fit'); pause;        
        %-----------------------------------------------------------------------
        printSeparator('-');
        disp('Executing LEAST SQUARE ..... ');
        [lsqTheta, lsqInliers, lsqRuntime ] = linearFit(x, y, epsilon, 'LSQ', randn(1,d), linearConfig);
        disp(['LSQ  #Inliers = '  num2str(lsqInliers)]);
        disp(['LSQ Runtime  = ' num2str(lsqRuntime) ' seconds']);
        disp('Least square terminated');
        disp(['Press any key to execute AMES with Least squares starting point']); pause;        
        %-----------------------------------------------------------------------
        printSeparator('-');
        disp('Executing AMES with LEAST SQUARES starting point ');
        [~, amesInliers, amesRuntime] = linearFit(x, y, epsilon, 'AMES', lsqTheta, linearConfig);
        disp(['AMES #Inliers = '  num2str(amesInliers) ]);
        disp(['AMES Runtime = '  num2str(amesRuntime) ' seconds']);
        disp(['AMES Runtime  = ' num2str(lsqRuntime+amesRuntime) ' seconds (including LSQ runtime) ' ]);
        
        %-----------------------------------------------------------------------
        printSeparator('=');
        disp('++++++ FINAL REPORT FOR LINEAR REGRESSION ++++++++++');
        disp(['N = ' num2str(N)]);        
        disp(['Least Squares #Inliers = '  num2str(lsqInliers)]);
        disp(['Least squares Runtime  = ' num2str(lsqRuntime) ' seconds ']);
        printSeparator('.');               
        disp(['AMES #Inliers = '  num2str(amesInliers) ]);
        disp(['AMES Runtime = '  num2str(amesRuntime) ' seconds']);
        disp(['AMES Runtime  = ' num2str(lsqRuntime+amesRuntime) ' seconds (including LSQ runtime) ' ]);
        printSeparator('.');        
        
        printSeparator('=');
        
    end    
    %% Demo for homography estimation


    function homographyDemo()

        printSeparator(' ');printSeparator('*'); 
        disp('ROBUST HOMOGRAPHY ESTIMATION ');
        printSeparator('*'); printSeparator(' ');
        disp('Loading data set (University Library).....');

        datasetFolder = 'dataset/';
        homographyDataset = 'unionhouse';
        dataFile = [datasetFolder homographyDataset '.mat'];
        load(dataFile);
        data=homographyData{1};                
        
        homographyEpsilon = 1.0; % Inlier threshold (epsilon) 
        
        %============================================
        %   Configurations for AMES
        %============================================
        config.beta_admm = 1.5; % Initial Rho
        config.ames_rho_increase_rate = 1.1; % rho increase rate 
        config.ames_theta_diff  = 0.001; % stopping creterion 
        config.ames_max_iter = 1000;      % Maximum number of iterations
        config.ames_mu = 0.001;          % mu        
        config.ames_gamma = 0.01;
        homographyConfig = config;
        
        disp('Dataset loaded. Press any key to execute RANSAC'); pause;
        printSeparator('-');
        %-----------------------------------------------------------------------
        disp('Executing RANSAC..... ');
        [ransacTheta, ransacInliers, ransacRuntime] = homographyFit(data, homographyEpsilon, 'RANSAC', rand(8,1), homographyConfig);
        disp(['Ransac  #Inliers = '  num2str(numel(ransacInliers))]);
        disp(['Ransac Runtime  = ' num2str(ransacRuntime) ' seconds']);
        disp('RANSAC terminated. Press any key to execute AMES'); pause;
        printSeparator('-');
        %-----------------------------------------------------------------------
        disp('Executing AMES using RANSAC as starting point');        
        [~, amesInliers, amesRuntime] = homographyFit(data, homographyEpsilon, 'AMES', ransacTheta, homographyConfig);
        disp(['AMES #Inliers = '  num2str(numel(amesInliers))]);
        disp(['AMES Runtime = '       num2str(amesRuntime) ' seconds' ]); 
        disp(['AMES Runtime  = ' num2str(ransacRuntime+amesRuntime) ' seconds (including RANSAC)']);%         


        %----------------------------------------------------------------------                
        printSeparator('=');
        disp('++++++ FINAL REPORT ++++++++++');
        disp(['N = '  num2str(length(data.x1))]);
        disp(['Ransac  #Inliers = '  num2str(numel(ransacInliers))]);
        disp(['Ransac Runtime  = ' num2str(ransacRuntime) ' seconds']);
        printSeparator('-');
        disp(['AMES #Inliers = '  num2str(numel(amesInliers))]);
        disp(['AMES Runtime = '       num2str(amesRuntime) ' seconds'  ]);
        disp(['AMES Runtime  = ' num2str(ransacRuntime+amesRuntime) ' seconds (including RANSAC runtime)']);    

        
        printSeparator('=');
        matches = data.matches;
        close all;
        plot_match(matches, [matches.X1; matches.X2], amesInliers, 1, 0);
        title('Inliers (green lines) and outliers (red lines) found by AMES');
    end
    
end
