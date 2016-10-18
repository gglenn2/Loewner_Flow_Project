function M = CapMatrix(grid, lambda, dt)
% Returns a logical matrix. 1 = captured. 0 = uncaptured.
    M = abs(grid-lambda) < sqrt(2*dt);
end

