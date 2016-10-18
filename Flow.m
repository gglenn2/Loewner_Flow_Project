function NewGrid = Flow(OldGrid, lambda, dt)
% Applies the Loewner flow approximation to OldGrid, and stores in NewGrid.
% Calculations are done element-wise, NOT using linear algebra.
    re = real(OldGrid);
    im = imag(OldGrid);
    
    denom = 1./((re-lambda).^2+im.^2);
    
    newX = re + 2.*dt.*(re-lambda).*denom;
    newY = im - 2.*dt.*im.*denom;
    
    NewGrid = newX + 1i.*newY;
end

