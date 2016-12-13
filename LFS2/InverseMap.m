function [W] = InverseMap(Z, dt, lam)

% Apply inverse of the Loewner flow approximation for fixed t
% to a matrix ENTRY WISE (not using Linear Algebra).
% Note this map is conformal.

    temp = double((sqrt(Z-lam-sqrt(8.*dt))).*(sqrt(Z-lam+sqrt(8.*dt)))); 
    
    W = (Z + lam + temp)./2.0;
end

