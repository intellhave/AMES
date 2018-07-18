function homographyDemo()

printSeparator('*');
disp(' HOMOGRAPHY ESTIMATION ');
printSeparator('*');

datasetFolder = 'dataset/';
homographyDataset = 'university';
dataFile = [datasetFolder homographyDataset '.mat'];
load(dataFile);
data=homographyData{1};
homographyEpsilon = 2; % Threshold in pixel;
homographyConfig = config;
homographyConfig.QThresh = 1e-5;

homographyConfig.alpha = 10; 
homographyConfig.kappa = 1.5;
homographyConfig.alphaMax = 1e9;

%-----------------------------------------------------------------------
disp(' Executing RANSAC..... ');
[ransacTheta, ransacInliers, ransacRuntime] = homographyFit(data, homographyEpsilon, 'RANSAC', rand(8,1), homographyConfig);
disp(['Ransac  #Inliers = '  num2str(numel(ransacInliers))]);
disp(['Ransac Runtime  = ' num2str(ransacRuntime)]);

%-----------------------------------------------------------------------
disp(' Executing EP..... ');
[eprsTheta, eprsInliers, eprsRuntime] = homographyFit(data, homographyEpsilon, 'EP', ransacTheta, homographyConfig);
disp(['EP-RS  #Inliers = '  num2str(numel(eprsInliers))]);
disp(['EP-RS Runtime  = ' num2str(ransacRuntime)]);

matches = data.matches;
plot_match(matches, [matches.X1; matches.X2], eprsInliers, 1, 0);




end