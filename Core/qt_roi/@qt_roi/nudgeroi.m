function nudgeroi(obj,key,keymod)
%nudgeroi  Moves an ROI according to arrow keystrokes
%
%   nudegroi(OBJ,KEY) moves the qt_roi object specified by OBJ by one unit to a
%   new location in the direction according to the string KEY. Valid strings:
%
%       Key             Event Description
%       ---------------------------------------
%       'uparrow'       up arrow key pressed
%       'downarrow'     down arrow key pressed
%       'rightarrow'    right arrow key pressed
%       'leftarrow'     left arrow key pressed
%
%
%   nudgeroi(...,MODIFIER) moves the object as stated previously by some
%   multiple of the distance unit. Valid modifiers:
%
%       Modifier        Multiplier
%       ----------------------------
%       'control'           5

    % Validate the inputs
    if ~any(obj.validaterois)
        return
    end
    if (nargin==2)
        keymod = '';
    else
        keymod = validatestring(keymod,{'control'});
    end
    key = validatestring(key,{'uparrow','downarrow','rightarrow','leftarrow'});

    %--- Move the ROI ---

    % Convert the nudge event into a pixel position (not a string)
    switch key
        case 'uparrow'
            delta = [ 0 -1 0 0];
        case 'downarrow'
            delta = [ 0  1 0 0];
        case 'rightarrow'
            delta = [ 1  0 0 0];
        case 'leftarrow'
            delta = [-1  0 0 0];
    end
    if ~isempty(keymod)
        delta = 5*delta;
    end

    % Apply the shift
    coors = obj.scaledPosition;
    switch obj.type
        case {'ellipse','rect'}
            coors = coors + delta;
        case 'poly'
            coors(:,1) = coors(:,1) + delta(1);
            coors(:,2) = coors(:,2) + delta(2);
        case 'spline'
            coors(:,1) = coors(:,1) + delta(1);
            coors(:,2) = coors(:,2) + delta(2);
        case 'point'
    end
    arrayfun(@(x) setPosition(x.hRoi,coors),obj.roiViewObj);

end %qt_roi.nudgeroi