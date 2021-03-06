%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LFS Loewner Flow Simulation.
% Created by Gavin Glenn.
% Last Modification 12/13/16.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Set up a prompt to gather user inputs
prompt = {'Enter start time t_0:',
          'Enter final time t_f:',
          'Enter time step size \Deltat:',
          'Enter number of x points:',
          'Enter number of y points:',
          'Enter left x bound. Enter "auto" for automatic bound.',
          'Enter right x bound. Enter "auto" for automatic bound.',
          'Enter bottom y bound. Enter "auto" for automatic bound.',
          'Enter top y bound. Enter "auto" for automatic bound.',
          'Enter the continuous, real-valued driving function \lambda(t) or enter "list" to read (t,\lambda(t)) values from a file.'};
titleStr = 'Simulation Input';
Inputs = {'0', '1', '.01', '100', '100', 'auto', 'auto', '0', 'auto', '0'};
options.Interpreter = 'tex';
options.WindowStyle = 'modal';
options.Resize = 'on';

global isList; isList = false;
 
% Loop will not exit until user provides valid input.
% The error checking can look overwhelming. The important thing to note is
% that certain variables must be checked before others, and the bounds
% of the grid are tested in their own function TestDims
while (true)
    Inputs = inputdlg(prompt,titleStr,1,Inputs,options);
    warning = '';
 
    % When user hits 'x' or cancel, Inputs contains only empty cells.
    % These do not count as elements.
    if (numel(Inputs) ~= 10)
        warndlg('Simulation aborted!', 'Exiting');
        return;
    else
        % str2double returns NaN for non-numeric values including 
        % whitespace. Do not convert dimension variables yet because they 
        % could be 'auto'
        t0 = str2double(Inputs{1});
        tf = str2double(Inputs{2});
        dt = str2double(Inputs{3});
        nCols = str2double(Inputs{4});
        nRows = str2double(Inputs{5});
        xMin = Inputs{6};
        xMax = Inputs{7};
        yMin = Inputs{8};
        yMax = Inputs{9};
 
        % Error check first wave of parameters (mostly time and size vars)
        if (any(isnan([t0 tf dt nCols nRows])))
            warning = 'Incomplete or non-numeric input!';
        elseif (any(~(isreal([t0 tf dt nCols nRows]))))
            warning = 'Input must be real valued!';
        elseif(any(isinf([t0 tf dt nCols nRows str2double(Inputs{10})])))
            warning = 'Input must be finite!';
        elseif ((t0 < 0) || (tf < 0))
            warning = 'Times must be non-negative';
        elseif (tf < t0)
            warning = 'Initial time must not exceed final time!';
        elseif (dt <= 0)
            warning = 'Time step must be positive!';
        elseif ((mod(nCols,1)) || (mod(nRows,1)))
            warning = 'Number of x and y points must be integers!';
        elseif ((nCols < 1) || (nRows < 1))
            warning = 'Number of x and y points must both be at least 1!';
        end
        
        % If no warning has been issued thus far, all params are valid
        % and we can test the driving function L(t).
        if ((strcmp(warning, '')))
            
            % The user may enter "list" to represent the driving function
            %as a list of data pts (taken from a file) instead of a formula
            isList = false; 
            if (strfind(Inputs{10}, 'list')) 
                [lamFile,temp,temp1] = uigetfile('./*.','Select a list of ordered pairs');
                if (lamFile == 0)
                    warning = 'Invalid input file.';
                else
                   fid = fopen(lamFile,'r');
                   list = fscanf(fid, '%g %g\n');
                   if (~feof(fid) || (any(~(isreal(list)))) || (any(isinf(list))))
                       warning = 'Invalid input file format.';
                   end
                   pairs = vec2mat(list,2);
                   fclose(fid);
                   t0 = pairs(1,1);
                   tf = pairs(size(pairs,1),1);
                   xMin = min(pairs(:,2));
                   xMax = max(pairs(:,2));
                   isList = true;
                end
                L = '';
                
            % Check the syntax of the driving function, when it is
            % specified with a formula instead of with a list.
            else
                syms t k f;
                synErr = false;

                try
                    f = eval(Inputs{10});
                    L = symfun(f,t);     
                catch
                    warning = 'Invalid MATLAB syntax for \lambda(t)!'; 
                    synErr = true;
                end

                % If the syntax is fine, a continuity check can be
                % performed on systems that have the symbolic toolbox.
                % If a user doesn't have it, this block does nothing.
                % See program documentation to tell if symbolic toolbox is
                % installed
                if (~synErr)               
                    try
                        assume(t>=t0);
                        assumeAlso(t<=tf);
                        temp = feval(symengine,'discont',f,t);
                        if (~isempty(temp))
                            warning = ['\lambda(t)',sprintf(' must be continuous on [%.3f,%.3f]!',t0,tf)];
                        end
                    catch
                    end
                end
            end
        end
          
        % If no warning has been issued thus far, all params are valid and
        % we can call TestDims. Note that one output parameter of TestDims,
        % dimWarning, is a string. If it contains 'Change Params', the user
        % chose to fix a nonfatal warning, so we jump back to the top of 
        % the loop with no warning. If dimWarning is any other nonempty 
        % string, there is an error that must be fixed. If it's the empty
        % string, we're golden.
        if ((strcmp(warning, ''))) 
            [xMin, xMax, yMin, yMax, dimWarning] = TestDims(xMin, xMax, yMin, yMax, L, t0, tf);
            Inputs{6} = num2str(xMin); 
            Inputs{7} = num2str(xMax); 
            Inputs{8} = num2str(yMin); 
            Inputs{9} = num2str(yMax); 
            
            if (~(strcmp(dimWarning,'')))
                if (strcmp(dimWarning, 'Change Params'))
                    continue;
                else
                    warning = dimWarning;
                end
            end
            
            % Hooray, no errors in any input. Exit the loop
            if ((strcmp(warning,'')))
                break;
            end
        end
    end
    
    %If we reach this point some input is bad. Display appropriate warning.
    warning = strcat(warning, ' Please enter valid input.');
    waitfor(warndlg(warning, 'Warning', options));
