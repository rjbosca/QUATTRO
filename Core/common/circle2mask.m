function mask = circle2mask(x0,r,xCoor,yCoor,logicOp)
%circle2mask  Creates a circular binary mask
%
%   M = circle2mask(X0,R,X,Y) creates a filled circular mask parameterized by
%   the circle's center X0 and radius R of the coordinate arrays X and Y (see
%   MESHGRID). X and Y can also be vectors specifying the extent of the
%   rectangular space.
%
%   M = circle2mask(...,OP) uses the logical operation OP specified by the
%   string 'lt', 'lte' (default), 'gt', 'gte', or 'eq' for relating the radius
%   to the coordinates.

    % Parse the inputs
    if (nargin<5)
        logicOp = 'lte';
    else
        logicOp = validatestring(logicOp,{'lt','lte','gt','gte','eq'});
    end

    % Determine if a rectangular coordinate space needs to be constructed, and
    % do so
    if (numel(xCoor)==length(xCoor))
        [xCoor,yCoor] = meshgrid(xCoor,yCoor);
    end

    % Create a coordinate mask centered at x0
    mask = sqrt( (xCoor-x0(1)).^2 + (yCoor-x0(2)).^2 );

    % Perform the appropriate logical operation
    switch logicOp
        case 'lt'
            mask = (mask<r);
        case 'lte'
            mask = (mask<=r);
        case 'gt'
            mask = (mask>r);
        case 'gte'
            mask = (mask>=r);
        case 'eq'
            mask = (mask==r);
    end
    

end %circle2mask