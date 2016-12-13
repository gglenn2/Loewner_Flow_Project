function [Circle] = temp(radius, center, nPts)
 
% Returns an (nPts x 2) matrix of (x,y) coordinates, approximately evenly 
% spaced on a half disk with a line through its bottom.
 
% It does so by approximating a ratio of arc to line perimeter.
% This approach was used to because it allows us to ensure that points 
% where the arc hits the line are included in the partitioning, 
% which is more important for itsintended application than perfect spacing. 
 
% For nPts>135, the approximation is within 1% of theoretical value 2/pi.
 
% Note: To simplify calculations the function treats the half circle
% as being centered at 0, and then adjusts the center at the very end.
 
    global nArcPts;
 
    nArcPts = ceil((pi/(pi+2))*nPts);
    nLinePts = nPts-nArcPts;
    nArcPts = nArcPts-1;
 
    if (nArcPts < 2 || nLinePts < 1)
        error('Please enter more points for the circle')
    end
    
    Circle = zeros(nPts,2);
    
% Procces circle sector first using polar coordinates (then converting)
% Start at polar value (pi, radius) and subtract delTheta iteratively 
% to trace out the desired points on the arc.
 
    delTheta = pi/(nArcPts-1);
 
    for j=1:nArcPts 
        [X Y] = pol2cart(pi-((j-1)*delTheta), radius);
        Circle(j,1) = X;
        Circle(j,2) = Y;
    end 
 
% Circle() now holds cartesian coords (x,y) of points on the arc.
% Now process line segment at base of half circle in cartesian.
% Start at (x,y) value (radius,0) and subtract delX iteratively
% to obtain desired points on the line.
 
    delX = (2*radius)/(nLinePts+1);
    
    for j=1:nLinePts+1
        Circle(j+nArcPts,:) = [radius - j*delX 0];
    end
 
% Shift the x values of the circle by center
    Circle(1:nPts,1) = Circle(1:nPts,1) + center;
 
% Remove comment to plot the partitioned circle
%     plot(Circle(1:nArcPts+nLinePts,1), Circle(1:nArcPts+nLinePts,2),'-*');
%     xmin = double((center)+(-1.0*radius));
%     xmax = double(radius+center);
%     ymin = 0.0;
%     ymax = double(2*radius);
%     limits = [xmin xmax ymin ymax];
%     axis(limits);
end