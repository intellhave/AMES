% Genereate set of linear constraints used in z-udpate step 
% for s, v only
function [Al, bl] = genQPLinearConstraints_sv(A, b)

    N = size(A, 1);
    d = size(A, 2);
    C = [A -A*ones(d,1)];
    
    Al = [eye(N) -C];
    %Al = [Al; [-eye(N) zeros(N, N) zeros(N,d+1)]];
    %Al = [Al; eye(N+d+1)];        
    %bl = [b; zeros(N+d+1,1)];
    bl = b;
    
        %Test
%      ut = rand(N,1);
%      st = rand(N,1);
%      vt = rand(d+1,1);
%      X = [ut; st; vt];
%      
% %     sum = 0;
%      for i=1:N
%          s1 = Al(i,:)*X + bl(i); 
%          s2 = st(i) - C(i,:)*vt + b(i);
%          disp(s1 - s2);
%      end
%      
%      for i = 1:N         
%          s1 = Al(N+i,:)*X + bl(N+i); 
%          s2 = 1-ut(i);
%          disp(s1 - s2);   
%      end
%      
%      for i=2*N+1:size(Al,1)
%          disp(Al(i,:));
%          disp(bl(i));
%      end
%      

        
end