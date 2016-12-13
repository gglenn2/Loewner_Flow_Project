function [n] = sz(X)
%Returns number of elements in X that are not NaN (ie, are numbers)
    n = nnz(isnan(X)==0);
end

