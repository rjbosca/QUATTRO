function c = mask2poly(mask)
%mask2poly  Converts a binary image to a polygon vertices
%
%   C = mask2poly(I) converts the binary image I a set of x-y coordinate pairs C

    % Calculate the convex hull of the mask, removing points that contribute
    % nothing to the area
    [Y,X] = find(mask);
    idx   = convhull(X,Y,'simplify',true);

    % Store the output
    c = [X(idx),Y(idx)];

end %mask2poly