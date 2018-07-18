function [x, flag] = gurobiLinProg(f,A,b)

    n = size(b,1);
    d = size(f,1);
    flag = 1;

    %Construct Gurobi Model
    model.obj = f;
    model.A = sparse(A);
    model.rhs = b;    
    model.sense = '<';
    model.modelsense = 'min';
   % params.outflag = 0;
    params.FeasibilityTol = 1e-9;
    params.IntFeasTol = 1e-9;
    params.OptimalityTol = 1e-9;
    params.MarkowitzTol=1e-4;
    params.NormAdjust = 0;
    params.ScaleFlag = 1;
    params.PerturbValue = 0;    
    params.OutputFlag = 0;
    params.Method  = 0;
    params.BarIterLimit = 50000;

    % Solve
    results = gurobi(model, params);

    x = [];
    if (~strcmp(results.status,'OPTIMAL'))
        flag = -1;
    else 
        x = results.x;
    end
    
    
end


