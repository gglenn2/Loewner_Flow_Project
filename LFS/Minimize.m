function [minVal, alert] = Minimize(fHandle, t0, tf)
% Use matlab's built in minimization function fmindbnd  to mimimize fHandle
% on the interval [t0,tf] where fHandle is a function handle.
% Allow the user to run the algorithm for longer if it fails to converge
% Return the minimum value found and an alert for error cases.

% WARNING: taken from the mathworks documentation page for fminbnd
% https://www.mathworks.com/help/matlab/ref/fminbnd.html
% Limitations: 
%    -The function to be minimized must be continuous.
%    -fminbnd might only give local solutions.
%    -fminbnd can exhibit slow convergence when the solution is on a 
%     boundary of the interval.


    alert = '';
    flag = 0;
    mOptions.MaxFunEvals = 5;
    while (flag ~= 1)
        
        [a,minVal,flag] = fminbnd(fHandle,t0,tf, mOptions);
        minVal = double(minVal);
        
        switch flag

            % 'Good Case'. Algorithm converged.
            case 1
                return;

            % Number of allowed iterations exceeded. Query user for more
            case 0 
                qString = 'Minimization algorithm for driving function did not converge. Try with more iterations? Click "No" to return to the main menu.';
                choice = questdlg(qString,'Convergence Warning','Yes','No','No');
                if (strcmp(choice,'Yes'))
                    mOptions.MaxFunEvals = mOptions.MaxFunEvals + 500;
                else
                    alert = 'Change Params';
                    return;
                end
                
            % Something else bad happened.
            otherwise
                waitfor(warndlg('Minimization Algorithm for driving function did not converge. Returning to main menu.', 'Error')); 
                alert = 'Change Params';
                return;
        end
    end
end