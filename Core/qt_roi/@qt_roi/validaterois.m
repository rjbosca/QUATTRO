function a = validaterois(obj)
%validaterois  Determines valid qt_roi objects
%
%   OBJ = validaterois(OBJ) returns a logical array the same size as OBJ that
%   specifies valid and non-empty qt_roi objects. When OBJ is an empty array, a
%   value of FALSE is returned.

    % Initialize the output array by determining the valid ROI objects. When
    % none are valid, simply return FALSE
    a = obj.isvalid;
    if isempty(a)
        a = false;
        return
    end

    % Update the valid indices to represent qt_roi objects that are valid and
    % non-empty
    a(a) = ~[obj(a).isEmpty];
    
end %qt_roi.validaterois