end

if (~isList)
    nTimeSteps = floor((tf - t0)/dt);

    % If necessary warn, user that the simulation will stop earlier than
    % they specified, because of their timestep size and total time.
    if (dt*nTimeSteps ~= tf-t0)
        warning = ['NOTE: Your \Deltat = ', sprintf('%.3f does not divide your total time\n', dt), 't_f-t_0 = ', sprintf('%.3f. Thus, the simulation will stop at t = %.3f.',tf-t0,dt*nTimeSteps)];    
        waitfor(warndlg(warning, 'Warning', options));                  
    end
else
    nTimeSteps = size(pairs,1);
%     temp = pairs(1,1);
end

% All of these variables are now irrevelvant. Free up some memory.
clear warning titleStr prompt options dimWarning temp1 f list synErr;

% Handle egde cases where there will be only one row or column
if ((nCols == 1) || (xMax == xMin))
    nCols = 1;
    xMax = xMin;
end

if ((nRows == 1) || (yMax == yMin)) 
    nRows = 1;
    xMax = xMin;
    dy = 0;
else 
    dy = (yMax - yMin)/(nRows - 1); 
end

% Partition the upper half plane into Grid. 
% Cannot use linspace to create a whole matrix, but can use on each row. 
Grid = zeros(nRows, nCols);

 for j=1:nRows
     Grid(j,:) = linspace(xMin,xMax,nCols) + 1i.*(yMax-(j-1).*dy);
 end
 
% Preliminary variable grid code. Unusabe for now
% dCols = ceil(sqrt(nCols));
% divisions = ceil(tf-t0);
% a = 2*nRows/((divisions)*(divisions+1));
% index = 1;
% for d = 1:divisions
%     
%     % add d*a lines
%     for r=1:d*a
%        X = linspace(xMin,xMax,nCols);
%        grid(index,:) = linspace(xMin,xMax,nCols) + 1i.*((d-1)*a+(r-1));
%        Z = grid(index,:);
%        disp(Z);
%        pause(4);
%        index = index + 1;
%     end
% end
% plot(grid,'-r*');

% Save the original grid since it is what we plot from later
% Create a logical index matrix containing whether a point has been 
% captured. Also create a color matrix to store the color at each time step
OriginalGrid = Grid;
C = false(nRows,nCols);
ColorMatrix = zeros(nTimeSteps-1,3);
%nC = floor((nRows*nCols*pi*(dt)^2)/((xMax-xMin)*(yMax-yMin)));
nC = 10; t = t0; 

