% Prepare linear program solver.
% solver = 'sedumi' : Use sedumi as LP solver. Sedumi is provided in the package
% solver = 'gurobi' : User gurobi as LP solver. Your system needs to have Gurobi
%                     installed to use this. 
% If Gurobi is used, need to set gurobiPath to the installation folder of Gurobi

function lpsolve = prepareSolver(solver)


addpath('src/solvers');

gurobiPath = '~/temp/gurobi652/linux64/'; % Please specify another path if you would like to use a different Gurobi installation

if (strcmp(solver,'sedumi'))

    disp('Using SeDuMi as the default solver....');
    disp(['If you have Gurobi installed with a proper license, please set solver to gurobi ']);
    disp(['and specify the path to gurobi installation folder using the variable gurobiPath ']);
    disp(['in prepareSolver.m ']);
    addpath('src/solvers/sedumi/');
    lpsolve = @sedumiLinProg;

elseif (strcmp(solver,'gurobi'))    

    lpsolve = @gurobiLinProg;
    disp('Using Gurobi as the default solver. Please make sure that you have a proper Gurobi license installed on your system.');
    disp([ 'Gurobi path is set to ' gurobiPath]);
    addpath([gurobiPath 'matlab/']);
    gurobi_setup;
    
end



end