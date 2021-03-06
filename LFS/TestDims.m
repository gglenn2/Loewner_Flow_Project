function [xMin, xMax, yMin, yMax, alert] = TestDims(xMin, xMax, yMin, yMax, L, t0, tf)
% This function is responsible for testing the user's dimensions.
% Specifically, it gets automatic bounds for a dimension with value 'auto',
% It also error checks all bounds. It returns an alert which will either be
% a flag to change parameters, an error message, or the empty string when
% all is good.

    global isList;
    alert = '';
    
    % Create separate function -L(t) so we don't have to write a separate
    % maximization function.
    % Lh is a function handle for L(t), and LhN for -L(t).
    if (~isList)
        Lh = matlabFunction(L); 
        temp = -1.0*L;
        LhN = matlabFunction(temp); 

        % xMin is where L(t) is minimized
        if (strfind(xMin, 'auto'))
            [tmpMin, alert] = Minimize(Lh, t0, tf);
            if (strcmp(alert,''))
                xMin = tmpMin;
            else 
                return;
            end
        else
            xMin = str2double(xMin);
        end

        % xMax = -min{-L(t)}.
        if (strfind(xMax, 'auto'))
            [tmpMin, alert] = Minimize(LhN, t0, tf);
            if (strcmp(alert,''))
                xMax = -1.0*tmpMin;
            else 
                return;
            end
        else
            xMax = str2double(xMax);
        end
    end
 
    % Smallest y value possible is 0.
    if (strfind(yMin, 'auto'))
        yMin = 0;
    else
        yMin = str2double(yMin);
    end
  
    % Largest y value possible is 2*sqrt(tf-t0)
    if (strfind(yMax, 'auto'))
        yMax = 2*sqrt(tf);
    else
        yMax = str2double(yMax);
    end
   
    % All params should now be numerical. Error check them.
    if (any(isnan([xMin xMax yMin yMax])))
        alert = 'Grid bounds must be numeric or "auto"!';
    elseif (any(~(isreal([xMin xMax yMin yMax]))))
        alert = 'Grid bounds must be real valued!';
    elseif(any(isinf([xMin xMax yMin yMax])))
        alert = 'Grid bounds must be finite!';
    end
    
    % If input is valid so far, perform logical error checks.
    if (strcmp(alert, ''))
        if (yMin < 0 || yMax < 0)
            alert = 'y bounds must be at least zero for upper half plane!';
        elseif (yMin > yMax)
            alert = 'Bottom y bound cannot exceed top y bound';
        elseif (xMin > xMax)
            alert = 'Left x bound cannot exceed right x bound';
            
        % (Nonfatal) warn the user if they entered an unreachable time
        elseif (yMax > (2*sqrt(tf)+.1))
            options.Interpreter = 'tex';
            options.Default = 'No';
            qstring = 'The top y bound of points that can be captured is 2\surd{t_f-t_0}';
            qstring = strcat(qstring, sprintf(' = %.2f\n Re-enter top y bound?',2.0*sqrt(tf-t0)));
            choice = questdlg(qstring,'Boundary Warning','Yes','No',options);
            if (strcmp(choice,'Yes'))
                alert = 'Change Params';
            end
        end 
    end
end

