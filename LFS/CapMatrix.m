%function [M, numCapt] = CapMatrix(grid, L, t, dt)
function [M, numCapt] = CapMatrix(grid, lambda, dt)
% Returns a logical matrix. 1 = captured. 0 = uncaptured.
    %lam1 = L(t); lam2 = L(t+(dt/2)); lam3 = L(t+dt);
    
    %M = ((abs(grid-lam1) < sqrt(2*dt)) | (abs(grid-lam2) < sqrt(2*dt)) | (abs(grid-lam3) < sqrt(2*dt)));
    M = (abs(grid-lambda) < sqrt(2*dt));
    numCapt = nnz(M);
end

