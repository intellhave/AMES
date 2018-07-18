function [A,b] = genLinearMatrix(X, Y, th)

    n = size(X,1);
    d = size(X,2);
    A=[X;-X];
    b=[Y+repmat(th,n,1); -Y+repmat(th,n,1)];
    
end
