% Driving function lambda(t). Set to the constant zero by default
% Enter any continuous single-variable function in t.
% See documentation for some recommended functions.
syms t;
L = symfun(8.0*(1.0-sqrt(1.0-t)),t);
% L = symfun(0,t);

% Time and size variables.
start = 0.90;
dt = 0.01;
nTimeSteps = 10;
nTestPts = 30;
global nArcPts;

% Allocate space for H. 1 extra row so points can be added later.
H = zeros(2*nTestPts,nTimeSteps);

% Create last circle, store it in last column of H
% Repeat last row to ensure H retains a fixed number of rows later.
lam = double(L((nTimeSteps-1)*dt+start));
Circle = PartitionCircle(sqrt(2*dt), lam, nTestPts);
H(1:nTestPts,nTimeSteps) = Circle(:,1) + 1i.*Circle(:,2);
H(nTestPts+1:2*nTestPts,:) = NaN;

% Outer loop iterates through number of circles-1 = number of time steps-1
for j=nTimeSteps:-1:2
    
%%%%%%%%%%%%%Discrete drawing for visualization aid%%%%%%%%%%%%%%%%%%%%%%%%
% Remove comment to watch the creation and inversion of circles 
    color = [j/nTimeSteps,1-(j/nTimeSteps), .5];
    plot(real(H(1:sz(H(:,j)),j:nTimeSteps)),imag(H(1:sz(H(:,j)),j:nTimeSteps)), '-*');
    drawnow
    pause(.35);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Invert circles j,...,nTimeSteps
% We could invert only the first sz(H(:,j)) rows of each circle.
% But inverting all rows is inconsequential since InverseMap(NaN) = NaN
    lam = double(L((j-2)*dt+start));    
    H(:,j:nTimeSteps) = InverseMap(H(:,j:nTimeSteps), dt, lam);

% Create the next circle in column j-1.  
    Circle = PartitionCircle(sqrt(2*dt), lam, nTestPts);
    H(1:nTestPts,j-1) = Circle(:,1) + 1i.*Circle(:,2);
   
% When necessary, refine the plot to fill shapes correctly 
% by adding boundary points missed in the discretization of circles.

    for k = j:nTimeSteps
        Y = imag(H(nArcPts:sz(H(:,k)),k));
        if (~(all(Y)))
            %to previous circle add corner point of new circle. to j+1 add j
            %split into cases. right case done. left add left corner point and use max function      
            %test first real value compared to center of new circle
            X = real(H(nArcPts:sz(H(:,k)),k));
            [mi,~] = min(X(Y==0));
            [mx,~] = max(X(Y==0));
            
            if (H(nTestPts,j-1) < mi)
                p = find(X==mi); 
                p = p + nArcPts;
                H(1:sz(H(:,k))+1,k) = vertcat(H(1:p-2,k), H(nTestPts,j-1), H(p-1:sz(H(:,k)),k)); 
            elseif (H(nArcPts,j-1) > mx)
                p = find(X==mx);
                p = p + nArcPts;
                H(1:sz(H(:,k))+1,k) = vertcat(H(1:p-1,k), H(nArcPts+1,j-1), H(p:sz(H(:,k)),k)); 
            end
            break;
        end
    end
end

% Plot the final hull in order that it would've actually been created.
% Vary the color of circles so one can see when a region was captured.
for j=1:nTimeSteps
    color = [j/nTimeSteps,1-(j/nTimeSteps), .5];
    fill(real(H(1:sz(H(:,j)),j)),imag(H(1:sz(H(:,j)),j)), color);
    hold on
    drawnow
end