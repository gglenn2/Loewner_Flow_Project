function [NewGrid] = RK_Flow(OldGrid, L, t, h)
% Implements classical Runge Kutta, 4th order.
% As of now, this isn't working any better than our forward Euler approx.
% Need to determine where RK-4 approx. is conformal to improve main code.

    f = @(t, z) 2./(z - double(L(t)));

    k1 = h*f(t, OldGrid);
    k2 = h*f(t + h/2, OldGrid + k1./2);
    k3 = h*f(t + h/2, OldGrid + k2./2);
    k4 = h*f(t + h, OldGrid + k3);
    
    NewGrid = OldGrid + ((k1 + 2.*k2 + 2.*k3 + k4)./6);
end