% Exploit continuity of driving function. Espcially if the function
% is wild, like the Weierstrass function. Still preliminary code.
% i = 1;
% 
% while (t < tf)
%     
%     epsilon = .01;
%     delta = .1;
% 
%     while (delta > eps*10^10)
% 
%         if (abs(double(L(t)) - double(L(t+delta))) < epsilon)
%             t = t + delta;
%             DT(i) = delta;  % Satisfactory change in L(t).
%             disp(delta);    % Save this delta for ith time step size  
%             i = i + 1;
%             break;
%         end
%         
%         delta = delta/2;
%     end
% end

% FINALLY, do the simulation
 for j=1:nTimeSteps-1  
%  for j=1:i-1
    % Calculate L(t), be it from a file or function expression
    if (isList) 
        lam = pairs(j,2);
        dt = pairs(j+1,1) - pairs(j,1);
    else
        lam = double(L(t));
    end
    
    % Test all points that have not yet been captured
    saveC = C;
    [C(~C), numCapt] = CapMatrix(Grid(~C), lam, dt);
    %[C(~C), numCapt] = CapMatrix(Grid(~C), L, t, dt);
   
    % Apply the Loewner flow approximation to all uncaptured points
    Grid(~C) = Flow(Grid(~C), lam, dt); 
    %Grid(~C) = RK_Flow(Grid(~C), L, t, dt);
    
    % Interactively plot all points captured just this iteration.
    % Change plot color each iteration so user can see when pts are capt.
    color = [(j/nTimeSteps)^2,(1-(j/nTimeSteps))^2, .5];
    ColorMatrix(j,:) = color; 
    p = plot(real(OriginalGrid(saveC~=C)),imag(OriginalGrid(saveC~=C)),'*');   
    set(p,'Color',color);
    xlabel('Real Axis','interpreter','latex');
    ylabel('Imaginary Axis','interpreter','latex');    
    drawnow;
    hold on;

    %dt = sqrt((nC*(xMax-xMin)*(yMax-yMin))/(nRows*nCols*pi));
    fprintf('Number of captured points: %d\n',numCapt);
    t = t+dt;%DT(i)
end

% Create a color bar to indicate when each point was captured
colormap(ColorMatrix);
c = colorbar;
c.Label.String = 'Time at which point was captured';
c.Label.FontSize = 13;
c.Label.Interpreter = 'latex';
caxis([t0 tf]);
hold off;
p = gcf;

% Create a nice plot title based on the driving function
if (isList)
    titleStr = ['Hull generated by ', lamFile]; 
else
    titleStr = ['Hull generated by $$\lambda(t) = ',latex(L),'$$'];
    if (numel(titleStr) >= 150)
        titleStr = 'Hull generated by $$\lambda(t)$$';
    end
end

title(titleStr,'FontSize',13,'interpreter','latex');

% Optionally create a folder in which to save user's results
pause(2);
choice = questdlg('Save results? Press "x" to save nothing.','Save Results','Variable Log and Plot','Variable Log Only','Plot Only','Variable Log and Plot');

folderName = datestr(datetime);
folderName = strrep(folderName,':','.');
fileName = strcat('./',folderName,'/','Variable_Log.txt');
plotName = strcat('./',folderName,'/','Plot');
fid = -1;

switch choice
    case 'Variable Log and Plot'
        mkdir(folderName);    
        saveas(p,strcat(plotName,'.fig'));
        saveas(p,strcat(plotName,'.jpg'));
        fid = fopen(fileName,'w');     
    case 'Variable Log Only'
        mkdir(folderName);
        fid = fopen(fileName,'w');     
    case 'Plot Only'
        mkdir(folderName);
        saveas(p,strcat(plotName,'.fig'));
        saveas(p,strcat(plotName,'.jpg'));
end

% If the user has chosen to create a log, write inputs to the file. 
% Written here once instead of twice above because it's one ugly line.
if (fid ~= -1)
    fprintf(fid,'Start Time\n%.16g\nEnd Time\n%.16g\nTime Step Size\n%.16g\nNumber of x Points\n%d\nNumber of y Points\n%d\nLeft x Bound\n%.16g\nRight x Bound\n%.16g\nBottom y Bound\n%.16g\nTop y Bound\n%.16g\nDriving Function lambda(t)\n%s\nNumber of Circle Points\n%d\n',t0,tf,dt,nCols,nRows,xMin,xMax,yMin,yMax,Inputs{10},nC);
    if (isList)
        fprintf(fid, '%s\n',lamFile);
    end
    fclose(fid);
end
